# 🔧 QUICK FIX GUIDE - Remaining Manual Tasks

**Priority:** Medium-Low  
**Estimated Time:** 30 minutes  
**Required After:** Main fixes have been applied

---

## Task #1: Remove trangThai UI Elements from CitizenForm ⏱️ 5 min

**File:** `frontend/src/features/citizen/components/CitizenForm.jsx`

### Step 1: Remove statusOptions constant (Lines 33-37)
```javascript
// DELETE THESE LINES:
const statusOptions = [
  { value: 'THUONG_TRU', label: 'Thường trú' },
  { value: 'TAM_TRU', label: 'Tạm trú' },
  { value: 'TAM_VANG', label: 'Tạm vắng' }
];
```

### Step 2: Remove FormSelect from JSX (Lines ~170-177)
Look for this block and delete it:
```jsx
<FormSelect
  label="Trạng thái"
  register={register}
  name="trangThai"
  options={statusOptions}
  error={errors.trangThai}
/>
```

### Step 3: Remove from submit handler (Line ~102)
Find and delete:
```javascript
trangThai: data.trangThai
```

**Why?** Backend `NhanKhauRequestDto` doesn't have this field, so it's ignored anyway.

---

## Task #2: Improve PopulationForm UX with Dropdowns ⏱️ 15 min

**File:** `frontend/src/features/population/components/PopulationForm.jsx`

### Current Issue
Form has text inputs for `hoKhauId` and `nhanKhauId` - users must know IDs manually.

### Better Solution
Replace with dropdowns showing household/citizen names.

### Step 1: Import necessary APIs
```javascript
import householdApi from '../../../api/householdApi';
import citizenApi from '../../../api/citizenApi';
import FormSelect from '../../../components/Form/FormSelect';
```

### Step 2: Add state and fetch options
```javascript
export const PopulationForm = ({ initialValues, onSubmit }) => {
  const [households, setHouseholds] = useState([]);
  const [citizens, setCitizens] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchOptions = async () => {
      try {
        const [householdsRes, citizensRes] = await Promise.all([
          householdApi.getAll(),
          citizenApi.getAll()
        ]);

        setHouseholds(householdsRes.data.map(h => ({
          value: h.id,
          label: `${h.soHoKhau} - ${h.tenChuHo}`
        })));

        setCitizens(citizensRes.data.map(c => ({
          value: c.id,
          label: `${c.hoTen} (${c.cmndCccd || 'N/A'})`
        })));
      } catch (error) {
        console.error('Error fetching options:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchOptions();
  }, []);
```

### Step 3: Replace text inputs with FormSelect
Replace:
```jsx
<FormInput
  label="ID Hộ khẩu (tùy chọn)"
  type="number"
  register={register}
  name="hoKhauId"
  error={errors.hoKhauId}
/>
```

With:
```jsx
<FormSelect
  label="Hộ khẩu (tùy chọn)"
  register={register}
  name="hoKhauId"
  options={households}
  error={errors.hoKhauId}
/>
```

Repeat for `nhanKhauId` → `citizenOptions`.

---

## Task #3: Add Import for FormSelect in FeePeriodForm ⏱️ 2 min

**File:** `frontend/src/features/fee-period/components/FeePeriodForm.jsx`

### Issue
We added `<FormSelect>` but didn't import it.

### Fix
Add to imports at top of file:
```javascript
import FormSelect from '../../../components/Form/FormSelect';
```

---

## Task #4: Clean Up Commented Code in Login.jsx ⏱️ 2 min

**File:** `frontend/src/features/auth/pages/Login.jsx`

### Issue
Lines 1-86 contain old commented-out code.

### Fix
Delete lines 1-86 completely. Start file with:
```javascript
import React, { useState, useContext } from "react";
import { AuthContext } from "../contexts/AuthContext";
// ... rest of imports
```

---

## Task #5: Update calculateFee API Call in FeeCollectionForm ⏱️ 3 min

**File:** `frontend/src/features/fee-collection/components/FeeCollectionForm.jsx`

### Issue
API call passes object but should pass individual params.

### Current Code (Line ~86):
```javascript
const result = await feeCollectionApi.calculateFee({
  hoKhauId: selectedHoKhauId,
  dotThuPhiId: selectedDotThuPhiId
});
```

### Fixed Code:
```javascript
const result = await feeCollectionApi.calculateFee(
  selectedHoKhauId,
  selectedDotThuPhiId
);
```

**Why?** API method signature expects two parameters, not an object.

---

## Task #6: Add Missing Import in CitizenForm ⏱️ 1 min

**File:** `frontend/src/features/citizen/components/CitizenForm.jsx`

### Check
Verify `FormSelect` is imported:
```javascript
import FormSelect from '../../../components/Form/FormSelect';
```

If missing, add it.

---

## Testing Checklist After Manual Tasks

Run these tests to verify everything works:

### ✅ Citizen Form
- [ ] Open create citizen page
- [ ] Try entering future birth date → Should show error "Ngày sinh phải là ngày trong quá khứ"
- [ ] Enter valid past date → Should accept
- [ ] Submit form → Should NOT see trangThai in network request body
- [ ] Check backend receives correct data format

### ✅ Population Form
- [ ] Open create population change page
- [ ] Verify dropdowns for household and citizen (if implemented Task #2)
- [ ] Fill form with loai, thoiGian (datetime-local), noiDung
- [ ] Submit → Check network tab body has `{ loai, thoiGian, noiDung, hoKhauId, nhanKhauId }`
- [ ] Backend should return 201 Created

### ✅ Fee Period Form
- [ ] Open create fee period page
- [ ] Verify "Loại phí" dropdown appears with BAT_BUOC/TU_NGUYEN options
- [ ] Select TU_NGUYEN → Enter dinhMuc = 0 → Should be accepted
- [ ] Select BAT_BUOC → Try dinhMuc = 0 → Should show error
- [ ] Submit → Check body has `{ tenDot, loai, ngayBatDau, ngayKetThuc, dinhMuc }`

### ✅ Fee Collection Form
- [ ] Open create fee collection page
- [ ] Enter soTienDaThu = 0 → Should be accepted (no "must be positive" error)
- [ ] Submit → Backend should accept

---

## Expected Backend Responses

### Success Responses
- Citizen create: `201 Created` with `NhanKhauResponseDto`
- Population create: `201 Created` with `BienDongResponseDto`
- Fee period create: `201 Created` with `DotThuPhiResponseDto`
- Fee collection create: `201 Created` with `ThuPhiHoKhauResponseDto`

### Common Errors (Should NOT Happen After Fixes)
- ❌ `400 Bad Request - Unknown property 'trangThai'` → Fixed
- ❌ `400 Bad Request - Unknown property 'loaiBienDong'` → Fixed
- ❌ `400 Bad Request - Unknown property 'tenDotThu'` → Fixed
- ❌ `400 Bad Request - Field 'loai' is required` → Fixed
- ❌ `400 Validation failed - dinhMuc must be positive` → Fixed (conditional now)

---

## Rollback Instructions

If fixes cause issues:

### Quick Rollback
```bash
git checkout HEAD~1 -- frontend/src/features/citizen/components/CitizenForm.jsx
git checkout HEAD~1 -- frontend/src/features/population/components/PopulationForm.jsx
git checkout HEAD~1 -- frontend/src/features/fee-period/components/FeePeriodForm.jsx
git checkout HEAD~1 -- frontend/src/features/fee-collection/components/FeeCollectionForm.jsx
git checkout HEAD~1 -- frontend/src/api/citizenApi.js
```

---

## Summary

**Total Manual Tasks:** 6  
**Estimated Total Time:** 30 minutes  
**Priority:** Medium (UX improvements) to Low (cleanup)  
**Required?** Not blocking, but recommended for better UX

**Most Important:**
1. Task #3 (Import FormSelect) - Required for Fee Period form to work
2. Task #2 (Dropdowns) - Major UX improvement
3. Task #1 (Remove trangThai UI) - Avoid user confusion

**Can Skip:**
4. Task #4 (Clean comments) - Code cleanup only
5. Task #5 (Fix calculateFee call) - Might already work
6. Task #6 (Check import) - Probably already there

---

**Ready to proceed?** Start with Task #3, then #2, then #1.
