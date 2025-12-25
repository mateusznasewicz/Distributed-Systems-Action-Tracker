package com.bezkoder.spring.jpa.postgresql.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import com.bezkoder.spring.jpa.postgresql.model.Comment;

import jakarta.transaction.Transactional; // lub javax.transaction.Transactional

public interface CommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findByTutorialId(Long tutorialId);
}