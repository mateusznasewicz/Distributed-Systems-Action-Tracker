import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Tutorial } from '../models/tutorial.model';
import { ConfigService } from './config.service';
import { AuthService } from './auth.service';


@Injectable({
  providedIn: 'root',
})
export class TutorialService {
  constructor(private http: HttpClient, private configService: ConfigService, private authService: AuthService) {}

  private get baseUrl() {
    return "/api";
  }

  getComments(tutorialId: any): Observable<any> {
    return this.http.get(`${this.baseUrl}/${tutorialId}/comments`);
  }

  createComment(tutorialId: any, content: string): Observable<any> {
    const data = { content: content };
    return this.http.post(`${this.baseUrl}/${tutorialId}/comments`, data);
  }

  getImage(id: any): Observable<Blob> {
    const url = `${this.baseUrl}/${id}/image`;
  
    return this.http.get(url, { responseType: 'blob' });
  }

  upload(file: File, id: number): Observable<any> {
    const formData: FormData = new FormData();
    formData.append('file', file);
    
    const url = `${this.baseUrl}/${id}/image`;

    return this.http.post(url, formData);
  }

  getAll(): Observable<Tutorial[]> {
    const username = this.authService.username!;
    return this.http.get<Tutorial[]>(this.baseUrl, {
      params: { username: username }
    });
  }

  get(id: any): Observable<Tutorial> {
    return this.http.get<Tutorial>(`${this.baseUrl}/${id}`);
  }

  create(data: any): Observable<any> {
    return this.http.post(this.baseUrl, data);
  }

  update(id: any, data: any): Observable<any> {
    return this.http.put(`${this.baseUrl}/${id}`, data);
  }

  delete(id: any): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }

  deleteAll(): Observable<any> {
    return this.http.delete(this.baseUrl);
  }

  findByTitle(title: any): Observable<Tutorial[]> {
    return this.http.get<Tutorial[]>(`${this.baseUrl}?title=${title}`);
  }
}
