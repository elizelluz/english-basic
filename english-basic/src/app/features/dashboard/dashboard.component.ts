import { Component, computed, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { SupabaseService } from '../../core/services/supabase.service';

interface CourseRow {
  id: number;
}

interface ModuleRow {
  id: number;
  title: string;
  description: string | null;
  order: number;
}

interface LessonRow {
  id: number;
  module_id: number;
  title: string;
  description: string | null;
  is_free: boolean;
  order: number;
}

interface ProgressRow {
  lesson_id: number;
  completed: boolean;
}

interface SubscriptionRow {
  status: string;
  current_period_end: string | null;
}

interface EventRow {
  event: string;
  created_at: string;
}

interface LessonState extends LessonRow {
  completed: boolean;
  locked: boolean;
}

interface ModuleCard {
  id: number;
  title: string;
  description: string | null;
  order: number;
  lessons: LessonState[];
  completedCount: number;
  totalCount: number;
}

const EVENT_LABELS: Record<string, string> = {
  lesson_started: 'Lección iniciada',
  lesson_completed: 'Lección completada',
  quiz_completed: 'Quiz completado',
  page_visit: 'Visitó la página',
  signup: 'Creó su cuenta',
  purchase: 'Suscripción Premium',
};

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent {
  private readonly supabase = inject(SupabaseService);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  readonly loading = signal(true);
  readonly noCourse = signal(false);
  readonly premium = signal(false);
  readonly modules = signal<ModuleCard[]>([]);
  readonly progressPercent = signal<number | null>(null);
  readonly completedVisible = signal(0);
  readonly totalVisible = signal(0);
  readonly started = signal(false);
  readonly activity = signal<EventRow[]>([]);

  readonly userName = computed(() => {
    const user = this.authService.user();
    const fullName = user?.user_metadata?.['full_name'];
    return typeof fullName === 'string' && fullName.trim() ? fullName : (user?.email ?? '');
  });

  constructor() {
    void this.load();
  }

  moduleProgress(module: ModuleCard): string {
    if (module.totalCount === 0) {
      return '—';
    }
    return `${Math.round((module.completedCount / module.totalCount) * 100)}%`;
  }

  eventLabel(event: string): string {
    return EVENT_LABELS[event] ?? event;
  }

  formatDate(iso: string): string {
    const date = new Date(iso);
    if (Number.isNaN(date.getTime())) {
      return '';
    }
    return new Intl.DateTimeFormat('es-ES', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date);
  }

  async onLogout(): Promise<void> {
    await this.authService.signOut();
    await this.router.navigate(['/']);
  }

  private async load(): Promise<void> {
    const user = this.authService.user();
    if (!user) {
      this.loading.set(false);
      return;
    }

    const { data: courseData } = await this.supabase.client
      .from('courses')
      .select('id')
      .eq('active', true)
      .limit(1)
      .single();

    const course = (courseData ?? null) as CourseRow | null;
    if (!course) {
      this.noCourse.set(true);
      this.loading.set(false);
      return;
    }

    const [modulesRes, lessonsRes, progressRes, subscriptionsRes, eventsRes] = await Promise.all([
      this.supabase.client
        .from('modules')
        .select('id, title, description, "order"')
        .eq('course_id', course.id)
        .order('order'),
      this.supabase.client
        .from('lessons')
        .select('id, module_id, title, description, is_free, "order"')
        .eq('active', true)
        .order('order'),
      this.supabase.client
        .from('lesson_progress')
        .select('lesson_id, completed')
        .eq('user_id', user.id),
      this.supabase.client
        .from('subscriptions')
        .select('status, current_period_end')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(1),
      this.supabase.client
        .from('events')
        .select('event, created_at')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(5),
    ]);

    const modules = (modulesRes.data ?? []) as ModuleRow[];
    const lessons = (lessonsRes.data ?? []) as LessonRow[];
    const progress = (progressRes.data ?? []) as ProgressRow[];
    const subscription = (subscriptionsRes.data?.[0] ?? null) as SubscriptionRow | null;
    const events = (eventsRes.data ?? []) as EventRow[];

    this.premium.set(
      subscription !== null &&
        subscription.status === 'active' &&
        (!subscription.current_period_end ||
          new Date(subscription.current_period_end).getTime() > Date.now())
    );

    const visibleIds = new Set(lessons.map((l) => l.id));
    const completedSet = new Set(
      progress.filter((p) => p.completed && visibleIds.has(p.lesson_id)).map((p) => p.lesson_id)
    );

    this.totalVisible.set(lessons.length);
    this.completedVisible.set(completedSet.size);
    this.progressPercent.set(
      lessons.length === 0 ? null : Math.round((completedSet.size / lessons.length) * 100)
    );
    this.started.set(
      progress.length > 0 || events.some((e) => e.event === 'lesson_started' || e.event === 'quiz_completed')
    );

    const isPremium = this.premium();
    const cards: ModuleCard[] = modules.map((m) => {
      const moduleLessons = lessons
        .filter((l) => l.module_id === m.id)
        .sort((a, b) => a.order - b.order)
        .map((l) => ({
          ...l,
          completed: completedSet.has(l.id),
          locked: !l.is_free && !isPremium,
        }));
      return {
        ...m,
        lessons: moduleLessons,
        completedCount: moduleLessons.filter((l) => l.completed).length,
        totalCount: moduleLessons.length,
      };
    });
    this.modules.set(cards);

    this.activity.set(events);
    this.loading.set(false);
  }
}