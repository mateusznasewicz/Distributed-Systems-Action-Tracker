import { Component, Input, OnChanges, OnInit, SimpleChanges } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Tutorial } from '../../models/tutorial.model';
import { TutorialService } from '../../services/tutorial.service';
import { DomSanitizer, SafeUrl } from '@angular/platform-browser';

@Component({
  selector: 'app-tutorial-details',
  templateUrl: './tutorial-details.component.html',
  styleUrls: ['./tutorial-details.component.css'],
})
export class TutorialDetailsComponent implements OnChanges {
  @Input() viewMode = false;

  @Input() currentTutorial: Tutorial = {
    title: '',
    description: '',
    published: false
  };

  message = '';
  selectedFile?: File
  imageSource: SafeUrl | null = null;
  isImageLoading = false;
  comments: any[] = [];
  newCommentContent = '';

  constructor(
    private tutorialService: TutorialService,
    private router: Router,
    private sanitizer: DomSanitizer
  ) {}

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['currentTutorial'] && this.currentTutorial.id) {
      this.loadImage();
      this.retrieveComments(this.currentTutorial.id);
    }
  }

  retrieveComments(id: any): void {
    this.tutorialService.getComments(id).subscribe({
      next: (data) => {
        this.comments = data;
      },
      error: (e) => console.error(e)
    });
  }

  addComment(): void {
    if (!this.newCommentContent.trim()) return;

    const tutorialId = this.currentTutorial.id;

    this.tutorialService.createComment(tutorialId, this.newCommentContent).subscribe({
      next: (res) => {
        console.log('Komentarz dodany!');
        this.newCommentContent = ''; 
        this.retrieveComments(tutorialId);
      },
      error: (e) => console.error(e)
    });
  }

  loadImage(): void {
    this.isImageLoading = true;
    this.imageSource = null
    
    this.tutorialService.getImage(this.currentTutorial.id).subscribe({
      next: (data: Blob) => {
        const objectURL = URL.createObjectURL(data);
        this.imageSource = this.sanitizer.bypassSecurityTrustUrl(objectURL);
        this.isImageLoading = false;
        console.log("obrazek pobrany")
      },
      error: (err) => {
        console.log('Nie udało się pobrać obrazka:', err);
        this.isImageLoading = false;
      }
    });
  }

  selectFile(event: any): void {
    this.selectedFile = event.target.files[0];
  }

  upload(): void {
    if (this.selectedFile) {
      this.tutorialService.upload(this.selectedFile!, this.currentTutorial.id).subscribe({
        next: (event: any) => {
          this.message = 'Udało się przesłać plik!';
          this.loadImage();
        },
        error: (err: any) => {
          console.log(err);
          this.message = 'Nie udało się przesłać pliku!';
          this.selectedFile = undefined;
        }
      });
    }
  }

  getTutorial(id: string): void {
    this.tutorialService.get(id).subscribe({
      next: (data) => {
        this.currentTutorial = data;
        console.log(data);
      },
      error: (e) => console.error(e)
    });
  }

  updatePublished(status: boolean): void {
    const data = {
      title: this.currentTutorial.title,
      description: this.currentTutorial.description,
      published: status
    };

    this.message = '';

    this.tutorialService.update(this.currentTutorial.id, data).subscribe({
      next: (res) => {
        console.log(res);
        this.currentTutorial.published = status;
        this.message = res.message
          ? res.message
          : 'The status was updated successfully!';
      },
      error: (e) => console.error(e)
    });
  }

  updateTutorial(): void {
    this.message = '';

    this.tutorialService
      .update(this.currentTutorial.id, this.currentTutorial)
      .subscribe({
        next: (res) => {
          console.log(res);
          this.message = res.message
            ? res.message
            : 'This tutorial was updated successfully!';
        },
        error: (e) => console.error(e)
      });
  }

  deleteTutorial(): void {
    this.tutorialService.delete(this.currentTutorial.id).subscribe({
      next: (res) => {
        console.log(res);
        this.router.navigate(['/tutorials']);
      },
      error: (e) => console.error(e)
    });
  }
}
