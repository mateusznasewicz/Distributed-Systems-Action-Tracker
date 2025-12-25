package com.bezkoder.spring.jpa.postgresql.controller;

import java.io.IOException;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.logging.Logger;

import com.bezkoder.spring.jpa.postgresql.service.S3Service;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import com.bezkoder.spring.jpa.postgresql.model.Tutorial;
import com.bezkoder.spring.jpa.postgresql.repository.TutorialRepository;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api")
@Slf4j
public class TutorialController {

	@Autowired
	TutorialRepository tutorialRepository;

    @Autowired
    S3Service s3Service;

	@GetMapping("/tutorials")
	public ResponseEntity<List<Tutorial>> getAllTutorials(@RequestParam String username) {
        try {
            List<Tutorial> tutorials;
            if (username == null)
                tutorials = tutorialRepository.findAll();
            else
                tutorials = tutorialRepository.findByUsername(username);

            if (tutorials.isEmpty()) {
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            }

            return new ResponseEntity<>(tutorials, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
	}

	@GetMapping("/tutorials/{id}")
	public ResponseEntity<Tutorial> getTutorialById(@PathVariable("id") long id) {
		Optional<Tutorial> tutorialData = tutorialRepository.findById(id);

		if (tutorialData.isPresent()) {
			return new ResponseEntity<>(tutorialData.get(), HttpStatus.OK);
		} else {
			return new ResponseEntity<>(HttpStatus.NOT_FOUND);
		}
	}

    @GetMapping("/tutorials/{id}/image")
    public ResponseEntity<byte[]> getImage(@PathVariable Long id) {
        Tutorial tutorial = tutorialRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Nie znaleziono tutoriala o id: " + id));

        String key = tutorial.getKey();

        byte[] data = s3Service.downloadFile(key);

        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG)
                .body(data);
    }

	@PostMapping("/tutorials")
	public ResponseEntity<Tutorial> createTutorial(@RequestBody Tutorial tutorial, @AuthenticationPrincipal Jwt jwt) {
		String username = jwt.getClaimAsString("username");
		if(!Objects.equals(username, tutorial.getUsername())) {
            log.info("Otrzymano zapytanie o tutoriale. Uzytkownik w jwt: {}", username);
            return new ResponseEntity<>(null, HttpStatus.FORBIDDEN);
        }

		try {
			Tutorial _tutorial = tutorialRepository
					.save(new Tutorial(tutorial.getTitle(), tutorial.getDescription(), false, username));
			return new ResponseEntity<>(_tutorial, HttpStatus.CREATED);
		} catch (Exception e) {
			return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

    @PostMapping(value = "/tutorials/{id}/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadImageToTutorial(
            @PathVariable("id") long id,
            @RequestParam("file") MultipartFile file
    ) {
        log.info("--> OTRZYMANO REQUEST POST IMAGE. ID: {}, File size: {}", id, file.getSize());
        try {
            Tutorial tutorial = tutorialRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Nie znaleziono tutoriala o id: " + id));

            String key = s3Service.uploadImage(file);

            tutorial.setKey(key);
            tutorialRepository.save(tutorial);

            return ResponseEntity.ok(tutorial);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Błąd podczas wgrywania zdjęcia: " + e.getMessage());
        }
    }

}
