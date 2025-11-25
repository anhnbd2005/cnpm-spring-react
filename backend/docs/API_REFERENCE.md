# API Reference Documentation

> **Generated from actual backend implementation**  
> Last updated: December 2024  
> Base URL: `http://localhost:8080/api`

---

## Table of Contents

1. [Authentication APIs](#1-authentication-apis)
2. [Nhân Khẩu (Citizen) APIs](#2-nhân-khẩu-citizen-apis)
3. [Hộ Khẩu (Household) APIs](#3-hộ-khẩu-household-apis)
4. [Đợt Thu Phí (Fee Period) APIs](#4-đợt-thu-phí-fee-period-apis)
5. [Thu Phí Hộ Khẩu (Fee Collection) APIs](#5-thu-phí-hộ-khẩu-fee-collection-apis)
6. [Tài Khoản (Account Management) APIs](#6-tài-khoản-account-management-apis)
7. [Common Response Formats](#7-common-response-formats)
8. [Error Handling](#8-error-handling)

---

## 1. Authentication APIs

### 1.1 Register New Account

**Endpoint:** `POST /api/auth/register`  
**Authorization:** Public (no authentication required)  
**Description:** Create a new user account in the system

**Request Body:**
```json
{
  "tenDangNhap": "user123",
  "matKhau": "SecurePassword123!",
  "hoTen": "Nguyễn Văn A",
  "email": "nguyenvana@example.com",
  "role": "KETOAN"
}
```

**Field Validation:**
- `tenDangNhap`: Required, unique, min 3 characters
- `matKhau`: Required, min 6 characters
- `hoTen`: Required
- `email`: Required, valid email format
- `role`: Required, allowed values: `ADMIN`, `TOTRUONG`, `KETOAN`

**Success Response (201):**
```json
"Đăng ký thành công"
```

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "message": "Tên đăng nhập đã tồn tại"
  }
  ```

---

### 1.2 Login

**Endpoint:** `POST /api/auth/login`  
**Authorization:** Public  
**Description:** Authenticate user and receive JWT token

**Request Body:**
```json
{
  "tenDangNhap": "user123",
  "matKhau": "SecurePassword123!"
}
```

**Success Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tenDangNhap": "user123",
  "hoTen": "Nguyễn Văn A",
  "role": "KETOAN"
}
```

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "message": "Sai tên đăng nhập hoặc mật khẩu"
  }
  ```

---

## 2. Nhân Khẩu (Citizen) APIs

### 2.1 Get All Citizens

**Endpoint:** `GET /api/nhan-khau`  
**Authorization:** `ADMIN`, `TOTRUONG`, `KETOAN`  
**Description:** Retrieve list of all citizens

**Success Response (200):**
```json
[
  {
    "id": 1,
    "hoTen": "Nguyễn Văn A",
    "ngaySinh": "1990-05-15",
    "gioiTinh": "Nam",
    "danToc": "Kinh",
    "quocTich": "Việt Nam",
    "ngheNghiep": "Kỹ sư",
    "cmndCccd": "001234567890",
    "ngayCap": "2020-01-15",
    "noiCap": "Công an TP. Hà Nội",
    "quanHeChuHo": "Chủ hộ",
    "ghiChu": null,
    "hoKhauId": 1,
    "soHoKhau": "HK001",
    "diaChiThuongTru": "123 Đường ABC, Quận 1, TP.HCM",
    "tamTruTu": null,
    "tamTruDen": null,
    "tamVangTu": null,
    "tamVangDen": null,
    "ngayKhaiTu": null,
    "lyDoKhaiTu": null
  }
]
```

---

### 2.2 Get Citizen by ID

**Endpoint:** `GET /api/nhan-khau/{id}`  
**Authorization:** `ADMIN`, `TOTRUONG`, `KETOAN`  
**Path Parameter:** `id` (Long) - Citizen ID

**Success Response (200):** Same as individual object in 2.1

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "message": "Không tìm thấy nhân khẩu với ID đã cho"
  }
  ```

---

### 2.3 Create New Citizen

**Endpoint:** `POST /api/nhan-khau`  
**Authorization:** `ADMIN`, `TOTRUONG`  
**Description:** Add new citizen to the system

**Request Body:**
```json
{
  "hoTen": "Nguyễn Thị B",
  "ngaySinh": "1995-08-20",
  "gioiTinh": "Nữ",
  "danToc": "Kinh",
  "quocTich": "Việt Nam",
  "ngheNghiep": "Giáo viên",
  "cmndCccd": "001987654321",
  "ngayCap": "2021-06-10",
  "noiCap": "Công an TP. Hà Nội",
  "quanHeChuHo": "Vợ/Chồng",
  "ghiChu": "Chuyển đến từ Hà Nội",
  "hoKhauId": 1
}
```

**Field Validation:**
- `hoTen`: Required, not blank
- `ngaySinh`: Required, must be past or present date
- `gioiTinh`: Required, allowed values: "Nam", "Nữ", "Khác"
- `hoKhauId`: Required, must exist
- `cmndCccd`: Optional for age < 14, required for age >= 14
- `ngayCap`, `noiCap`: Optional for age < 14, required for age >= 14

**Business Rules:**
- If age < 14: CMND/CCCD fields are optional
- If age >= 14: CMND/CCCD, ngayCap, noiCap are REQUIRED
- Age is calculated as: `YEAR(CURRENT_DATE) - YEAR(ngaySinh)`

**Success Response (201):** Same as 2.2

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "message": "Dữ liệu không hợp lệ"
  }
  ```
- **403 Forbidden:**
  ```json
  {
    "message": "Không có quyền thực hiện thao tác"
  }
  ```

---

### 2.4 Update Citizen (Partial Update)

**Endpoint:** `PUT /api/nhan-khau/{id}`  
**Authorization:** `ADMIN`, `TOTRUONG`  
**Description:** Update citizen information - only provided fields are updated

**Request Body Example:**
```json
{
  "ngheNghiep": "Bác sĩ",
  "ghiChu": "Đã chuyển công tác"
}
```

**Success Response (200):** Updated citizen object

**Error Responses:** Same as 2.3

---

### 2.5 Delete Citizen

**Endpoint:** `DELETE /api/nhan-khau/{id}`  
**Authorization:** `ADMIN`, `TOTRUONG`

**Success Response (204):** No content

**Error Responses:**
- **400 Bad Request:** Citizen not found
- **403 Forbidden:** Insufficient permissions

---

### 2.6 Register Temporary Residence (Tạm Trú)

**Endpoint:** `PUT /api/nhan-khau/{id}/tamtru`  
**Authorization:** `ADMIN`, `TOTRUONG`  
**Description:** Register temporary residence for a citizen

**Request Body:**
```json
{
  "tu": "2025-01-01",
  "den": "2025-06-30",
  "lyDo": "Công tác tại TP.HCM"
}
```

**Field Validation:**
- `tu`: Required, start date
- `den`: Required, end date, must be after `tu`
- `lyDo`: Optional reason

**Success Response (200):** Updated citizen object with tamTruTu and tamTruDen filled

---

### 2.7 Cancel Temporary Residence

**Endpoint:** `DELETE /api/nhan-khau/{id}/tamtru`  
**Authorization:** `ADMIN`, `TOTRUONG`

**Success Response (204):** No content

---

### 2.8 Register Temporary Absence (Tạm Vắng)

**Endpoint:** `PUT /api/nhan-khau/{id}/tamvang`  
**Authorization:** `ADMIN`, `TOTRUONG`  
**Description:** Register temporary absence for a citizen

**Request Body:**
```json
{
  "tu": "2025-02-01",
  "den": "2025-07-31",
  "lyDo": "Đi du học nước ngoài"
}
```

**Success Response (200):** Updated citizen object with tamVangTu and tamVangDen filled

**IMPORTANT:** Citizens with active temporary absence (tamVangDen >= CURRENT_DATE) are **excluded** from fee calculations.

---

### 2.9 Cancel Temporary Absence

**Endpoint:** `DELETE /api/nhan-khau/{id}/tamvang`  
**Authorization:** `ADMIN`, `TOTRUONG`

**Success Response (204):** No content

---

### 2.10 Register Death (Khai Tử)

**Endpoint:** `PUT /api/nhan-khau/{id}/khaitu`  
**Authorization:** `ADMIN`, `TOTRUONG`

**Request Body:**
```json
{
  "lyDo": "Bệnh tật"
}
```

**Success Response (200):** Updated citizen with ngayKhaiTu set to current date

---

### 2.11 Search Citizens by Name

**Endpoint:** `GET /api/nhan-khau/search?q={keyword}`  
**Authorization:** `ADMIN`, `TOTRUONG`, `KETOAN`  
**Query Parameter:** `q` - Search keyword

**Example:** `GET /api/nhan-khau/search?q=Nguyen`

**Success Response (200):** Array of matching citizens

---

### 2.12 Gender Statistics

**Endpoint:** `GET /api/nhan-khau/stats/gender`  
**Authorization:** `ADMIN`, `TOTRUONG`, `KETOAN`

**Success Response (200):**
```json
{
  "totalCitizens": 150,
  "male": 75,
  "female": 73,
  "other": 2
}
```

---

### 2.13 Age Statistics

**Endpoint:** `GET /api/nhan-khau/stats/age?underAge=18&retireAge=60`  
**Authorization:** `ADMIN`, `TOTRUONG`, `KETOAN`  
**Query Parameters:**
- `underAge` (optional, default 16): Age threshold for children
- `retireAge` (optional, default 60): Age threshold for retirees

**Success Response (200):**
```json
{
  "children": 30,
  "workingAge": 100,
  "retirees": 20
}
```

---

## 3. Hộ Khẩu (Household) APIs

### 3.1 Get All Households

**Endpoint:** `GET /api/ho-khau`  
**Authorization:** `ADMIN`, `TOTRUONG`, `KETOAN`

**Success Response (200):**
```json
[
  {
    "id": 1,
    "soHoKhau": "HK001",
    "tenChuHo": "Nguyễn Văn A",
    "diaChiThuongTru": "123 Đường ABC, Quận 1, TP.HCM",
    "soThanhVien": 4,
    "members": [...]
  }
]
```

---

### 3.2 Get Household by ID

**Endpoint:** `GET /api/ho-khau/{id}`  
**Authorization:** `ADMIN`, `TOTRUONG`, `KETOAN`

**Success Response (200):** Same as individual object in 3.1

**Error Responses:**
- **404 Not Found:**
  ```json
  {
    "message": "Không tìm thấy hộ khẩu"
  }
  ```

---

### 3.3 Create New Household

**Endpoint:** `POST /api/ho-khau`  
**Authorization:** `ADMIN`, `TOTRUONG`

**Request Body:**
```json
{
  "soHoKhau": "HK002",
  "tenChuHo": "Trần Văn B",
  "diaChiThuongTru": "456 Đường XYZ, Quận 2, TP.HCM"
}
```

**Field Validation:**
- `soHoKhau`: Required, unique, not blank
- `tenChuHo`: Required, not blank
- `diaChiThuongTru`: Required, not blank

**Success Response (201):** Created household object

**Automatic Action:** System automatically creates initial ThuPhiHoKhau record for the most recent fee period

---

### 3.4 Update Household (Partial Update)

**Endpoint:** `PUT /api/ho-khau/{id}`  
**Authorization:** `ADMIN`, `TOTRUONG`

**Request Body Example:**
```json
{
  "diaChiThuongTru": "789 Đường MNO, Quận 3, TP.HCM"
}
```

**Success Response (200):** Updated household object

---

### 3.5 Delete Household

**Endpoint:** `DELETE /api/ho-khau/{id}`  
**Authorization:** `ADMIN`, `TOTRUONG`

**Success Response (204):** No content

**Automatic Action:** All associated ThuPhiHoKhau records are deleted

---

## 4. Đợt Thu Phí (Fee Period) APIs

### 4.1 Get All Fee Periods

**Endpoint:** `GET /api/dot-thu-phi`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`

**Success Response (200):**
```json
[
  {
    "id": 1,
    "tenDot": "Phí quản lý tháng 1/2025",
    "loai": "BAT_BUOC",
    "ngayBatDau": "2025-01-01",
    "ngayKetThuc": "2025-01-31",
    "dinhMuc": 6000,
    "createdBy": 1,
    "createdAt": "2025-01-01T10:00:00",
    "updatedAt": "2025-01-01T10:00:00"
  }
]
```

---

### 4.2 Get Fee Period by ID

**Endpoint:** `GET /api/dot-thu-phi/{id}`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`

**Success Response (200):** Same as individual object in 4.1

**Error Responses:**
- **404 Not Found:**
  ```json
  {
    "message": "Không tìm thấy đợt thu phí"
  }
  ```

---

### 4.3 Create New Fee Period

**Endpoint:** `POST /api/dot-thu-phi`  
**Authorization:** `ADMIN`, `KETOAN`

**Request Body:**
```json
{
  "tenDot": "Phí quản lý tháng 2/2025",
  "loai": "BAT_BUOC",
  "ngayBatDau": "2025-02-01",
  "ngayKetThuc": "2025-02-28",
  "dinhMuc": 6000
}
```

**Field Validation:**
- `tenDot`: Required, not blank
- `loai`: Required, values: `BAT_BUOC` (mandatory) or `TU_NGUYEN` (voluntary)
- `ngayBatDau`: Required
- `ngayKetThuc`: Required, must be >= ngayBatDau
- `dinhMuc`: 
  - For `BAT_BUOC`: Must be > 0
  - For `TU_NGUYEN`: Defaults to 0

**Business Rules:**
- **BAT_BUOC (Mandatory Fee):**
  - Requires positive dinhMuc
  - Fee calculation: dinhMuc × 12 × memberCount
  - Status: CHUA_NOP or DA_NOP based on payment
  - Auto-recalculates when household members change

- **TU_NGUYEN (Voluntary Fee):**
  - dinhMuc defaults to 0
  - No automatic calculation
  - Status: KHONG_AP_DUNG (not applicable)
  - Does NOT auto-recalculate

**Success Response (201):** Created fee period object

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "message": "Dữ liệu không hợp lệ"
  }
  ```
- **403 Forbidden:**
  ```json
  {
    "message": "Không có quyền truy cập"
  }
  ```

---

### 4.4 Update Fee Period (Partial Update)

**Endpoint:** `PUT /api/dot-thu-phi/{id}`  
**Authorization:** `ADMIN`, `KETOAN`

**Request Body Example:**
```json
{
  "tenDot": "Phí quản lý Q1/2025 (cập nhật)",
  "dinhMuc": 7000
}
```

**Success Response (200):** Updated fee period object

---

### 4.5 Delete Fee Period

**Endpoint:** `DELETE /api/dot-thu-phi/{id}`  
**Authorization:** `ADMIN`, `KETOAN`

**Success Response (200):**
```json
"Đã xóa đợt thu phí id = 1"
```

**Error Responses:**
- **403 Forbidden:** Insufficient permissions
- **404 Not Found:** Fee period not found

---

## 5. Thu Phí Hộ Khẩu (Fee Collection) APIs

### 5.1 Get All Fee Collections

**Endpoint:** `GET /api/thu-phi-ho-khau`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`

**Success Response (200):**
```json
[
  {
    "id": 1,
    "hoKhauId": 1,
    "soHoKhau": "HK001",
    "tenChuHo": "Nguyễn Văn A",
    "dotThuPhiId": 1,
    "tenDot": "Phí quản lý tháng 1/2025",
    "soNguoi": 4,
    "tongPhi": 288000,
    "soTienDaThu": 288000,
    "trangThai": "DA_NOP",
    "periodDescription": "Cả năm 2025",
    "ngayThu": "2025-01-15",
    "ghiChu": "Đã thanh toán đủ",
    "collectedBy": 2,
    "createdAt": "2025-01-15T14:30:00"
  }
]
```

**Fee Status Values:**
- `CHUA_NOP`: Not paid (soTienDaThu < tongPhi)
- `DA_NOP`: Fully paid (soTienDaThu >= tongPhi)
- `KHONG_AP_DUNG`: Not applicable (voluntary fees)

---

### 5.2 Get Fee Collection Statistics

**Endpoint:** `GET /api/thu-phi-ho-khau/stats`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`

**Success Response (200):**
```json
{
  "totalRecords": 50,
  "totalCollected": 14400000,
  "totalHouseholds": 50,
  "paidRecords": 35,
  "unpaidRecords": 15
}
```

---

### 5.3 Calculate Fee for Household

**Endpoint:** `GET /api/thu-phi-ho-khau/calc?hoKhauId={id}&dotThuPhiId={id}`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`  
**Query Parameters:**
- `hoKhauId` (required): Household ID
- `dotThuPhiId` (required): Fee period ID

**Example:** `GET /api/thu-phi-ho-khau/calc?hoKhauId=1&dotThuPhiId=1`

**Success Response (200):**
```json
{
  "hoKhauId": 1,
  "soHoKhau": "HK001",
  "tenChuHo": "Nguyễn Văn A",
  "dotThuPhiId": 1,
  "tenDot": "Phí quản lý tháng 1/2025",
  "memberCount": 4,
  "monthlyFeePerPerson": 6000,
  "monthsPerYear": 12,
  "totalFee": 288000,
  "formula": "6000 * 12 * 4 = 288000"
}
```

**Calculation Logic:**
```
totalFee = monthlyFeePerPerson × 12 × memberCount
```

**Member Count Rules:**
- Includes all citizens in household
- **EXCLUDES** citizens with active temporary absence (tamVangDen >= CURRENT_DATE)

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "message": "Không tìm thấy hộ khẩu hoặc đợt thu phí"
  }
  ```

---

### 5.4 Get Fee Collection by ID

**Endpoint:** `GET /api/thu-phi-ho-khau/{id}`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`

**Success Response (200):** Same as individual object in 5.1

**Error Responses:**
- **404 Not Found:**
  ```json
  {
    "message": "Không tìm thấy thu phí id = {id}"
  }
  ```

---

### 5.5 Get Fee Collections by Household

**Endpoint:** `GET /api/thu-phi-ho-khau/ho-khau/{hoKhauId}`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`

**Success Response (200):** Array of fee collection records for the household

---

### 5.6 Get Fee Collections by Fee Period

**Endpoint:** `GET /api/thu-phi-ho-khau/dot-thu-phi/{dotThuPhiId}`  
**Authorization:** `ADMIN`, `KETOAN`, `TOTRUONG`

**Success Response (200):** Array of fee collection records for the period

---

### 5.7 Create New Fee Collection

**Endpoint:** `POST /api/thu-phi-ho-khau`  
**Authorization:** `ADMIN`, `KETOAN`  
**Description:** Record a new fee payment for a household

**Request Body:**
```json
{
  "hoKhauId": 1,
  "dotThuPhiId": 1,
  "soTienDaThu": 288000,
  "ngayThu": "2025-01-15",
  "ghiChu": "Thanh toán đầy đủ một lần"
}
```

**Field Validation:**
- `hoKhauId`: Required, must exist
- `dotThuPhiId`: Required, must exist
- `soTienDaThu`: Required, must be >= 0
- `ngayThu`: Optional, but if provided must be within fee period range
- `ghiChu`: Optional

**Critical Business Rules:**

1. **Payment Date Validation:**
   - `ngayThu` must be >= `dotThuPhi.ngayBatDau`
   - `ngayThu` must be <= `dotThuPhi.ngayKetThuc`
   
2. **Automatic Calculations:**
   - `soNguoi`: Auto-calculated (excludes temporarily absent citizens)
   - `tongPhi`: Auto-calculated = dinhMuc × 12 × soNguoi
   - `trangThai`: Auto-determined based on total paid across ALL payments

3. **Multiple Payment Support:**
   - System supports partial payments
   - Status is determined by **SUM of ALL payments** for same hoKhauId + dotThuPhiId
   - Example: Payment 1 (100,000) + Payment 2 (188,000) = 288,000 total
   - If tongPhi = 288,000, **BOTH records** show status DA_NOP

**Success Response (201):** Created fee collection object with updated status

**Error Responses:**
- **400 Bad Request (Invalid Date Before Start):**
  ```json
  {
    "message": "Đợt thu phí 'Phí tháng 1/2025' chưa bắt đầu. Ngày thu phải từ 2025-01-01 trở đi."
  }
  ```
- **400 Bad Request (Invalid Date After End):**
  ```json
  {
    "message": "Đợt thu phí 'Phí tháng 1/2025' đã kết thúc vào 2025-01-31. Không thể ghi nhận thanh toán sau ngày này."
  }
  ```
- **400 Bad Request (Not Found):**
  ```json
  {
    "message": "Không tìm thấy hộ khẩu id = {id}"
  }
  ```
- **403 Forbidden:**
  ```json
  {
    "message": "Không có quyền truy cập (chỉ ADMIN hoặc KETOAN)"
  }
  ```

---

### 5.8 Update Fee Collection

**Endpoint:** `PUT /api/thu-phi-ho-khau/{id}`  
**Authorization:** `ADMIN`, `KETOAN`

**Request Body:**
```json
{
  "soTienDaThu": 300000,
  "ngayThu": "2025-01-20",
  "ghiChu": "Cập nhật số tiền"
}
```

**Business Rules:** Same validation and automatic calculation as 5.7

**Success Response (200):** Updated fee collection object

**IMPORTANT:** When updating payment amount, system recalculates status for **ALL related records** (same hoKhauId + dotThuPhiId) to ensure consistency.

---

### 5.9 Delete Fee Collection

**Endpoint:** `DELETE /api/thu-phi-ho-khau/{id}`  
**Authorization:** `ADMIN`, `KETOAN`

**Success Response (200):**
```json
"Đã xóa thu phí id = 1"
```

---

## 6. Tài Khoản (Account Management) APIs

### 6.1 Get All Accounts

**Endpoint:** `GET /api/tai-khoan`  
**Authorization:** `ADMIN` only

**Success Response (200):**
```json
[
  {
    "id": 1,
    "tenDangNhap": "admin",
    "hoTen": "Administrator",
    "email": "admin@example.com",
    "role": "ADMIN",
    "createdAt": "2025-01-01T00:00:00"
  }
]
```

---

### 6.2 Delete Account

**Endpoint:** `DELETE /api/tai-khoan/{id}`  
**Authorization:** `ADMIN` only

**Business Rules:**
- Cannot delete ADMIN accounts
- Cannot delete your own account

**Success Response (200):**
```json
"Xóa tài khoản thành công"
```

**Error Responses:**
- **400 Bad Request:**
  ```json
  {
    "message": "Không thể xóa tài khoản ADMIN hoặc chính mình"
  }
  ```
- **403 Forbidden:**
  ```json
  {
    "message": "Không có quyền truy cập"
  }
  ```
- **404 Not Found:**
  ```json
  {
    "message": "Không tìm thấy tài khoản"
  }
  ```

---

## 7. Common Response Formats

### Success Response Pattern
```json
{
  "data": {...},
  "message": "Operation successful"
}
```

### Pagination (if implemented)
```json
{
  "content": [...],
  "totalElements": 100,
  "totalPages": 10,
  "currentPage": 0,
  "pageSize": 10
}
```

---

## 8. Error Handling

### HTTP Status Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful GET, PUT, DELETE |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE with no response body |
| 400 | Bad Request | Validation error, business rule violation |
| 401 | Unauthorized | Missing or invalid JWT token |
| 403 | Forbidden | Insufficient permissions for operation |
| 404 | Not Found | Resource does not exist |
| 500 | Internal Server Error | Unexpected server error |

### Error Response Format
```json
{
  "timestamp": "2025-01-15T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Specific error message in Vietnamese",
  "path": "/api/thu-phi-ho-khau"
}
```

### Common Error Messages

**Validation Errors:**
- "Dữ liệu không hợp lệ"
- "Trường {fieldName} không được để trống"
- "Giá trị phải lớn hơn 0"

**Authorization Errors:**
- "Không có quyền thực hiện thao tác"
- "Chỉ ADMIN hoặc KETOAN mới có thể thực hiện thao tác này"

**Business Rule Violations:**
- "Ngày thu phải nằm trong khoảng thời gian đợt thu phí"
- "Đợt thu phí đã kết thúc vào {date}"
- "Tên đăng nhập đã tồn tại"

**Not Found Errors:**
- "Không tìm thấy {resource} id = {id}"
- "Không tìm thấy hộ khẩu/nhân khẩu/đợt thu phí"

---

## Authentication Headers

All authenticated endpoints require JWT token in header:
```
Authorization: Bearer {your_jwt_token}
```

---

## Notes

1. All dates use ISO 8601 format: `yyyy-MM-dd`
2. All timestamps use ISO 8601 format: `yyyy-MM-dd'T'HH:mm:ss`
3. Currency amounts use BigDecimal with 2 decimal places
4. All API responses are in JSON format
5. Character encoding: UTF-8

---

**End of API Reference**
