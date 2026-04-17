package com.joatech.gasmax.webapi.controllers;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
@RestController
public class ImageController {

    // 이미지가 저장된 경로
    private final Path imageFolder = Paths.get("D:\\0.안전관리\\gasmax\\gasmax\\gasmax-web-api\\static\\img");

    @GetMapping("/image/{imageName}")
    public ResponseEntity<Resource> getImage(@PathVariable String imageName) throws IOException {
        // 이미지 파일의 경로 생성
        Path imagePath = imageFolder.resolve(imageName).normalize();
        Resource resource = new UrlResource(imagePath.toUri());

        // 파일이 존재하지 않으면 404 오류 반환
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }

        // 이미지 반환 (Content-Type 설정)
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG)  // 이미지 타입 설정 (여기서는 JPEG로 설정)
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

}
