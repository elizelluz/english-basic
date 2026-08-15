import { Component, computed, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

interface Benefit {
  title: string;
  description: string;
  icon: string;
}

interface Step {
  number: string;
  title: string;
  description: string;
}

interface ProgramWeek {
  title: string;
  tag: string;
  topics: string[];
}

interface Testimonial {
  name: string;
  initials: string;
  role: string;
  quote: string;
}

interface Faq {
  question: string;
  answer: string;
}

@Component({
  selector: 'app-landing',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './landing.component.html',
  styleUrl: './landing.component.scss',
})
export class LandingComponent {
  private readonly authService = inject(AuthService);
  readonly isAuthenticated = computed(() => this.authService.isAuthenticated());

  readonly benefits: Benefit[] = [
    {
      title: 'Lecciones cortas',
      description: 'Aprende en bloques de 15 minutos que se adaptan a tu día.',
      icon: 'M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20Zm0-6v-4l3-2',
    },
    {
      title: 'Vocabulario esencial',
      description: 'Las palabras que de verdad usas en situaciones cotidianas.',
      icon: 'M4 19.5A2.5 2.5 0 0 1 6.5 17H20V4H6.5A2.5 2.5 0 0 0 4 6.5v13Zm0 0A2.5 2.5 0 0 0 6.5 22H20v-5',
    },
    {
      title: 'Gramática práctica',
      description: 'Solo la gramática que necesitas para comunicarte, sin teoría eterna.',
      icon: 'M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3Z',
    },
    {
      title: 'Audios de pronunciación',
      description: 'Escucha y repite para sonar natural desde el primer día.',
      icon: 'M11 5 6 9H2v6h4l5 4V5Zm2 3.5a5 5 0 0 1 0 7m4.5-11.5a10 10 0 0 1 0 14',
    },
    {
      title: 'Ejercicios y quizzes',
      description: 'Practica y comprueba lo que aprendes en cada lección.',
      icon: 'M22 11.08V12a10 10 0 1 1-5.93-9.14L22 11.08ZM22 4 12 14.01l-3-3',
    },
    {
      title: 'Progreso visible',
      description: 'Mira tu avance semana a semana y mantén la motivación.',
      icon: 'M23 6 13.5 15.5 8.5 10.5 1 18M17 6h6v6',
    },
  ];

  readonly steps: Step[] = [
    {
      number: '1',
      title: 'Crea tu cuenta gratis',
      description: 'Regístrate en menos de un minuto y accede a tus primeras lecciones.',
    },
    {
      number: '2',
      title: 'Aprende 15 minutos al día',
      description: 'Lecciones cortas, ejercicios y práctica diaria con un método paso a paso.',
    },
    {
      number: '3',
      title: 'Pasa a Premium cuando quieras',
      description: 'Cuando estés listo, desbloquea el curso completo con todos los módulos.',
    },
  ];

  readonly weeks: ProgramWeek[] = [
    {
      title: 'Semana 1 · Supervivencia',
      tag: 'Empezar a hablar',
      topics: ['Saludos', 'Números', 'Verbo to be', 'Frases útiles'],
    },
    {
      title: 'Semana 2 · Vida cotidiana',
      tag: 'Tu día a día',
      topics: ['Familia', 'Comida', 'Rutinas', 'Presente simple'],
    },
    {
      title: 'Semana 3 · Conversación',
      tag: 'Sal a la calle',
      topics: ['Preguntas', 'Compras', 'Restaurantes', 'Direcciones'],
    },
    {
      title: 'Semana 4 · Comunicación',
      tag: 'Suéltate',
      topics: ['Presentarte', 'Tu día', 'Gustos', 'Conversaciones básicas'],
    },
  ];

  readonly testimonials: Testimonial[] = [
    {
      name: 'María, 32',
      initials: 'M',
      role: 'Estudiante principiante',
      quote: 'En un mes ya puedo presentarme y pedir en un restaurante.',
    },
    {
      name: 'Carlos, 41',
      initials: 'C',
      role: 'Retomando el inglés',
      quote: 'Por fin entendí el verbo to be. Me faltaba estructura, no talento.',
    },
    {
      name: 'Lucía, 27',
      initials: 'L',
      role: 'Nivel cero',
      quote: 'Con 15 minutos al día armo frases básicas para el trabajo.',
    },
  ];

  readonly faqs: Faq[] = [
    {
      question: '¿Necesito saber algo de inglés?',
      answer:
        'No. El curso empieza desde cero absoluto: saludar, presentarte y lo básico para comunicarte. No necesitas experiencia previa.',
    },
    {
      question: '¿Cuánto tiempo necesito al día?',
      answer:
        'Con 15 minutos diarios es suficiente. Las lecciones son cortas y están diseñadas para practicar poco, pero todos los días.',
    },
    {
      question: '¿Cómo pago?',
      answer:
        'Con tarjeta de débito o crédito. Los pagos se procesan de forma segura a través de Hotmart.',
    },
    {
      question: '¿Puedo cancelar cuando quiera?',
      answer:
        'Sí. Puedes cancelar tu suscripción en cualquier momento y sigues teniendo acceso hasta el fin del período pagado.',
    },
    {
      question: '¿Qué incluye Premium?',
      answer:
        'Todo el curso: los 4 módulos completos, todas las lecciones, ejercicios, quizzes, audios de pronunciación y seguimiento de tu progreso.',
    },
    {
      question: '¿Funciona en el celular?',
      answer:
        'Sí. La plataforma está diseñada mobile-first y puedes estudiar desde tu celular o tu computadora.',
    },
  ];
}