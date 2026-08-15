import { Component, computed, inject } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent {
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  readonly userName = computed(() => {
    const user = this.authService.user();
    const fullName = user?.user_metadata?.['full_name'];
    return typeof fullName === 'string' && fullName.trim() ? fullName : (user?.email ?? '');
  });

  async onLogout(): Promise<void> {
    await this.authService.signOut();
    await this.router.navigate(['/']);
  }
}