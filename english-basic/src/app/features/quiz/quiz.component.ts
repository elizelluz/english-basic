import { Component, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { SupabaseService } from '../../core/services/supabase.service';

type QuestionType = 'multiple_choice' | 'true_false' | 'fill_blank';

interface AnswerRow {
  id: number;
  answer: string;
  is_correct: boolean;
  order: number;
}

interface QuestionRow {
  id: number;
  question: string;
  type: QuestionType;
  order: number;
  answers: AnswerRow[];
}

interface QuizRow {
  id: number;
  title: string;
}

@Component({
  selector: 'app-quiz',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './quiz.component.html',
  styleUrl: './quiz.component.scss',
})
export class QuizComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly supabase = inject(SupabaseService);
  private readonly authService = inject(AuthService);

  readonly lessonId = Number(this.route.snapshot.paramMap.get('lessonId'));

  readonly loading = signal(true);
  readonly locked = signal(false);
  readonly quiz = signal<QuizRow | null>(null);
  readonly lessonTitle = signal<string | null>(null);
  readonly questions = signal<QuestionRow[]>([]);

  readonly index = signal(0);
  readonly selectedAnswerId = signal<number | null>(null);
  readonly fillAnswer = signal('');
  readonly answered = signal(false);
  readonly correct = signal(false);
  readonly score = signal(0);
  readonly finished = signal(false);
  readonly saving = signal(false);

  readonly currentQuestion = computed<QuestionRow | null>(() => {
    const list = this.questions();
    const i = this.index();
    return list.length > 0 && i >= 0 && i < list.length ? list[i] : null;
  });

  readonly total = computed(() => this.questions().length);
  readonly currentNumber = computed(() => Math.min(this.index() + 1, this.total()));
  readonly progressPercent = computed(() =>
    this.total() === 0 ? 0 : Math.round((this.currentNumber() / this.total()) * 100)
  );
  readonly finalPercent = computed(() =>
    this.total() === 0 ? 0 : Math.round((this.score() / this.total()) * 100)
  );

  constructor() {
    void this.load();
  }

  selectAnswer(answerId: number): void {
    if (this.answered()) {
      return;
    }
    const question = this.currentQuestion();
    if (!question) {
      return;
    }
    const chosen = question.answers.find((a) => a.id === answerId);
    if (!chosen) {
      return;
    }
    this.selectedAnswerId.set(answerId);
    this.answered.set(true);
    this.correct.set(chosen.is_correct);
    if (chosen.is_correct) {
      this.score.set(this.score() + 1);
    }
  }

  checkFillBlank(): void {
    if (this.answered()) {
      return;
    }
    const question = this.currentQuestion();
    if (!question) {
      return;
    }
    const correctAnswer = question.answers.find((a) => a.is_correct)?.answer ?? '';
    const ok = this.normalize(this.fillAnswer()) === this.normalize(correctAnswer);
    this.answered.set(true);
    this.correct.set(ok);
    if (ok) {
      this.score.set(this.score() + 1);
    }
  }

  next(): void {
    if (this.index() + 1 >= this.total()) {
      void this.finish();
      return;
    }
    this.index.set(this.index() + 1);
    this.selectedAnswerId.set(null);
    this.fillAnswer.set('');
    this.answered.set(false);
    this.correct.set(false);
  }

  restart(): void {
    this.index.set(0);
    this.selectedAnswerId.set(null);
    this.fillAnswer.set('');
    this.answered.set(false);
    this.correct.set(false);
    this.score.set(0);
    this.finished.set(false);
  }

  isAnswerCorrect(answer: AnswerRow): boolean {
    return this.answered() && answer.is_correct;
  }

  isAnswerWrong(answer: AnswerRow): boolean {
    return this.answered() && !answer.is_correct && this.selectedAnswerId() === answer.id;
  }

  fillCorrectAnswer(): string {
    return this.currentQuestion()?.answers.find((a) => a.is_correct)?.answer ?? '';
  }

  correctAnswerText(question: QuestionRow): string {
    return question.answers.find((a) => a.is_correct)?.answer ?? '';
  }

  private normalize(value: string): string {
    return value
      .trim()
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');
  }

  private async finish(): Promise<void> {
    this.finished.set(true);
    const user = this.authService.user();
    const quiz = this.quiz();
    const percent = this.finalPercent();
    if (!user || !quiz) {
      return;
    }
    this.saving.set(true);
    // completed se marca true solo con >= 70% (aprobado); si no, se guarda el score.
    await this.supabase.client
      .from('lesson_progress')
      .upsert(
        {
          user_id: user.id,
          lesson_id: this.lessonId,
          completed: percent >= 70,
          score: percent,
          completed_at: new Date().toISOString(),
        },
        { onConflict: 'user_id,lesson_id' }
      );
    // Best-effort analytics: never break the quiz UX on failure.
    await this.supabase.client
      .from('events')
      .insert({ user_id: user.id, event: 'quiz_completed', payload: { quiz_id: quiz.id, score: percent } });
    this.saving.set(false);
  }

  private async load(): Promise<void> {
    const lessonId = this.lessonId;
    if (!Number.isFinite(lessonId)) {
      this.locked.set(true);
      this.loading.set(false);
      return;
    }

    const { data: lessonData } = await this.supabase.client
      .from('lessons')
      .select('title')
      .eq('id', lessonId)
      .single();
    if (!lessonData) {
      this.locked.set(true);
      this.loading.set(false);
      return;
    }
    this.lessonTitle.set(lessonData.title);

    const { data: quizData, error: quizError } = await this.supabase.client
      .from('quizzes')
      .select('id, title')
      .eq('lesson_id', lessonId)
      .single();

    if (quizError || !quizData) {
      this.locked.set(true);
      this.loading.set(false);
      return;
    }
    this.quiz.set(quizData as QuizRow);

    const { data: questionsData, error: questionsError } = await this.supabase.client
      .from('questions')
      .select('id, question, type, "order", answers(*)')
      .eq('quiz_id', quizData.id)
      .order('order');

    if (questionsError || !questionsData) {
      this.locked.set(true);
      this.loading.set(false);
      return;
    }

    const questions = (questionsData ?? []) as QuestionRow[];
    this.questions.set(
      questions
        .map((q) => ({ ...q, answers: [...q.answers].sort((a, b) => a.order - b.order) }))
        .sort((a, b) => a.order - b.order)
    );
    this.loading.set(false);
  }
}