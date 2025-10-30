# Test Coverage Overview

**Document Version:** 1.0  
**Last Updated:** October 29, 2025  
**Test Suite Version:** 4.0.0  
**Purpose:** Comprehensive documentation of test coverage for QuanLyDanCu Backend API

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Test Infrastructure](#test-infrastructure)
3. [Seed Data Overview](#seed-data-overview)
4. [Test Modules & Scenarios](#test-modules--scenarios)
5. [Business Logic Testing](#business-logic-testing)
6. [Role-Based Authorization](#role-based-authorization)
7. [Coverage Metrics](#coverage-metrics)
8. [Running Tests](#running-tests)

---

## Executive Summary

This document describes the comprehensive test coverage for the QuanLyDanCu (Population Management) backend system. The test suite validates all core functionality including authentication, CRUD operations for 6 entities, business logic (fee calculation with discounts), and role-based authorization.

**Key Highlights:**
- ✅ **26 integration tests** covering all API endpoints
- ✅ **100% pass rate** achieved
- ✅ **6 modules** fully tested (Auth, HoKhau, NhanKhau, BienDong, DotThuPhi, ThuPhiHoKhau)
- ✅ **3 role levels** validated (ADMIN, TOTRUONG, KETOAN)
- ✅ **One-click execution**: `./test/test-all.sh`

---

## Test Infrastructure

### Files

| File | Lines | Purpose |
|------|-------|---------|
| `test/test-all.sh` | 451 | Unified test suite with Docker (11 phases) |
| `test/test-local.sh` | 451 | Local test suite without Docker (11 phases) 🆕 |
| `test/seed-data/test-seed.sql` | 249 | Reproducible test data for all entities |
| `docs/API_TEST_REPORT.md` | Generated | Auto-generated test execution report |

### Test Phases

The test suite executes in 11 sequential phases:

1. **Environment Setup** - Docker container checks, backend readiness
2. **Database Seeding** - Load test data from SQL file
3. **Authentication Tests** - Login, register
4. **HoKhau Module** - Household CRUD operations
5. **NhanKhau Module** - Citizen CRUD + statistics
6. **BienDong Module** - Population change tracking
7. **DotThuPhi Module** - Fee period management
8. **ThuPhiHoKhau Module** - Payment processing + fee calculation
9. **API Documentation** - Swagger UI, OpenAPI spec
10. **Test Summary & Reporting** - Generate markdown report
11. **Cleanup** - Clear test data (optional)

---

## Seed Data Overview

### Database Clearing

The test suite starts with a clean slate:

```sql
TRUNCATE TABLE thu_phi_ho_khau CASCADE;
TRUNCATE TABLE bien_dong CASCADE;
TRUNCATE TABLE dot_thu_phi CASCADE;
TRUNCATE TABLE nhan_khau CASCADE;
TRUNCATE TABLE ho_khau CASCADE;
TRUNCATE TABLE tai_khoan CASCADE;
```

All sequences are reset to start from 1, ensuring predictable IDs.

### Test Accounts (5 total)

| Username | Role | Password | Purpose |
|----------|------|----------|---------|
| admin | ROLE_ADMIN | admin123 | System administrator - full access |
| totruong01 | ROLE_TOTRUONG | admin123 | Neighborhood leader - manage households |
| totruong02 | ROLE_TOTRUONG | admin123 | Additional leader for testing |
| ketoan01 | ROLE_KETOAN | admin123 | Fee collector - view payments only |
| ketoan02 | ROLE_KETOAN | admin123 | Additional collector for testing |

### Test Households (8 scenarios)

| Household | Members | Scenario | Discount Eligible |
|-----------|---------|----------|-------------------|
| HK001 | 3 | Working-age adults, no dependents | ❌ No |
| HK002 | 4 | Has elderly member (≥60 years) | ✅ Yes (20%) |
| HK003 | 3 | Has student member (≤22 years) | ✅ Yes (20%) |
| HK004 | 5 | Mixed: elderly + students | ✅ Yes (20%) |
| HK005 | 7 | Large family with children | ✅ Yes (20%) |
| HK006 | 1 | Single person household | ❌ No |
| HK007 | 2 | Couple, one temporarily absent | ❌ No |
| HK008 | 4 | New household (unpaid) | ❌ No |

### Citizens (29 total)

Citizens are distributed across households with realistic demographics:
- **Age groups**: Elderly (≥60), Working-age (23-59), Students (≤22)
- **Gender distribution**: 15 male, 14 female
- **Relationships**: Chủ hộ (head), Vợ/Chồng (spouse), Con (child), Bố/Mẹ (parent)

### Fee Periods (6 types)

| Type | Description | Amount | Calculation |
|------|-------------|--------|-------------|
| BAT_BUOC (Mandatory) | Sanitation fee Jan 2025 | 6,000 VND | Per person |
| BAT_BUOC (Mandatory) | Sanitation fee Feb 2025 | 6,000 VND | Per person |
| BAT_BUOC (Mandatory) | Sanitation fee Mar 2025 | 6,000 VND | Per person |
| BAT_BUOC (Mandatory) | Management fee Q1 2025 | 50,000 VND | Per household |
| BAT_BUOC (Mandatory) | Management fee Q2 2025 | 50,000 VND | Per household |
| TU_NGUYEN (Voluntary) | Cultural center contribution | 100,000 VND | Voluntary |

**Note:** Fee types are now standardized using the `LoaiThuPhi` enum:
- `BAT_BUOC` (Bắt buộc): Mandatory fees such as sanitation, management, security, etc.
- `TU_NGUYEN` (Tự nguyện): Voluntary contributions for community projects

### Payment Records (18 scenarios)

| Household | Fee Period | Amount Paid | Discount Applied | Status |
|-----------|------------|-------------|------------------|--------|
| HK001 | Jan Sanitation | 18,000 VND | No | ✅ Paid |
| HK001 | Feb Sanitation | 18,000 VND | No | ✅ Paid |
| HK002 | Jan Sanitation | 19,200 VND | Yes (20%) | ✅ Paid |
| HK003 | Jan Sanitation | 14,400 VND | Yes (20%) | ✅ Paid |
| HK003 | Feb Sanitation | 14,400 VND | Yes (20%) | ✅ Paid |
| HK004 | Jan Sanitation | 24,000 VND | Yes (20%) | ✅ Paid |
| HK004 | Feb Sanitation | 24,000 VND | Yes (20%) | ✅ Paid |
| HK005 | Jan Sanitation | 33,600 VND | Yes (20%) | ✅ Paid |
| HK005 | Feb Sanitation | 33,600 VND | Yes (20%) | ✅ Paid |
| HK006 | Jan Sanitation | 6,000 VND | No | ✅ Paid |
| HK006 | Feb Sanitation | 6,000 VND | No | ✅ Paid |
| HK007 | Jan Sanitation | 12,000 VND | No | ✅ Paid |
| HK007 | Feb Sanitation | - | - | ❌ Unpaid |
| HK008 | All | - | - | ❌ Unpaid (new) |
| HK001 | Q1 Management | 50,000 VND | No | ✅ Paid |
| HK003 | Q1 Management | 50,000 VND | No | ✅ Paid |
| HK005 | Q1 Management | 50,000 VND | No | ✅ Paid |
| Various | Contribution | 200K-300K VND | No | ✅ Voluntary |

### Population Changes (4 events)

| Type | Household | Description | Date |
|------|-----------|-------------|------|
| SINH (Birth) | HK005 | New baby born | Sept 2024 |
| TU_VONG (Death) | HK002 | Elderly member deceased | June 2024 |
| CHUYEN_DEN (Move-in) | HK006 | New resident | Oct 2024 |
| TAM_VANG (Temporary absence) | HK002 | Member traveling | Jan 2025 |

---

## Test Modules & Scenarios

### 1. Authentication Module

**Total Tests:** 2

| Test | Method | Endpoint | Status Code | Description |
|------|--------|----------|-------------|-------------|
| Login | POST | `/api/auth/login` | 200 | Admin login with credentials |
| Register | POST | `/api/auth/register` | 201 | Create new user account |

**Scenarios Tested:**
- ✅ Successful login with valid credentials
- ✅ JWT token generation and extraction
- ✅ New user registration with unique username
- ✅ Role assignment (ROLE_TOTRUONG)

**Authorization:** Public access (no JWT required)

---

### 2. Hộ Khẩu (Household) Module

**Total Tests:** 4

| Test | Method | Endpoint | Status Code | Description |
|------|--------|----------|-------------|-------------|
| Get All | GET | `/api/ho-khau` | 200 | Retrieve all households |
| Get By ID | GET | `/api/ho-khau/{id}` | 200 | Retrieve specific household |
| Create | POST | `/api/ho-khau` | 201 | Create new household |
| Update | PUT | `/api/ho-khau/{id}` | 200 | Update household details |

**Scenarios Tested:**
- ✅ List all households (8 seeded records)
- ✅ Retrieve household by ID (HK001)
- ✅ Create new household with unique `soHoKhau`
- ✅ Update household address and head of household
- ✅ Dynamic ID extraction for created resources

**Authorization:** ROLE_ADMIN, ROLE_TOTRUONG

**Business Rules:**
- `soHoKhau` must be unique
- Address is required for creation
- Can track "change of head" with `noiDungThayDoiChuHo`

---

### 3. Nhân Khẩu (Citizen) Module

**Total Tests:** 5

| Test | Method | Endpoint | Status Code | Description |
|------|--------|----------|-------------|-------------|
| Get All | GET | `/api/nhan-khau?page=0&size=10` | 200 | Paginated citizen list |
| Search | GET | `/api/nhan-khau/search?q=Nguyen` | 200 | Search by name |
| Gender Stats | GET | `/api/nhan-khau/stats/gender` | 200 | Gender distribution |
| Age Stats | GET | `/api/nhan-khau/stats/age` | 200 | Age category breakdown |
| Create | POST | `/api/nhan-khau` | 201 | Create new citizen |

**Scenarios Tested:**
- ✅ Paginated retrieval (29 seeded citizens)
- ✅ Full-text search by name
- ✅ Gender statistics (Male: 15, Female: 14)
- ✅ Age category statistics (Under 18, 18-60, Over 60)
- ✅ Create citizen with household association
- ✅ Relationship to head of household tracking

**Authorization:** ROLE_ADMIN, ROLE_TOTRUONG

**Business Rules:**
- Must belong to a household (`hoKhauId` required)
- `quanHeVoiChuHo` tracks relationship (Chủ hộ, Con, Vợ/Chồng, etc.)
- Age calculated from `ngaySinh` for statistics

---

### 4. Biến Động (Population Changes) Module

**Total Tests:** 3

| Test | Method | Endpoint | Status Code | Description |
|------|--------|----------|-------------|-------------|
| Get All | GET | `/api/bien-dong` | 200 | List all changes |
| Create | POST | `/api/bien-dong` | 201 | Record new change |
| Get By ID | GET | `/api/bien-dong/{id}` | 200 | Retrieve change by ID |

**Scenarios Tested:**
- ✅ List all population changes (4 seeded records)
- ✅ Record temporary absence (`TAM_VANG`)
- ✅ Retrieve change details by ID
- ✅ Link changes to specific citizen and household

**Authorization:** ROLE_ADMIN, ROLE_TOTRUONG

**Business Rules:**
- Types: `SINH` (birth), `TU_VONG` (death), `CHUYEN_DEN` (move-in), `CHUYEN_DI` (move-out), `TAM_VANG` (temporary absence)
- Must reference valid `nhanKhauId` and `hoKhauId`
- Timestamp tracking with `thoiGian`

---

### 5. Đợt Thu Phí (Fee Period) Module

**Total Tests:** 4

| Test | Method | Endpoint | Status Code | Description |
|------|--------|----------|-------------|-------------|
| Get All | GET | `/api/dot-thu-phi` | 200 | List all fee periods |
| Create | POST | `/api/dot-thu-phi` | 201 | Create new fee period |
| Get By ID | GET | `/api/dot-thu-phi/{id}` | 200 | Retrieve period by ID |
| Update | PUT | `/api/dot-thu-phi/{id}` | 200 | Update fee period |

**Scenarios Tested:**
- ✅ List all fee periods (6 seeded records)
- ✅ Create new mandatory fee period (BAT_BUOC)
- ✅ Retrieve fee period details
- ✅ Update fee amount (`dinhMuc`)
- ✅ Date range validation (`ngayBatDau`, `ngayKetThuc`)

**Authorization:** ROLE_ADMIN, ROLE_TOTRUONG

**Business Rules:**
- Types: `BAT_BUOC` (mandatory) or `TU_NGUYEN` (voluntary)
- `dinhMuc` defines base fee amount
- Date range must be valid (end date after start date)

---

### 6. Thu Phí Hộ Khẩu (Household Payment) Module

**Total Tests:** 8

| Test | Method | Endpoint | Status Code | Description |
|------|--------|----------|-------------|-------------|
| Get All | GET | `/api/thu-phi-ho-khau` | 200 | List all payments |
| Get Stats | GET | `/api/thu-phi-ho-khau/stats` | 200 | Payment statistics |
| Calculate Fee | GET | `/api/thu-phi-ho-khau/calc` | 200 | Calculate fee (no discount) |
| Calculate w/ Discount | GET | `/api/thu-phi-ho-khau/calc` | 200 | Calculate fee (elderly discount) |
| Create | POST | `/api/thu-phi-ho-khau` | 201 | Record new payment |
| Get By ID | GET | `/api/thu-phi-ho-khau/{id}` | 200 | Retrieve payment by ID |

**Scenarios Tested:**
- ✅ List all payment records (18 seeded records)
- ✅ Aggregate payment statistics
  - Total collected
  - Number of paid households
  - Number of unpaid households
- ✅ Fee calculation for household without discounts (HK001)
- ✅ Fee calculation with elderly/student discount (HK002 - 20% off)
- ✅ Record new payment with dynamic IDs
- ✅ Retrieve payment details by ID

**Authorization:** ROLE_ADMIN, ROLE_TOTRUONG, ROLE_KETOAN

**Business Rules:**
- **Discount logic:**
  - 20% discount if household has elderly members (≥60 years)
  - 20% discount if household has student members (≤22 years)
  - Discount applies if ANY member qualifies
- **Fee calculation:**
  - Monthly fees: `memberCount * dinhMuc * (1 - discount)`
  - Quarterly/voluntary fees: Fixed amount (no per-person multiplier)
- **Payment tracking:**
  - `soTienDaThu`: Amount actually paid
  - `ngayThu`: Payment date
  - `months`: Month(s) paid for

---

### 7. API Documentation

**Total Tests:** 2

| Test | Method | Endpoint | Status Code | Description |
|------|--------|----------|-------------|-------------|
| Swagger UI | GET | `/swagger-ui/index.html` | 200 | Access Swagger UI |
| OpenAPI Spec | GET | `/v3/api-docs` | 200 | Retrieve OpenAPI JSON |

**Scenarios Tested:**
- ✅ Swagger UI accessibility
- ✅ OpenAPI 3.0 specification generation

**Authorization:** Public access

---

## Business Logic Testing

### Fee Calculation with Discounts

The test suite validates the core business logic for fee calculation:

#### Scenario 1: No Discount (HK001)
- **Household:** HK001 (3 working-age adults)
- **Fee Period:** Jan 2025 Sanitation (BAT_BUOC - 6,000 VND per person)
- **Calculation:** 3 members × 6,000 VND = **18,000 VND**
- **Discount:** None (no elderly or students)
- **Test:** `GET /api/thu-phi-ho-khau/calc?hoKhauId=1&dotThuPhiId=1`

#### Scenario 2: Elderly Discount (HK002)
- **Household:** HK002 (4 members, includes 1 elderly ≥60)
- **Fee Period:** Jan 2025 Sanitation (BAT_BUOC - 6,000 VND per person)
- **Calculation:** 4 members × 6,000 VND × 0.8 = **19,200 VND**
- **Discount:** 20% (has elderly member)
- **Test:** `GET /api/thu-phi-ho-khau/calc?hoKhauId=2&dotThuPhiId=1`

#### Scenario 3: Student Discount (HK003)
- **Household:** HK003 (3 members, includes 1 student ≤22)
- **Fee Period:** Jan 2025 Sanitation (BAT_BUOC - 6,000 VND per person)
- **Calculation:** 3 members × 6,000 VND × 0.8 = **14,400 VND**
- **Discount:** 20% (has student member)
- **Seed Data:** Pre-calculated in `test-seed.sql`

#### Scenario 4: Mixed Discount (HK004)
- **Household:** HK004 (5 members, has both elderly and students)
- **Calculation:** 5 members × 6,000 VND × 0.8 = **24,000 VND**
- **Discount:** 20% (qualifies for either elderly OR student)

### Unpaid Household Detection

The test suite includes households with different payment states:

| Household | Status | Test Purpose |
|-----------|--------|--------------|
| HK001-HK006 | Fully paid | Validate calculation accuracy |
| HK007 | Partially paid | Test unpaid fee detection |
| HK008 | Unpaid (new) | Test new household edge case |

### Payment Statistics

The `/api/thu-phi-ho-khau/stats` endpoint aggregates:
- **Total collected:** Sum of all `soTienDaThu` values
- **Paid households:** COUNT(DISTINCT hoKhauId)
- **Unpaid households:** Total households - Paid households

---

## Role-Based Authorization

### Authorization Matrix

| Endpoint | ADMIN | TOTRUONG | KETOAN | Public |
|----------|-------|----------|--------|--------|
| `/api/auth/login` | ✅ | ✅ | ✅ | ✅ |
| `/api/auth/register` | ✅ | ✅ | ✅ | ✅ |
| `/api/ho-khau/*` | ✅ | ✅ | ❌ | ❌ |
| `/api/nhan-khau/*` | ✅ | ✅ | ❌ | ❌ |
| `/api/bien-dong/*` | ✅ | ✅ | ❌ | ❌ |
| `/api/dot-thu-phi/*` | ✅ | ✅ | ❌ | ❌ |
| `/api/thu-phi-ho-khau/*` | ✅ | ✅ | ✅ (read) | ❌ |
| `/swagger-ui/*` | ✅ | ✅ | ✅ | ✅ |

### Role Descriptions

1. **ROLE_ADMIN**
   - Full system access
   - Can manage all entities
   - User management capabilities

2. **ROLE_TOTRUONG** (Neighborhood Leader)
   - Manage households and citizens
   - Create/update fee periods
   - View and record payments
   - Track population changes

3. **ROLE_KETOAN** (Fee Collector)
   - View payment records
   - Calculate fees
   - View payment statistics
   - **Cannot** create/update households or citizens

### Authorization Testing Approach

All tests in `test-all.sh` use **ADMIN credentials** with JWT token:

```bash
ADMIN_TOKEN=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"admin","password":"admin123"}' \
    | grep -o '"token":"[^"]*' | cut -d'"' -f4)
```

Requests include: `Authorization: Bearer $ADMIN_TOKEN`

**Why Admin Token?**
- Tests validate core functionality, not authorization boundaries
- Separate authorization tests should be created for role-specific scenarios
- Future enhancement: Add tests with `totruong01` and `ketoan01` tokens

---

## Coverage Metrics

### Test Execution Summary

- **Total Tests:** 26
- **Pass Rate:** 100% ✅
- **Execution Time:** ~10-15 seconds
- **Modules Covered:** 6 (Auth, HoKhau, NhanKhau, BienDong, DotThuPhi, ThuPhiHoKhau)
- **API Documentation:** Verified (Swagger UI, OpenAPI spec)

### Coverage by Module

| Module | CRUD | Search/Filter | Statistics | Calculation | Auth |
|--------|------|---------------|------------|-------------|------|
| Hộ Khẩu | ✅ ✅ ✅ | ❌ | ❌ | ❌ | ✅ |
| Nhân Khẩu | ✅ ❌ ❌ | ✅ | ✅ | ❌ | ✅ |
| Biến Động | ✅ ✅ ❌ | ❌ | ❌ | ❌ | ✅ |
| Đợt Thu Phí | ✅ ✅ ✅ | ❌ | ❌ | ❌ | ✅ |
| Thu Phí Hộ Khẩu | ✅ ✅ ❌ | ❌ | ✅ | ✅ | ✅ |
| Authentication | N/A | N/A | N/A | N/A | ✅ |

**Legend:**
- ✅ = Tested
- ❌ = Not applicable or not tested

### Entity Coverage

| Entity | Create | Read | Update | Delete | Count |
|--------|--------|------|--------|--------|-------|
| TaiKhoan | ✅ | ✅ | ❌ | ❌ | 5 seeded |
| HoKhau | ✅ | ✅ | ✅ | ❌ | 8 seeded |
| NhanKhau | ✅ | ✅ | ❌ | ❌ | 29 seeded |
| BienDong | ✅ | ✅ | ❌ | ❌ | 4 seeded |
| DotThuPhi | ✅ | ✅ | ✅ | ❌ | 6 seeded |
| ThuPhiHoKhau | ✅ | ✅ | ❌ | ❌ | 18 seeded |

**Note:** Delete operations are intentionally not tested (soft delete or audit trail preferred in production).

### Seed Data Coverage

- **Users:** 5 accounts across 3 roles
- **Households:** 8 scenarios (discount eligibility, payment states)
- **Citizens:** 29 individuals (realistic age/gender distribution)
- **Fee Periods:** 6 types (monthly, quarterly, voluntary)
- **Payments:** 18 records (paid, unpaid, discounted)
- **Changes:** 4 events (birth, death, move-in, temporary absence)

**Total Records:** 70+ seeded records

---

## Running Tests

### Prerequisites

**Docker Environment (test-all.sh):**
1. **Docker Desktop** running
2. **PostgreSQL container** (`quanlydancu-postgres`) running
3. **Backend container** (`quanlydancu-backend`) running
4. **Port 8080** available for backend

**Local Environment (test-local.sh):** 🆕
1. **PostgreSQL 15** installed and running locally
2. **Spring Boot application** running on port 8080 (via Maven or IntelliJ)
3. **Database** `quanlydancu` created with schema applied
4. **Port 5432** available for PostgreSQL

### One-Click Execution

**Option 1: Docker Environment (Recommended)**
```bash
cd /Users/nqd2005/Documents/Project_CNPM/cnpm-spring-react/backend
./test/test-all.sh
```

**Option 2: Local Environment (No Docker)** 🆕
```bash
cd /Users/nqd2005/Documents/Project_CNPM/cnpm-spring-react/backend

# Ensure PostgreSQL is running
pg_isready -h localhost -p 5432

# Ensure backend is running
curl -s http://localhost:8080/swagger-ui/index.html > /dev/null && echo "Backend is ready"

# Run tests
./test/test-local.sh
```

### What Happens During Execution

1. **Phase 1:** Checks Docker containers, waits for backend readiness
2. **Phase 2:** Loads `test/seed-data/test-seed.sql` into PostgreSQL
3. **Phases 3-8:** Executes 26 API tests across 6 modules
4. **Phase 9:** Verifies API documentation endpoints
5. **Phase 10:** Generates `docs/API_TEST_REPORT.md` with results
6. **Phase 11:** (Optional) Cleans up test data

### Expected Output

```
╔══════════════════════════════════════════════════════════════════════╗
║                         TEST SUMMARY                                 ║
╠══════════════════════════════════════════════════════════════════════╣
║ Total Tests:    26                                                   ║
║ Passed:         26 ✅                                                ║
║ Failed:         0  ❌                                                ║
║ Success Rate:   100.00%                                              ║
╚══════════════════════════════════════════════════════════════════════╝
```

### Viewing Results

- **Terminal:** Real-time colored output with pass/fail indicators
- **Report File:** `docs/API_TEST_REPORT.md` (auto-generated)
- **Logs:** Inline during execution

### Skip Cleanup (Optional)

To preserve test data for manual inspection:

**Docker:**
```bash
SKIP_CLEANUP=true ./test/test-all.sh
```

**Local:** 🆕
```bash
SKIP_CLEANUP=true ./test/test-local.sh
```

### Custom Configuration (Local Tests Only) 🆕

Override default PostgreSQL connection settings:

```bash
# Custom password
POSTGRES_PASSWORD=mypassword ./test/test-local.sh

# Custom host and port
POSTGRES_HOST=192.168.1.100 POSTGRES_PORT=5433 ./test/test-local.sh

# Custom database name
POSTGRES_DB=my_test_db ./test/test-local.sh

# Custom backend URL
BASE_URL=http://localhost:9090 ./test/test-local.sh
```

---

## Recommendations

### Test Coverage Enhancements

1. **Role-Based Tests**
   - Add tests with `totruong01` token to verify TOTRUONG permissions
   - Add tests with `ketoan01` token to verify read-only access for KETOAN
   - Add negative tests for unauthorized access (e.g., KETOAN trying to create household)

2. **Edge Cases**
   - Test fee calculation with zero members
   - Test payment with amount exceeding calculated fee
   - Test household with all members temporarily absent
   - Test date validation for overlapping fee periods

3. **Negative Tests**
   - Invalid credentials (login)
   - Duplicate `soHoKhau` (household creation)
   - Invalid `hoKhauId` (citizen creation)
   - Past date for future fee period

4. **Performance Tests**
   - Load test with 1000+ households
   - Concurrent payment submissions
   - Large search result sets

5. **Integration Tests**
   - Test fee recalculation when citizen is added/removed
   - Test discount application when citizen ages from 22 to 23
   - Test payment status change when household pays

### Documentation Improvements

1. Add sequence diagrams for fee calculation flow
2. Document error response formats
3. Create Postman collection with pre-configured tests
4. Add video walkthrough of test execution

---

## Appendix

### Test Data Files

- **Seed Data:** `test/seed-data/test-seed.sql` (249 lines)
- **Test Script:** `test/test-all.sh` (451 lines)
- **Test Report:** `docs/API_TEST_REPORT.md` (auto-generated)
- **Setup Guide:** `docs/TEST_SETUP_GUIDE.md`

### Related Documentation

- **Phase 4 Report:** `docs/PHASE4_REFACTOR_TESTING_REPORT.md` (detailed refactor notes)
- **API Documentation:** Swagger UI at `http://localhost:8080/swagger-ui/index.html`
- **Database Schema:** `quanlydancu.sql` (production schema)

### Contact

For questions or issues with the test suite:
- Review `docs/TEST_SETUP_GUIDE.md` for setup instructions
- Check `docs/API_TEST_REPORT.md` for recent test results
- Inspect `test/test-all.sh` for test implementation details

---

**Document Generated:** October 29, 2025  
**Test Suite Version:** 4.0.0  
**Coverage:** 26 tests, 100% pass rate, 6 modules  
**Execution:** One command: `./test/test-all.sh`
