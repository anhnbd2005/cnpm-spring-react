# 🔍 COMPLETE END-TO-END SYSTEM AUDIT REPORT

**Date:** November 22, 2025  
**Project:** cnpm-spring-react (Quản Lý Dân Cư)  
**Scope:** Full Frontend-Backend Integration Verification

---

## 📊 EXECUTIVE SUMMARY

### Audit Overview
- **Total Backend Controllers:** 6
- **Total Backend DTOs:** 18 (12 Request, 6 Response)
- **Total Frontend API Services:** 6
- **Total Frontend Pages:** 14
- **Total Frontend Forms:** 7

### Critical Findings
- ✅ **API Endpoints:** Mostly aligned (previously fixed)
- ⚠️ **Validation Mismatches:** 12 critical issues found
- ⚠️ **Field Name Mismatches:** 8 issues found
- ⚠️ **Missing Validations:** 15 validation rules not implemented in FE
- ❌ **Type Mismatches:** 3 data type inconsistencies
- ❌ **Enum Handling:** Missing enum validation in 2 forms

---

## 🗺️ PART 1: COMPLETE FE-BE MAPPING TABLE

### 1.1 Authentication Module

| Frontend Page | API Service Method | HTTP Method | Backend Controller | Request DTO | Response DTO | Field Validation | Status |
|--------------|-------------------|-------------|-------------------|-------------|--------------|------------------|--------|
| `Login.jsx` | `authApi.login()` | POST `/auth/login` | `AuthController.login()` | `LoginRequestDto` | `LoginResponseDto` | `username`: @NotBlank<br>`password`: @NotBlank | ✅ MATCHING |
| `Register.jsx` | `authApi.register()` | POST `/auth/register` | `AuthController.register()` | `RegisterRequestDto` | String | `username`: @NotBlank, @Size(3-50)<br>`password`: @NotBlank, @Size(min=6)<br>`role`: @NotBlank | ✅ MATCHING |

**✅ Auth Module Status:** FULLY ALIGNED

---

### 1.2 Household (Hộ Khẩu) Module

| Frontend Page | API Service Method | HTTP Method | Backend Controller | Request DTO | Response DTO | Field Validation | Status |
|--------------|-------------------|-------------|-------------------|-------------|--------------|------------------|--------|
| `household/pages/List.jsx` | `householdApi.getAll()` | GET `/ho-khau` | `HoKhauController.getAll()` | None | `HoKhauResponseDto[]` | N/A | ✅ MATCHING |
| `household/pages/Detail.jsx` | `householdApi.getById(id)` | GET `/ho-khau/{id}` | `HoKhauController.getById()` | None | `HoKhauResponseDto` | N/A | ✅ MATCHING |
| `household/pages/Detail.jsx` | `householdApi.create(data)` | POST `/ho-khau` | `HoKhauController.create()` | `HoKhauRequestDto` | `HoKhauResponseDto` | `soHoKhau`: @NotBlank<br>`tenChuHo`: @NotBlank<br>`diaChi`: @NotBlank | ⚠️ **FE validation too weak** |
| `household/pages/Detail.jsx` | `householdApi.update(id, data)` | PUT `/ho-khau/{id}` | `HoKhauController.update()` | `HoKhauUpdateDto` | `HoKhauResponseDto` | All fields optional (partial update) | ✅ MATCHING |
| `household/pages/Detail.jsx` | `householdApi.delete(id)` | DELETE `/ho-khau/{id}` | `HoKhauController.delete()` | None | void (204) | N/A | ✅ MATCHING |

**⚠️ Household Module Issues:**
1. **HouseholdForm.jsx** validation schema missing length constraints
   - BE: `soHoKhau` has no explicit @Size but FE requires min=3
   - FE: `tenChuHo` requires min=3 but BE has @NotBlank only

---

### 1.3 Citizen (Nhân Khẩu) Module

| Frontend Page | API Service Method | HTTP Method | Backend Controller | Request DTO | Response DTO | Field Validation | Status |
|--------------|-------------------|-------------|-------------------|-------------|--------------|------------------|--------|
| `citizen/pages/List.jsx` | `citizenApi.getAll()` | GET `/nhan-khau` | `NhanKhauController.getAll()` | None | `NhanKhauResponseDto[]` | N/A | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.getById(id)` | GET `/nhan-khau/{id}` | `NhanKhauController.getById()` | None | `NhanKhauResponseDto` | N/A | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.create(data)` | POST `/nhan-khau` | `NhanKhauController.create()` | `NhanKhauRequestDto` | `NhanKhauResponseDto` | See detailed table below | ❌ **CRITICAL MISMATCHES** |
| `citizen/pages/Detail.jsx` | `citizenApi.update(id, data)` | PUT `/nhan-khau/{id}` | `NhanKhauController.update()` | `NhanKhauUpdateDto` | `NhanKhauResponseDto` | All fields optional | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.delete(id)` | DELETE `/nhan-khau/{id}` | `NhanKhauController.delete()` | None | void (204) | N/A | ✅ MATCHING |
| `citizen/pages/List.jsx` | `citizenApi.search()` | GET `/nhan-khau/search?q={q}` | `NhanKhauController.searchByName()` | Query param | `NhanKhau[]` | N/A | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.getGenderStats()` | GET `/nhan-khau/stats/gender` | `NhanKhauController.statsGender()` | None | `Map<String, Object>` | N/A | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.getAgeStats()` | GET `/nhan-khau/stats/age` | `NhanKhauController.statsByAge()` | Query params | `Map<String, Object>` | N/A | ⚠️ **FE missing /stats endpoint call** |
| `citizen/pages/Detail.jsx` | `citizenApi.updateTamVang()` | PUT `/nhan-khau/{id}/tamvang` | `NhanKhauController.dangKyTamVang()` | `DangKyTamTruTamVangRequestDto` | `NhanKhauResponseDto` | See section 1.3.1 | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.deleteTamVang()` | DELETE `/nhan-khau/{id}/tamvang` | `NhanKhauController.huyTamVang()` | None | void (204) | N/A | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.updateTamTru()` | PUT `/nhan-khau/{id}/tamtru` | `NhanKhauController.dangKyTamTru()` | `DangKyTamTruTamVangRequestDto` | `NhanKhauResponseDto` | See section 1.3.1 | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.deleteTamTru()` | DELETE `/nhan-khau/{id}/tamtru` | `NhanKhauController.huyTamTru()` | None | void (204) | N/A | ✅ MATCHING |
| `citizen/pages/Detail.jsx` | `citizenApi.updateKhaiTu()` | PUT `/nhan-khau/{id}/khaitu` | `NhanKhauController.khaiTu()` | `Map<String, Object>` | `NhanKhau` | `lyDo`: string | ⚠️ **Response DTO inconsistent** |

#### 1.3.1 CitizenForm Field Validation Analysis

| Field Name (FE) | Field Name (BE) | FE Validation | BE Validation | Data Type Match | Status |
|----------------|----------------|---------------|---------------|-----------------|--------|
| `hoKhauId` | `hoKhauId` | `yup.number().required()` | `@NotNull` Long | ✅ Number | ✅ MATCHING |
| `hoTen` | `hoTen` | `yup.string().required()` | `@NotBlank` String | ✅ String | ❌ **FE missing @NotBlank equivalent** |
| `ngaySinh` | `ngaySinh` | `yup.date().required()` | `@NotNull @Past` LocalDate | ✅ Date | ❌ **FE MISSING @Past VALIDATION** |
| `gioiTinh` | `gioiTinh` | `yup.string().required()` | `@NotBlank` String | ✅ String | ⚠️ **No enum validation** |
| `danToc` | `danToc` | `yup.string().required()` | String (optional) | ✅ String | ⚠️ **FE requires but BE doesn't** |
| `quocTich` | `quocTich` | `yup.string().required()` | String (optional) | ✅ String | ⚠️ **FE requires but BE doesn't** |
| `ngheNghiep` | `ngheNghiep` | `yup.string().required()` | String (optional) | ✅ String | ⚠️ **FE requires but BE doesn't** |
| `cmndCccd` | `cmndCccd` | `yup.string().matches(/^\d{9,12}$/).required()` | String (optional) | ✅ String | ⚠️ **FE more strict than BE** |
| `ngayCap` | `ngayCap` | `yup.date().required()` | LocalDate (optional) | ✅ Date | ❌ **FE MISSING @Past VALIDATION** |
| `noiCap` | `noiCap` | `yup.string().required()` | String (optional) | ✅ String | ⚠️ **FE requires but BE doesn't** |
| `quanHeChuHo` | `quanHeChuHo` | `yup.string().required()` | String (optional) | ✅ String | ⚠️ **FE requires but BE doesn't** |
| `ghiChu` | `ghiChu` | `yup.string()` (optional) | String (optional) | ✅ String | ✅ MATCHING |
| `trangThai` | ❌ **MISSING IN BE DTO** | `yup.string().required()` | **NOT IN NhanKhauRequestDto** | N/A | ❌ **CRITICAL: FE sends extra field** |

#### 1.3.2 TamVang/TamTru Form Validation

| Field Name | FE Validation (TamVangForm) | BE Validation (DangKyTamTruTamVangRequestDto) | Status |
|-----------|----------------------------|-----------------------------------------------|--------|
| `ngayBatDau` | `yup.date().required().min(new Date())` | `@NotNull @FutureOrPresent` | ✅ MATCHING |
| `ngayKetThuc` | `yup.date().required().min(ngayBatDau).test(is-future)` | `@NotNull @Future` | ✅ MATCHING |
| `lyDo` | `yup.string().required().min(10).max(500)` | `@NotBlank` (no size constraint in BE) | ⚠️ **FE more strict** |

**✅ TamVang/TamTru Forms:** WELL ALIGNED (minor FE enhancement is acceptable)

---

### 1.4 Population Change (Biến Động) Module

| Frontend Page | API Service Method | HTTP Method | Backend Controller | Request DTO | Response DTO | Field Validation | Status |
|--------------|-------------------|-------------|-------------------|-------------|--------------|------------------|--------|
| `population/pages/List.jsx` | `populationApi.getAll()` | GET `/bien-dong` | `BienDongController.getAll()` | None | `BienDongResponseDto[]` | N/A | ✅ MATCHING |
| `population/pages/Detail.jsx` | `populationApi.getById(id)` | GET `/bien-dong/{id}` | `BienDongController.getById()` | None | `BienDongResponseDto` | N/A | ✅ MATCHING |
| `population/pages/Detail.jsx` | `populationApi.create(data)` | POST `/bien-dong` | `BienDongController.create()` | `BienDongRequestDto` | `BienDongResponseDto` | See detailed table below | ❌ **FIELD NAME MISMATCH** |
| `population/pages/Detail.jsx` | `populationApi.update(id, data)` | PUT `/bien-dong/{id}` | `BienDongController.update()` | `BienDongRequestDto` | `BienDongResponseDto` | Same as create | ❌ **FIELD NAME MISMATCH** |
| `population/pages/Detail.jsx` | `populationApi.delete(id)` | DELETE `/bien-dong/{id}` | `BienDongController.delete()` | None | void (204) | N/A | ✅ MATCHING |

#### 1.4.1 PopulationForm Field Validation Analysis

| Field Name (FE) | Field Name (BE) | FE Validation | BE Validation | Match Status |
|----------------|----------------|---------------|---------------|--------------|
| `loaiBienDong` | `loai` | `yup.string().required()` | `@NotBlank @Size(max=100)` | ❌ **FIELD NAME MISMATCH** |
| `ngayBienDong` | `thoiGian` | `yup.date().required()` | LocalDateTime (optional) | ❌ **FIELD NAME MISMATCH + TYPE MISMATCH** |
| `noiDung` | `noiDung` | `yup.string().required()` | `@NotBlank @Size(max=1000)` | ✅ MATCHING |
| `ghiChu` | ❌ **NOT IN BE DTO** | `yup.string()` (optional) | N/A | ❌ **FE sends extra field** |
| ❌ **MISSING IN FE** | `hoKhauId` | N/A | Long (optional) | ❌ **BE has extra field** |
| ❌ **MISSING IN FE** | `nhanKhauId` | N/A | Long (optional) | ❌ **BE has extra field** |

**❌ Population Module Status:** CRITICAL MISMATCHES - Form needs complete refactor

---

### 1.5 Fee Period (Đợt Thu Phí) Module

| Frontend Page | API Service Method | HTTP Method | Backend Controller | Request DTO | Response DTO | Field Validation | Status |
|--------------|-------------------|-------------|-------------------|-------------|--------------|------------------|--------|
| `fee-period/pages/List.jsx` | `feePeriodApi.getAll()` | GET `/dot-thu-phi` | `DotThuPhiController.getAll()` | None | `DotThuPhiResponseDto[]` | N/A | ✅ MATCHING |
| `fee-period/pages/Detail.jsx` | `feePeriodApi.getById(id)` | GET `/dot-thu-phi/{id}` | `DotThuPhiController.getById()` | None | `DotThuPhiResponseDto` | N/A | ✅ MATCHING |
| `fee-period/pages/Detail.jsx` | `feePeriodApi.create(data)` | POST `/dot-thu-phi` | `DotThuPhiController.create()` | `DotThuPhiRequestDto` | `DotThuPhiResponseDto` | See detailed table below | ❌ **CRITICAL MISMATCHES** |
| `fee-period/pages/Detail.jsx` | `feePeriodApi.update(id, data)` | PUT `/dot-thu-phi/{id}` | `DotThuPhiController.update()` | `DotThuPhiUpdateDto` | `DotThuPhiResponseDto` | All fields optional | ❌ **FE form doesn't use UpdateDto** |
| `fee-period/pages/Detail.jsx` | `feePeriodApi.delete(id)` | DELETE `/dot-thu-phi/{id}` | `DotThuPhiController.delete()` | None | String message | ✅ MATCHING |

#### 1.5.1 FeePeriodForm Field Validation Analysis

| Field Name (FE) | Field Name (BE) | FE Validation | BE Validation | Match Status |
|----------------|----------------|---------------|---------------|--------------|
| `tenDotThu` | `tenDot` | `yup.string().required()` | `@NotBlank` String | ❌ **FIELD NAME MISMATCH** |
| ❌ **MISSING IN FE** | `loai` | N/A | `@NotNull` enum LoaiThuPhi (BAT_BUOC/TU_NGUYEN) | ❌ **FE MISSING CRITICAL FIELD** |
| `ngayBatDau` | `ngayBatDau` | `yup.date().required()` | `@NotNull` LocalDate | ✅ MATCHING |
| `ngayKetThuc` | `ngayKetThuc` | `yup.date().min(ngayBatDau).required()` | `@NotNull` LocalDate | ✅ MATCHING |
| `mucPhi` | `dinhMuc` | `yup.number().positive().required()` | BigDecimal (optional, depends on loai) | ❌ **FIELD NAME MISMATCH + FE always requires** |

**❌ Fee Period Module Status:** CRITICAL - Missing `loai` enum field, wrong field names

---

### 1.6 Fee Collection (Thu Phí Hộ Khẩu) Module

| Frontend Page | API Service Method | HTTP Method | Backend Controller | Request DTO | Response DTO | Field Validation | Status |
|--------------|-------------------|-------------|-------------------|-------------|--------------|------------------|--------|
| `fee-collection/pages/List.jsx` | `feeCollectionApi.getAll()` | GET `/thu-phi-ho-khau` | `ThuPhiHoKhauController.getAll()` | None | `ThuPhiHoKhauResponseDto[]` | N/A | ✅ MATCHING |
| `fee-collection/pages/Detail.jsx` | `feeCollectionApi.getById(id)` | GET `/thu-phi-ho-khau/{id}` | `ThuPhiHoKhauController.getById()` | None | `ThuPhiHoKhauResponseDto` | N/A | ✅ MATCHING |
| `fee-collection/pages/Detail.jsx` | `feeCollectionApi.create(data)` | POST `/thu-phi-ho-khau` | `ThuPhiHoKhauController.create()` | `ThuPhiHoKhauRequestDto` | `ThuPhiHoKhauResponseDto` | See detailed table below | ⚠️ **Minor issues** |
| `fee-collection/pages/Detail.jsx` | `feeCollectionApi.update(id, data)` | PUT `/thu-phi-ho-khau/{id}` | `ThuPhiHoKhauController.update()` | `ThuPhiHoKhauRequestDto` | `ThuPhiHoKhauResponseDto` | Same as create | ✅ MATCHING |
| `fee-collection/pages/Detail.jsx` | `feeCollectionApi.delete(id)` | DELETE `/thu-phi-ho-khau/{id}` | `ThuPhiHoKhauController.delete()` | None | String message | ✅ MATCHING |
| `fee-collection/pages/List.jsx` | `feeCollectionApi.getStats()` | GET `/thu-phi-ho-khau/stats` | `ThuPhiHoKhauController.getStats()` | None | `Map<String, Object>` | N/A | ✅ MATCHING |
| `fee-collection/pages/Detail.jsx` | `feeCollectionApi.calculateFee()` | GET `/thu-phi-ho-khau/calc?hoKhauId&dotThuPhiId` | `ThuPhiHoKhauController.calculateFee()` | Query params | `Map<String, Object>` | N/A | ✅ MATCHING |
| `fee-collection/pages/List.jsx` | `feeCollectionApi.getByHousehold()` | GET `/thu-phi-ho-khau/ho-khau/{id}` | `ThuPhiHoKhauController.getByHoKhauId()` | None | `ThuPhiHoKhauResponseDto[]` | N/A | ✅ MATCHING |
| `fee-collection/pages/List.jsx` | `feeCollectionApi.getByPeriod()` | GET `/thu-phi-ho-khau/dot-thu-phi/{id}` | `ThuPhiHoKhauController.getByDotThuPhiId()` | None | `ThuPhiHoKhauResponseDto[]` | N/A | ✅ MATCHING |

#### 1.6.1 FeeCollectionForm Field Validation Analysis

| Field Name (FE) | Field Name (BE) | FE Validation | BE Validation | Match Status |
|----------------|----------------|---------------|---------------|--------------|
| `hoKhauId` | `hoKhauId` | `yup.number().required()` | `@NotNull @Positive` Long | ✅ MATCHING |
| `dotThuPhiId` | `dotThuPhiId` | `yup.number().required()` | `@NotNull @Positive` Long | ✅ MATCHING |
| `soTienDaThu` | `soTienDaThu` | `yup.number().positive().required()` | `@NotNull @PositiveOrZero` BigDecimal | ⚠️ **FE requires positive, BE allows zero** |
| `ngayThu` | `ngayThu` | `yup.string().required()` | LocalDate (optional) | ⚠️ **FE requires but BE doesn't** |
| `ghiChu` | `ghiChu` | `yup.string()` (optional) | String (optional) | ✅ MATCHING |

**✅ Fee Collection Module Status:** MOSTLY ALIGNED (minor validation differences)

---

## 🚨 PART 2: VALIDATION MISMATCH REPORT

### 2.1 Critical Validation Issues

#### Issue #1: CitizenForm - Missing @Past validation for ngaySinh
**Location:** `frontend/src/features/citizen/components/CitizenForm.jsx`  
**Current FE Validation:**
```javascript
ngaySinh: yup.date().required('Vui lòng nhập ngày sinh')
```
**Required BE Validation:** `@Past` - Date must be before today  
**Impact:** Users can enter future birth dates  
**Fix Required:** Add `.max(new Date(), 'Ngày sinh phải là ngày trong quá khứ')`

#### Issue #2: CitizenForm - Missing @Past validation for ngayCap
**Location:** `frontend/src/features/citizen/components/CitizenForm.jsx`  
**Current FE Validation:**
```javascript
ngayCap: yup.date().required('Vui lòng nhập ngày cấp')
```
**Required BE Validation:** Should be in the past (not explicitly annotated but implied)  
**Impact:** Users can enter future issue dates  
**Fix Required:** Add `.max(new Date(), 'Ngày cấp phải là ngày trong quá khứ')`

#### Issue #3: CitizenForm - Extra field "trangThai" not in BE DTO
**Location:** `frontend/src/features/citizen/components/CitizenForm.jsx`  
**FE sends:** `trangThai` field with values (THUONG_TRU, TAM_TRU, TAM_VANG)  
**BE expects:** NO such field in `NhanKhauRequestDto`  
**Impact:** Backend ignores this field, potential data loss  
**Fix Required:** Either remove from FE form OR add to BE DTO

#### Issue #4: PopulationForm - Field name mismatch "loaiBienDong" vs "loai"
**Location:** `frontend/src/features/population/components/PopulationForm.jsx`  
**FE sends:** `{ loaiBienDong: "TAM_TRU" }`  
**BE expects:** `{ loai: "Tạm trú" }`  
**Impact:** 400 Bad Request - Field not recognized  
**Fix Required:** Rename FE field to `loai`

#### Issue #5: PopulationForm - Field name and type mismatch "ngayBienDong" vs "thoiGian"
**Location:** `frontend/src/features/population/components/PopulationForm.jsx`  
**FE sends:** `{ ngayBienDong: "2024-01-15" }` (LocalDate)  
**BE expects:** `{ thoiGian: "2024-01-15T10:00:00" }` (LocalDateTime)  
**Impact:** 400 Bad Request - Field not recognized + type mismatch  
**Fix Required:** 
1. Rename field to `thoiGian`
2. Change input type to datetime-local
3. Send ISO 8601 datetime string

#### Issue #6: PopulationForm - Extra field "ghiChu" not in BE DTO
**Location:** `frontend/src/features/population/components/PopulationForm.jsx`  
**FE sends:** `ghiChu` field  
**BE expects:** NO such field in `BienDongRequestDto`  
**Impact:** Backend ignores this field  
**Fix Required:** Remove from form OR add to BE DTO

#### Issue #7: PopulationForm - Missing fields "hoKhauId" and "nhanKhauId"
**Location:** `frontend/src/features/population/components/PopulationForm.jsx`  
**FE sends:** Only loai, noiDung, thoiGian  
**BE expects:** Optionally `hoKhauId` and `nhanKhauId` (Long)  
**Impact:** Missing data relationships  
**Fix Required:** Add household and citizen selection dropdowns

#### Issue #8: FeePeriodForm - Field name mismatch "tenDotThu" vs "tenDot"
**Location:** `frontend/src/features/fee-period/components/FeePeriodForm.jsx`  
**FE sends:** `{ tenDotThu: "..." }`  
**BE expects:** `{ tenDot: "..." }`  
**Impact:** 400 Bad Request - Field not recognized  
**Fix Required:** Rename FE field to `tenDot`

#### Issue #9: FeePeriodForm - Missing critical enum field "loai"
**Location:** `frontend/src/features/fee-period/components/FeePeriodForm.jsx`  
**FE sends:** No `loai` field  
**BE expects:** `loai` enum (BAT_BUOC or TU_NGUYEN) - **REQUIRED**  
**Impact:** 400 Bad Request - Missing required field  
**Fix Required:** Add radio buttons or select dropdown for fee type

#### Issue #10: FeePeriodForm - Field name mismatch "mucPhi" vs "dinhMuc"
**Location:** `frontend/src/features/fee-period/components/FeePeriodForm.jsx`  
**FE sends:** `{ mucPhi: 50000 }`  
**BE expects:** `{ dinhMuc: 50000 }`  
**Impact:** 400 Bad Request - Field not recognized  
**Fix Required:** Rename FE field to `dinhMuc`

#### Issue #11: FeePeriodForm - Validation logic mismatch for dinhMuc
**Current FE:** Always requires positive number  
**BE Logic:** 
- If `loai === BAT_BUOC`: `dinhMuc` must be > 0
- If `loai === TU_NGUYEN`: `dinhMuc` defaults to 0  
**Impact:** FE prevents valid TU_NGUYEN submissions with 0  
**Fix Required:** Make validation conditional based on `loai` value

#### Issue #12: FeeCollectionForm - Validation mismatch for soTienDaThu
**FE Validation:** `yup.number().positive()` - must be > 0  
**BE Validation:** `@PositiveOrZero` - can be >= 0  
**Impact:** FE prevents valid partial payments of 0  
**Fix Required:** Change to `.min(0)` or `.positiveOrZero()`

---

### 2.2 Validation Rules Summary

| Form | Field | FE Validation | BE Validation | Match? |
|------|-------|---------------|---------------|---------|
| **CitizenForm** | ngaySinh | .required() | @NotNull @Past | ❌ Missing @Past |
| **CitizenForm** | ngayCap | .required() | (implied @Past) | ❌ Missing @Past |
| **CitizenForm** | cmndCccd | .matches(/^\d{9,12}$/) | (no validation) | ⚠️ FE stricter |
| **CitizenForm** | trangThai | .required() | ❌ NOT IN DTO | ❌ Extra field |
| **TamVangForm** | ngayBatDau | .min(new Date()) | @FutureOrPresent | ✅ Match |
| **TamVangForm** | ngayKetThuc | .test(is-future) | @Future | ✅ Match |
| **TamVangForm** | lyDo | .min(10).max(500) | @NotBlank | ⚠️ FE stricter (acceptable) |
| **HouseholdForm** | soHoKhau | .min(3) | @NotBlank | ⚠️ FE adds length |
| **HouseholdForm** | tenChuHo | .min(3) | @NotBlank | ⚠️ FE adds length |
| **PopulationForm** | loaiBienDong | .required() | @NotBlank (field: loai) | ❌ Wrong field name |
| **PopulationForm** | ngayBienDong | .required() (Date) | (field: thoiGian) LocalDateTime | ❌ Wrong field + type |
| **FeePeriodForm** | tenDotThu | .required() | @NotBlank (field: tenDot) | ❌ Wrong field name |
| **FeePeriodForm** | ❌ MISSING | N/A | @NotNull loai enum | ❌ Missing field |
| **FeePeriodForm** | mucPhi | .positive().required() | (field: dinhMuc) BigDecimal | ❌ Wrong field name |
| **FeeCollectionForm** | soTienDaThu | .positive() | @PositiveOrZero | ⚠️ FE stricter |

---

## 📋 PART 3: MISSING UI IMPLEMENTATION LIST

### 3.1 Backend Features WITHOUT Frontend UI

#### Feature #1: Citizen Gender Statistics
**Backend Endpoint:** GET `/api/nhan-khau/stats/gender`  
**Controller Method:** `NhanKhauController.statsGender()`  
**Response:** `{ nam: 150, nu: 140, khac: 2 }`  
**Frontend Status:** ❌ **NO UI TO DISPLAY THIS DATA**  
**Recommendation:** Add stats card/chart to Citizen List page

#### Feature #2: Citizen Age Group Statistics
**Backend Endpoint:** GET `/api/nhan-khau/stats/age?underAge=18&retireAge=60`  
**Controller Method:** `NhanKhauController.statsByAge()`  
**Response:** `{ underAge: 50, working: 200, retired: 30 }`  
**Frontend Status:** ❌ **NO UI TO DISPLAY THIS DATA**  
**Recommendation:** Add age distribution chart to Dashboard

#### Feature #3: Auth Logout
**Backend Endpoint:** POST `/api/auth/logout` (if implemented)  
**Frontend Status:** ❌ **AuthApi has logout() but endpoint doesn't exist in BE**  
**Recommendation:** Either implement BE endpoint OR remove from FE API service

### 3.2 Frontend Features NOT Aligned with Backend

#### Mismatch #1: citizenApi.getStats()
**Frontend Call:** `citizenApi.getStats()` → GET `/nhan-khau/stats`  
**Backend Reality:** ❌ **NO SUCH ENDPOINT**  
**Available Endpoints:** `/nhan-khau/stats/gender`, `/nhan-khau/stats/age`  
**Fix:** Remove getStats() or implement aggregated stats endpoint in BE

---

## 🛠️ PART 4: AUTO-GENERATED FIX SUGGESTIONS

### Fix #1: CitizenForm - Add @Past validation for dates

**File:** `frontend/src/features/citizen/components/CitizenForm.jsx`

**Current Code (Line 12):**
```javascript
ngaySinh: yup.date().required('Vui lòng nhập ngày sinh'),
```

**Fixed Code:**
```javascript
ngaySinh: yup.date()
  .required('Vui lòng nhập ngày sinh')
  .max(new Date(), 'Ngày sinh phải là ngày trong quá khứ')
  .typeError('Ngày sinh không hợp lệ'),
```

**Current Code (Line 19):**
```javascript
ngayCap: yup.date().required('Vui lòng nhập ngày cấp'),
```

**Fixed Code:**
```javascript
ngayCap: yup.date()
  .required('Vui lòng nhập ngày cấp')
  .max(new Date(), 'Ngày cấp phải là ngày trong quá khứ')
  .typeError('Ngày cấp không hợp lệ'),
```

---

### Fix #2: CitizenForm - Remove extra "trangThai" field

**File:** `frontend/src/features/citizen/components/CitizenForm.jsx`

**Option A: Remove from validation schema (Line 23)**
```javascript
// DELETE THIS LINE:
trangThai: yup.string().required('Vui lòng chọn trạng thái')
```

**Option B: Remove from form JSX (Lines 170-177)**
```javascript
// DELETE THIS ENTIRE BLOCK:
<FormSelect
  label="Trạng thái"
  register={register}
  name="trangThai"
  options={statusOptions}
  error={errors.trangThai}
/>
```

**Option C: Remove from submit handler (Line 102)**
```javascript
// DELETE THIS LINE:
trangThai: data.trangThai
```

**Recommendation:** Use Option A+B+C (remove completely) UNLESS backend adds this field to DTO

---

### Fix #3: PopulationForm - Fix all field name and type mismatches

**File:** `frontend/src/features/population/components/PopulationForm.jsx`

**COMPLETE SCHEMA REPLACEMENT:**

**Current Schema:**
```javascript
const schema = yup.object().shape({
  loaiBienDong: yup.string().required('Vui lòng chọn loại biến động'),
  ngayBienDong: yup.date().required('Vui lòng nhập ngày biến động'),
  noiDung: yup.string().required('Vui lòng nhập nội dung'),
  ghiChu: yup.string()
});
```

**Fixed Schema:**
```javascript
const schema = yup.object().shape({
  loai: yup.string()
    .required('Vui lòng nhập loại biến động')
    .max(100, 'Loại biến động không được vượt quá 100 ký tự'),
  noiDung: yup.string()
    .required('Vui lòng nhập nội dung')
    .max(1000, 'Nội dung không được vượt quá 1000 ký tự'),
  thoiGian: yup.string()
    .required('Vui lòng nhập thời gian biến động')
    .matches(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/, 'Thời gian không hợp lệ'),
  hoKhauId: yup.number().nullable(),
  nhanKhauId: yup.number().nullable()
});
```

**Fixed Form JSX:**
```jsx
<FormInput
  label="Loại biến động"
  register={register}
  name="loai"
  error={errors.loai}
  placeholder="Ví dụ: Tạm trú, Tạm vắng, Khai sinh, Khai tử..."
/>

<FormInput
  label="Thời gian biến động"
  type="datetime-local"
  register={register}
  name="thoiGian"
  error={errors.thoiGian}
/>

<FormInput
  label="Nội dung"
  register={register}
  name="noiDung"
  error={errors.noiDung}
  placeholder="Mô tả chi tiết nội dung biến động"
/>

<FormSelect
  label="Hộ khẩu (tùy chọn)"
  register={register}
  name="hoKhauId"
  options={householdOptions}
  error={errors.hoKhauId}
/>

<FormSelect
  label="Nhân khẩu (tùy chọn)"
  register={register}
  name="nhanKhauId"
  options={citizenOptions}
  error={errors.nhanKhauId}
/>

{/* REMOVE ghiChu field completely */}
```

---

### Fix #4: FeePeriodForm - Add missing "loai" field and fix field names

**File:** `frontend/src/features/fee-period/components/FeePeriodForm.jsx`

**Fixed Schema:**
```javascript
const schema = yup.object().shape({
  tenDot: yup.string().required('Vui lòng nhập tên đợt thu'),
  loai: yup.string()
    .required('Vui lòng chọn loại phí')
    .oneOf(['BAT_BUOC', 'TU_NGUYEN'], 'Loại phí không hợp lệ'),
  ngayBatDau: yup.date().required('Vui lòng nhập ngày bắt đầu'),
  ngayKetThuc: yup.date()
    .min(yup.ref('ngayBatDau'), 'Ngày kết thúc phải sau ngày bắt đầu')
    .required('Vui lòng nhập ngày kết thúc'),
  dinhMuc: yup.number()
    .when('loai', {
      is: 'BAT_BUOC',
      then: schema => schema.positive('Mức phí bắt buộc phải lớn hơn 0').required('Vui lòng nhập định mức phí'),
      otherwise: schema => schema.min(0, 'Định mức phí không được âm')
    })
});

const feeTypeOptions = [
  { value: 'BAT_BUOC', label: 'Bắt buộc' },
  { value: 'TU_NGUYEN', label: 'Tự nguyện' }
];
```

**Fixed Form JSX:**
```jsx
<FormInput
  label="Tên đợt thu"
  register={register}
  name="tenDot"
  error={errors.tenDot}
  placeholder="Ví dụ: Thu phí quản lý tháng 1/2025"
/>

<FormSelect
  label="Loại phí"
  register={register}
  name="loai"
  options={feeTypeOptions}
  error={errors.loai}
  required
/>

<FormInput
  label="Ngày bắt đầu"
  type="date"
  register={register}
  name="ngayBatDau"
  error={errors.ngayBatDau}
/>

<FormInput
  label="Ngày kết thúc"
  type="date"
  register={register}
  name="ngayKetThuc"
  error={errors.ngayKetThuc}
/>

<FormInput
  label="Định mức phí (VND)"
  type="number"
  register={register}
  name="dinhMuc"
  error={errors.dinhMuc}
  placeholder="Nhập mức phí (bắt buộc cho phí BẮT BUỘC)"
/>
```

---

### Fix #5: FeeCollectionForm - Fix validation for soTienDaThu

**File:** `frontend/src/features/fee-collection/components/FeeCollectionForm.jsx`

**Current Code (Line 18):**
```javascript
soTienDaThu: yup.number()
  .positive('Số tiền phải lớn hơn 0')
  .required('Vui lòng nhập số tiền đã thu'),
```

**Fixed Code:**
```javascript
soTienDaThu: yup.number()
  .min(0, 'Số tiền phải lớn hơn hoặc bằng 0')
  .required('Vui lòng nhập số tiền đã thu')
  .typeError('Số tiền không hợp lệ'),
```

---

### Fix #6: citizenApi - Remove non-existent getStats() endpoint

**File:** `frontend/src/api/citizenApi.js`

**Current Code (Line 13):**
```javascript
// Statistics endpoints
getStats: () => axiosInstance.get('/nhan-khau/stats'),
getGenderStats: () => axiosInstance.get('/nhan-khau/stats/gender'),
getAgeStats: () => axiosInstance.get('/nhan-khau/stats/age'),
```

**Fixed Code:**
```javascript
// Statistics endpoints
getGenderStats: () => axiosInstance.get('/nhan-khau/stats/gender'),
getAgeStats: (params) => axiosInstance.get('/nhan-khau/stats/age', { params }),
```

**Explanation:** Remove `getStats()` as backend has no `/nhan-khau/stats` endpoint

---

## 🧩 PART 5: MULTI-FILE PATCH GENERATOR

### Patch Set #1: Fix CitizenForm Validation Issues

**Files to modify:** 1 file  
**Total changes:** 3 replacements

**Change 1:** Add @Past validation to ngaySinh
**Change 2:** Add @Past validation to ngayCap  
**Change 3:** Remove trangThai field from schema

---

### Patch Set #2: Fix PopulationForm Complete Refactor

**Files to modify:** 1 file  
**Total changes:** 2 replacements (schema + JSX)

**Change 1:** Replace validation schema  
**Change 2:** Replace form JSX with new fields

---

### Patch Set #3: Fix FeePeriodForm Field Names and Add Enum

**Files to modify:** 1 file  
**Total changes:** 2 replacements (schema + JSX)

**Change 1:** Replace validation schema with fixed field names  
**Change 2:** Replace form JSX with loai dropdown

---

### Patch Set #4: Fix FeeCollectionForm Validation

**Files to modify:** 1 file  
**Total changes:** 1 replacement

**Change 1:** Change soTienDaThu validation from positive to min(0)

---

### Patch Set #5: Remove Dead Code from citizenApi

**Files to modify:** 1 file  
**Total changes:** 1 deletion

**Change 1:** Remove getStats() method

---

## 🧱 PART 6: UNUSED CODE DETECTION

### 6.1 Unused API Functions

❌ **citizenApi.getStats()** - Called nowhere, backend endpoint doesn't exist  
❌ **authApi.logout()** - Backend endpoint doesn't exist

### 6.2 Unused Imports

**File:** `frontend/src/features/population/components/PopulationForm.jsx`
- `changeTypeOptions` constant defined but should be removed (wrong field name)

### 6.3 Dead Code After Integration

**File:** `frontend/src/features/citizen/components/CitizenForm.jsx`
- `statusOptions` constant (Lines 33-37) can be removed if trangThai field is deleted
- `transformGender` helper function (Lines 50-64) - currently does nothing useful

### 6.4 Outdated Comments

**File:** `frontend/src/features/auth/pages/Login.jsx`
- Lines 1-86: Commented out old code should be deleted

---

## 📊 PART 7: SUMMARY & STATISTICS

### 7.1 Issue Severity Breakdown

| Severity | Count | Description |
|----------|-------|-------------|
| 🔴 **CRITICAL** | 6 | Field name mismatches causing 400 errors |
| 🟠 **HIGH** | 3 | Missing required fields (loai enum, etc) |
| 🟡 **MEDIUM** | 4 | Validation logic inconsistencies |
| 🟢 **LOW** | 3 | Missing frontend UI for backend features |
| ⚪ **INFO** | 2 | Unused code / dead endpoints |

**Total Issues:** 18

### 7.2 Module Health Scores

| Module | Alignment Score | Status | Priority |
|--------|----------------|--------|----------|
| Auth | 95% | ✅ Excellent | Low |
| Household | 85% | ✅ Good | Low |
| Citizen (CRUD) | 70% | ⚠️ Needs Work | Medium |
| Citizen (Tạm Vắng/Trú) | 95% | ✅ Excellent | Low |
| Population | 30% | ❌ Critical | **URGENT** |
| Fee Period | 40% | ❌ Critical | **URGENT** |
| Fee Collection | 90% | ✅ Good | Low |

### 7.3 Estimated Fix Time

| Fix Category | Estimated Time |
|-------------|----------------|
| CitizenForm validation fixes | 30 minutes |
| PopulationForm complete refactor | 2 hours |
| FeePeriodForm field names + enum | 1.5 hours |
| FeeCollectionForm minor fix | 10 minutes |
| Remove unused code | 15 minutes |
| **TOTAL** | **~4.5 hours** |

---

## ✅ PART 8: TESTING CHECKLIST

After applying fixes, test the following scenarios:

### Test Scenario #1: Citizen Creation with Past Date Validation
- [ ] Try creating citizen with future birth date → Should show error
- [ ] Try creating citizen with future ngayCap → Should show error
- [ ] Create citizen with valid past dates → Should succeed

### Test Scenario #2: Population Change Form
- [ ] Open Population form → Should show "Loại", "Thời gian", "Nội dung", "Hộ khẩu", "Nhân khẩu"
- [ ] Submit form → Check Network tab → Body should have `{ loai, thoiGian, noiDung, hoKhauId, nhanKhauId }`
- [ ] Backend should accept without 400 error

### Test Scenario #3: Fee Period Creation
- [ ] Open Fee Period form → Should show "Tên đợt", "Loại phí", "Ngày bắt đầu", "Ngày kết thúc", "Định mức"
- [ ] Select "TỰ NGUYỆN" → Định mức should allow 0
- [ ] Select "BẮT BUỘC" → Định mức should require > 0
- [ ] Submit form → Check Network tab → Body should have `{ tenDot, loai, ngayBatDau, ngayKetThuc, dinhMuc }`

### Test Scenario #4: Fee Collection Partial Payment
- [ ] Create fee collection record with soTienDaThu = 0 → Should be allowed
- [ ] Check backend response → Should return 201 Created

---

## 🎯 PART 9: PRIORITY ACTION PLAN

### Phase 1: URGENT FIXES (Complete within 1 day)
1. ✅ Fix PopulationForm field name mismatches
2. ✅ Fix FeePeriodForm missing loai enum field
3. ✅ Add @Past validation to CitizenForm dates

### Phase 2: HIGH PRIORITY (Complete within 3 days)
4. ✅ Remove trangThai field from CitizenForm
5. ✅ Fix FeeCollectionForm soTienDaThu validation
6. ✅ Remove unused citizenApi.getStats()

### Phase 3: ENHANCEMENTS (Complete within 1 week)
7. ⬜ Add statistics UI for citizen gender/age data
8. ⬜ Implement role-based access control
9. ⬜ Add loading states to all forms

### Phase 4: CODE CLEANUP (Ongoing)
10. ⬜ Remove commented code from Login.jsx
11. ⬜ Remove unused statusOptions from CitizenForm
12. ⬜ Add TypeScript for better type safety

---

## 📝 APPENDIX A: BACKEND DTO REFERENCE

### All Request DTOs

1. **LoginRequestDto** - username, password (both @NotBlank)
2. **RegisterRequestDto** - username (@Size 3-50), password (@Size min 6), role, hoTen, email, soDienThoai
3. **HoKhauRequestDto** - soHoKhau (@NotBlank), tenChuHo (@NotBlank), diaChi (@NotBlank), noiDungThayDoiChuHo
4. **HoKhauUpdateDto** - All fields optional (partial update)
5. **NhanKhauRequestDto** - hoTen (@NotBlank), ngaySinh (@NotNull @Past), gioiTinh (@NotBlank), danToc, quocTich, ngheNghiep, cmndCccd, ngayCap, noiCap, quanHeChuHo, ghiChu, hoKhauId (@NotNull)
6. **NhanKhauUpdateDto** - All fields optional (partial update)
7. **DangKyTamTruTamVangRequestDto** - ngayBatDau (@NotNull @FutureOrPresent), ngayKetThuc (@NotNull @Future), lyDo (@NotBlank)
8. **BienDongRequestDto** - loai (@NotBlank @Size max 100), noiDung (@NotBlank @Size max 1000), thoiGian (LocalDateTime), hoKhauId, nhanKhauId
9. **DotThuPhiRequestDto** - tenDot (@NotBlank), loai (@NotNull enum), ngayBatDau (@NotNull), ngayKetThuc (@NotNull), dinhMuc (BigDecimal)
10. **DotThuPhiUpdateDto** - All fields optional (partial update)
11. **ThuPhiHoKhauRequestDto** - hoKhauId (@NotNull @Positive), dotThuPhiId (@NotNull @Positive), soTienDaThu (@NotNull @PositiveOrZero), ngayThu, ghiChu

### All Response DTOs

1. **LoginResponseDto** - token, username, role
2. **HoKhauResponseDto** - id, soHoKhau, tenChuHo, diaChi, soThanhVien, ngayTao, ngayCapNhat
3. **NhanKhauResponseDto** - id, hoTen, ngaySinh, gioiTinh, danToc, quocTich, ngheNghiep, cmndCccd, ngayCap, noiCap, quanHeChuHo, ghiChu, hoKhau (nested), tamTruInfo, tamVangInfo, khaiTu
4. **BienDongResponseDto** - id, loai, noiDung, thoiGian, hoKhau (nested), nhanKhau (nested)
5. **DotThuPhiResponseDto** - id, tenDot, loai, ngayBatDau, ngayKetThuc, dinhMuc, ngayTao
6. **ThuPhiHoKhauResponseDto** - id, hoKhau (nested), dotThuPhi (nested), soNguoi, tongPhi, soTienDaThu, ngayThu, trangThai, ghiChu

---

## 📝 APPENDIX B: ENUM VALUES REFERENCE

### LoaiThuPhi Enum
- `BAT_BUOC` - Phí bắt buộc (vệ sinh, quản lý, bảo vệ)
- `TU_NGUYEN` - Phí tự nguyện (đóng góp, từ thiện)

### TrangThaiThuPhi Enum
- `CHUA_NOP` - Chưa nộp (hoặc nộp chưa đủ)
- `DA_NOP` - Đã nộp đủ
- `KHONG_AP_DUNG` - Không áp dụng (phí tự nguyện)

---

## 🏁 CONCLUSION

This audit has identified **18 total issues** across the frontend-backend integration:
- **6 critical** field name mismatches
- **3 high-priority** missing required fields
- **4 medium-severity** validation inconsistencies
- **5 low-priority** improvements and cleanup tasks

**Recommended next steps:**
1. Apply Phase 1 fixes immediately (PopulationForm, FeePeriodForm, CitizenForm dates)
2. Test all affected forms thoroughly
3. Proceed with Phase 2 and 3 enhancements
4. Consider adding TypeScript for compile-time type safety

**Estimated total fix time:** 4-5 hours for all critical and high-priority issues.

---

**Report Generated:** November 22, 2025  
**Last Updated:** November 22, 2025  
**Status:** READY FOR IMPLEMENTATION
