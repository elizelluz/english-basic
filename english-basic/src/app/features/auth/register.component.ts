import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
})
export class RegisterComponent {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  readonly form = this.fb.nonNullable.group({
    fullName: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
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
    const { fullName, email, password } = this.form.getRawValue();

    const { error } = await this.authService.signUp(email, password, fullName);
    this.loading = false;

    if (error) {
      this.errorMessage = error.message;
      return;
    }

    this.successMessage = 'Revisa tu email para confirmar tu cuenta';
    await this.router.navigate(['/login']);
  }
}