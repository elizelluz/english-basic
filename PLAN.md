# PLAN — MVP English Basic

Plataforma de suscripción para infoproducto de inglés básico.
Documento de planificación aprobado. Fuente: `idea_mvp`.

---

## 1. Resumen ejecutivo

MVP de plataforma web de suscripción (freemium) para vender un curso de inglés básico.
Objetivo: **validar el modelo de negocio** (registro → consumo → pago → retención), no construir una academia compleja.

- **Propuesta de valor**: "Aprende las bases del inglés y empieza a comunicarte en situaciones cotidianas en 30 días."
- **Nombre provisional**: English Basic (comercial por decidir).
- **Costo fijo objetivo**: $0 (solo comisión por venta).
- **Procesador de pagos**: Hotmart (Merchant of Record, venta internacional con tarjeta de crédito).
- **Entrega de acceso**: PDF automático con credenciales + link a PWA instalable en el teléfono.

---

## 2. Decisiones confirmadas

| # | Decisión | Valor |
|---|---|---|
| 1 | Procesador de pagos | **Hotmart** — venta internacional, solo países que puedan pagar con tarjeta de crédito |
| 2 | Restricción de países | Se configura en el panel de Hotmart (no en código) |
| 3 | Identificación del comprador | Mapeo por **email** (Hotmart envía `buyer.email`; la Edge Function resuelve/crea el usuario) |
| 4 | Entrega de acceso | **PDF automático** con link de la app + credenciales, enviado por Resend tras `PURCHASE_APPROVED` |
| 5 | Experiencia móvil | **PWA instalable** (icono en pantalla de inicio, "como un APK") |
| 6 | Dominio | `*.pages.dev` ($0) |
| 7 | Idioma de la UI | Español |
| 8 | Admin MVP | Supabase Dashboard + panel Hotmart (NO construir `/admin` Angular en el MVP) |
| 9 | Audio | TTS gratuito para beta |
| 10 | Videos | YouTube no listado (evita límite de storage) |
| 11 | Analytics | Hotmart Analytics (ventas) + tabla `events` en Supabase (aprendizaje) |
| 12 | Plan anual | Diferido |
| 13 | Gamificación | Mínima: progreso + racha simple. Nada complejo |

---

## 3. Stack tecnológico

| Capa | Tecnología | Costo |
|---|---|---|
| Frontend | Angular (standalone, lazy loading) | $0 |
| Hosting | Cloudflare Pages | $0 |
| Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions) | $0 (free tier) |
| Pagos | Hotmart (tarjeta, suscripciones, internacional) | Comisión por venta |
| Email | Resend | $0 (free: 3K/mes, 100/día) |
| PDF | Generado en Edge Function (`pdf-lib`) | $0 |
| Analytics | Hotmart Analytics + tabla `events` | $0 |
| Video | YouTube no listado | $0 |
| Git | GitHub | $0 |
| Diseño | Figma Free | $0 |

### Arquitectura

```
Internet
  ↓
Cloudflare Pages (Angular SPA, estático, HTTPS gratis)
  ↓  anon key (pública)
Supabase: Auth + PostgreSQL + Storage + Edge Functions
  ↓  service_role + secrets (solo Edge Functions)
Hotmart (pagos)  +  Resend (email/PDF)  +  YouTube (video)
```

**Regla de seguridad**: el frontend NUNCA contiene secretos ni service role.
Toda operación sensible (activar suscripción, webhook, generar PDF) vive en Edge Functions.
El acceso Premium se autoriza por RLS con función SQL `is_premium()`, nunca por Angular.

---

## 4. Esquema de base de datos

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

---

## 5. Row Level Security (RLS)

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

## 6. Estructura Angular

```
src/app/
  core/        (auth.service, subscription.service, guards, interceptors)
  shared/      (componentes, pipes, types/interfaces)
  features/
    landing/ pricing/ auth/ dashboard/ course/ lesson/ quiz/
    progress/ profile/ subscription/
```

- Standalone components, lazy loading, route guards, services, interceptors.
- **PWA**: `@angular/pwa` — manifest.json, service worker, iconos 192/512, apple-touch-icon.
- Sin `admin/` en el MVP (Supabase Dashboard cubre la gestión).

---

## 7. Flujos

### Autenticación
Registro → Supabase Auth → confirmación de email (Resend) → trigger crea `profiles` → login → guard de ruta → dashboard.

### Compra y entrega de acceso (flujo del cliente)

```
Compra en Hotmart (tarjeta, países configurados)
  → webhook PURCHASE_APPROVED
  → Edge Function `activate-subscription`:
      1. Busca usuario por buyer.email; si no existe, lo CREA
         (cuenta auth con password generado + perfil)
      2. Crea registro en `subscriptions` (ACTIVE)
      3. Genera PDF: link de la app, email, password (o token único),
         instrucciones para instalar el icono (Android e iPhone)
      4. Envía el PDF por Resend
  → comprador abre el PDF en el teléfono
  → toca el link → inicia sesión → instala el icono
  → usa la "app" desde su pantalla de inicio
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

---

## 8. Estrategia de contenido

- **20–30 lecciones** en 4 módulos (curso "English Basic — Inglés Básico en 30 días"):
  - Semana 1 Supervivencia · Semana 2 Vida cotidiana · Semana 3 Conversación · Semana 4 Comunicación
- **Plantilla fija de lección**: objetivo → vocabulario → gramática → listening → práctica → speaking → quiz (5 preguntas) → resultado (score, respuestas correctas, lección completada, siguiente lección).
- **Free**: 3 lecciones + vocabulario + quiz inicial ($0).
- **Premium**: curso completo, ejercicios, audio, quizzes, progreso ($9.99/mes).
- Audio: TTS gratuito (Supabase Storage, 500MB/1GB free).
- Video: YouTube no listado.

---

## 9. Roadmap

| Fase | Contenido | Gate de salida |
|---|---|---|
| **0** | Definición (este documento) | ✅ aprobado |
| **1** | GitHub + Angular + Supabase + Cloudflare Pages + PWA base | deploy en blanco en `*.pages.dev` |
| **2** | DB + RLS + roles + seed de `plans` | políticas probadas |
| **3** | Auth completo | registro/login/recuperación |
| **4** | Landing + pricing | responsive, CTA |
| **5** | Curso: 20-30 lecciones, quizzes, audios | lección free + premium visible; icono instalable probado |
| **6** | Progreso + dashboard | % progreso, continuar, racha |
| **7** | Hotmart + suscripciones + PDF + email | pago sandbox activa Premium y llega el PDF |
| **8** | Admin (Supabase Dashboard + panel Hotmart) | gestión manual operativa |
| **9** | Analytics (eventos de aprendizaje) | embudo medible |
| **10** | Testing integral + beta 10-20 alumnos | bugs conocidos, no bloqueantes |
| **11** | Deploy producción | dominio/HTTPS/var/ambiente final |

---

## 10. Riesgos

| Riesgo | Severidad | Mitigación |
|---|---|---|
| Mapeo Hotmart → usuario por email (email distinto al comprar) | Media | Aviso claro en checkout; upsert seguro por email en Edge Function |
| Producción de contenido/audio (riesgo humano) | Media | TTS gratuito; 20-30 lecciones priorizadas |
| Fuga de contenido Premium (SPA descargable) | Baja (aceptado) | RLS impide acceso no autorizado; no se puede impedir copiar lo visible |
| Límites free tier (storage 1GB, 50K MAU, 100 emails/día) | Baja | Sobrado para beta; primer servicio a migrar a pago: Resend |
| Webhook sin idempotencia = doble activación | Media | Idempotencia por ID de evento (diseñado) |
| Vendor lock-in Supabase | Baja | Postgres portable |
| Cancelación/chargeback | Baja | Webhook revoca Premium automáticamente |

---

## 11. Costos

- **$0 fijo**: Cloudflare Pages, Supabase, Resend, GitHub, YouTube, Hotmart Analytics, Figma.
- **Variable (solo con venta)**: comisión Hotmart por transacción (verificar % vigente al crear el producto).
- **Único costo fijo posible futuro**: dominio propio (~$10/año) cuando haya marca.

---

## 12. Funcionalidades excluidas del MVP (Fase 2)

App nativa/APK real, chat, videollamadas, profesores, marketplace, comunidad propia,
certificados oficiales, gamificación avanzada, afiliados, reconocimiento de voz,
IA conversacional, tutor IA, generación automática de ejercicios, recomendaciones avanzadas.
(La PWA instalable cubre la necesidad móvil sin APK.)

---

## 13. Criterios de éxito

1. Personas llegan a la landing.
2. Algunas se registran.
3. Algunas consumen contenido gratuito.
4. Algunas pagan (Hotmart, tarjeta, internacional).
5. El pago activa Premium y llega el PDF con credenciales.
6. Los usuarios abren la PWA en el teléfono e instalan el icono.
7. Los usuarios completan lecciones.
8. Algunos permanecen activos después de varias semanas.

No medir el éxito por cantidad de funcionalidades.

---

## 14. Principios de desarrollo

KISS · YAGNI · DRY cuando corresponda.
Prioridad: simplicidad, seguridad, mantenibilidad, escalabilidad razonable, velocidad.
No sobrearquitecturar. No introducir dependencias innecesarias.
Implementar por fases, probar cada fase, commits claros y rastreables.
