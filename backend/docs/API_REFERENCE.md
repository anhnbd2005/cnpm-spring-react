# Tài Liệu Tham Khảo API - Hệ Thống Quản Lý Dân Cư

> **Đồ án Công Nghệ Phần Mềm**  
> Phiên bản: 1.0  
> Cập nhật: Tháng 11/2024

---

## Mục Lục

1. [Tổng Quan](#1-tổng-quan)
2. [Xác Thực và Phân Quyền](#2-xác-thực-và-phân-quyền)
3. [API Quản Lý Nhân Khẩu](#3-api-quản-lý-nhân-khẩu)
4. [API Quản Lý Hộ Khẩu](#4-api-quản-lý-hộ-khẩu)
5. [API Quản Lý Đợt Thu Phí](#5-api-quản-lý-đợt-thu-phí)
6. [API Thu Phí Hộ Khẩu](#6-api-thu-phí-hộ-khẩu)
7. [API Quản Lý Tài Khoản](#7-api-quản-lý-tài-khoản)
8. [Xử Lý Lỗi và Mã Trạng Thái](#8-xử-lý-lỗi-và-mã-trạng-thái)

---

## 1. Tổng Quan

### 1.1 Thông Tin Cơ Bản

**Base URL:** `http://localhost:8080/api`

**Công nghệ:** RESTful API sử dụng Spring Boot 3.3.5

**Định dạng dữ liệu:** JSON (UTF-8)

**Xác thực:** JWT (JSON Web Token) với thời hạn 24 giờ

### 1.2 Nguyên Tắc Thiết Kế

Hệ thống API tuân thủ các nguyên tắc RESTful:
- **Stateless**: Mỗi request độc lập, không lưu trữ session
- **Resource-based**: Mỗi endpoint đại diện cho một tài nguyên
- **HTTP Methods**: GET (truy vấn), POST (tạo mới), PUT (cập nhật), DELETE (xóa)
- **Status Codes**: Sử dụng mã HTTP chuẩn để thông báo kết quả

---

## 2. Xác Thực và Phân Quyền

### 2.1 Đăng Ký Tài Khoản

**Endpoint:** `POST /api/auth/register`

**Mô tả:** Tạo tài khoản người dùng mới trong hệ thống

**Dữ liệu đầu vào:**

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|----------|-------|
| tenDangNhap | String | ✓ | Tên đăng nhập (tối thiểu 3 ký tự, duy nhất) |
| matKhau | String | ✓ | Mật khẩu (tối thiểu 6 ký tự) |
| hoTen | String | ✓ | Họ và tên người dùng |
| email | String | ✓ | Địa chỉ email hợp lệ |
| role | Enum | ✓ | Vai trò: ADMIN, TOTRUONG, KETOAN |

**Kết quả:**
- **201 Created**: Đăng ký thành công
- **400 Bad Request**: Tên đăng nhập đã tồn tại hoặc dữ liệu không hợp lệ

---

### 2.2 Đăng Nhập

**Endpoint:** `POST /api/auth/login`

**Mô tả:** Xác thực người dùng và cấp JWT token

**Dữ liệu đầu vào:**

| Trường | Kiểu | Mô tả |
|--------|------|-------|
| tenDangNhap | String | Tên đăng nhập |
| matKhau | String | Mật khẩu |

**Kết quả:**
- **200 OK**: Đăng nhập thành công, trả về token và thông tin người dùng
- **400 Bad Request**: Sai tên đăng nhập hoặc mật khẩu

**Lưu ý:** Token nhận được phải được gửi kèm trong header `Authorization: Bearer {token}` cho các request tiếp theo.

---

### 2.3 Ma Trận Phân Quyền

| Chức năng | ADMIN | TOTRUONG | KETOAN |
|-----------|-------|----------|---------|
| **Quản lý nhân khẩu** | Toàn quyền | Toàn quyền | Chỉ xem |
| **Quản lý hộ khẩu** | Toàn quyền | Toàn quyền | Chỉ xem |
| **Quản lý đợt thu phí** | Toàn quyền | Toàn quyền | Chỉ xem |
| **Thu phí hộ khẩu** | Toàn quyền | Chỉ xem | Toàn quyền |
| **Quản lý tài khoản** | Toàn quyền | Không | Không |

---

## 3. API Quản Lý Nhân Khẩu

### 3.1 Tổng Quan Chức Năng

Module nhân khẩu cung cấp các chức năng quản lý thông tin cá nhân của công dân, bao gồm:
- Thêm, sửa, xóa, tra cứu thông tin nhân khẩu
- Đăng ký tạm trú, tạm vắng
- Khai tử
- Thống kê theo giới tính, độ tuổi

### 3.2 Danh Sách Endpoints

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| GET | `/api/nhan-khau` | Lấy danh sách tất cả nhân khẩu | ALL |
| GET | `/api/nhan-khau/{id}` | Lấy thông tin chi tiết một nhân khẩu | ALL |
| POST | `/api/nhan-khau` | Thêm nhân khẩu mới | ADMIN, TOTRUONG |
| PUT | `/api/nhan-khau/{id}` | Cập nhật thông tin nhân khẩu | ADMIN, TOTRUONG |
| DELETE | `/api/nhan-khau/{id}` | Xóa nhân khẩu | ADMIN, TOTRUONG |
| PUT | `/api/nhan-khau/{id}/tamtru` | Đăng ký tạm trú | ADMIN, TOTRUONG |
| DELETE | `/api/nhan-khau/{id}/tamtru` | Hủy tạm trú | ADMIN, TOTRUONG |
| PUT | `/api/nhan-khau/{id}/tamvang` | Đăng ký tạm vắng | ADMIN, TOTRUONG |
| DELETE | `/api/nhan-khau/{id}/tamvang` | Hủy tạm vắng | ADMIN, TOTRUONG |
| PUT | `/api/nhan-khau/{id}/khaitu` | Khai tử | ADMIN, TOTRUONG |
| GET | `/api/nhan-khau/search?q={keyword}` | Tìm kiếm theo tên | ALL |
| GET | `/api/nhan-khau/stats/gender` | Thống kê theo giới tính | ALL |
| GET | `/api/nhan-khau/stats/age` | Thống kê theo độ tuổi | ALL |

### 3.3 Cấu Trúc Dữ Liệu Nhân Khẩu

**Thông tin cơ bản:**
- Họ và tên, ngày sinh, giới tính
- Dân tộc, quốc tịch, nghề nghiệp
- CMND/CCCD, ngày cấp, nơi cấp
- Quan hệ với chủ hộ

**Thông tin đăng ký:**
- Tạm trú: ngày bắt đầu, ngày kết thúc, lý do
- Tạm vắng: ngày bắt đầu, ngày kết thúc, lý do
- Khai tử: ngày khai tử, lý do

### 3.4 Quy Tắc Validation

- **Họ tên, giới tính, ngày sinh, hộ khẩu**: Bắt buộc
- **Ngày sinh**: Phải là quá khứ hoặc hiện tại
- **Giới tính**: Nam, Nữ, hoặc Khác
- **CMND/CCCD**: 
  - Không bắt buộc nếu tuổi < 14
  - Bắt buộc nếu tuổi ≥ 14

---

## 4. API Quản Lý Hộ Khẩu

### 4.1 Tổng Quan Chức Năng

Module hộ khẩu quản lý thông tin các hộ gia đình, bao gồm:
- Thêm, sửa, xóa, tra cứu thông tin hộ khẩu
- Quản lý danh sách thành viên trong hộ
- Tự động cập nhật số lượng thành viên

### 4.2 Danh Sách Endpoints

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| GET | `/api/ho-khau` | Lấy danh sách tất cả hộ khẩu | ALL |
| GET | `/api/ho-khau/{id}` | Lấy thông tin chi tiết một hộ khẩu | ALL |
| POST | `/api/ho-khau` | Thêm hộ khẩu mới | ADMIN, TOTRUONG |
| PUT | `/api/ho-khau/{id}` | Cập nhật thông tin hộ khẩu | ADMIN, TOTRUONG |
| DELETE | `/api/ho-khau/{id}` | Xóa hộ khẩu | ADMIN, TOTRUONG |

### 4.3 Cấu Trúc Dữ Liệu Hộ Khẩu

- Số hộ khẩu (duy nhất)
- Tên chủ hộ
- Địa chỉ thường trú
- Số lượng thành viên (tự động tính)
- Danh sách thành viên

### 4.4 Quy Tắc Validation

- **Số hộ khẩu**: Bắt buộc, duy nhất
- **Tên chủ hộ**: Bắt buộc
- **Địa chỉ thường trú**: Bắt buộc

### 4.5 Hành Vi Tự Động

- **Khi tạo hộ khẩu mới**: Hệ thống tự động tạo bản ghi thu phí cho đợt thu phí gần nhất
- **Khi xóa hộ khẩu**: Tất cả nhân khẩu và bản ghi thu phí liên quan sẽ bị xóa

---

## 5. API Quản Lý Đợt Thu Phí

### 5.1 Tổng Quan Chức Năng

Module đợt thu phí quản lý các kỳ thu phí, bao gồm:
- Tạo, sửa, xóa, tra cứu đợt thu phí
- Phân biệt phí bắt buộc và phí tự nguyện
- Thiết lập định mức và thời gian thu phí

### 5.2 Danh Sách Endpoints

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| GET | `/api/dot-thu-phi` | Lấy danh sách tất cả đợt thu phí | ALL |
| GET | `/api/dot-thu-phi/{id}` | Lấy thông tin chi tiết một đợt thu phí | ALL |
| POST | `/api/dot-thu-phi` | Tạo đợt thu phí mới | ADMIN, KETOAN |
| PUT | `/api/dot-thu-phi/{id}` | Cập nhật đợt thu phí | ADMIN, KETOAN |
| DELETE | `/api/dot-thu-phi/{id}` | Xóa đợt thu phí | ADMIN, KETOAN |

### 5.3 Cấu Trúc Dữ Liệu Đợt Thu Phí

- Tên đợt thu phí
- Loại phí: BAT_BUOC (bắt buộc) hoặc TU_NGUYEN (tự nguyện)
- Ngày bắt đầu, ngày kết thúc
- Định mức (VND/người/tháng)
- Thông tin người tạo và thời gian tạo

### 5.4 Phân Loại Phí

**Phí Bắt Buộc (BAT_BUOC):**
- Yêu cầu định mức > 0
- Tự động tính phí cho mọi hộ khẩu
- Tình trạng: CHUA_NOP hoặc DA_NOP
- Tự động tính lại khi số lượng thành viên hộ thay đổi

**Phí Tự Nguyện (TU_NGUYEN):**
- Định mức mặc định = 0
- Không tự động tính phí
- Tình trạng: KHONG_AP_DUNG
- Không tự động tính lại

---

## 6. API Thu Phí Hộ Khẩu

### 6.1 Tổng Quan Chức Năng

Module thu phí hộ khẩu quản lý việc ghi nhận các khoản thanh toán, bao gồm:
- Ghi nhận thanh toán từng hộ khẩu
- Tính toán tự động số tiền phải nộp
- Hỗ trợ thanh toán nhiều lần
- Thống kê tình trạng thu phí

### 6.2 Danh Sách Endpoints

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| GET | `/api/thu-phi-ho-khau` | Lấy danh sách tất cả bản ghi thu phí | ALL |
| GET | `/api/thu-phi-ho-khau/{id}` | Lấy thông tin chi tiết một bản ghi | ALL |
| GET | `/api/thu-phi-ho-khau/ho-khau/{id}` | Lấy lịch sử thu phí của một hộ khẩu | ALL |
| GET | `/api/thu-phi-ho-khau/dot-thu-phi/{id}` | Lấy danh sách thu phí của một đợt | ALL |
| GET | `/api/thu-phi-ho-khau/calc` | Tính toán phí cho hộ khẩu | ALL |
| GET | `/api/thu-phi-ho-khau/stats` | Thống kê tổng quan | ALL |
| POST | `/api/thu-phi-ho-khau` | Ghi nhận thanh toán mới | ADMIN, KETOAN |
| PUT | `/api/thu-phi-ho-khau/{id}` | Cập nhật thông tin thanh toán | ADMIN, KETOAN |
| DELETE | `/api/thu-phi-ho-khau/{id}` | Xóa bản ghi thanh toán | ADMIN, KETOAN |

### 6.3 Cấu Trúc Dữ Liệu Thu Phí

- Hộ khẩu (tham chiếu)
- Đợt thu phí (tham chiếu)
- Số người (tự động tính)
- Tổng phí (tự động tính)
- Số tiền đã thu (người dùng nhập)
- Trạng thái: CHUA_NOP, DA_NOP, KHONG_AP_DUNG
- Ngày thu, ghi chú
- Người thu (tự động ghi nhận)

### 6.4 Công Thức Tính Phí

```
Tổng phí = Định mức × 12 tháng × Số người đủ điều kiện
```

**Lưu ý:** Chỉ tính những người đang thường trú (không bao gồm người đang tạm vắng)

### 6.5 Quy Tắc Validation

- **Hộ khẩu và đợt thu phí**: Bắt buộc
- **Số tiền đã thu**: Bắt buộc, ≥ 0
- **Ngày thu**: Phải nằm trong khoảng thời gian của đợt thu phí

### 6.6 Tính Năng Thanh Toán Nhiều Lần

Hệ thống hỗ trợ thanh toán từng phần:
- Một hộ có thể thanh toán nhiều lần cho cùng một đợt thu phí
- Tổng số tiền đã thu = tổng các lần thanh toán
- Trạng thái được cập nhật đồng bộ cho tất cả bản ghi liên quan

**Ví dụ:**
- Tổng phí: 288,000 VND
- Lần 1: Nộp 100,000 VND → Trạng thái: CHUA_NOP
- Lần 2: Nộp 188,000 VND → Tổng đã thu: 288,000 VND → Trạng thái: DA_NOP (cả 2 bản ghi)

---

## 7. API Quản Lý Tài Khoản

### 7.1 Tổng Quan Chức Năng

Module tài khoản cho phép quản trị viên quản lý người dùng hệ thống.

### 7.2 Danh Sách Endpoints

| Method | Endpoint | Mô tả | Phân quyền |
|--------|----------|-------|------------|
| GET | `/api/tai-khoan` | Lấy danh sách tất cả tài khoản | ADMIN |
| DELETE | `/api/tai-khoan/{id}` | Xóa tài khoản | ADMIN |

### 7.3 Quy Tắc Xóa Tài Khoản

- Không được xóa tài khoản ADMIN
- Không được xóa tài khoản của chính mình

---

## 8. Xử Lý Lỗi và Mã Trạng Thái

### 8.1 Mã Trạng Thái HTTP

| Mã | Ý nghĩa | Khi nào sử dụng |
|----|---------|-----------------|
| 200 | OK | Thao tác GET, PUT, DELETE thành công |
| 201 | Created | Tạo mới thành công (POST) |
| 204 | No Content | Xóa thành công, không trả về dữ liệu |
| 400 | Bad Request | Dữ liệu không hợp lệ, vi phạm quy tắc nghiệp vụ |
| 401 | Unauthorized | Thiếu hoặc JWT token không hợp lệ |
| 403 | Forbidden | Không có quyền thực hiện thao tác |
| 404 | Not Found | Không tìm thấy tài nguyên |
| 500 | Internal Server Error | Lỗi không xác định từ server |

### 8.2 Định Dạng Thông Báo Lỗi

Tất cả các lỗi được trả về theo cấu trúc JSON chuẩn:

```json
{
  "timestamp": "2025-01-15T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Thông báo lỗi cụ thể bằng tiếng Việt",
  "path": "/api/thu-phi-ho-khau"
}
```

### 8.3 Các Lỗi Thường Gặp

**Lỗi xác thực dữ liệu:**
- Dữ liệu không hợp lệ
- Trường bắt buộc không được để trống
- Giá trị phải lớn hơn 0

**Lỗi phân quyền:**
- Không có quyền thực hiện thao tác
- Chỉ ADMIN mới có thể thực hiện

**Lỗi nghiệp vụ:**
- Ngày thu phải nằm trong khoảng thời gian đợt thu phí
- Tên đăng nhập đã tồn tại
- Số hộ khẩu đã tồn tại

**Lỗi không tìm thấy:**
- Không tìm thấy tài nguyên với ID đã cho

---

## Kết Luận

Tài liệu này cung cấp mô tả đầy đủ về các API endpoint của hệ thống Quản Lý Dân Cư. Mỗi API được thiết kế theo nguyên tắc RESTful, đảm bảo tính nhất quán, bảo mật và dễ sử dụng. Hệ thống phân quyền rõ ràng giúp đảm bảo chỉ những người dùng có thẩm quyền mới có thể thực hiện các thao tác nhạy cảm.

**Lưu ý khi sử dụng:**
- Luôn gửi kèm JWT token trong header Authorization
- Kiểm tra mã trạng thái HTTP để xác định kết quả
- Xử lý các trường hợp lỗi một cách thích hợp
- Tuân thủ các quy tắc validation để tránh lỗi

---

**Hết tài liệu API Reference**
