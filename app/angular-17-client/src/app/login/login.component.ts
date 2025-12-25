import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../services/auth.service';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  template: `
  <h2>Login</h2>
  <form (ngSubmit)="login()">
  <input type="text" placeholder="Nazwa użytkownika" [(ngModel)]="username" name="username" />
  <input type="password" placeholder="Hasło" [(ngModel)]="password" name="password" />
  <button type="submit">Zaloguj</button>
  </form>

  <p>Nie masz konta? 
    <button routerLink="/register">Zarejestruj się</button>
  </p>
  `
})
export class LoginComponent {
  username = '';
  password = '';

  constructor(private authService: AuthService, private router: Router) {}

  login() {
    this.authService.login(this.username, this.password)
    .then(() => this.router.navigate(['/']))
    .catch(err => console.error('Błąd logowania', err));
  }
}