import { Component, OnInit } from '@angular/core';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit{
  title = 'Angular 17 Crud example';
  username: string | null = ''

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.username$.subscribe(name => {
      this.username = name;
    });
  }

  logout() {
    this.authService.logout();
  }


}
