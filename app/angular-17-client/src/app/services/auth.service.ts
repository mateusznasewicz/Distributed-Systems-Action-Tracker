import { Injectable } from '@angular/core';
import { OAuthService, AuthConfig } from 'angular-oauth2-oidc';
import { BehaviorSubject, ReplaySubject } from 'rxjs';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  public username$ = new BehaviorSubject<string | null>(null);

  private isDoneLoadingSubject = new ReplaySubject<boolean>(1);
  public isDoneLoading$ = this.isDoneLoadingSubject.asObservable();

  public isAuthenticatedSubject$ = new BehaviorSubject<boolean>(false);
  public isAuthenticated$ = this.isAuthenticatedSubject$.asObservable();

  constructor(private oauthService: OAuthService, private router: Router) {
    this.initAuth();
  }

  private initAuth() {
    const authConfig: AuthConfig = {
      issuer: `${window.location.origin}/auth/realms/todo-app-realm`,
      redirectUri: window.location.origin,
      postLogoutRedirectUri: window.location.origin,
      clientId: 'todo-app-frontend',
      responseType: 'code',
      scope: 'openid profile email',
      showDebugInformation: true,
      requireHttps: false,
    };

    this.oauthService.configure(authConfig);

    this.oauthService.loadDiscoveryDocumentAndTryLogin().then(() => {
      const hasToken = this.oauthService.hasValidAccessToken();

      if (hasToken) {
        this.refreshUser();
      }

      this.isAuthenticatedSubject$.next(hasToken);
      this.isDoneLoadingSubject.next(true);
    });

    this.oauthService.setupAutomaticSilentRefresh();
  }

  login() {
    this.oauthService.initCodeFlow();
  }

  register() {
    this.oauthService.initCodeFlow(undefined, { kc_action: 'register' });
  }

  logout() {
    this.oauthService.logOut();
  }

  private refreshUser(): void {
    const claims = this.oauthService.getIdentityClaims();

    if (claims) {
      const displayName = claims['preferred_username'] || claims['name'] || 'User';
      console.log("claim username: ", displayName);
      this.username$.next(displayName);
    } else {
      this.username$.next(null);
    }

  }

  getAccessToken(): string {
    console.log("hasAccessToken: " + this.oauthService.hasValidAccessToken());
    return this.oauthService.getAccessToken();
  }

  get username(): string {
    return this.username$.value!;
  }

}