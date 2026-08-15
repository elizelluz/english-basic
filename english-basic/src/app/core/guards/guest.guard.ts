import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

/**
 * Restricts guest-only routes (login/register/forgot password).
 * Allows access only when there is no session; otherwise redirects to /dashboard.
 */
export const guestGuard: CanActivateFn = async () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const { data } = await authService.getSession();
  if (data.session) {
    return router.createUrlTree(['/dashboard']);
  }
  return true;
};