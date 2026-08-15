-- ============================================================================
-- English Basic — Schema Fase 2 (Supabase / PostgreSQL)
-- Aplicar en: Supabase Dashboard → SQL Editor → New query → Run
-- Diseño aprobado en PLAN.md (secciones 4 y 5).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Helper functions (seguridad y roles)
-- ----------------------------------------------------------------------------

-- True si el usuario actual tiene una suscripción activa.
create or replace function public.is_premium()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.subscriptions s
    where s.user_id = auth.uid()
      and s.status = 'active'
      and (s.current_period_end is null or s.current_period_end > now())
  );
$$;

-- True si el usuario actual es administrador.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
  );
$$;

-- ----------------------------------------------------------------------------
-- 2. Tablas
-- ----------------------------------------------------------------------------

-- Perfil del usuario (relacionado con auth.users por id).
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text,
  role        text not null default 'user' check (role in ('user', 'admin')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Planes de suscripción (Hotmart es la fuente del cobro; aquí referencia).
create table public.plans (
  id          bigint generated always as identity primary key,
  name        text not null unique,
  price       numeric(10,2) not null default 0,
  currency    text not null default 'USD',
  interval    text not null default 'month' check (interval in ('month', 'year')),
  active      boolean not null default true,
  created_at  timestamptz not null default now()
);

-- Suscripciones: fuente de verdad del acceso Premium (sincronizada con Hotmart).
create table public.subscriptions (
  id                       bigint generated always as identity primary key,
  user_id                  uuid not null references public.profiles (id) on delete cascade,
  plan_id                  bigint references public.plans (id),
  provider                 text not null default 'hotmart',
  provider_subscription_id text,
  status                   text not null default 'active'
                             check (status in ('trialing', 'active', 'past_due', 'cancelled', 'expired')),
  started_at               timestamptz,
  current_period_start     timestamptz,
  current_period_end       timestamptz,
  cancelled_at             timestamptz,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

-- Curso
create table public.courses (
  id          bigint generated always as identity primary key,
  title       text not null,
  description text,
  level       text not null default 'beginner',
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Módulos (semanas)
create table public.modules (
  id          bigint generated always as identity primary key,
  course_id   bigint not null references public.courses (id) on delete cascade,
  title       text not null,
  description text,
  "order"     integer not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Lecciones
create table public.lessons (
  id          bigint generated always as identity primary key,
  module_id   bigint not null references public.modules (id) on delete cascade,
  title       text not null,
  description text,
  content     jsonb,                 -- secciones: vocabulary, grammar, examples, practice, speaking
  video_url   text,
  audio_url   text,
  "order"     integer not null default 0,
  is_free     boolean not null default false,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Quizzes
create table public.quizzes (
  id          bigint generated always as identity primary key,
  lesson_id   bigint not null references public.lessons (id) on delete cascade,
  title       text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Preguntas
create table public.questions (
  id          bigint generated always as identity primary key,
  quiz_id     bigint not null references public.quizzes (id) on delete cascade,
  question    text not null,
  type        text not null default 'multiple_choice'
                check (type in ('multiple_choice', 'true_false', 'fill_blank')),
  "order"     integer not null default 0,
  created_at  timestamptz not null default now()
);

-- Respuestas
create table public.answers (
  id          bigint generated always as identity primary key,
  question_id bigint not null references public.questions (id) on delete cascade,
  answer      text not null,
  is_correct  boolean not null default false,
  "order"     integer not null default 0
);

-- Progreso del alumno por lección
create table public.lesson_progress (
  id           bigint generated always as identity primary key,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  lesson_id    bigint not null references public.lessons (id) on delete cascade,
  completed    boolean not null default false,
  score        numeric(5,2),
  started_at   timestamptz not null default now(),
  completed_at timestamptz,
  updated_at   timestamptz not null default now(),
  constraint lesson_progress_user_lesson_unique unique (user_id, lesson_id)
);

-- Eventos de aprendizaje (embudo: visita, registro, inicio/fin lección, quiz, compra)
create table public.events (
  id          bigint generated always as identity primary key,
  user_id     uuid references public.profiles (id) on delete set null,
  event       text not null,
  payload     jsonb,
  created_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------------------
-- 3. Índices
-- ----------------------------------------------------------------------------

create index subscriptions_user_status_idx on public.subscriptions (user_id, status);
create index lessons_module_order_idx        on public.lessons (module_id, "order");
create index lesson_progress_user_idx        on public.lesson_progress (user_id);
create index events_user_created_idx         on public.events (user_id, created_at);
create index questions_quiz_order_idx        on public.questions (quiz_id, "order");
create index answers_question_order_idx      on public.answers (question_id, "order");

-- ----------------------------------------------------------------------------
-- 4. Trigger: crear profile automáticamente al registrarse
-- ----------------------------------------------------------------------------

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', new.email))
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 5. Row Level Security
-- ----------------------------------------------------------------------------

alter table public.profiles        enable row level security;
alter table public.plans           enable row level security;
alter table public.subscriptions   enable row level security;
alter table public.courses         enable row level security;
alter table public.modules         enable row level security;
alter table public.lessons         enable row level security;
alter table public.quizzes         enable row level security;
alter table public.questions       enable row level security;
alter table public.answers         enable row level security;
alter table public.lesson_progress enable row level security;
alter table public.events          enable row level security;

-- profiles: ver/editar el propio; admin ve todos
create policy profiles_select_own on public.profiles
  for select using (auth.uid() = id or public.is_admin());

create policy profiles_update_own on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- plans: lectura pública (precios); escritura solo admin
create policy plans_select_public on public.plans
  for select using (true);

create policy plans_admin_all on public.plans
  for all using (public.is_admin()) with check (public.is_admin());

-- subscriptions: lectura de la propia; escrituras SOLO vía Edge Function (service_role)
create policy subscriptions_select_own on public.subscriptions
  for select using (auth.uid() = user_id or public.is_admin());

-- courses/modules: lectura pública (estructura del curso)
create policy courses_select_public on public.courses
  for select using (active);

create policy modules_select_public on public.modules
  for select using (true);

-- lessons: lectura pública si es free, o si el usuario es premium; escritura solo admin
create policy lessons_select_access on public.lessons
  for select using (active and (is_free or public.is_premium() or public.is_admin()));

create policy lessons_admin_all on public.lessons
  for all using (public.is_admin()) with check (public.is_admin());

-- quizzes/questions/answers: acceso si el usuario puede ver la lección del quiz
create policy quizzes_select_access on public.quizzes
  for select using (
    public.is_admin()
    or exists (
      select 1 from public.lessons l
      where l.id = quizzes.lesson_id and (l.is_free or public.is_premium())
    )
  );

create policy questions_select_access on public.questions
  for select using (
    public.is_admin()
    or exists (
      select 1 from public.quizzes q
      join public.lessons l on l.id = q.lesson_id
      where q.id = questions.quiz_id and (l.is_free or public.is_premium())
    )
  );

create policy answers_select_access on public.answers
  for select using (
    public.is_admin()
    or exists (
      select 1 from public.questions q
      join public.quizzes qu on qu.id = q.quiz_id
      join public.lessons l on l.id = qu.lesson_id
      where q.id = answers.question_id and (l.is_free or public.is_premium())
    )
  );

-- lesson_progress: solo el propio usuario
create policy lesson_progress_select_own on public.lesson_progress
  for select using (auth.uid() = user_id);

create policy lesson_progress_insert_own on public.lesson_progress
  for insert with check (auth.uid() = user_id);

create policy lesson_progress_update_own on public.lesson_progress
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- events: insert del propio, select del propio (admin todo)
create policy events_select_own on public.events
  for select using (auth.uid() = user_id or public.is_admin());

create policy events_insert_own on public.events
  for insert with check (auth.uid() = user_id or public.is_admin());

-- ----------------------------------------------------------------------------
-- 6. Seed: planes
-- ----------------------------------------------------------------------------

insert into public.plans (name, price, currency, interval) values
  ('FREE',    0.00,   'USD', 'month'),
  ('PREMIUM', 9.99,   'USD', 'month')
on conflict (name) do nothing;