package com.bezkoder.spring.jpa.postgresql.service;

import com.bezkoder.spring.jpa.postgresql.repository.TutorialRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class S3Service {

    public String uploadImage(MultipartFile file) throws IOException {
        return "asddsadsa";
    }

    public byte[] downloadFile(String key) {
        return new byte[0];
    }
}
