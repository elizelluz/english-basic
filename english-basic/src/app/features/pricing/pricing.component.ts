import { Component, computed, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

interface PlanFeature {
  label: string;
  free: boolean;
  premium: boolean;
}

@Component({
  selector: 'app-pricing',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './pricing.component.html',
  styleUrl: './pricing.component.scss',
})
export class PricingComponent {
  private readonly authService = inject(AuthService);
  readonly isAuthenticated = computed(() => this.authService.isAuthenticated());

  readonly features: PlanFeature[] = [
    { label: '3 lecciones de muestra', free: true, premium: true },
    { label: 'Vocabulario básico', free: true, premium: true },
    { label: 'Quiz inicial', free: true, premium: true },
    { label: 'Progreso básico', free: true, premium: true },
    { label: 'Curso completo (4 módulos)', free: false, premium: true },
    { label: 'Ejercicios y quizzes ilimitados', free: false, premium: true },
    { label: 'Audios de pronunciación', free: false, premium: true },
    { label: 'Seguimiento de progreso', free: false, premium: true },
    { label: 'Acceso mientras la suscripción esté activa', free: false, premium: true },
  ];
}