import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { guestGuard } from './core/guards/guest.guard';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./features/landing/landing.component').then((m) => m.LandingComponent),
  },
  {
    path: 'pricing',
    loadComponent: () =>
      import('./features/pricing/pricing.component').then((m) => m.PricingComponent),
  },
  {
    path: 'login',
    loadComponent: () =>
      import('./features/auth/login.component').then((m) => m.LoginComponent),
    canActivate: [guestGuard],
  },
  {
    path: 'registro',
    loadComponent: () =>
      import('./features/auth/register.component').then((m) => m.RegisterComponent),
    canActivate: [guestGuard],
  },
  {
    path: 'recuperar',
    loadComponent: () =>
      import('./features/auth/forgot-password.component').then((m) => m.ForgotPasswordComponent),
    canActivate: [guestGuard],
  },
  {
    path: 'gracias',
    loadComponent: () =>
      import('./features/thanks/thanks.component').then((m) => m.ThanksComponent),
  },
  {
    path: 'dashboard',
    loadComponent: () =>
      import('./features/dashboard/dashboard.component').then((m) => m.DashboardComponent),
    canActivate: [authGuard],
  },
  {
    path: 'curso',
    loadComponent: () =>
      import('./features/course/course.component').then((m) => m.CourseComponent),
    canActivate: [authGuard],
  },
  {
    path: 'curso/:lessonId',
    loadComponent: () =>
      import('./features/lesson/lesson.component').then((m) => m.LessonComponent),
    canActivate: [authGuard],
  },
  {
    path: 'curso/:lessonId/quiz',
    loadComponent: () =>
      import('./features/quiz/quiz.component').then((m) => m.QuizComponent),
    canActivate: [authGuard],
  },
  { path: '**', redirectTo: '' },
];