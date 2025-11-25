# Kiến Trúc Hệ Thống - Quản Lý Dân Cư

> **Đồ án Công Nghệ Phần Mềm**  
> Phiên bản: 1.0  
> Cập nhật: Tháng 11/2024

---

## Mục Lục

1. [Tổng Quan Hệ Thống](#1-tổng-quan-hệ-thống)
2. [Công Nghệ Sử Dụng](#2-công-nghệ-sử-dụng)
3. [Kiến Trúc Phân Tầng](#3-kiến-trúc-phân-tầng)
4. [Sơ Đồ Kiến Trúc](#4-sơ-đồ-kiến-trúc)
5. [Thiết Kế Cơ Sở Dữ Liệu](#5-thiết-kế-cơ-sở-dữ-liệu)
6. [Cơ Chế Bảo Mật](#6-cơ-chế-bảo-mật)
7. [Quy Trình Nghiệp Vụ](#7-quy-trình-nghiệp-vụ)
8. [Các Mẫu Thiết Kế](#8-các-mẫu-thiết-kế)

---

## 1. Tổng Quan Hệ Thống

### 1.1 Giới Thiệu

Hệ thống Quản Lý Dân Cư là một ứng dụng web RESTful được xây dựng để hỗ trợ quản lý thông tin dân cư và thu phí tại khu dân cư. Hệ thống tuân thủ kiến trúc phân tầng (layered architecture) với sự tách biệt rõ ràng giữa các thành phần.

### 1.2 Mục Tiêu Thiết Kế

- **Tính mô-đun cao**: Mỗi tầng có trách nhiệm riêng biệt
- **Dễ bảo trì**: Code được tổ chức có cấu trúc, dễ hiểu
- **Bảo mật**: Xác thực JWT và phân quyền dựa trên vai trò
- **Khả năng mở rộng**: Dễ dàng thêm chức năng mới
- **Hiệu suất**: Tối ưu hóa truy vấn database và xử lý logic

### 1.3 Đặc Điểm Chính

- RESTful API với định dạng JSON
- Xác thực không trạng thái (stateless) sử dụng JWT
- Phân quyền dựa trên vai trò (Role-Based Access Control)
- Tự động validation dữ liệu đầu vào
- Xử lý lỗi tập trung
- Hỗ trợ CORS cho frontend

---

## 2. Công Nghệ Sử Dụng

### 2.1 Backend Framework

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| Spring Boot | 3.3.5 | Framework chính cho backend |
| Spring Web | 3.3.5 | Xây dựng RESTful API |
| Spring Data JPA | 3.3.5 | Truy xuất cơ sở dữ liệu |
| Spring Security | 3.3.5 | Xác thực và phân quyền |
| Hibernate | 6.x | ORM (Object-Relational Mapping) |

### 2.2 Database

| Công nghệ | Mục đích |
|-----------|----------|
| PostgreSQL | Cơ sở dữ liệu quan hệ chính |
| HikariCP | Connection pool |

### 2.3 Bảo Mật

| Công nghệ | Mục đích |
|-----------|----------|
| JWT (JSON Web Token) | Xác thực không trạng thái |
| BCrypt | Mã hóa mật khẩu |

### 2.4 Công Cụ Phát Triển

| Công nghệ | Mục đích |
|-----------|----------|
| Maven | Quản lý dependencies và build |
| Lombok | Giảm boilerplate code |
| Jackson | JSON serialization/deserialization |
| Jakarta Validation | Validation dữ liệu đầu vào |

---

## 3. Kiến Trúc Phân Tầng

Hệ thống tuân theo kiến trúc 4 tầng:

### 3.1 Presentation Layer (Tầng Trình Diễn)

**Trách nhiệm:**
- Nhận HTTP requests từ client
- Validation dữ liệu đầu vào cơ bản
- Chuyển đổi request thành lời gọi service
- Trả về HTTP responses

**Thành phần:**
- Controllers (AuthController, NhanKhauController, HoKhauController, v.v.)
- DTO (Data Transfer Objects)
- Exception Handlers

**Đặc điểm:**
- Sử dụng annotation `@RestController`
- Áp dụng `@PreAuthorize` cho phân quyền
- Validation với `@Valid`

---

### 3.2 Service Layer (Tầng Nghiệp Vụ)

**Trách nhiệm:**
- Xử lý logic nghiệp vụ phức tạp
- Điều phối giao dịch (transaction management)
- Kết hợp dữ liệu từ nhiều repositories
- Thực hiện các phép tính và validation phức tạp

**Thành phần:**
- AuthService: Xử lý đăng ký, đăng nhập
- HoKhauService: Logic quản lý hộ khẩu
- ThuPhiHoKhauService: **Tầng nghiệp vụ phức tạp nhất** - xử lý tính toán phí, thanh toán, tự động cập nhật trạng thái

**Đặc điểm:**
- Sử dụng annotation `@Service`
- Quản lý transaction với `@Transactional`
- Độc lập với cơ chế truyền tải (HTTP, messaging, v.v.)

---

### 3.3 Repository Layer (Tầng Truy Xuất Dữ Liệu)

**Trách nhiệm:**
- Truy xuất và thao tác dữ liệu trong database
- Cung cấp các phương thức CRUD cơ bản
- Thực thi các truy vấn tùy chỉnh

**Thành phần:**
- HoKhauRepository
- NhanKhauRepository
- DotThuPhiRepository
- ThuPhiHoKhauRepository
- TaiKhoanRepository

**Đặc điểm:**
- Extends `JpaRepository<Entity, ID>`
- Tự động sinh các phương thức CRUD
- Hỗ trợ query methods và `@Query` annotation

---

### 3.4 Domain Layer (Tầng Miền)

**Trách nhiệm:**
- Định nghĩa cấu trúc dữ liệu
- Mapping giữa object và database tables
- Định nghĩa quan hệ giữa các entities

**Thành phần:**
- Entity classes (HoKhau, NhanKhau, DotThuPhi, ThuPhiHoKhau, TaiKhoan)
- Enums (Role, LoaiThuPhi)

**Đặc điểm:**
- Sử dụng JPA annotations (`@Entity`, `@Table`, `@Column`)
- Định nghĩa relationships (`@ManyToOne`, `@OneToMany`)
- Lombok để giảm boilerplate code

---

## 4. Sơ Đồ Kiến Trúc

### 4.1 Sơ Đồ Thành Phần Tổng Quan

```mermaid
graph TB
    subgraph "Client Layer"
        Client[React Frontend]
    end
    
    subgraph "Backend System"
        subgraph "Security"
            JWTFilter[JWT Filter]
            Security[Spring Security]
        end
        
        subgraph "Presentation Layer"
            AuthC[Auth Controller]
            NhanKhauC[NhanKhau Controller]
            HoKhauC[HoKhau Controller]
            DotThuPhiC[DotThuPhi Controller]
            ThuPhiC[ThuPhiHoKhau Controller]
            TaiKhoanC[TaiKhoan Controller]
        end
        
        subgraph "Service Layer"
            AuthS[Auth Service]
            HoKhauS[HoKhau Service]
            ThuPhiS[ThuPhiHoKhau Service]
        end
        
        subgraph "Repository Layer"
            HoKhauR[HoKhau Repository]
            NhanKhauR[NhanKhau Repository]
            DotThuPhiR[DotThuPhi Repository]
            ThuPhiR[ThuPhiHoKhau Repository]
            TaiKhoanR[TaiKhoan Repository]
        end
        
        subgraph "Domain Layer"
            HoKhauE[HoKhau Entity]
            NhanKhauE[NhanKhau Entity]
            DotThuPhiE[DotThuPhi Entity]
            ThuPhiE[ThuPhiHoKhau Entity]
            TaiKhoanE[TaiKhoan Entity]
        end
    end
    
    subgraph "Database"
        PostgreSQL[(PostgreSQL Database)]
    end
    
    Client -->|HTTP/JSON| JWTFilter
    JWTFilter --> Security
    Security --> AuthC
    Security --> NhanKhauC
    Security --> HoKhauC
    Security --> DotThuPhiC
    Security --> ThuPhiC
    Security --> TaiKhoanC
    
    AuthC --> AuthS
    HoKhauC --> HoKhauS
    ThuPhiC --> ThuPhiS
    
    AuthS --> TaiKhoanR
    HoKhauS --> HoKhauR
    HoKhauS --> NhanKhauR
    ThuPhiS --> ThuPhiR
    ThuPhiS --> DotThuPhiR
    ThuPhiS --> HoKhauR
    ThuPhiS --> NhanKhauR
    
    HoKhauR --> HoKhauE
    NhanKhauR --> NhanKhauE
    DotThuPhiR --> DotThuPhiE
    ThuPhiR --> ThuPhiE
    TaiKhoanR --> TaiKhoanE
    
    HoKhauE -.->|JPA/Hibernate| PostgreSQL
    NhanKhauE -.->|JPA/Hibernate| PostgreSQL
    DotThuPhiE -.->|JPA/Hibernate| PostgreSQL
    ThuPhiE -.->|JPA/Hibernate| PostgreSQL
    TaiKhoanE -.->|JPA/Hibernate| PostgreSQL
```

### 4.2 Luồng Xử Lý Request

```mermaid
sequenceDiagram
    participant Client
    participant JWTFilter
    participant Controller
    participant Service
    participant Repository
    participant Database
    
    Client->>JWTFilter: HTTP Request + JWT Token
    JWTFilter->>JWTFilter: Validate Token
    JWTFilter->>Controller: Forward Request
    Controller->>Controller: Validate Input (DTO)
    Controller->>Service: Call Business Logic
    Service->>Service: Process Business Rules
    Service->>Repository: Query/Update Data
    Repository->>Database: SQL Query
    Database-->>Repository: Result Set
    Repository-->>Service: Entity Objects
    Service-->>Controller: Processed Data
    Controller-->>Client: JSON Response
```

---

## 5. Thiết Kế Cơ Sở Dữ Liệu

### 5.1 Sơ Đồ ERD

```mermaid
erDiagram
    TAI_KHOAN ||--o{ NHAN_KHAU : creates
    TAI_KHOAN ||--o{ DOT_THU_PHI : creates
    TAI_KHOAN ||--o{ THU_PHI_HO_KHAU : collects
    
    HO_KHAU ||--o{ NHAN_KHAU : contains
    HO_KHAU ||--o{ THU_PHI_HO_KHAU : has
    
    DOT_THU_PHI ||--o{ THU_PHI_HO_KHAU : applies_to
    
    TAI_KHOAN {
        bigint id PK
        varchar ten_dang_nhap UK
        varchar mat_khau
        varchar ho_ten
        varchar email
        varchar role
        timestamp created_at
    }
    
    HO_KHAU {
        bigint id PK
        varchar so_ho_khau UK
        varchar ten_chu_ho
        text dia_chi_thuong_tru
        int so_thanh_vien
    }
    
    NHAN_KHAU {
        bigint id PK
        varchar ho_ten
        date ngay_sinh
        varchar gioi_tinh
        varchar dan_toc
        varchar quoc_tich
        varchar nghe_nghiep
        varchar cmnd_cccd
        date ngay_cap
        varchar noi_cap
        varchar quan_he_chu_ho
        bigint ho_khau_id FK
        date tam_tru_tu
        date tam_tru_den
        date tam_vang_tu
        date tam_vang_den
        date ngay_khai_tu
        text ly_do_khai_tu
    }
    
    DOT_THU_PHI {
        bigint id PK
        varchar ten_dot
        varchar loai
        date ngay_bat_dau
        date ngay_ket_thuc
        int dinh_muc
        bigint created_by FK
        timestamp created_at
        timestamp updated_at
    }
    
    THU_PHI_HO_KHAU {
        bigint id PK
        bigint ho_khau_id FK
        bigint dot_thu_phi_id FK
        int so_nguoi
        decimal tong_phi
        decimal so_tien_da_thu
        varchar trang_thai
        date ngay_thu
        text ghi_chu
        bigint collected_by FK
        timestamp created_at
    }
```

### 5.2 Mô Tả Các Bảng Chính

**tai_khoan (Tài Khoản)**
- Lưu trữ thông tin người dùng hệ thống
- Mật khẩu được mã hóa BCrypt
- Role: ADMIN, TOTRUONG, KETOAN

**ho_khau (Hộ Khẩu)**
- Lưu trữ thông tin hộ gia đình
- so_ho_khau là định danh duy nhất
- so_thanh_vien được tự động cập nhật

**nhan_khau (Nhân Khẩu)**
- Lưu trữ thông tin công dân
- Liên kết với ho_khau qua foreign key
- Hỗ trợ tạm trú, tạm vắng, khai tử

**dot_thu_phi (Đợt Thu Phí)**
- Định nghĩa các kỳ thu phí
- Phân biệt BAT_BUOC và TU_NGUYEN
- Lưu định mức và thời gian

**thu_phi_ho_khau (Thu Phí Hộ Khẩu)**
- Ghi nhận thanh toán của từng hộ
- Hỗ trợ thanh toán nhiều lần
- Tự động tính toán số người và tổng phí

---

## 6. Cơ Chế Bảo Mật

### 6.1 Quy Trình Xác Thực

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant AuthController
    participant AuthService
    participant Database
    participant JwtUtil
    
    User->>Frontend: Nhập username/password
    Frontend->>AuthController: POST /api/auth/login
    AuthController->>AuthService: authenticate()
    AuthService->>Database: Tìm user theo username
    Database-->>AuthService: User data
    AuthService->>AuthService: Verify password (BCrypt)
    AuthService->>JwtUtil: Generate JWT Token
    JwtUtil-->>AuthService: JWT Token
    AuthService-->>AuthController: Token + User Info
    AuthController-->>Frontend: JSON Response
    Frontend->>Frontend: Lưu token vào localStorage
    Frontend-->>User: Đăng nhập thành công
```

### 6.2 Quy Trình Phân Quyền

```mermaid
sequenceDiagram
    participant Frontend
    participant JwtFilter
    participant SecurityContext
    participant Controller
    
    Frontend->>JwtFilter: Request + Authorization Header
    JwtFilter->>JwtFilter: Extract JWT Token
    JwtFilter->>JwtFilter: Validate Token
    JwtFilter->>JwtFilter: Extract username & role
    JwtFilter->>SecurityContext: Set Authentication
    JwtFilter->>Controller: Forward Request
    Controller->>Controller: Check @PreAuthorize
    alt Has Permission
        Controller-->>Frontend: Process & Return Data
    else No Permission
        Controller-->>Frontend: 403 Forbidden
    end
```

### 6.3 Cấu Hình CORS

Hệ thống cho phép cross-origin requests từ:
- `http://localhost:3000` (React dev server)
- `http://localhost:5173` (Vite dev server)

Các methods được phép: GET, POST, PUT, DELETE, OPTIONS

---

## 7. Quy Trình Nghiệp Vụ

### 7.1 Quy Trình Thu Phí

```mermaid
flowchart TD
    Start([Bắt đầu]) --> CreatePeriod[Admin/Kế toán tạo đợt thu phí]
    CreatePeriod --> CheckType{Loại phí?}
    
    CheckType -->|BAT_BUOC| AutoCalc[Tự động tính phí cho tất cả hộ khẩu]
    CheckType -->|TU_NGUYEN| Manual[Không tự động tính]
    
    AutoCalc --> CountMembers[Đếm số người đủ điều kiện]
    CountMembers --> CalcFee[Tính phí = Định mức × 12 × Số người]
    CalcFee --> CreateRecord[Tạo bản ghi thu phí]
    Manual --> CreateRecord
    
    CreateRecord --> WaitPayment[Chờ thanh toán]
    WaitPayment --> RecordPayment[Kế toán ghi nhận thanh toán]
    
    RecordPayment --> ValidateDate{Ngày thu hợp lệ?}
    ValidateDate -->|Không| Error[Báo lỗi]
    ValidateDate -->|Có| SavePayment[Lưu thông tin thanh toán]
    
    SavePayment --> CalcTotal[Tính tổng đã thu từ tất cả lần thanh toán]
    CalcTotal --> CheckStatus{Tổng đã thu >= Tổng phí?}
    
    CheckStatus -->|Có| UpdatePaid[Cập nhật trạng thái: DA_NOP]
    CheckStatus -->|Không| UpdateUnpaid[Cập nhật trạng thái: CHUA_NOP]
    
    UpdatePaid --> UpdateAll[Cập nhật đồng bộ tất cả bản ghi liên quan]
    UpdateUnpaid --> UpdateAll
    
    UpdateAll --> End([Kết thúc])
    Error --> End
```

### 7.2 Quy Trình Tự Động Tính Lại Phí

```mermaid
flowchart TD
    Start([Sự kiện kích hoạt]) --> Event{Loại sự kiện?}
    
    Event -->|Thêm nhân khẩu| AddMember[Thêm thành viên vào hộ]
    Event -->|Xóa nhân khẩu| RemoveMember[Xóa thành viên khỏi hộ]
    Event -->|Thay đổi tạm vắng| ChangeTamVang[Cập nhật trạng thái tạm vắng]
    
    AddMember --> GetHousehold[Lấy thông tin hộ khẩu]
    RemoveMember --> GetHousehold
    ChangeTamVang --> GetHousehold
    
    GetHousehold --> GetPeriods[Lấy tất cả đợt thu phí BAT_BUOC]
    GetPeriods --> LoopPeriods{Duyệt từng đợt}
    
    LoopPeriods -->|Còn đợt| CountNew[Đếm lại số người đủ điều kiện]
    CountNew --> RecalcFee[Tính lại tổng phí]
    RecalcFee --> UpdateRecords[Cập nhật số người và tổng phí]
    UpdateRecords --> RecalcStatus[Tính lại trạng thái thanh toán]
    RecalcStatus --> LoopPeriods
    
    LoopPeriods -->|Hết| End([Kết thúc])
```

---

## 8. Các Mẫu Thiết Kế

### 8.1 Layered Architecture (Kiến Trúc Phân Tầng)

- Tách biệt rõ ràng: Presentation → Service → Repository → Domain
- Dependency flow: từ trên xuống dưới
- Mỗi tầng có trách nhiệm riêng biệt

### 8.2 Dependency Injection (Tiêm Phụ Thuộc)

- Spring IoC container quản lý các beans
- Sử dụng `@Autowired` cho constructor injection
- Giảm coupling giữa các components

### 8.3 DTO Pattern (Data Transfer Object)

- Tách biệt entity và data transfer layer
- Validation tại DTO level
- Ngăn chặn over-fetching/under-fetching

### 8.4 Repository Pattern

- Abstract hóa data access logic
- JpaRepository cung cấp CRUD operations
- Custom queries với method naming hoặc @Query

### 8.5 Service Facade Pattern

- Service layer đóng vai trò facade
- Che giấu complexity của business logic
- Điều phối nhiều repository calls

### 8.6 Filter Pattern

- JwtFilter chặn mọi requests
- Validate authentication trước khi vào controller
- Implements OncePerRequestFilter

---

## Kết Luận

Hệ thống Quản Lý Dân Cư được xây dựng trên kiến trúc phân tầng rõ ràng, tuân thủ các nguyên tắc SOLID và các mẫu thiết kế chuẩn. Việc tách biệt các tầng giúp hệ thống dễ bảo trì, mở rộng và kiểm thử. Cơ chế bảo mật JWT kết hợp với phân quyền dựa trên vai trò đảm bảo tính an toàn của dữ liệu. Thiết kế database được tối ưu với các ràng buộc và quan hệ phù hợp, hỗ trợ tốt cho các nghiệp vụ phức tạp như tính toán phí và thanh toán nhiều lần.

---

**Hết tài liệu Kiến Trúc Hệ Thống**
