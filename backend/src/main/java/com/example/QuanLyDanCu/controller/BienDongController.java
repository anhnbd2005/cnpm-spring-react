package com.example.QuanLyDanCu.controller;

import com.example.QuanLyDanCu.entity.BienDong;
import com.example.QuanLyDanCu.service.BienDongService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bien-dong")
@RequiredArgsConstructor
@Tag(name = "Biến Động", description = "API quản lý biến động nhân khẩu")
public class BienDongController {

    private final BienDongService bienDongService;

    // Lấy tất cả biến động
    @GetMapping
    public List<BienDong> getAll() {
        return bienDongService.getAll();  // Gọi phương thức getAll() từ service
    }

    // Tạo mới biến động
    @PostMapping
    public BienDong create(@RequestBody BienDong bienDong, Authentication auth) {
        return bienDongService.create(bienDong, auth);  // Gọi phương thức create() từ service
    }

    // Cập nhật biến động
    @PutMapping("/{id}")
    public BienDong update(@PathVariable Long id, @RequestBody BienDong bienDong, Authentication auth) {
        return bienDongService.update(id, bienDong, auth);  // Gọi phương thức update() từ service
    }

    // Xóa biến động
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id, Authentication auth) {
        bienDongService.delete(id, auth);  // Gọi phương thức delete() từ service
    }
}
