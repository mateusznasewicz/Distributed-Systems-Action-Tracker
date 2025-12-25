package com.bezkoder.spring.jpa.postgresql.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.bezkoder.spring.jpa.postgresql.model.Comment;
import com.bezkoder.spring.jpa.postgresql.model.Tutorial;
import com.bezkoder.spring.jpa.postgresql.repository.CommentRepository;
import com.bezkoder.spring.jpa.postgresql.repository.TutorialRepository;

@RestController
@RequestMapping("/api")
public class CommentController {

    @Autowired
    private TutorialRepository tutorialRepository;

    @Autowired
    private CommentRepository commentRepository;

    @GetMapping("/tutorials/{id}/comments")
    public ResponseEntity<List<Comment>> getAllCommentsByTutorialId(@PathVariable Long id) {
        if (!tutorialRepository.existsById(id)) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        List<Comment> comments = commentRepository.findByTutorialId(id);
        return new ResponseEntity<>(comments, HttpStatus.OK);
    }

    @PostMapping("/tutorials/{id}/comments")
    public ResponseEntity<Comment> createComment(@PathVariable Long id,
                                                 @RequestBody Comment commentRequest) {
        try {
            Tutorial tutorial = tutorialRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Nie znaleziono tutoriala o id = " + id));

            commentRequest.setTutorial(tutorial);
            Comment comment = commentRepository.save(commentRequest);

            return new ResponseEntity<>(comment, HttpStatus.CREATED);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}