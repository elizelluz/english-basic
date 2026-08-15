import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss',
})
export class ForgotPasswordComponent {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);

  readonly form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
  });

  errorMessage: string | null = null;
  successMessage: string | null = null;
  loading = false;

  async onSubmit(): Promise<void> {
    if (this.form.invalid) {
      return;
    }
    this.loading = true;
    this.errorMessage = null;
    this.successMessage = null;
    const { email } = this.form.getRawValue();

    const { error } = await this.authService.resetPassword(email);
    this.loading = false;

    if (error) {
      this.errorMessage = error.message;
      return;
    }

    this.successMessage = 'Si el email existe, recibirás un enlace para restablecer tu contraseña';
    this.form.reset();
  }
}