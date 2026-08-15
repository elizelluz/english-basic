import { Component, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { SupabaseService } from '../../core/services/supabase.service';

interface VocabularyItem {
  en: string;
  es: string;
}

interface GrammarItem {
  en: string;
  es: string;
  note?: string;
}

interface ExampleItem {
  en: string;
  es: string;
}

interface PracticeItem {
  instruction: string;
  answer: string;
}

interface LessonContent {
  vocabulary?: VocabularyItem[];
  grammar?: GrammarItem[];
  examples?: ExampleItem[];
  practice?: PracticeItem[];
}

interface QuizMeta {
  id: number;
  title: string;
}

interface LessonRow {
  id: number;
  module_id: number;
  title: string;
  description: string | null;
  content: LessonContent | null;
  audio_url: string | null;
  is_free: boolean;
  order: number;
  quizzes: QuizMeta[] | null;
}

@Component({
  selector: 'app-lesson',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './lesson.component.html',
  styleUrl: './lesson.component.scss',
})
export class LessonComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly supabase = inject(SupabaseService);
  private readonly authService = inject(AuthService);

  readonly lessonId = Number(this.route.snapshot.paramMap.get('lessonId'));

  readonly lesson = signal<LessonRow | null>(null);
  readonly moduleTitle = signal<string | null>(null);
  readonly locked = signal(false);
  readonly loading = signal(true);
  readonly completed = signal(false);
  readonly marking = signal(false);
  readonly revealed = signal<Set<number>>(new Set());

  readonly quizId = computed(() => this.lesson()?.quizzes?.[0]?.id ?? null);

  constructor() {
    void this.load();
  }

  reveal(index: number): void {
    const next = new Set(this.revealed());
    next.add(index);
    this.revealed.set(next);
  }

  async markComplete(): Promise<void> {
    const user = this.authService.user();
    const lesson = this.lesson();
    if (!user || !lesson || this.marking()) {
      return;
    }
    this.marking.set(true);
    const { error } = await this.supabase.client
      .from('lesson_progress')
      .upsert(
        {
          user_id: user.id,
          lesson_id: lesson.id,
          completed: true,
          completed_at: new Date().toISOString(),
        },
        { onConflict: 'user_id,lesson_id' }
      );
    if (!error) {
      this.completed.set(true);
    }
    this.marking.set(false);
  }

  private async load(): Promise<void> {
    const lessonId = this.lessonId;
    if (!Number.isFinite(lessonId)) {
      this.locked.set(true);
      this.loading.set(false);
      return;
    }

    const { data: lessonData, error: lessonError } = await this.supabase.client
      .from('lessons')
      .select('id, module_id, title, description, content, audio_url, is_free, "order", quizzes(*)')
      .eq('id', lessonId)
      .single();

    if (lessonError || !lessonData) {
      this.locked.set(true);
      this.loading.set(false);
      return;
    }
    this.lesson.set(lessonData as LessonRow);
    this.loading.set(false);

    void this.loadModuleTitle(lessonData.module_id);
    void this.loadProgress(lessonId);
    void this.logEvent(lessonId);
  }

  private async loadModuleTitle(moduleId: number): Promise<void> {
    const { data } = await this.supabase.client
      .from('modules')
      .select('title')
      .eq('id', moduleId)
      .single();
    if (data) {
      this.moduleTitle.set(data.title);
    }
  }

  private async loadProgress(lessonId: number): Promise<void> {
    const user = this.authService.user();
    if (!user) {
      return;
    }
    const { data } = await this.supabase.client
      .from('lesson_progress')
      .select('completed')
      .eq('user_id', user.id)
      .eq('lesson_id', lessonId)
      .maybeSingle();
    if (data) {
      this.completed.set(data.completed);
    }
  }

  private async logEvent(lessonId: number): Promise<void> {
    const user = this.authService.user();
    // Best-effort analytics: a failing insert must never break the lesson UX.
    await this.supabase.client
      .from('events')
      .insert({ user_id: user?.id ?? null, event: 'lesson_started', payload: { lesson_id: lessonId } });
  }
}