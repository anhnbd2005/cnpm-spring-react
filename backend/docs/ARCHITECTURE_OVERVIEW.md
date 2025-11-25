# Architecture Overview

> **System Architecture Documentation - Based on Actual Implementation**  
> Last updated: December 2024  
> Spring Boot 3.3.5 | Java 17 | PostgreSQL

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Technology Stack](#2-technology-stack)
3. [Architecture Layers](#3-architecture-layers)
4. [Package Structure](#4-package-structure)
5. [Security Architecture](#5-security-architecture)
6. [Database Design](#6-database-design)
7. [Key Workflows](#7-key-workflows)
8. [Design Patterns](#8-design-patterns)

---

## 1. System Overview

QuanLyDanCu is a **Spring Boot RESTful backend** system for managing residential population and fee collection. The system follows a **layered architecture** with clear separation of concerns.

### Core Features
- **Population Management**: Citizens (Nhân Khẩu) and Households (Hộ Khẩu)
- **Fee Collection**: Mandatory and voluntary fee management
- **Authentication & Authorization**: JWT-based with role-based access control
- **Population Change Tracking**: Temporary residence/absence, death registration

### Architecture Principles
- ✅ **Layered Architecture** - Controller → Service → Repository
- ✅ **Dependency Injection** - Spring IoC container
- ✅ **RESTful API Design** - Stateless, resource-oriented
- ✅ **Security First** - JWT authentication + role-based authorization
- ✅ **Data Validation** - Jakarta Bean Validation
- ✅ **Centralized Exception Handling** - Global error management

---

## 2. Technology Stack

### Backend Framework
- **Spring Boot 3.3.5** - Main application framework
- **Spring Web** - REST API support
- **Spring Data JPA** - Database access layer
- **Spring Security** - Authentication & authorization
- **Hibernate** - ORM implementation

### Database
- **PostgreSQL** - Production database
- **Flyway/Liquibase** (if configured) - Database migration

### Security
- **JWT (JSON Web Tokens)** - Stateless authentication
- **BCrypt** - Password hashing
- **CORS** - Cross-origin resource sharing

### Validation & Utilities
- **Jakarta Validation (javax.validation)** - Input validation
- **Lombok** - Boilerplate code reduction
- **Jackson** - JSON serialization/deserialization

### Build Tool
- **Maven** - Dependency management and build automation

---

## 3. Architecture Layers

### 3.1 Presentation Layer (Controllers)

**Location:** `com.example.QuanLyDanCu.controller`

**Responsibility:** Handle HTTP requests, validate input, return responses

**Components:**
- `AuthController` - Authentication (login, register)
- `NhanKhauController` - Citizen management
- `HoKhauController` - Household management
- `DotThuPhiController` - Fee period management
- `ThuPhiHoKhauController` - Fee collection
- `TaiKhoanController` - Account management
- `BienDongController` - Population change tracking

**Key Features:**
- `@RestController` annotation for REST endpoints
- `@PreAuthorize` for method-level security
- Request validation using `@Valid` and DTO objects
- Exception handling via `@ExceptionHandler`

**Example:**
```java
@RestController
@RequestMapping("/api/thu-phi-ho-khau")
@PreAuthorize("hasAnyRole('ADMIN', 'KETOAN', 'TOTRUONG')")
public class ThuPhiHoKhauController {
    
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'KETOAN')")
    public ResponseEntity<?> create(@Valid @RequestBody ThuPhiHoKhauRequestDto dto) {
        // Delegate to service layer
    }
}
```

---

### 3.2 Service Layer

**Location:** `com.example.QuanLyDanCu.service`

**Responsibility:** Business logic, transaction management, data orchestration

**Components:**
- `AuthService` - Authentication logic
- `HoKhauService` - Household business logic
- `ThuPhiHoKhauService` - **Core fee collection logic** (642 lines)
- Additional services for other entities

**Key Features:**
- `@Service` annotation
- `@Transactional` for database transactions
- Complex business logic implementation
- Data validation and transformation

**Critical Service: ThuPhiHoKhauService**

This service contains the **most complex business logic** in the system:

```java
@Service
public class ThuPhiHoKhauService {
    
    // Calculate active members (exclude temporarily absent)
    private int countActiveMembersInHousehold(Long hoKhauId) {
        List<NhanKhau> members = nhanKhauRepository.findByHoKhauId(hoKhauId);
        int count = 0;
        LocalDate today = LocalDate.now();
        for (NhanKhau nk : members) {
            if (nk.getTamVangDen() == null || nk.getTamVangDen().isBefore(today)) {
                count++;
            }
        }
        return count;
    }
    
    // Calculate annual fee: dinhMuc × 12 × memberCount
    private BigDecimal calculateAnnualFee(int dinhMuc, int numberOfPeople) {
        return BigDecimal.valueOf(dinhMuc)
            .multiply(BigDecimal.valueOf(12))
            .multiply(BigDecimal.valueOf(numberOfPeople));
    }
    
    // Validate payment date is within fee period
    private void validatePaymentDate(LocalDate ngayThu, DotThuPhi dotThuPhi) {
        if (ngayThu != null) {
            if (ngayThu.isBefore(dotThuPhi.getNgayBatDau())) {
                throw new RuntimeException("Chưa bắt đầu...");
            }
            if (ngayThu.isAfter(dotThuPhi.getNgayKetThuc())) {
                throw new RuntimeException("Đã kết thúc vào " + 
                    dotThuPhi.getNgayKetThuc() + "...");
            }
        }
    }
    
    // Calculate total paid across ALL payment records
    private BigDecimal calculateTotalPaid(Long hoKhauId, Long dotThuPhiId) {
        List<ThuPhiHoKhau> allRecords = 
            repository.findByHoKhauIdAndDotThuPhiId(hoKhauId, dotThuPhiId);
        return allRecords.stream()
            .map(ThuPhiHoKhau::getSoTienDaThu)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
    
    // Determine status based on total paid
    private String determineStatus(BigDecimal totalPaid, BigDecimal tongPhi, 
                                   LoaiThuPhi loai) {
        if (loai == LoaiThuPhi.TU_NGUYEN) {
            return "KHONG_AP_DUNG";
        }
        return totalPaid.compareTo(tongPhi) >= 0 ? "DA_NOP" : "CHUA_NOP";
    }
    
    // Update ALL related records to maintain consistency
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
}
```

**Why This Service is Critical:**
- Handles **multiple partial payments** for same household + fee period
- Maintains **status consistency** across all related records
- Implements **complex member counting** (excludes temporarily absent citizens)
- Validates **payment dates** within fee period boundaries
- Automatically **recalculates fees** when household members change

---

### 3.3 Repository Layer

**Location:** `com.example.QuanLyDanCu.repository`

**Responsibility:** Database access, query execution

**Components:**
- `HoKhauRepository`
- `NhanKhauRepository`
- `DotThuPhiRepository`
- `ThuPhiHoKhauRepository`
- `TaiKhoanRepository`

**Key Features:**
- Extends `JpaRepository<Entity, ID>`
- Custom query methods using method naming conventions
- `@Query` annotations for complex queries
- Automatic CRUD operations

**Example:**
```java
public interface ThuPhiHoKhauRepository extends JpaRepository<ThuPhiHoKhau, Long> {
    List<ThuPhiHoKhau> findByHoKhauIdAndDotThuPhiId(Long hoKhauId, Long dotThuPhiId);
    List<ThuPhiHoKhau> findByHoKhauId(Long hoKhauId);
    List<ThuPhiHoKhau> findByDotThuPhiId(Long dotThuPhiId);
    
    @Query("SELECT COUNT(t) FROM ThuPhiHoKhau t WHERE t.trangThai = 'DA_NOP'")
    long countPaidRecords();
}
```

---

### 3.4 Entity Layer

**Location:** `com.example.QuanLyDanCu.entity`

**Responsibility:** Database table mapping, data model

**Components:**
- `NhanKhau` (Citizen)
- `HoKhau` (Household)
- `DotThuPhi` (Fee Period)
- `ThuPhiHoKhau` (Fee Collection)
- `TaiKhoan` (Account)

**Key Features:**
- `@Entity` annotation
- `@Id` and `@GeneratedValue` for primary keys
- `@ManyToOne`, `@OneToMany` for relationships
- Lombok annotations (`@Data`, `@NoArgsConstructor`, etc.)

**Critical Entity: ThuPhiHoKhau**

```java
@Entity
@Table(name = "thu_phi_ho_khau")
@Data
public class ThuPhiHoKhau {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "ho_khau_id", nullable = false)
    private HoKhau hoKhau;
    
    @ManyToOne
    @JoinColumn(name = "dot_thu_phi_id", nullable = false)
    private DotThuPhi dotThuPhi;
    
    @Column(name = "so_nguoi")
    private Integer soNguoi;  // Auto-calculated
    
    @Column(name = "tong_phi", precision = 10, scale = 2)
    private BigDecimal tongPhi;  // Auto-calculated
    
    @Column(name = "so_tien_da_thu", precision = 10, scale = 2)
    private BigDecimal soTienDaThu;  // User input
    
    @Column(name = "trang_thai", length = 20)
    private String trangThai;  // Auto-determined
    
    @Column(name = "ngay_thu")
    private LocalDate ngayThu;
    
    @Column(name = "ghi_chu", columnDefinition = "TEXT")
    private String ghiChu;
    
    @ManyToOne
    @JoinColumn(name = "collected_by")
    private TaiKhoan collectedBy;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
```

**Important Fields:**
- **soNguoi**: Calculated excluding temporarily absent citizens
- **tongPhi**: dinhMuc × 12 × soNguoi
- **trangThai**: Determined by comparing total paid vs tongPhi across ALL records

---

### 3.5 DTO Layer

**Location:** DTO classes are defined within service/controller packages or separate dto package

**Responsibility:** Data transfer between layers, input validation

**Key DTOs:**
- `ThuPhiHoKhauRequestDto` - Fee collection input
- `DotThuPhiRequestDto` - Fee period input
- `NhanKhauRequestDto` - Citizen input
- `HoKhauRequestDto` - Household input

**Example: ThuPhiHoKhauRequestDto**

```java
@Data
public class ThuPhiHoKhauRequestDto {
    @NotNull(message = "Hộ khẩu không được để trống")
    private Long hoKhauId;
    
    @NotNull(message = "Đợt thu phí không được để trống")
    private Long dotThuPhiId;
    
    @NotNull(message = "Số tiền đã thu không được để trống")
    @PositiveOrZero(message = "Số tiền phải >= 0")
    private BigDecimal soTienDaThu;
    
    private LocalDate ngayThu;  // Optional, but validated if provided
    
    private String ghiChu;
}
```

**Validation Annotations:**
- `@NotNull` - Field cannot be null
- `@NotBlank` - String cannot be empty
- `@PositiveOrZero` - Number must be >= 0
- `@PastOrPresent` - Date must be past or today

---

## 4. Package Structure

```
com.example.QuanLyDanCu/
├── QuanLyDanCuApplication.java         # Main application entry point
├── config/
│   └── SecurityConfig.java             # Security configuration
├── controller/
│   ├── AuthController.java
│   ├── HoKhauController.java
│   ├── NhanKhauController.java
│   ├── DotThuPhiController.java
│   ├── ThuPhiHoKhauController.java
│   ├── TaiKhoanController.java
│   └── BienDongController.java
├── service/
│   ├── AuthService.java
│   ├── HoKhauService.java
│   ├── ThuPhiHoKhauService.java        # CORE business logic (642 lines)
│   └── ...
├── repository/
│   ├── HoKhauRepository.java
│   ├── NhanKhauRepository.java
│   ├── DotThuPhiRepository.java
│   ├── ThuPhiHoKhauRepository.java
│   ├── TaiKhoanRepository.java
│   └── ...
├── entity/
│   ├── HoKhau.java
│   ├── NhanKhau.java
│   ├── DotThuPhi.java
│   ├── ThuPhiHoKhau.java
│   ├── TaiKhoan.java
│   └── ...
├── security/
│   ├── JwtUtil.java                    # JWT token generation/validation
│   └── JwtFilter.java                  # Request filter for JWT
└── exception/
    └── GlobalExceptionHandler.java     # Centralized error handling
```

---

## 5. Security Architecture

### 5.1 Authentication Flow

```
1. User → POST /api/auth/login {username, password}
2. AuthController → AuthService.authenticate()
3. AuthService → Verify password with BCrypt
4. AuthService → Generate JWT token using JwtUtil
5. Return JWT token to user
6. User → Include token in Authorization header for subsequent requests
7. JwtFilter → Intercept request, validate token
8. SecurityContext → Set authentication if valid
9. Controller → Check @PreAuthorize for role-based access
10. Execute request or return 403 Forbidden
```

### 5.2 SecurityConfig.java

**Location:** `com.example.QuanLyDanCu.config.SecurityConfig`

**Key Configuration:**

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())  // Disable CSRF for stateless API
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()  // Public endpoints
                .anyRequest().authenticated()  // All other endpoints require auth
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)  // No sessions
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",   // React dev server
            "http://localhost:5173"    // Vite dev server
        ));
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(Arrays.asList("*"));
        config.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
```

### 5.3 JWT Implementation

**JwtUtil.java:**
```java
@Component
public class JwtUtil {
    private static final String SECRET = "your-secret-key";
    private static final long EXPIRATION = 86400000; // 24 hours
    
    public String generateToken(String username, String role) {
        return Jwts.builder()
            .setSubject(username)
            .claim("role", role)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
            .signWith(SignatureAlgorithm.HS256, SECRET)
            .compact();
    }
    
    public Claims extractClaims(String token) {
        return Jwts.parser()
            .setSigningKey(SECRET)
            .parseClaimsJws(token)
            .getBody();
    }
    
    public boolean isTokenValid(String token) {
        try {
            extractClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
```

**JwtFilter.java:**
```java
@Component
public class JwtFilter extends OncePerRequestFilter {
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   FilterChain filterChain) {
        String header = request.getHeader("Authorization");
        
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            
            if (jwtUtil.isTokenValid(token)) {
                Claims claims = jwtUtil.extractClaims(token);
                String username = claims.getSubject();
                String role = claims.get("role", String.class);
                
                // Set authentication in SecurityContext
                UsernamePasswordAuthenticationToken auth = 
                    new UsernamePasswordAuthenticationToken(username, null, 
                        Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + role)));
                
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
        }
        
        filterChain.doFilter(request, response);
    }
}
```

### 5.4 Role-Based Authorization

**Roles:**
- `ADMIN` - Full system access
- `TOTRUONG` - Population management
- `KETOAN` - Fee management

**Method-Level Security:**
```java
@PreAuthorize("hasAnyRole('ADMIN', 'KETOAN')")  // Only ADMIN or KETOAN
public ResponseEntity<?> createFeeCollection(...) { }

@PreAuthorize("hasRole('ADMIN')")  // Only ADMIN
public ResponseEntity<?> deleteAccount(...) { }

@PreAuthorize("hasAnyRole('ADMIN', 'TOTRUONG', 'KETOAN')")  // All roles
public ResponseEntity<?> getAllCitizens(...) { }
```

---

## 6. Database Design

### 6.1 Entity Relationships

```
TaiKhoan (Account)
    ↓
    1:N
    ↓
NhanKhau (Citizen) ←─────┐
    ↓                    │
    N:1                  │
    ↓                    │
HoKhau (Household)       │
    ↓                    │
    1:N                  │
    ↓                    │
ThuPhiHoKhau ───────────┘
    ↓
    N:1
    ↓
DotThuPhi (Fee Period)
    ↓
    N:1
    ↓
TaiKhoan (created_by)
```

### 6.2 Key Tables

**ho_khau (Household)**
```sql
CREATE TABLE ho_khau (
    id BIGSERIAL PRIMARY KEY,
    so_ho_khau VARCHAR(50) UNIQUE NOT NULL,
    ten_chu_ho VARCHAR(100) NOT NULL,
    dia_chi_thuong_tru TEXT NOT NULL,
    so_thanh_vien INT DEFAULT 0
);
```

**nhan_khau (Citizen)**
```sql
CREATE TABLE nhan_khau (
    id BIGSERIAL PRIMARY KEY,
    ho_ten VARCHAR(100) NOT NULL,
    ngay_sinh DATE NOT NULL,
    gioi_tinh VARCHAR(10) NOT NULL,
    dan_toc VARCHAR(50),
    quoc_tich VARCHAR(50),
    nghe_nghiep VARCHAR(100),
    cmnd_cccd VARCHAR(20),
    ngay_cap DATE,
    noi_cap VARCHAR(100),
    quan_he_chu_ho VARCHAR(50),
    ghi_chu TEXT,
    ho_khau_id BIGINT NOT NULL,
    tam_tru_tu DATE,
    tam_tru_den DATE,
    tam_vang_tu DATE,
    tam_vang_den DATE,
    ngay_khai_tu DATE,
    ly_do_khai_tu TEXT,
    FOREIGN KEY (ho_khau_id) REFERENCES ho_khau(id) ON DELETE CASCADE
);
```

**dot_thu_phi (Fee Period)**
```sql
CREATE TABLE dot_thu_phi (
    id BIGSERIAL PRIMARY KEY,
    ten_dot VARCHAR(200) NOT NULL,
    loai VARCHAR(20) NOT NULL,  -- BAT_BUOC or TU_NGUYEN
    ngay_bat_dau DATE NOT NULL,
    ngay_ket_thuc DATE NOT NULL,
    dinh_muc INT DEFAULT 0,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES tai_khoan(id)
);
```

**thu_phi_ho_khau (Fee Collection)**
```sql
CREATE TABLE thu_phi_ho_khau (
    id BIGSERIAL PRIMARY KEY,
    ho_khau_id BIGINT NOT NULL,
    dot_thu_phi_id BIGINT NOT NULL,
    so_nguoi INT,
    tong_phi DECIMAL(10,2),
    so_tien_da_thu DECIMAL(10,2) NOT NULL,
    trang_thai VARCHAR(20),
    ngay_thu DATE,
    ghi_chu TEXT,
    collected_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ho_khau_id) REFERENCES ho_khau(id) ON DELETE CASCADE,
    FOREIGN KEY (dot_thu_phi_id) REFERENCES dot_thu_phi(id) ON DELETE CASCADE,
    FOREIGN KEY (collected_by) REFERENCES tai_khoan(id)
);
```

---

## 7. Key Workflows

### 7.1 Fee Collection Workflow

```
1. ADMIN/KETOAN creates DotThuPhi (Fee Period)
   - Specifies: tenDot, loai (BAT_BUOC/TU_NGUYEN), dates, dinhMuc
   
2. System auto-calculates fees for each household (for BAT_BUOC):
   - Counts active members (excludes tamVangDen >= today)
   - Calculates: tongPhi = dinhMuc × 12 × memberCount
   
3. KETOAN records payment via POST /api/thu-phi-ho-khau:
   - Validates payment date within period range
   - System auto-fills: soNguoi, tongPhi
   - System calculates total paid across ALL records
   - System determines trangThai: DA_NOP or CHUA_NOP
   
4. If partial payment:
   - KETOAN records another payment (same hoKhauId + dotThuPhiId)
   - System sums ALL payments
   - System updates status for ALL related records
   
5. Automatic recalculation:
   - When member added to household → recalculate fees
   - When member removed → recalculate fees
   - When tamVang status changes → recalculate fees
```

### 7.2 Authentication Workflow

```
1. User registers via POST /api/auth/register
   - Password hashed with BCrypt
   - Account created with assigned role
   
2. User logs in via POST /api/auth/login
   - System verifies password
   - JWT token generated with username + role
   - Token returned to client
   
3. Client includes token in subsequent requests:
   Authorization: Bearer {token}
   
4. JwtFilter intercepts request:
   - Validates token
   - Extracts username and role
   - Sets SecurityContext authentication
   
5. Controller checks @PreAuthorize:
   - If role matches → execute request
   - If role doesn't match → 403 Forbidden
```

---

## 8. Design Patterns

### 8.1 Layered Architecture Pattern
- Clear separation: Controller → Service → Repository
- Each layer has single responsibility
- Dependencies flow downward

### 8.2 Dependency Injection Pattern
- Spring IoC container manages all beans
- `@Autowired` for dependency injection
- Loose coupling between components

### 8.3 DTO Pattern
- Separate data transfer objects from entities
- Validation at DTO level
- Prevents over-fetching/under-fetching

### 8.4 Repository Pattern
- Abstract database operations
- JpaRepository provides CRUD operations
- Custom queries via method naming or @Query

### 8.5 Service Facade Pattern
- Service layer encapsulates complex business logic
- Controllers delegate to services
- Services orchestrate multiple repository calls

### 8.6 Filter Pattern
- JwtFilter intercepts all requests
- Validates authentication before reaching controllers
- Implements OncePerRequestFilter

---

## Summary

The QuanLyDanCu backend follows **Spring Boot best practices** with:
- **Clear layered architecture** for maintainability
- **JWT-based security** for stateless authentication
- **Role-based authorization** for fine-grained access control
- **Comprehensive validation** at all levels
- **Complex business logic** in service layer (especially fee calculations)
- **RESTful API design** for frontend integration

The most **critical component** is `ThuPhiHoKhauService`, which handles:
- Multiple partial payments
- Status consistency across records
- Member counting with exclusions
- Date validation
- Automatic recalculation triggers

---

**End of Architecture Overview**
