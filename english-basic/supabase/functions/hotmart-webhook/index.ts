// Hotmart webhook handler: keeps `subscriptions` in sync with Hotmart and sends
// the Premium access email (PDF credentials) via Resend.
//
// Secrets (env vars): SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected
// automatically by Supabase on deploy. HOTMART_HOTTOK, RESEND_API_KEY and
// RESEND_FROM must be set with `supabase secrets set`. Never expose secrets to
// the frontend.

import { createClient } from 'npm:@supabase/supabase-js@2';
import { PDFDocument, StandardFonts, rgb } from 'https://esm.sh/pdf-lib@1.17.1';

const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const hotmartHottok = Deno.env.get('HOTMART_HOTTOK');
const resendApiKey = Deno.env.get('RESEND_API_KEY');
const resendFrom = Deno.env.get('RESEND_FROM');

const APP_LOGIN_URL = 'https://english-basic.elizelluz-a-r-t.workers.dev/login';

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'content-type, x-hotmart-hottok',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function getPath(source: Record<string, unknown> | undefined, path: string): unknown {
  if (!source) return undefined;
  return path.split('.').reduce((acc: unknown, key: string) => {
    if (acc === null || acc === undefined) return undefined;
    return (acc as Record<string, unknown>)[key];
  }, source);
}

function asString(value: unknown): string | undefined {
  if (typeof value === 'string') return value.trim() || undefined;
  if (typeof value === 'number') return String(value);
  return undefined;
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>"']/g, (char) => {
    const map: Record<string, string> = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
    };
    return map[char];
  });
}

function bytesToBase64(bytes: Uint8Array): string {
  let binary = '';
  const chunkSize = 0x8000;
  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunkSize));
  }
  return btoa(binary);
}

function isoFromMs(value: unknown): string | null {
  const ms = Number(value);
  if (!Number.isFinite(ms) || ms <= 0) return null;
  return new Date(ms).toISOString();
}

function daysFromNow(days: number): string {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000).toISOString();
}

async function parseBody(req: Request): Promise<Record<string, unknown>> {
  const contentType = req.headers.get('content-type') ?? '';
  if (contentType.includes('application/x-www-form-urlencoded')) {
    const form = await req.formData();
    const object: Record<string, unknown> = {};
    for (const [key, value] of form.entries()) object[key] = value;
    return object;
  }
  return (await req.json()) as Record<string, unknown>;
}

async function insertEvent(
  eventName: string,
  userId: string | null,
  payload: Record<string, unknown>,
): Promise<void> {
  const { error } = await supabase.from('events').insert({
    user_id: userId,
    event: eventName,
    payload,
  });
  if (error) console.error(`[hotmart-webhook] insertEvent ${eventName} failed`, error);
}

async function findUserByEmail(email: string): Promise<{ id: string } | null> {
  const normalized = email.trim().toLowerCase();
  const { data, error } = await supabase.auth.admin.listUsers({ page: 1, perPage: 1000 });
  if (error) {
    console.error('[hotmart-webhook] listUsers failed', error);
    throw error;
  }
  const match = data.users.find(
    (user) => (user.email ?? '').trim().toLowerCase() === normalized,
  );
  return match ? { id: match.id } : null;
}

async function getPremiumPlanId(): Promise<number | null> {
  const { data } = await supabase.from('plans').select('id').eq('name', 'PREMIUM').maybeSingle();
  return data?.id ?? null;
}

async function upsertSubscription(params: {
  userId: string;
  planId: number | null;
  subscriberCode: string;
  currentPeriodEnd: string;
}): Promise<void> {
  const { data: existing } = await supabase
    .from('subscriptions')
    .select('id')
    .eq('provider_subscription_id', params.subscriberCode)
    .maybeSingle();

  const fields = {
    user_id: params.userId,
    plan_id: params.planId,
    provider: 'hotmart',
    provider_subscription_id: params.subscriberCode,
    status: 'active',
    started_at: new Date().toISOString(),
    current_period_start: new Date().toISOString(),
    current_period_end: params.currentPeriodEnd,
    cancelled_at: null,
  };

  if (existing) {
    const { error } = await supabase
      .from('subscriptions')
      .update(fields)
      .eq('id', existing.id);
    if (error) console.error('[hotmart-webhook] subscription update failed', error);
  } else {
    const { error } = await supabase.from('subscriptions').insert(fields);
    if (error) console.error('[hotmart-webhook] subscription insert failed', error);
  }
}

async function handlePurchase(body: Record<string, unknown>): Promise<void> {
  const buyerEmail =
    asString(getPath(body, 'data.buyer.email')) ?? asString(body.email);
  const buyerName =
    asString(getPath(body, 'data.buyer.name')) ?? asString(body.name) ?? '';
  const productId =
    asString(getPath(body, 'data.product.id')) ?? asString(body.product_id) ?? '';
  const subscriberCode =
    asString(getPath(body, 'data.subscription.subscriber_code')) ??
    asString(body.subscriber_code);
  const dateNextCharge = getPath(body, 'data.subscription.date_next_charge');

  if (!buyerEmail) {
    console.error('[hotmart-webhook] PURCHASE_APPROVED without buyer email');
    return;
  }

  const user = await findUserByEmail(buyerEmail);

  if (!user) {
    await insertEvent('hotmart_purchase_without_account', null, {
      email: buyerEmail,
      name: buyerName,
      subscriber_code: subscriberCode ?? null,
      product_id: productId,
    });
    console.log(
      '[hotmart-webhook] purchase for unknown user, access deferred until signup',
      buyerEmail,
    );
    return;
  }

  if (subscriberCode) {
    const planId = await getPremiumPlanId();
    const periodEnd = isoFromMs(dateNextCharge) ?? daysFromNow(30);
    await upsertSubscription({
      userId: user.id,
      planId,
      subscriberCode,
      currentPeriodEnd: periodEnd,
    });
  } else {
    console.warn('[hotmart-webhook] purchase approved without subscriber_code', buyerEmail);
  }

  await insertEvent('subscription_activated', user.id, {
    email: buyerEmail,
    subscriber_code: subscriberCode ?? null,
    product_id: productId,
  });

  const emailResult = await sendAccessEmail(buyerEmail, buyerName);
  if (!emailResult.ok) {
    await insertEvent('email_failed', user.id, {
      email: buyerEmail,
      error: emailResult.error ?? 'unknown error',
    });
  }
}

async function handleCancellation(body: Record<string, unknown>): Promise<void> {
  const subscriberEmail =
    asString(getPath(body, 'data.subscriber.email')) ?? '';
  const subscriberCode =
    asString(getPath(body, 'data.subscriber.code')) ??
    asString(getPath(body, 'data.subscription.subscriber_code'));
  const dateNextCharge = getPath(body, 'data.date_next_charge');

  if (!subscriberCode) {
    console.error('[hotmart-webhook] SUBSCRIPTION_CANCELLATION without subscriber code');
    return;
  }

  const { data: existing } = await supabase
    .from('subscriptions')
    .select('id, user_id, current_period_end')
    .eq('provider_subscription_id', subscriberCode)
    .maybeSingle();

  if (!existing) {
    console.warn('[hotmart-webhook] cancellation for unknown subscription', subscriberCode);
    return;
  }

  const periodEnd = isoFromMs(dateNextCharge) ?? existing.current_period_end;
  const update: Record<string, unknown> = {
    status: 'cancel_at_period_end',
    cancelled_at: new Date().toISOString(),
  };
  if (periodEnd) update.current_period_end = periodEnd;

  const { error } = await supabase
    .from('subscriptions')
    .update(update)
    .eq('id', existing.id);
  if (error) console.error('[hotmart-webhook] cancellation update failed', error);

  await insertEvent('subscription_cancelled', existing.user_id, {
    email: subscriberEmail,
    subscriber_code: subscriberCode,
  });
}

async function handleRefund(body: Record<string, unknown>): Promise<void> {
  const subscriberCode =
    asString(getPath(body, 'data.subscription.subscriber_code')) ??
    asString(getPath(body, 'data.subscriber.code'));

  if (!subscriberCode) {
    console.error('[hotmart-webhook] refund/chargeback without subscriber code');
    return;
  }

  const { data: existing } = await supabase
    .from('subscriptions')
    .select('id, user_id')
    .eq('provider_subscription_id', subscriberCode)
    .maybeSingle();

  if (!existing) {
    console.warn('[hotmart-webhook] refund for unknown subscription', subscriberCode);
    return;
  }

  const { error } = await supabase
    .from('subscriptions')
    .update({ status: 'cancelled', current_period_end: new Date().toISOString() })
    .eq('id', existing.id);
  if (error) console.error('[hotmart-webhook] refund update failed', error);

  await insertEvent('subscription_refunded', existing.user_id, {
    subscriber_code: subscriberCode,
  });
}

async function buildCredentialPdf(input: { name: string; email: string }): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  const page = doc.addPage([595.28, 841.89]);
  const font = await doc.embedFont(StandardFonts.Helvetica);
  const bold = await doc.embedFont(StandardFonts.HelveticaBold);

  const blue = rgb(37 / 255, 99 / 255, 235 / 255);
  const dark = rgb(15 / 255, 23 / 255, 42 / 255);
  const gray = rgb(71 / 255, 85 / 255, 105 / 255);

  const today = new Date().toISOString().slice(0, 10);

  page.drawText('English Basic', { x: 60, y: 740, size: 28, font: bold, color: blue });
  page.drawText('Acceso Premium', { x: 60, y: 706, size: 16, font, color: gray });
  page.drawLine({ start: { x: 60, y: 688 }, end: { x: 535, y: 688 }, thickness: 1.5, color: blue });

  page.drawText('Credenciales de acceso', { x: 60, y: 620, size: 18, font: bold, color: dark });

  const rows: Array<{ label: string; value: string }> = [
    { label: 'Nombre', value: input.name || '-' },
    { label: 'Email', value: input.email },
    { label: 'Fecha', value: today },
    { label: 'Plan', value: 'PREMIUM $9.99/mes' },
    { label: 'URL de acceso', value: APP_LOGIN_URL },
  ];

  let y = 570;
  for (const row of rows) {
    page.drawText(row.label.toUpperCase(), { x: 60, y, size: 9, font: bold, color: gray });
    page.drawText(row.value, { x: 60, y: y - 20, size: 14, font, color: dark });
    y -= 68;
  }

  page.drawText(
    'Este documento confirma tu suscripción Premium a English Basic.',
    { x: 60, y: 110, size: 10, font, color: gray },
  );

  return await doc.save();
}

async function sendAccessEmail(
  to: string,
  name: string,
): Promise<{ ok: boolean; error?: string }> {
  if (!resendApiKey || !resendFrom) {
    return { ok: false, error: 'RESEND_API_KEY or RESEND_FROM is not configured' };
  }

  let pdfBytes: Uint8Array;
  try {
    pdfBytes = await buildCredentialPdf({ name, email: to });
  } catch (err) {
    return { ok: false, error: `pdf generation failed: ${String(err)}` };
  }

  const safeName = escapeHtml(name || to);

  const html = `
<html>
  <body style="margin:0;padding:24px;background:#f8fafc;font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;">
    <div style="max-width:560px;margin:0 auto;background:#ffffff;border-radius:12px;padding:32px;border:1px solid #e2e8f0;">
      <h2 style="margin:0 0 16px;color:#2563eb;">Bienvenido a English Basic Premium</h2>
      <p style="margin:0 0 12px;color:#0f172a;">Hola ${safeName},</p>
      <p style="margin:0 0 12px;color:#0f172a;">Gracias por tu compra. Ya tienes acceso a todo el curso completo.</p>
      <p style="margin:0 0 20px;">
        <a href="${APP_LOGIN_URL}" style="display:inline-block;background:#2563eb;color:#ffffff;padding:12px 20px;border-radius:999px;text-decoration:none;font-weight:600;">Entrar a tu curso</a>
      </p>
      <p style="margin:0 0 12px;color:#475569;">Si no creaste tu cuenta, regístrate con este mismo email para activar tu acceso.</p>
      <p style="margin:0;color:#475569;">Adjuntamos tus credenciales de acceso en el PDF incluido.</p>
    </div>
  </body>
</html>`;

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: resendFrom,
      to: [to],
      subject: 'Tu acceso a English Basic Premium',
      html,
      attachments: [{ filename: 'english-basic-acceso.pdf', content: bytesToBase64(pdfBytes) }],
    }),
  });

  if (!res.ok) {
    const detail = await res.text();
    return { ok: false, error: `resend error ${res.status}: ${detail}` };
  }
  return { ok: true };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { status: 200, headers: corsHeaders });
  }
  if (req.method !== 'POST') {
    return json({ ok: false, error: 'method not allowed' }, 405);
  }

  const hottok = req.headers.get('X-HOTMART-HOTTOK');
  if (!hotmartHottok || hottok !== hotmartHottok) {
    return json({ ok: false, error: 'invalid hotmart hottok' }, 401);
  }

  try {
    const body = await parseBody(req);
    const event = asString(body.event);

    if (!event) {
      console.error('[hotmart-webhook] missing event');
      return json({ ok: true }, 200);
    }

    switch (event) {
      case 'PURCHASE_APPROVED':
      case 'PURCHASE_COMPLETE':
        await handlePurchase(body);
        break;
      case 'SUBSCRIPTION_CANCELLATION':
        await handleCancellation(body);
        break;
      case 'PURCHASE_REFUNDED':
      case 'PURCHASE_CHARGEBACK':
        await handleRefund(body);
        break;
      default:
        console.log(`[hotmart-webhook] unknown event: ${event}`);
    }

    return json({ ok: true }, 200);
  } catch (err) {
    console.error('[hotmart-webhook] processing failed', err);
    return json({ ok: false, error: String(err) }, 200);
  }
});