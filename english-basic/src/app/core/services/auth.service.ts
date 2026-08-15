import { Injectable, signal } from '@angular/core';
import { type AuthSession, type AuthUser } from '@supabase/supabase-js';
import { SupabaseService } from './supabase.service';

/**
 * Thin reactive wrapper around Supabase Auth.
 * Exposes the current user/session as signals and reuses the single
 * Supabase client from SupabaseService (anon key only).
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly client;

  readonly user = signal<AuthUser | null>(null);
  readonly session = signal<AuthSession | null>(null);

  constructor(private readonly supabase: SupabaseService) {
    this.client = supabase.client;
    this.client.auth.onAuthStateChange((_event, session) => {
      this.session.set(session);
      this.user.set(session?.user ?? null);
    });
  }

  async signUp(email: string, password: string, fullName: string) {
    return this.client.auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
  }

  async signIn(email: string, password: string) {
    return this.client.auth.signInWithPassword({ email, password });
  }

  async signOut() {
    return this.client.auth.signOut();
  }

  async resetPassword(email: string) {
    return this.client.auth.resetPasswordForEmail(email);
  }

  getSession() {
    return this.client.auth.getSession();
  }

  isAuthenticated(): boolean {
    return this.user() !== null;
  }
}