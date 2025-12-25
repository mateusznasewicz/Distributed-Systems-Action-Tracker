import { Injectable } from '@angular/core';
import { ConfigService } from './config.service';
import { AuthenticationDetails, CognitoUser } from 'amazon-cognito-identity-js';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  public username$ = new BehaviorSubject<string | null>(null);
  
  constructor(private configService: ConfigService) { 
    const storedUsername = localStorage.getItem('username');
    if (storedUsername) {
      this.username$.next(storedUsername);
    }
  }
  
  login(username: string, password: string): Promise<void> {
    const authDetails = new AuthenticationDetails({
        Username: username,
        Password: password
    });

    const user = new CognitoUser({
      Username: username,
      Pool: this.configService.userPool
    });

    return new Promise((resolve, reject) => {
      user.authenticateUser(authDetails, {
        onSuccess: () => {
          const session = user.getSignInUserSession()!
      
          localStorage.setItem('idToken', session.getIdToken().getJwtToken());
          localStorage.setItem('accessToken', session.getAccessToken().getJwtToken())
          localStorage.setItem('username', user.getUsername());
          this.username$.next(this.username);
          resolve();
        },
        onFailure(err) {
          reject(err);
        },
      })
    });
  }

  register(username: string, password: string): Promise<void> {
    return new Promise((resolve, reject) => {
      this.configService.userPool.signUp(username, password, [], [], (err, result) => {
        if(err) {
          reject(err);
        }else {
          resolve();
        }
      });
    });
  }

  logout() {
    localStorage.clear();
  }
  
  get idToken(): string | null {
    return localStorage.getItem('idToken');
  }

  get accessToken(): string | null {
    return localStorage.getItem('accessToken')
  }

  get username(): string | null {
    return localStorage.getItem('username');
  }
}
