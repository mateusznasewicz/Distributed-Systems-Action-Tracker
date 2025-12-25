import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../services/auth.service';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  template: `
    <h2>Rejestracja</h2>
    <form (ngSubmit)="register()">
      <input type="text" placeholder="Username" [(ngModel)]="username" name="username" />
      <input type="password" placeholder="Hasło" [(ngModel)]="password" name="password" />
      <button type="submit">Zarejestruj</button>
    </form>
    <p *ngIf="errorMessage" style="color:red">{{ errorMessage }}</p>

    <p>Masz konto? 
      <button routerLink="/login">Zaloguj się</button>
    </p>
  `
})
export class RegisterComponent {
  username = '';
  password = '';
  errorMessage = '';

  constructor(private authService: AuthService, private router: Router) {}

  register() {
    this.errorMessage = '';
    this.authService.register(this.username, this.password)
      .then(() => {
        console.log('Użytkownik zarejestrowany');
        this.router.navigate(['/login']);
      })
      .catch(err => {
        console.error('Błąd rejestracji', err);
        this.errorMessage = err.message || 'Błąd rejestracji';
      });
  }
}
