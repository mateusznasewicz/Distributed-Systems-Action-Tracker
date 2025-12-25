import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CognitoUserPool } from 'amazon-cognito-identity-js';

@Injectable({
  providedIn: 'root',
})
export class ConfigService {
  private config: any;

  constructor(private http: HttpClient) {}

  loadConfig(): Promise<void> {
    return this.http.get('/assets/config.json').toPromise().then((cfg: any) => {
      this.config = cfg;
    });
  }

  get apiUrl(): string {
    return this.config.apiUrl;
  }

  get userPool(): CognitoUserPool {
    return new CognitoUserPool({
      UserPoolId: this.config.userPoolId,
      ClientId: this.config.clientId
    })
  }

}