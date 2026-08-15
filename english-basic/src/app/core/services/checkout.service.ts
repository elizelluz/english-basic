import { Injectable, inject } from '@angular/core';
import { environment } from '../../../environments/environment';
import { AuthService } from './auth.service';

/**
 * Builds the Hotmart checkout URL, pre-filling the logged-in user's email.
 * The checkout URL may already contain its own query string (Hotmart appends
 * tracking params), so the email parameter is joined with '&' when the base
 * URL already has a query and with '?' otherwise.
 */
@Injectable({ providedIn: 'root' })
export class CheckoutService {
  private readonly authService = inject(AuthService);

  getCheckoutUrl(): string {
    const base = environment.hotmartCheckoutUrl;
    const email = this.authService.user()?.email;
    if (!email) {
      return base;
    }
    const separator = base.includes('?') ? '&' : '?';
    return `${base}${separator}email=${encodeURIComponent(email)}`;
  }
}