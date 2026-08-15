# MVP English Basic — Registro de Avance

> Bitácora del proyecto: plataforma de suscripción (freemium) para curso de inglés básico.
> Stack: Angular 20 + Supabase + Cloudflare Workers + Hotmart + Resend.
> Última actualización: 2026-08-15.

---

## Estado global

| Fase | Descripción | Estado |
|---|---|---|
| F1 | Infraestructura (git, Angular+PWA, Supabase, Cloudflare) | ✅ Completada |
| F2 | Esquema BD + RLS + seed de planes | ✅ Completada |
| F3 | Autenticación (registro, login, recuperación, guards) | ✅ Completada |
| F4 | Landing + pricing de conversión | ✅ Completada |
| F5 | Contenido del curso (20 lecciones, quizzes, audios) | ✅ Completada |
| F6 | Progreso + dashboard del alumno | ✅ Completada |
| F7 | Hotmart + suscripciones + PDF + email | ⏳ Pendiente (investigación lista) |

**Pendiente de usuario antes de F7**: crear cuenta en Hotmart (productor) y en Resend.

---

## Decisiones clave del proyecto

- **Ejecutar `PLAN.md`** (Angular). Se descartó explícitamente `PLAN_LOVABLE.md` (Lovable).
- **Hotmart como Merchant of Record**: procesa pagos y cobros recurrentes; la app nunca toca tarjetas.
- **Venta internacional**: solo países que paguen con tarjeta de crédito; restricción configurada en panel Hotmart (no en código).
- **Mapeo comprador→usuario por `buyer.email`**.
- **PDF con credenciales** + email vía Resend tras `PURCHASE_APPROVED`.
- **PWA instalable** "tipo APK"; dominio workers.dev (costo $0).
- **Admin** = Supabase Dashboard + panel Hotmart (sin `/admin` en Angular).
- **Audio**: TTS gratuito (placeholder `audio/lesson-N.mp3` pendiente de F7).
- **UI en español**; identificadores/comentarios/código en inglés.

---

## Fase 1 — Infraestructura ✅

### Lo hecho
- Repo git en `C:\Users\eliza\proyectos_claude\mvp_ingles` (remoto `origin` → GitHub, rama `main`).
- Scaffold Angular 20 standalone en `english-basic/` con PWA (`@angular/pwa`: manifest, ngsw, iconos).
- Estructura de features: `core/` (services, guards), `shared/`, `features/{landing,pricing,auth,dashboard,course,lesson,quiz,progress,profile,subscription}`.
- Lazy loading en rutas.
- Build OK → `dist/english-basic/browser`.
- Despliegue Cloudflare via wrangler (Worker estático): `wrangler.jsonc` con `assets.directory` y `not_found_handling: "single-page-application"`.
- Push a GitHub dispara **deploy automático** en Cloudflare (detecta framework Angular).

### Datos clave
- Repo: `https://github.com/elizelluz/english-basic.git` (rama `main`).
- App desplegada: `https://english-basic.elizelluz-a-r-t.workers.dev` (responde 200 en `/`, `/pricing`, `/registro`, `/dashboard`).
- Cuenta Cloudflare: `elizelluz.a.r.t@gmail.com`.
- Git local: user `eliza` / email `eliza@local` (no hay config global; se pasa con `-c` por commit).

### Gotchas
- Cloudflare tarda unos segundos en redeployar tras cada push → puede dar **504 gateway timeout** durante ese lapso. No es un bug.

---

## Fase 2 — Esquema BD + RLS ✅

### Lo hecho
- `english-basic/supabase/schema.sql` (326 líneas, orden: limpieza → tablas → índices → funciones → trigger → RLS → seed).
- 11 tablas: `profiles`, `plans`, `subscriptions`, `courses`, `modules`, `lessons`, `quizzes`, `questions`, `answers`, `lesson_progress`, `events`.
- Funciones: `is_premium()`, `is_admin()`; trigger `handle_new_user` (crea profile al registrarse).
- RLS activa en todas las tablas con policies:
  - `plans` lectura pública; `courses`/`modules` lectura pública.
  - `lessons`/`quizzes`/`questions`/`answers`: acceso solo si `is_free` o premium/admin.
  - `lesson_progress` y `events`: solo propio.
  - `profiles`: select/update propio o admin.
- Seed: planes FREE ($0) y PREMIUM ($9.99/mes).
- Bloque de limpieza al inicio → script **re-ejecutable sin errores**.

### Gotchas (bugs resueltos)
1. **Orden de creación**: la función `is_premium()` se creaba antes que la tabla `subscriptions` → error `42P01 relation does not exist`. Se reordenó a tablas → índices → funciones → trigger → RLS → seed.
2. **Dominio Supabase**: la app apuntaba a `qeopcwsuwntmjmodiwpt.supabase.**com**` pero el proyecto real vive en `.supabase.**co**`. El `.com` no existe en DNS → `ERR_NAME_NOT_RESOLVED` / "Failed to fetch" al registrarse. Corregido en `environment.ts` y `environment.prod.ts`.

### Datos clave
- Proyecto Supabase: `https://qeopcwsuwntmjmodiwpt.supabase.co` (⚠️ `.co`, no `.com`).
- Anon key: en `src/environments/environment{,.prod}.ts` (pública por diseño; el `service_role` nunca va al frontend).
- Script aplicado en Supabase Dashboard → SQL Editor (✅ confirmado).

---

## Fase 3 — Autenticación ✅

### Lo hecho
- `core/services/auth.service.ts`: `signUp(email, password, fullName)` (guarda `full_name` en `user_metadata`), `signIn`, `signOut`, `resetPassword`, `getSession`, signals reactivos a `onAuthStateChange`, `isAuthenticated()`.
- Guards: `auth.guard.ts` (exige sesión, redirige a `/login`), `guest.guard.ts` (si ya hay sesión, redirige a `/dashboard`).
- Componentes: `login`, `register` (con confirmación por email), `forgot-password` (en español).
- `dashboard` placeholder inicial (sustituido en F6).
- Rutas: `login`, `registro`, `recuperar`, `dashboard` (authGuard), wildcard `**` → `''`.
- Landing muestra CTA según sesión.
- Configuración Supabase Auth para emails: Site URL `https://english-basic.elizelluz-a-r-t.workers.dev` + Redirect URL `http://localhost:4200/**` (✅ hecho por el usuario; registro/confirmación/login probados de punta a punta).

### Gotchas
- Supabase expone `User`/`Session` como `AuthUser`/`AuthSession` en esta versión.
- Los guards redirigen con `router.createUrlTree(...)` (idiomático), no `false` directo.
- `*ngIf` → control flow nativo `@if` (Angular 17+).

---

## Fase 4 — Landing + Pricing ✅

### Lo hecho
- **Landing** completa: header sticky con CTA según sesión, hero (propuesta "aprende y comunícate en 30 días"), problema/solución, 6 beneficios con SVG inline, cómo funciona (3 pasos), programa (4 semanas), testimonios con badge "Próximamente", pricing teaser, FAQ nativo `<details>`, CTA final, footer.
- **Pricing**: 2 tarjetas (FREE $0 / PREMIUM $9.99/mes destacada "Más popular"), comparativa checks ✓, nota "Pagos seguros procesados por Hotmart", `<!-- TODO F7: link a checkout Hotmart -->`.
- `src/styles.scss`: tokens CSS (`:root` custom properties), reset, botones, `.container`.
- `app.html`: solo `<router-outlet />` (se eliminó el placeholder "Hello Angular").
- `index.html`: `lang="es"`, título "English Basic — Aprende inglés desde cero".

### Gotchas
- Warning de budget `landing.component.scss` (7.97 kB vs 8 kB) — preexistente, no bloquea.

---

## Fase 5 — Contenido del curso ✅

### Lo hecho
- `supabase/seed_content.sql` (1.673 líneas, script `do $$` plpgsql con CTEs/variables para encadenar ids):
  - 1 curso · 4 módulos · **20 lecciones** (5 por semana) con `content` JSONB: vocabulary, grammar, examples, practice.
  - **20 quizzes · 81 preguntas** (42 multiple_choice, 20 true_false, 19 fill_blank) · **227 answers**.
  - `is_free=true` solo lecciones 1-2 del Módulo 1 (sample gratis); resto premium (protegido por RLS).
  - `audio_url` placeholder `https://english-basic.elizelluz-a-r-t.workers.dev/audio/lesson-N.mp3` + `-- TODO F7`.
  - Consultas de verificación al final (`lessons_count`, `questions_count`, etc.).
- Páginas (todas con `authGuard`):
  - `course/` (`/curso`): 4 módulos con lecciones, etiqueta GRATIS, estados.
  - `lesson/` (`/curso/:lessonId`): secciones del contenido, audio player, "Mostrar respuesta", "Marcar como completada" (upsert en `lesson_progress`), bloqueo premium (RLS → pantalla "Ver planes").
  - `quiz/` (`/curso/:lessonId/quiz`): una pregunta a la vez, corrección inmediata, `fill_blank` con normalización (trim/lowercase/acentos), resultado ≥70%, guarda score/progreso.
- Dashboard enlaza "Ir al curso".

### Gotchas (bug resuelto)
- **Escapado de comillas en SQL**: las preguntas `true_false` que citan frases tenían `''''` (4 comillas) → PostgreSQL interpretaba la 4ª como cierre del literal → `syntax error at or near "Eleven"`. Corregido a `'''` (3 comillas) en 16 líneas. Validación posterior con parser: 0 líneas desbalanceadas.
- **Importante**: al re-aplicar el seed, copiar el archivo ACTUALIZADO (la versión vieja con 4 comillas seguía en el portapapeles del usuario).

---

## Fase 6 — Progreso + Dashboard ✅

### Lo hecho
- Dashboard del alumno (`features/dashboard/`, reescrito):
  - Saludo + badge FREE/PREMIUM (detecta suscripción `active` en `subscriptions`).
  - **Barra de progreso general**: % = completadas visibles / total visibles (fórmula honesta con RLS: un FREE solo cuenta sobre las 2 lecciones gratis; un PREMIUM sobre las 20).
  - 4 cards de módulos con progreso interno y lecciones (✓ completada / link / candado).
  - Últimas actividades: últimos 5 `events` con traducción (`lesson_started` → "Lección iniciada", etc.).
  - CTAs: "Ir al curso", "Ver planes" (si FREE), "Cerrar sesión".
- Curso: check verde ✓ junto a lecciones completadas.
- Dashboard es **solo lectura**; los inserts best-effort de eventos viven en lesson/quiz.

---

## Fase 7 — Hotmart + Suscripciones + PDF + Email (INVESTIGACIÓN COMPLETA, PENDIENTE)

### Hallazgos de la investigación (docs oficiales Hotmart, 2026)
1. **Hotmart es Merchant of Record**: procesa pago + cobros recurrentes (mensual, etc.). El cobro se repite el día de la suscripción. Hasta 5 intentos de recobro; tras 5 pagos atrasados consecutivos, se cancela sola.
2. **Checkout**: dos modos — URL directa `pay.hotmart.com/XXX` (recomendado para MVP) o Checkout Elements (overlay/embebido). Se pueden pre-llenar datos: `&name=...&email=...` (clave para mapear comprador→usuario).
3. **Entrega de acceso**: configurar la URL del área de miembros NO crea cuentas automáticamente. **La liberación depende del Webhook**.
4. **Webhook** (`app.hotmart.com` → Herramientas → Webhook): URL destino `https://qeopcwsuwntmjmodiwpt.supabase.co/functions/v1/hotmart-webhook`; eventos a seleccionar: `PURCHASE_APPROVED`, `SUBSCRIPTION_CANCELLATION`, `PURCHASE_REFUNDED`. Llega con header **`X-HOTMART-HOTTOK`** (token único por cuenta) — validarlo SIEMPRE antes de procesar.
5. **Payload PURCHASE_APPROVED (v2)**: `event`, `data.buyer.{email,name}`, `data.product.{id,name}`, `data.subscription.{subscriber_code,plan}`.
6. **SUBSCRIPTION_CANCELLATION**: NO revoca de inmediato — el suscriptor conserva acceso hasta `date_next_charge` (ya pagó el mes). Marcar como `cancel_at_period_end`.
7. **PURCHASE_REFUNDED**: revoca acceso de inmediato.
8. **No se necesita** la API completa de Hotmart (OAuth) ni Hotmart Club para el MVP. Hotmart tiene **sandbox/test** para simular compras.

### Plan de implementación F7
1. Crear producto/suscripción en Hotmart (panel) + configurar webhook + URL de pago.
2. Edge Function Supabase `hotmart-webhook`: valida `X-HOTMART-HOTTOK`, maneja eventos, upsert en `subscriptions` (status `active`/`cancel_at_period_end`/`expired`), y si el comprador no tiene cuenta → crea registro pendiente.
3. Resend: email con **PDF de credenciales** al comprador (generado por la Edge Function).
4. Pricing: botón → `pay.hotmart.com/XXX?email=<logueado>`; página `/gracias`.
5. Pruebas con sandbox de Hotmart.

### Cuentas pendientes del usuario
- **Hotmart** (productor): `https://app.hotmart.com` — requiere datos fiscales para cobrar.
- **Resend**: `https://resend.com` — gratis, 100 emails/día, 3K/mes.

---

## Configuración y comandos de referencia

```bash
# Build
cd english-basic && npm run build

# Commit + push (dispara deploy automático en Cloudflare)
git add -A
git -c user.name="eliza" -c user.email="eliza@local" commit -m "<conventional commit>"
git push

# Historial
git log --oneline -10
```

### Últimos commits
- `872f6e2` feat: add student progress dashboard with module cards and activity feed
- `014f79c` fix: escape leading quotes in true_false seed questions
- `efac128` feat: add course content seed and course/lesson/quiz pages
- `f651176` fix: use correct supabase.co project domain
- `560cd82` feat: build conversion-focused landing and pricing pages
- `a4a1c8d` feat: add full authentication flow (register, login, reset, guards, dashboard)

### Límites free tier a vigilar
- Resend: 100 emails/día, 3K/mes.
- Supabase: 1GB storage.
- Comisión Hotmart variable por venta (pago + servicio).

---

## Siguiente paso (cuando se retome)

1. ✅ Confirmar que el usuario tiene cuenta en **Hotmart** (productor) y **Resend**.
2. Implementar Fase 7 según el plan de arriba (Edge Function webhook → Resend → PDF → botón checkout → `/gracias`).
3. Probar con sandbox de Hotmart: compra aprobada → acceso premium + email con PDF; cancelación → acceso hasta fin de periodo; reembolso → revocación.
