import { Component } from '@angular/core';

@Component({
  selector: 'app-pricing',
  standalone: true,
  imports: [],
  template: `
    <section class="pricing">
      <h1>Planes</h1>
      <p>FREE — $0 · 3 lecciones, vocabulario, quiz inicial</p>
      <p>PREMIUM — $9.99/mes · curso completo, ejercicios, audio, quizzes, progreso</p>
    </section>
  `,
  styles: [
    `
      .pricing {
        max-width: 640px;
        margin: 0 auto;
        padding: 4rem 1rem;
        font-family: system-ui, sans-serif;
      }
    `,
  ],
})
export class PricingComponent {}