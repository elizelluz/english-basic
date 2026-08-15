import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

/**
 * Protects authenticated routes. Waits for the initial session to resolve,
 * then allows access only when a session exists; otherwise redirects to /login.
 */
export const authGuard: CanActivateFn = async () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const { data } = await authService.getSession();
  if (data.session) {
    return true;
  }
  return router.createUrlTree(['/login']);
};