# Business Rules Documentation

> **Extracted from Actual Source Code**  
> Last updated: December 2024  
> These rules govern system behavior and are enforced in the backend

---

## Table of Contents

1. [Fee Collection Rules](#1-fee-collection-rules)
2. [Citizen Management Rules](#2-citizen-management-rules)
3. [Household Management Rules](#3-household-management-rules)
4. [Fee Period Rules](#4-fee-period-rules)
5. [Account Management Rules](#5-account-management-rules)
6. [Authorization Rules](#6-authorization-rules)

---

## 1. Fee Collection Rules

### 1.1 Fee Calculation Formula

**Rule:** Annual fee is calculated based on household size and fee period rate

**Formula:**
```
tongPhi = dinhMuc × 12 × soNguoi

Where:
- dinhMuc: Monthly fee per person (from DotThuPhi)
- 12: Number of months in a year
- soNguoi: Number of eligible household members
```

**Implementation:** `ThuPhiHoKhauService.calculateAnnualFee()`

**Example:**
```
Household: HK001
Fee Period: "Phí quản lý 2025"
Monthly rate (dinhMuc): 6,000 VND
Household members: 4 people

Calculation: 6,000 × 12 × 4 = 288,000 VND
```

---

### 1.2 Active Member Counting

**Rule:** Only active household members are counted for fee calculation

**Exclusion Criteria:**
- Citizens with active temporary absence (tamVangDen >= CURRENT_DATE) are **EXCLUDED**

**Implementation:** `ThuPhiHoKhauService.countActiveMembersInHousehold()`

**Code Logic:**
```java
private int countActiveMembersInHousehold(Long hoKhauId) {
    List<NhanKhau> members = nhanKhauRepository.findByHoKhauId(hoKhauId);
    int count = 0;
    LocalDate today = LocalDate.now();
    
    for (NhanKhau nk : members) {
        // Exclude if still in temporary absence period
        if (nk.getTamVangDen() == null || nk.getTamVangDen().isBefore(today)) {
            count++;
        }
    }
    return count;
}
```

**Example:**
```
Household HK001 has 4 members:
- Member A: No temporary absence → COUNTED
- Member B: tamVangDen = 2024-12-31 (expired) → COUNTED
- Member C: No temporary absence → COUNTED
- Member D: tamVangDen = 2026-06-30 (active) → EXCLUDED

Active member count = 3
Fee = 6,000 × 12 × 3 = 216,000 VND
```

---

### 1.3 Payment Date Validation

**Rule:** Payment date must fall within the fee period's date range

**Validation Logic:**
- `ngayThu >= dotThuPhi.ngayBatDau`
- `ngayThu <= dotThuPhi.ngayKetThuc`

**Implementation:** `ThuPhiHoKhauService.validatePaymentDate()`

**Error Messages (EXACT from code):**

1. **Payment before period start:**
```
"Đợt thu phí '{tenDot}' chưa bắt đầu. Ngày thu phải từ {ngayBatDau} trở đi."
```

2. **Payment after period end:**
```
"Đợt thu phí '{tenDot}' đã kết thúc vào {ngayKetThuc}. Không thể ghi nhận thanh toán sau ngày này."
```

**Code Implementation:**
```java
private void validatePaymentDate(LocalDate ngayThu, DotThuPhi dotThuPhi) {
    if (ngayThu != null) {
        LocalDate ngayBatDau = dotThuPhi.getNgayBatDau();
        LocalDate ngayKetThuc = dotThuPhi.getNgayKetThuc();
        
        if (ngayThu.isBefore(ngayBatDau)) {
            throw new RuntimeException(String.format(
                "Đợt thu phí '%s' chưa bắt đầu. Ngày thu phải từ %s trở đi.",
                dotThuPhi.getTenDot(), ngayBatDau.toString()));
        }
        
        if (ngayThu.isAfter(ngayKetThuc)) {
            throw new RuntimeException(String.format(
                "Đợt thu phí '%s' đã kết thúc vào %s. Không thể ghi nhận thanh toán sau ngày này.",
                dotThuPhi.getTenDot(), ngayKetThuc.toString()));
        }
    }
}
```

**Example:**
```
Fee Period: "Phí tháng 1/2025"
ngayBatDau: 2025-01-01
ngayKetThuc: 2025-01-31

Valid payment dates: 2025-01-01 to 2025-01-31
Invalid: 2024-12-31 → Error: "chưa bắt đầu"
Invalid: 2025-02-01 → Error: "đã kết thúc vào 2025-01-31"
```

---

### 1.4 Multiple Payment Support

**Rule:** System supports partial payments, with status determined by total paid across ALL records

**Key Behavior:**
- Multiple payment records can exist for same hoKhauId + dotThuPhiId
- Total paid is **SUM of all soTienDaThu** for that combination
- Status is updated for **ALL related records** to maintain consistency

**Implementation:** 
- `ThuPhiHoKhauService.calculateTotalPaid()`
- `ThuPhiHoKhauService.updateAllRelatedRecordsStatus()`

**Code Logic:**
```java
private BigDecimal calculateTotalPaid(Long hoKhauId, Long dotThuPhiId) {
    List<ThuPhiHoKhau> allRecords = 
        repository.findByHoKhauIdAndDotThuPhiId(hoKhauId, dotThuPhiId);
    
    return allRecords.stream()
        .map(ThuPhiHoKhau::getSoTienDaThu)
        .reduce(BigDecimal.ZERO, BigDecimal::add);
}

private void updateAllRelatedRecordsStatus(Long hoKhauId, Long dotThuPhiId) {
    BigDecimal totalPaid = calculateTotalPaid(hoKhauId, dotThuPhiId);
    List<ThuPhiHoKhau> allRecords = 
        repository.findByHoKhauIdAndDotThuPhiId(hoKhauId, dotThuPhiId);
    
    for (ThuPhiHoKhau record : allRecords) {
        String newStatus = determineStatus(totalPaid, record.getTongPhi(), 
            record.getDotThuPhi().getLoai());
        record.setTrangThai(newStatus);
        repository.save(record);
    }
}
```

**Example:**
```
Household HK001, Fee Period "2025", Total Fee: 288,000 VND

Payment 1: 100,000 VND on 2025-01-10
- totalPaid = 100,000
- Status = "CHUA_NOP" (100,000 < 288,000)

Payment 2: 188,000 VND on 2025-01-20
- totalPaid = 100,000 + 188,000 = 288,000
- Status = "DA_NOP" (288,000 >= 288,000)
- BOTH Payment 1 and Payment 2 records updated to "DA_NOP"

Payment 3: 50,000 VND on 2025-01-25 (overpayment)
- totalPaid = 288,000 + 50,000 = 338,000
- Status = "DA_NOP" (338,000 >= 288,000)
- ALL THREE records show "DA_NOP"
```

---

### 1.5 Payment Status Determination

**Rule:** Status is determined by comparing total paid vs total fee

**Status Values:**
- `CHUA_NOP` (Not paid) - For mandatory fees when totalPaid < tongPhi
- `DA_NOP` (Paid) - For mandatory fees when totalPaid >= tongPhi
- `KHONG_AP_DUNG` (Not applicable) - For voluntary fees

**Implementation:** `ThuPhiHoKhauService.determineStatus()`

**Code Logic:**
```java
private String determineStatus(BigDecimal totalPaid, BigDecimal tongPhi, 
                               LoaiThuPhi loai) {
    if (loai == LoaiThuPhi.TU_NGUYEN) {
        return "KHONG_AP_DUNG";
    }
    
    return totalPaid.compareTo(tongPhi) >= 0 ? "DA_NOP" : "CHUA_NOP";
}
```

**Decision Table:**

| Fee Type | Total Paid | Total Fee | Status |
|----------|-----------|-----------|---------|
| BAT_BUOC | 100,000 | 288,000 | CHUA_NOP |
| BAT_BUOC | 288,000 | 288,000 | DA_NOP |
| BAT_BUOC | 300,000 | 288,000 | DA_NOP |
| TU_NGUYEN | Any | Any | KHONG_AP_DUNG |

---

### 1.6 Automatic Fee Recalculation

**Rule:** Fees are automatically recalculated when household composition changes

**Triggers:**
1. New citizen added to household
2. Citizen removed from household
3. Citizen's temporary absence status changes

**Applies to:** Only `BAT_BUOC` (mandatory) fees

**Does NOT apply to:** `TU_NGUYEN` (voluntary) fees

**Implementation:** `ThuPhiHoKhauService.recalculateForHousehold()`

**Code Logic:**
```java
public void recalculateForHousehold(Long hoKhauId) {
    // Get all BAT_BUOC fee periods
    List<DotThuPhi> mandatoryPeriods = dotThuPhiRepository
        .findByLoai(LoaiThuPhi.BAT_BUOC);
    
    for (DotThuPhi period : mandatoryPeriods) {
        // Get existing records
        List<ThuPhiHoKhau> existingRecords = repository
            .findByHoKhauIdAndDotThuPhiId(hoKhauId, period.getId());
        
        // Recalculate member count and total fee
        int newMemberCount = countActiveMembersInHousehold(hoKhauId);
        BigDecimal newTotalFee = calculateAnnualFee(period.getDinhMuc(), 
                                                     newMemberCount);
        
        // Update all records
        for (ThuPhiHoKhau record : existingRecords) {
            record.setSoNguoi(newMemberCount);
            record.setTongPhi(newTotalFee);
            repository.save(record);
        }
        
        // Update status based on new total fee
        updateAllRelatedRecordsStatus(hoKhauId, period.getId());
    }
}
```

**Example:**
```
Initial state:
- Household HK001: 4 members
- Fee: 6,000 × 12 × 4 = 288,000 VND
- Paid: 288,000 VND
- Status: DA_NOP

Action: Add 1 new member
- New member count: 5
- New fee: 6,000 × 12 × 5 = 360,000 VND
- Total paid: 288,000 VND (unchanged)
- New status: CHUA_NOP (288,000 < 360,000)
```

---

### 1.7 Initial Fee Record Creation

**Rule:** When a new household is created, initial fee records are automatically generated

**Behavior:**
- System finds the most recent fee period
- Creates ThuPhiHoKhau record with:
  - soTienDaThu = 0
  - Status = CHUA_NOP (for BAT_BUOC) or KHONG_AP_DUNG (for TU_NGUYEN)

**Implementation:** Called in `HoKhauService.createHoKhau()`

---

## 2. Citizen Management Rules

### 2.1 Age-Based CCCD Validation

**Rule:** CCCD (Citizen ID) requirements depend on age

**Age Calculation:**
```
age = YEAR(CURRENT_DATE) - YEAR(ngaySinh)
```

**Validation Rules:**

| Age | CCCD Required | ngayCap Required | noiCap Required |
|-----|---------------|------------------|-----------------|
| < 14 | Optional | Optional | Optional |
| >= 14 | **Required** | **Required** | **Required** |

**Implementation:** Applied in `NhanKhauRequestDto` validation

**Code Logic:**
```java
@Data
public class NhanKhauRequestDto {
    @NotBlank
    private String hoTen;
    
    @NotNull
    @PastOrPresent
    private LocalDate ngaySinh;
    
    @NotBlank
    private String gioiTinh;
    
    @NotNull
    private Long hoKhauId;
    
    // Age-dependent validation
    private String cmndCccd;  // Required if age >= 14
    private LocalDate ngayCap;  // Required if age >= 14
    private String noiCap;  // Required if age >= 14
}
```

**Example:**
```
Citizen A: Born 2015-05-10 (age 9)
- CCCD: Optional
- Can create without CCCD

Citizen B: Born 2005-05-10 (age 19)
- CCCD: REQUIRED
- ngayCap: REQUIRED
- noiCap: REQUIRED
- Cannot create without these fields
```

---

### 2.2 Gender Values

**Rule:** Gender must be one of predefined values

**Allowed Values:**
- `Nam` (Male)
- `Nữ` (Female)
- `Khác` (Other)

**Implementation:** Validated in DTO and stored in database

---

### 2.3 Birth Date Validation

**Rule:** Birth date must be in the past or today

**Validation:** `@PastOrPresent` annotation on `ngaySinh` field

**Invalid Examples:**
- `2026-01-01` → Error: "Ngày sinh phải là quá khứ hoặc hiện tại"

---

### 2.4 Temporary Absence (Tạm Vắng) Rules

**Rule:** Citizens on temporary absence are excluded from fee calculations

**Validation:**
- `tamVangTu` must be before `tamVangDen`
- If `tamVangDen >= CURRENT_DATE`, citizen is considered "actively absent"

**Impact:**
- Actively absent citizens are NOT counted in `soNguoi`
- Fees are automatically recalculated when tamVang status changes

**Example:**
```
Citizen registers temporary absence:
- tamVangTu: 2025-01-01
- tamVangDen: 2025-12-31

On 2025-06-15:
- tamVangDen (2025-12-31) >= today (2025-06-15)
- Status: Actively absent
- Action: Excluded from fee calculation

On 2026-01-15:
- tamVangDen (2025-12-31) < today (2026-01-15)
- Status: Returned
- Action: Included in fee calculation
```

---

### 2.5 Temporary Residence (Tạm Trú) Rules

**Rule:** Temporary residence records citizen's temporary stay

**Validation:**
- `tamTruTu` must be before `tamTruDen`

**Note:** Unlike tamVang, tamTru does NOT affect fee calculation. It's for record-keeping only.

---

### 2.6 Death Registration (Khai Tử) Rules

**Rule:** Death registration sets official death date

**Behavior:**
- `ngayKhaiTu` is set to **CURRENT_DATE** automatically
- `lyDoKhaiTu` is optional (user can provide reason)

**Impact:**
- Deceased citizens remain in database for historical records
- Frontend should filter out deceased citizens from active lists

---

## 3. Household Management Rules

### 3.1 Household Code Uniqueness

**Rule:** `soHoKhau` must be unique across all households

**Validation:** Enforced at database level with UNIQUE constraint

**Error Message:**
```
"Số hộ khẩu đã tồn tại"
```

---

### 3.2 Required Fields

**Rule:** All household core fields are mandatory

**Required Fields:**
- `soHoKhau` - Household code (unique)
- `tenChuHo` - Head of household name
- `diaChiThuongTru` - Permanent address

---

### 3.3 Member Count Tracking

**Rule:** `soThanhVien` is automatically calculated

**Calculation:**
```
soThanhVien = COUNT(citizens WHERE hoKhauId = this.id)
```

**Update Triggers:**
- Citizen added to household
- Citizen removed from household

---

### 3.4 Cascade Deletion

**Rule:** Deleting household deletes all related records

**Cascade Targets:**
- All citizens (`nhan_khau`) in the household
- All fee collection records (`thu_phi_ho_khau`)

**Implementation:** `ON DELETE CASCADE` foreign key constraint

---

## 4. Fee Period Rules

### 4.1 Fee Type (Loai) Rules

**Rule:** Fee period type determines calculation and status behavior

**Type Values:**

**1. BAT_BUOC (Mandatory Fee)**
- `dinhMuc` must be > 0
- Fees are **automatically calculated** for all households
- Status can be: CHUA_NOP or DA_NOP
- Fees **auto-recalculate** when household members change

**2. TU_NGUYEN (Voluntary Fee)**
- `dinhMuc` defaults to 0 (optional contribution)
- No automatic calculation
- Status is always: KHONG_AP_DUNG
- Does **NOT** auto-recalculate

**Implementation:**
```java
public enum LoaiThuPhi {
    BAT_BUOC,   // Mandatory
    TU_NGUYEN   // Voluntary
}
```

---

### 4.2 Date Range Validation

**Rule:** Fee period must have valid date range

**Validation:**
- `ngayKetThuc >= ngayBatDau`

**Implementation:** Validated in `DotThuPhiRequestDto`

**Error Message:**
```
"Ngày kết thúc phải sau hoặc bằng ngày bắt đầu"
```

---

### 4.3 Fee Rate (Dinh Muc) Rules

**Rule:** Fee rate validation depends on fee type

**For BAT_BUOC:**
- `dinhMuc` must be > 0
- Typical value: 6,000 VND/person/month

**For TU_NGUYEN:**
- `dinhMuc` can be 0 or omitted
- No validation required

**Implementation:**
```java
@Data
public class DotThuPhiRequestDto {
    @NotBlank
    private String tenDot;
    
    @NotNull
    private LoaiThuPhi loai;
    
    @NotNull
    private LocalDate ngayBatDau;
    
    @NotNull
    private LocalDate ngayKetThuc;
    
    private Integer dinhMuc;  // Validated based on loai
}
```

---

### 4.4 Created By Tracking

**Rule:** System tracks who created the fee period

**Fields:**
- `createdBy` - ID of the account that created the period
- `createdAt` - Timestamp of creation
- `updatedAt` - Timestamp of last update

**Implementation:** Automatically set in service layer from SecurityContext

---

## 5. Account Management Rules

### 5.1 Username Uniqueness

**Rule:** `tenDangNhap` must be unique

**Validation:** Enforced at database level with UNIQUE constraint

**Error Message:**
```
"Tên đăng nhập đã tồn tại"
```

---

### 5.2 Password Requirements

**Rule:** Password must meet minimum security standards

**Requirements:**
- Minimum length: 6 characters
- Stored as BCrypt hash (never plain text)

**Implementation:**
```java
String hashedPassword = passwordEncoder.encode(plainPassword);
```

---

### 5.3 Role Assignment

**Rule:** Every account must have exactly one role

**Valid Roles:**
- `ADMIN` - System administrator
- `TOTRUONG` - Population manager
- `KETOAN` - Accountant

**Implementation:**
```java
public enum Role {
    ADMIN,
    TOTRUONG,
    KETOAN
}
```

---

### 5.4 Account Deletion Restrictions

**Rule:** Certain accounts cannot be deleted

**Restrictions:**
1. Cannot delete ADMIN accounts
2. Cannot delete your own account

**Implementation:** Enforced in `TaiKhoanService.deleteAccount()`

**Error Message:**
```
"Không thể xóa tài khoản ADMIN hoặc chính mình"
```

**Code Logic:**
```java
public void deleteAccount(Long accountId, String currentUsername) {
    TaiKhoan account = repository.findById(accountId)
        .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
    
    // Check if deleting own account
    if (account.getTenDangNhap().equals(currentUsername)) {
        throw new RuntimeException("Không thể xóa tài khoản ADMIN hoặc chính mình");
    }
    
    // Check if deleting ADMIN account
    if (account.getRole() == Role.ADMIN) {
        throw new RuntimeException("Không thể xóa tài khoản ADMIN hoặc chính mình");
    }
    
    repository.delete(account);
}
```

---

## 6. Authorization Rules

### 6.1 Role-Based Access Control

**Rule:** Each endpoint requires specific roles

**Access Matrix:**

| Operation | ADMIN | TOTRUONG | KETOAN |
|-----------|-------|----------|---------|
| **Authentication** |
| Register | ✅ | ✅ | ✅ |
| Login | ✅ | ✅ | ✅ |
| **Citizens** |
| View All | ✅ | ✅ | ✅ |
| Create | ✅ | ✅ | ❌ |
| Update | ✅ | ✅ | ❌ |
| Delete | ✅ | ✅ | ❌ |
| TamTru/TamVang | ✅ | ✅ | ❌ |
| **Households** |
| View All | ✅ | ✅ | ✅ |
| Create | ✅ | ✅ | ❌ |
| Update | ✅ | ✅ | ❌ |
| Delete | ✅ | ✅ | ❌ |
| **Fee Periods** |
| View All | ✅ | ✅ | ✅ |
| Create | ✅ | ✅ | ❌ |
| Update | ✅ | ✅ | ❌ |
| Delete | ✅ | ✅ | ❌ |
| **Fee Collections** |
| View All | ✅ | ✅ | ✅ |
| Create | ✅ | ❌ | ✅ |
| Update | ✅ | ❌ | ✅ |
| Delete | ✅ | ❌ | ✅ |
| Calculate | ✅ | ✅ | ✅ |
| **Accounts** |
| View All | ✅ | ❌ | ❌ |
| Delete | ✅ | ❌ | ❌ |

**Implementation:**
```java
@PreAuthorize("hasAnyRole('ADMIN', 'TOTRUONG', 'KETOAN')")  // View
@PreAuthorize("hasAnyRole('ADMIN', 'TOTRUONG')")  // Citizen/Household
@PreAuthorize("hasAnyRole('ADMIN', 'KETOAN')")  // Fee operations
@PreAuthorize("hasRole('ADMIN')")  // Account management
```

---

### 6.2 JWT Token Expiration

**Rule:** JWT tokens expire after 24 hours

**Configuration:**
```
EXPIRATION = 86400000 ms = 24 hours
```

**Behavior:**
- After expiration, user must login again
- Frontend should handle 401 Unauthorized responses

---

### 6.3 CORS Configuration

**Rule:** API allows cross-origin requests from frontend

**Allowed Origins:**
- `http://localhost:3000` (React dev server)
- `http://localhost:5173` (Vite dev server)

**Allowed Methods:**
- GET, POST, PUT, DELETE, OPTIONS

**Implementation:** Configured in `SecurityConfig.corsConfigurationSource()`

---

## Summary

These business rules are **extracted directly from the source code** and represent the **actual behavior** of the QuanLyDanCu backend system. The most complex rules involve:

1. **Fee calculation with member counting** - Excludes temporarily absent citizens
2. **Multiple payment support** - Status across all related records
3. **Payment date validation** - Must be within fee period range
4. **Automatic recalculation** - Triggered by household changes
5. **Role-based authorization** - Granular access control

All error messages shown are **exact strings from the code**, not assumptions.

---

**End of Business Rules Documentation**
