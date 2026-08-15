import { Component, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { SupabaseService } from '../../core/services/supabase.service';

interface Course {
  id: number;
  title: string;
  description: string | null;
}

interface ModuleRow {
  id: number;
  title: string;
  description: string | null;
  order: number;
  lessons: LessonRow[];
}

interface LessonRow {
  id: number;
  module_id: number;
  title: string;
  description: string | null;
  is_free: boolean;
  order: number;
}

@Component({
  selector: 'app-course',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './course.component.html',
  styleUrl: './course.component.scss',
})
export class CourseComponent {
  private readonly supabase = inject(SupabaseService);
  private readonly authService = inject(AuthService);

  readonly course = signal<Course | null>(null);
  readonly modules = signal<ModuleRow[]>([]);
  readonly loading = signal(true);
  readonly empty = signal(false);
  readonly premium = signal(false);
  readonly expanded = signal<Set<number>>(new Set());

  constructor() {
    void this.load();
    void this.loadPremium();
  }

  toggleModule(id: number): void {
    const next = new Set(this.expanded());
    if (next.has(id)) {
      next.delete(id);
    } else {
      next.add(id);
    }
    this.expanded.set(next);
  }

  private async loadPremium(): Promise<void> {
    const user = this.authService.user();
    if (!user) {
      return;
    }
    const { data } = await this.supabase.client
      .from('subscriptions')
      .select('status, current_period_end')
      .eq('user_id', user.id)
      .eq('status', 'active')
      .maybeSingle();
    if (data) {
      const periodEnd = data.current_period_end as string | null;
      this.premium.set(!periodEnd || new Date(periodEnd).getTime() > Date.now());
    }
  }

  private async load(): Promise<void> {
    const { data: courseData } = await this.supabase.client
      .from('courses')
      .select('id, title, description')
      .eq('active', true)
      .limit(1)
      .single();

    if (!courseData) {
      this.empty.set(true);
      this.loading.set(false);
      return;
    }
    this.course.set(courseData as Course);

    const { data: moduleData } = await this.supabase.client
      .from('modules')
      .select('id, title, description, "order"')
      .eq('course_id', courseData.id)
      .order('order');

    const modules = (moduleData ?? []) as ModuleRow[];

    let lessons: LessonRow[] = [];
    const moduleIds = modules.map((m) => m.id);
    if (moduleIds.length > 0) {
      const { data: lessonData } = await this.supabase.client
        .from('lessons')
        .select('id, module_id, title, description, is_free, "order"')
        .in('module_id', moduleIds)
        .eq('active', true)
        .order('order');
      lessons = (lessonData ?? []) as LessonRow[];
    }

    const withLessons: ModuleRow[] = modules.map((m) => ({
      ...m,
      lessons: lessons.filter((l) => l.module_id === m.id).sort((a, b) => a.order - b.order),
    }));

    this.modules.set(withLessons);
    if (withLessons.length > 0) {
      this.expanded.set(new Set([withLessons[0].id]));
    }
    this.loading.set(false);
  }
}