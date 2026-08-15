import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
})
export class LoginComponent {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  readonly form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
  });

  errorMessage: string | null = null;
  loading = false;

  async onSubmit(): Promise<void> {
    if (this.form.invalid) {
      return;
    }
    this.loading = true;
    this.errorMessage = null;
    const { email, password } = this.form.getRawValue();

    const { error } = await this.authService.signIn(email, password);
    this.loading = false;

    if (error) {
      this.errorMessage = 'Email o contraseña incorrectos';
      return;
    }
    await this.router.navigate(['/dashboard']);
  }
}