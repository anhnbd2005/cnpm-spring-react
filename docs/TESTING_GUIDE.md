# Quick Start Guide - Testing All Fixes

## Prerequisites
- Docker Desktop running
- Node.js installed (for frontend dev server)

## Start Backend
```bash
cd /Users/nqd2005/Documents/Project_CNPM/cnpm-spring-react
docker compose up -d

# Wait 10 seconds, then verify
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health
# Expected: 200
```

## Start Frontend
```bash
cd frontend
npm install
npm run dev
# Open http://localhost:5173
```

## Test Checklist

### ✅ Issue 1: Fee Period Create/Update
**Bug:** Was calling `PUT /dot-thu-phi/undefined` instead of `POST /dot-thu-phi`

**Test Steps:**
1. Login as ADMIN
2. Click "Đợt thu phí" in sidebar
3. Click "Tạo đợt thu phí" button
4. Open Browser DevTools → Network tab
5. ✅ Verify: NO request to `/api/dot-thu-phi/undefined`
6. Fill form:
   - Tên đợt: "Test Fee Period Q4"
   - Loại: "Bắt buộc"
   - Ngày bắt đầu: 2025-10-01
   - Ngày kết thúc: 2025-12-31
   - Định mức: 50000
7. Click Submit
8. ✅ Verify Network: `POST http://localhost:8080/api/dot-thu-phi`
9. ✅ Verify Response: 200 OK with created object
10. Click "Chi tiết" on any existing record
11. Modify "Định mức" field
12. Click Submit
13. ✅ Verify Network: `PUT http://localhost:8080/api/dot-thu-phi/{id}`

**Console Logs to Verify:**
```
FeePeriodDetail mounted with id: undefined isNew: true
Submitting fee period data: {...} id: undefined isNew: true
```

---

### ✅ Issue 2: Household List Filter Error
**Bug:** `TypeError: n.filter is not a function` after creating household

**Test Steps:**
1. Click "Hộ khẩu" in sidebar
2. ✅ Verify list displays correctly
3. Check Browser Console
4. ✅ Verify log: `Households in List: [...] Type: Array`
5. Click "Thêm hộ khẩu" button
6. Fill modal:
   - Số hộ khẩu: "HK123"
   - Tên chủ hộ: "Test Nguyen"
   - Địa chỉ: "123 Test Street"
7. Click Save
8. ✅ Verify: Success message appears
9. Click anywhere to close modal (or close button)
10. ✅ Verify: List refreshes and shows new record
11. ✅ Verify Console: NO TypeError
12. ✅ Verify Console: `Type: Array` still logged

**What Was Fixed:**
- Added `safeHouseholds` wrapper: `Array.isArray(households) ? households : []`
- Prevents crash even if state becomes non-array temporarily

---

### ✅ Issue 3: CCCD Validation for Children
**Bug:** None (was already implemented correctly)

**Test Steps - Child < 14:**
1. Click "Nhân khẩu" in sidebar
2. Click "Thêm nhân khẩu"
3. Fill form:
   - Hộ khẩu: Select any
   - Họ tên: "Test Child"
   - Ngày sinh: 2015-01-01 (10 years old)
   - Giới tính: Nam
   - Dân tộc: Kinh
   - Quốc tịch: Việt Nam
   - Nghề nghiệp: Học sinh
   - **CMND/CCCD: [Leave empty]**
   - Quan hệ với chủ hộ: Con
4. Click Submit
5. ✅ Verify: Success! (No validation error)
6. ✅ Verify Network: `POST /api/nhan-khau` with `"cmndCccd": null`

**Test Steps - Adult ≥ 14:**
1. Click "Thêm nhân khẩu"
2. Fill form:
   - Họ tên: "Test Adult"
   - Ngày sinh: 2000-01-01 (25 years old)
   - **CMND/CCCD: [Leave empty]**
3. Click Submit
4. ✅ Verify: Frontend validation error appears
5. ✅ Verify: "Người từ 14 tuổi trở lên phải có CMND/CCCD"
6. Fill CCCD: 001234567890
7. Fill Ngày cấp: 2018-01-01
8. Fill Nơi cấp: Công an TP. HCM
9. Click Submit
10. ✅ Verify: Success!

**Test Steps - Child with CCCD (Invalid):**
1. Try to manually send request:
```bash
curl -X POST http://localhost:8080/api/nhan-khau \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "hoTen": "Test Child",
    "ngaySinh": "2015-01-01",
    "cmndCccd": "001234567890",
    "hoKhauId": 1
  }'
```
11. ✅ Verify: Backend rejects with 400 error
12. ✅ Verify: Message contains "Người dưới 14 tuổi không được cấp CMND/CCCD"

---

## Verification Commands

### Check Backend Logs
```bash
docker compose logs backend -f
```

### Check Backend Health
```bash
curl http://localhost:8080/actuator/health
```

### Check All Containers
```bash
docker compose ps
```

### Stop Everything
```bash
docker compose down
```

---

## Expected Console Outputs

### Fee Period (Creating New)
```
FeePeriodDetail mounted with id: undefined isNew: true
Submitting fee period data: {...} id: undefined isNew: true
Backend response: {id: 5, tenDot: "...", ...}
```

### Household (List)
```
Households in List: [{id: 1, ...}, {id: 2, ...}] Type: Array
```

### Citizen (Age Calculation)
```
Form submitted with data (camelCase): {
  cmndCccd: null,  // For age < 14
  ngayCap: null,
  noiCap: null
}
```

---

## Success Criteria

✅ **Fee Period:**
- Create uses POST (not PUT)
- No `/undefined` requests
- Logs show correct `isNew` flag

✅ **Household:**
- No TypeError on filter
- Console shows `Type: Array`
- List refreshes after create

✅ **Citizen CCCD:**
- Child < 14: CCCD optional
- Adult ≥ 14: CCCD required
- Backend validates both cases

---

## Rollback (If Needed)
```bash
cd /Users/nqd2005/Documents/Project_CNPM/cnpm-spring-react
git checkout frontend/src/features/fee-period/pages/Detail.jsx
git checkout frontend/src/features/household/pages/List.jsx
```

---

**Last Updated:** November 24, 2025  
**Status:** All fixes verified and ready for deployment
