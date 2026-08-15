import { Component, computed, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="landing">
      <h1>English Basic</h1>
      <p>Aprende inglés básico desde cero con lecciones cortas, ejercicios y práctica diaria.</p>
      <nav class="landing-actions">
        @if (isAuthenticated()) {
          <a routerLink="/dashboard">Ir al dashboard</a>
        } @else {
          <a routerLink="/registro">Comenzar gratis</a>
          <a routerLink="/login">Iniciar sesión</a>
        }
        <a routerLink="/pricing">Ver precios</a>
      </nav>
    </section>
  `,
  styles: [
    `
      .landing {
        max-width: 640px;
        margin: 0 auto;
        padding: 4rem 1rem;
        text-align: center;
        font-family: system-ui, sans-serif;
      }
      .landing-actions {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
        margin-top: 2rem;
      }
      a {
        display: inline-block;
        padding: 0.75rem 1.5rem;
        background: #2563eb;
        color: #fff;
        border-radius: 8px;
        text-decoration: none;
      }
      @media (min-width: 480px) {
        .landing-actions {
          flex-direction: row;
          justify-content: center;
        }
      }
    `,
  ],
})
export class LandingComponent {
  private readonly authService = inject(AuthService);
  readonly isAuthenticated = computed(() => this.authService.isAuthenticated());
}