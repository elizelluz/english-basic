import { Component } from '@angular/core';

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [],
  template: `
    <section class="landing">
      <h1>English Basic</h1>
      <p>Aprende inglés básico desde cero con lecciones cortas, ejercicios y práctica diaria.</p>
      <a routerLink="/pricing">Ver precios</a>
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
      a {
        display: inline-block;
        margin-top: 1rem;
        padding: 0.75rem 1.5rem;
        background: #2563eb;
        color: #fff;
        border-radius: 8px;
        text-decoration: none;
      }
    `,
  ],
})
export class LandingComponent {}