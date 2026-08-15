# PLAN — MVP English Basic (con Lovable)

Plataforma de suscripción para infoproducto de inglés básico.
Documento de planificación aprobado. Fuente: `idea_mvp`.
**Cambio de stack**: frontend construido con **Lovable** (en lugar de Angular + Cloudflare Pages).
Este plan es la alternativa a `PLAN.md` (que conserva el stack Angular).

---

## 1. Resumen ejecutivo

MVP de plataforma web de suscripción (freemium) para vender un curso de inglés básico.
Objetivo: **validar el modelo de negocio** (registro → consumo → pago → retención), no construir una academia compleja.

- **Propuesta de valor**: "Aprende las bases del inglés y empieza a comunicarte en situaciones cotidianas en 30 días."
- **Nombre provisional**: English Basic (comercial por decidir).
- **Cómo se construye**: Lovable genera la app (React + TypeScript + Tailwind) por IA; Supabase es el backend; se exporta a GitHub para no quedar preso de la plataforma.
- **Costo fijo objetivo**: $0 (solo comisión por venta). ⚠️ Ver §11: el free tier de Lovable sirve para prototipo; un MVP real probablemente exige Pro ($25/mes).
- **Procesador de pagos**: Hotmart (Merchant of Record, venta internacional con tarjeta de crédito).
- **Entrega de acceso**: PDF automático con credenciales + link a la app web en el teléfono.

---

## 2. Decisiones confirmadas

| # | Decisión | Valor |
|---|---|---|
| 1 | Constructor del frontend | **Lovable** — genera React + TypeScript + Tailwind por IA; UI iterada por prompts |
| 2 | Procesador de pagos | **Hotmart** — venta internacional, solo países que puedan pagar con tarjeta de crédito. ⚠️ **No es nativo de Lovable**: webhook y activación viven en Supabase Edge Function |
| 3 | Restricción de países | Se configura en el panel de Hotmart (no en código) |
| 4 | Identificación del comprador | Mapeo por **email** (Hotmart envía `buyer.email`; la Edge Function resuelve/crea el usuario) |
| 5 | Entrega de acceso | **PDF automático** con link de la app + credenciales, enviado por Resend tras `PURCHASE_APPROVED` (Edge Function) |
| 6 | Experiencia móvil | Web responsive mobile-first. ⚠️ **PWA instalable**: Lovable no genera PWA "tipo APK" por defecto; decisión pendiente (ver §2.1) |
| 7 | Dominio | `*.lovable.app` ($0). Dominio propio solo si se contrata Pro |
| 8 | Idioma de la UI | Español |
| 9 | Admin MVP | Supabase Dashboard + panel Hotmart (NO construir `/admin` en el MVP) |
| 10 | Audio | TTS gratuito para beta |
| 11 | Videos | YouTube no listado (evita límite de storage) |
| 12 | Analytics | Hotmart Analytics (ventas) + tabla `events` en Supabase (aprendizaje) |
| 13 | Plan anual | Diferido |
| 14 | Gamificación | Mínima: progreso + racha simple. Nada complejo |
| 15 | Git | GitHub con **sync desde Lovable** (export del código generado) — evita vendor lock-in y permite commits rastreables |
| 16 | Diseño | La genera Lovable. Figma opcional solo para referencias visuales |

### 2.1 Decisión pendiente — PWA instalable

Lovable produce una web app normal, no una PWA instalable con icono en pantalla de inicio "como un APK" (decisión 5 del plan anterior). Opciones:

- **A (recomendada)**: aceptar la web en el navegador del teléfono (guardar en pantalla de inicio funciona de forma básica con el menú del navegador).
- **B**: exportar a GitHub y añadir manifest.json + service worker a mano (React) para instalación real. Más trabajo, requiere Pro/custom domain para que el service worker funcione bien con HTTPS propio.

---

## 3. Stack tecnológico

| Capa | Tecnología | Costo |
|---|---|---|
| Frontend | **Lovable** (React + TypeScript + Tailwind, generado por IA) | $0 free / $25 Pro |
| Hosting | Lovable hosting (`*.lovable.app`); custom domain en Pro | $0 (free) |
| Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions) | $0 (free tier) |
| Pagos | Hotmart (tarjeta, suscripciones, internacional) | Comisión por venta |
| Email | Resend | $0 (free: 3K/mes, 100/día) |
| PDF | Generado en Edge Function (`pdf-lib`) | $0 |
| Analytics | Hotmart Analytics + tabla `events` | $0 |
| Video | YouTube no listado | $0 |
| Git | GitHub (sync desde Lovable) | $0 |
| Diseño | Generado por Lovable; Figma Free opcional | $0 |

### Arquitectura

```
Internet
  ↓
Lovable (React + Tailwind, hosting lovable.app, HTTPS gratis)
  ↓  anon key (pública)
Supabase: Auth + PostgreSQL + Storage + Edge Functions
  ↓  service_role + secrets (solo Edge Functions)
Hotmart (pagos)  +  Resend (email/PDF)  +  YouTube (video)
```

**Regla de seguridad**: el frontend Lovable NUNCA contiene secretos ni service role.
Toda operación sensible (activar suscripción, webhook, generar PDF) vive en Edge Functions de Supabase.
El acceso Premium se autoriza por RLS con función SQL `is_premium()`, nunca desde el frontend.
**Lovable se usa para la UI y el flujo del cliente; la lógica crítica de pagos no se implementa "por prompts" en Lovable.**

---

## 4. Esquema de base de datos

Sin cambios respecto al diseño original (Supabase/PostgreSQL):

| Tabla | Campos clave / notas |
|---|---|
| `profiles` | `id` (= auth.users.id), `full_name`, `role` ('user'\|'admin'), `created_at`. El rol vive en DB, nunca llega del frontend |
| `plans` | `name`, `price`, `currency`, `interval`, `active` |
| `subscriptions` | `user_id`, `plan_id`, `provider` ('hotmart'), `provider_subscription_id`, `status` ('trialing'\|'active'\|'past_due'\|'cancelled'\|'expired'), `started_at`, `current_period_start`, `current_period_end`, `cancelled_at`, timestamps |
| `courses` | `title`, `description`, `level`, `active` |
| `modules` | `course_id`, `title`, `order` |
| `lessons` | `module_id`, `title`, `content`, `video_url`, `audio_url`, `order`, `is_free`, `active` |
| `quizzes` | `lesson_id`, `title` |
| `questions` | `quiz_id`, `question`, `type`, `order` |
| `answers` | `question_id`, `answer`, `is_correct`, `order` |
| `lesson_progress` | `user_id`, `lesson_id`, `completed`, `score`, `started_at`, `completed_at` — **UNIQUE(user_id, lesson_id)** |
| `events` | eventos de aprendizaje (inicio/fin lección, quiz, etc.) para embudo |

**Índices**: `subscriptions(user_id, status)`, `lessons(module_id, order)`, `lesson_progress(user_id)`.
**Integridad**: claves primarias, foreign keys, unique constraints, timestamps, integridad referencial.
Se crean desde el SQL Editor de Supabase (no en Lovable).

---

## 5. Row Level Security (RLS)

Sin cambios. Se implementa en Supabase, independiente del frontend:

| Tabla | Regla |
|---|---|
| `profiles` | SELECT/UPDATE propio (UPDATE no toca `role`); admin SELECT todos |
| `plans` | SELECT público (precios) |
| `lessons` | SELECT si `is_free` **O** (`is_premium()` y suscripción `active`) |
| `questions`/`answers` | SELECT solo autenticados con acceso a la lección |
| `lesson_progress` | SELECT/INSERT/UPDATE solo propio |
| `subscriptions` | SELECT solo propia; **escrituras solo vía Edge Function con service_role** |
| CRUD contenido | solo `is_admin()` |

Un usuario NO puede: ver progreso ajeno, modificar suscripciones/precios/contenidos/roles/pagos.

---

## 6. Estructura de la app (Lovable)

Lovable genera la app en React + TypeScript + Tailwind con una estructura similar a:

```
src/
  components/      (Landing, Pricing, Login, Registro, Dashboard, Lección, Quiz…)
  pages/           (rutas: /, /pricing, /login, /registro, /dashboard, /curso/…, /perfil, /suscripcion)
  lib/             (cliente Supabase anon, helpers, tipos)
  supabase/        (conexión generada por Lovable a tu proyecto Supabase)
```

- Las **rutas y la UI** se construyen/iteran por prompts en Lovable (landing, pricing, dashboard, lección, quiz, progreso).
- Los **datos** vienen de Supabase vía RLS con la anon key (igual que el plan Angular).
- El **código generado se sincroniza a GitHub** para versionar, revisar y (si se quiere) continuar en desarrollo tradicional.
- Sin `admin/` en el MVP (Supabase Dashboard cubre la gestión).

---

## 7. Flujos

### Autenticación
Registro → Supabase Auth → confirmación de email (Resend) → trigger crea `profiles` → login → guard de ruta → dashboard.
Lovable conecta Supabase Auth con unos prompts; la lógica de sesión es la nativa de Supabase.

### Compra y entrega de acceso (flujo del cliente)

```
Compra en Hotmart (tarjeta, países configurados)
  → webhook PURCHASE_APPROVED
  → Edge Function `activate-subscription` (Supabase, NO Lovable):
      1. Busca usuario por buyer.email; si no existe, lo CREA
         (cuenta auth con password generado + perfil)
      2. Crea registro en `subscriptions` (ACTIVE)
      3. Genera PDF: link de la app, email, password (o token único),
         instrucciones para guardar la app en pantalla de inicio (Android e iPhone)
      4. Envía el PDF por Resend
  → comprador abre el PDF en el teléfono
  → toca el link → inicia sesión → usa la app en su navegador (o PWA si se elige opción B)
```

### Webhooks Hotmart (Postback v2.0.0)
- Validar firma con `hottok` (nunca en frontend).
- **Idempotencia por ID de evento** (un evento no activa dos veces).
- Eventos relevantes:
  - `PURCHASE_APPROVED` / `PURCHASE_COMPLETE` → activar Premium
  - `PURCHASE_REFUNDED` / `PURCHASE_CHARGEBACK` → revocar acceso
  - `PURCHASE_EXPIRED` / `PURCHASE_CANCELED` / `PURCHASE_PROTEST` → past_due / expired
  - Suscripción: cancelación, cambio de plan, renovación de fecha de cobro
- Nunca confiar en el retorno del usuario: la fuente de verdad es Hotmart + nuestra DB.
- **Todo esto se construye en Edge Functions de Supabase**, no en prompts de Lovable.

---

## 8. Estrategia de contenido

Sin cambios:

- **20–30 lecciones** en 4 módulos (curso "English Basic — Inglés Básico en 30 días"):
  - Semana 1 Supervivencia · Semana 2 Vida cotidiana · Semana 3 Conversación · Semana 4 Comunicación
- **Plantilla fija de lección**: objetivo → vocabulario → gramática → listening → práctica → speaking → quiz (5 preguntas) → resultado (score, respuestas correctas, lección completada, siguiente lección).
- **Free**: 3 lecciones + vocabulario + quiz inicial ($0).
- **Premium**: curso completo, ejercicios, audio, quizzes, progreso ($9.99/mes).
- Audio: TTS gratuito (Supabase Storage, 500MB/1GB free).
- Video: YouTube no listado.

---

## 9. Roadmap (adaptado a Lovable)

| Fase | Contenido | Gate de salida |
|---|---|---|
| **0** | Definición (este documento) | ✅ aprobado |
| **1** | Crear proyecto en Lovable + conectar Supabase + GitHub sync | deploy en blanco en `*.lovable.app` |
| **2** | DB + RLS + roles + seed de `plans` (SQL Editor de Supabase) | políticas probadas |
| **3** | Auth completo vía Lovable (Supabase Auth) | registro/login/recuperación |
| **4** | Landing + pricing construidas por IA en Lovable | responsive, CTA |
| **5** | Curso: 20-30 lecciones, quizzes, audios (UI en Lovable, contenido en Supabase) | lección free + premium visible |
| **6** | Progreso + dashboard | % progreso, continuar, racha |
| **7** | Hotmart + suscripciones + PDF + email (Edge Functions en Supabase) | pago sandbox activa Premium y llega el PDF |
| **8** | Admin (Supabase Dashboard + panel Hotmart) | gestión manual operativa |
| **9** | Analytics (eventos de aprendizaje) | embudo medible |
| **10** | Testing integral + beta 10-20 alumnos | bugs conocidos, no bloqueantes |
| **11** | Deploy producción | dominio/HTTPS/var/ambiente final (custom domain si se contrata Pro) |

**Nota de créditos**: las fases 1, 4, 5 y 6 consumen la mayoría de créditos de Lovable (UI + iteración). La fase 7 no consume créditos (es código en Supabase). Planificar el gasto de créditos por fase.

---

## 10. Riesgos

| Riesgo | Severidad | Mitigación |
|---|---|---|
| **Free tier de Lovable insuficiente** (30 créditos/mes, branding, proyectos públicos) | Alta | Decidir plan antes de la fase 4; presupuestar créditos por fase; Pro $25/mes si el MVP es real |
| **Regresión por IA** (Lovable rompe algo ya funcionando al pedir un cambio) | Media | GitHub sync + commits frecuentes; probar tras cada cambio; no encadenar muchos prompts sin verificar |
| **Hotmart no nativo en Lovable** (webhook/PDF deben integrarse a mano) | Media | Lógica de pagos 100% en Edge Functions de Supabase; probar en sandbox Hotmart |
| **PWA instalable débil** (decisión 5 anterior) | Media | Aceptar web (opción A) o añadir manifest/service worker vía GitHub (opción B) |
| **Lógica de negocio compleja vía prompts** (webhooks, idempotencia, roles) | Media | Esa lógica NO se pide por prompts: vive en Edge Functions; Lovable solo consume RLS |
| **Mapeo Hotmart → usuario por email** (email distinto al comprar) | Media | Aviso claro en checkout; upsert seguro por email en Edge Function |
| Producción de contenido/audio (riesgo humano) | Media | TTS gratuito; 20-30 lecciones priorizadas |
| Fuga de contenido Premium (SPA descargable) | Baja (aceptado) | RLS impide acceso no autorizado; no se puede impedir copiar lo visible |
| Límites free tier Supabase (storage 1GB, 50K MAU, 100 emails/día) | Baja | Sobrado para beta; primer servicio a migrar a pago: Resend |
| Webhook sin idempotencia = doble activación | Media | Idempotencia por ID de evento (diseñado) |
| Vendor lock-in Lovable | Baja | GitHub sync (el código es React estándar y exportable); Supabase es Postgres portable |
| Cancelación/chargeback | Baja | Webhook revoca Premium automáticamente |

---

## 11. Costos (realistas, verificados jul-2026)

- **Lovable Free $0**: 5 créditos/día (máx 30/mes), branding de Lovable, proyectos públicos, subdominio `lovable.app`. ⚠️ Suficiente para prototipo, no para un MVP con usuarios reales.
- **Lovable Pro $25/mes** (o ~$21/mes anual): 100 créditos base, sin branding, dominio propio, GitHub sync. **Candidato realista para este MVP.** Un build típico consume ~0.5-2 créditos; iterar UI/lógica de negocio gasta 15-40 créditos al mes. Comprar créditos extra: ~$20 por 100.
- **Supabase free tier $0** (pausa tras 1 semana de inactividad; reactivar gratis). Pro $25/mes solo si se necesita.
- **$0 fijo adicional**: Resend, GitHub, YouTube, Hotmart Analytics.
- **Variable (solo con venta)**: comisión Hotmart por transacción (verificar % vigente al crear el producto).
- **Posible costo futuro**: dominio propio (~$10/año) cuando haya marca.

> **Conclusión honesta**: el objetivo de $0 se mantiene solo para el prototipo (free tier). Para lanzar un MVP con usuarios reales, presupuestar **Lovable Pro ~$25/mes** como único costo fijo del stack.

---

## 12. Funcionalidades excluidas del MVP (Fase 2)

App nativa/APK real, chat, videollamadas, profesores, marketplace, comunidad propia,
certificados oficiales, gamificación avanzada, afiliados, reconocimiento de voz,
IA conversacional, tutor IA, generación automática de ejercicios, recomendaciones avanzadas.
(La web mobile-first de Lovable cubre la necesidad móvil; una PWA real solo si se elige opción B.)

---

## 13. Criterios de éxito

1. Personas llegan a la landing.
2. Algunas se registran.
3. Algunas consumen contenido gratuito.
4. Algunas pagan (Hotmart, tarjeta, internacional).
5. El pago activa Premium y llega el PDF con credenciales.
6. Los usuarios abren la app en el teléfono.
7. Los usuarios completan lecciones.
8. Algunos permanecen activos después de varias semanas.

No medir el éxito por cantidad de funcionalidades.

---

## 14. Principios de desarrollo

KISS · YAGNI · DRY cuando corresponda.
Prioridad: simplicidad, seguridad, mantenibilidad, escalabilidad razonable, velocidad.
**Lovable para la UI, Supabase para los datos y la lógica crítica.**
No pedir por prompts lógica que debe ser confiable (pagos, webhooks, roles, RLS).
GitHub sync + commits claros y rastreables. Implementar por fases, probar cada fase.
