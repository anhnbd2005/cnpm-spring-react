package com.example.QuanLyDanCu.repository;

import com.example.QuanLyDanCu.entity.HoKhau;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface HoKhauRepository extends JpaRepository<HoKhau, Long> {
    List<HoKhau> findAllByOrderByIdAsc();

    @org.springframework.data.jpa.repository.Query("SELECT h FROM HoKhau h WHERE h.isDeleted = false OR h.isDeleted IS NULL ORDER BY h.id ASC")
    List<HoKhau> findAllByIsDeletedFalseOrderByIdAsc();

    boolean existsBySoHoKhau(String soHoKhau);
}
