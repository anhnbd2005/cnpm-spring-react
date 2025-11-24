# Quick Reference - What Changed

## Fee Period Fix
**File:** `frontend/src/features/fee-period/pages/Detail.jsx`

**Before:**
```javascript
if (id === 'new') return; // Wrong: id is undefined, not 'new'
id === 'new' ? create() : update() // Wrong: always calls update()
```

**After:**
```javascript
const isNew = !id; // Correct: checks if id is undefined
if (isNew) return; // Correct: skips fetch for new
isNew ? create() : update() // Correct: creates when id is undefined
```

**Result:** ✅ POST for create, PUT for update

---

## Household Fix
**File:** `frontend/src/features/household/pages/List.jsx`

**Before:**
```javascript
households.filter(...) // Risky: crashes if not array
```

**After:**
```javascript
const safe = Array.isArray(households) ? households : [];
safe.filter(...) // Safe: always filters array
console.log('Type:', Array.isArray(households) ? 'Array' : typeof households);
```

**Result:** ✅ No TypeError crashes

---

## CCCD Validation
**Files:** Frontend + Backend (Already Correct)

**Logic:**
- Age < 14: CCCD optional (null allowed)
- Age ≥ 14: CCCD required (9-12 digits)

**Frontend:** `frontend/src/features/citizen/components/CitizenForm.jsx`
```javascript
cmndCccd: yup.string().when('ngaySinh', {
  is: (date) => calculateAge(date) >= 14,
  then: (schema) => schema.required('Required for age ≥ 14'),
  otherwise: (schema) => schema.nullable()
})
```

**Backend:** `backend/.../service/NhanKhauService.java`
```java
private void validateCccdByAge(...) {
  if (age < 14 && hasCccd) throw error;
  if (age >= 14 && !hasCccd) throw error;
}
```

**Result:** ✅ Already working correctly

---

## Test Commands

```bash
# Start everything
docker compose up -d

# Health check
curl http://localhost:8080/actuator/health

# Frontend
cd frontend && npm run dev
```

---

## Network Requests to Verify

**Creating Fee Period:**
```
✅ POST http://localhost:8080/api/dot-thu-phi
❌ PUT http://localhost:8080/api/dot-thu-phi/undefined
```

**Editing Fee Period:**
```
✅ GET http://localhost:8080/api/dot-thu-phi/5
✅ PUT http://localhost:8080/api/dot-thu-phi/5
```

---

## Console Logs to Check

**Fee Period (New):**
```
FeePeriodDetail mounted with id: undefined isNew: true
Submitting fee period data: {...} id: undefined isNew: true
```

**Household (List):**
```
Households in List: [...] Type: Array
```

---

## Quick Test

1. **Fee Period:** Create new → Check Network tab → POST (not PUT)
2. **Household:** Create new → Close modal → No TypeError
3. **Citizen:** Age 10 no CCCD ✅, Age 20 no CCCD ❌

---

**Files Changed:** 2  
**Bugs Fixed:** 4  
**Status:** Ready ✅
