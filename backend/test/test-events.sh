#!/bin/bash
# Test event-driven fee recalculation

BASE_URL="http://localhost:8080"

echo "=== Testing Event-Driven Fee Recalculation ==="
echo

# Login as ADMIN
echo "1. Logging in as admin..."
ADMIN_TOKEN=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"tenDangNhap":"admin","matKhau":"admin123"}' | jq -r '.token')

echo "✓ Admin token obtained"
echo

# Create a new household
echo "2. Creating new household..."
NEW_HK=$(curl -s -X POST "${BASE_URL}/api/ho-khau" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "soHoKhau": "HK999",
    "tenChuHo": "Test Auto Event",
    "diaChi": "Test Street"
  }')

HK_ID=$(echo $NEW_HK | jq -r '.id')
echo "✓ Created household ID: $HK_ID"
echo

# Wait for event to process
echo "3. Waiting for event listener to create initial fee record..."
sleep 3

# Check if ThuPhiHoKhau was auto-created
echo "4. Checking if fee record was auto-created..."
KETOAN_TOKEN=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"tenDangNhap":"ketoan01","matKhau":"admin123"}' | jq -r '.token')

FEE_RECORDS=$(curl -s -X GET "${BASE_URL}/api/thu-phi-ho-khau" \
  -H "Authorization: Bearer ${KETOAN_TOKEN}")

echo "Fee records for household $HK_ID:"
echo "$FEE_RECORDS" | jq ".[] | select(.hoKhauId == $HK_ID)"
echo

# Add a citizen to the household
echo "5. Adding citizen to household $HK_ID..."
curl -s -X POST "${BASE_URL}/api/nhan-khau" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "hoTen": "Test Person",
    "ngaySinh": "2000-01-01",
    "gioiTinh": "Nam",
    "hoKhauId": '$HK_ID'
  }' | jq '.id'

echo "✓ Citizen added"
echo

# Wait for recalculation
echo "6. Waiting for fee recalculation..."
sleep 3

# Check updated fee
echo "7. Checking recalculated fees..."
FEE_RECORDS_AFTER=$(curl -s -X GET "${BASE_URL}/api/thu-phi-ho-khau" \
  -H "Authorization: Bearer ${KETOAN_TOKEN}")

echo "Updated fee records for household $HK_ID:"
echo "$FEE_RECORDS_AFTER" | jq ".[] | select(.hoKhauId == $HK_ID)"
echo

echo "=== Check Docker logs for event processing ===" 
echo "Run: docker logs quanlydancu-backend 2>&1 | grep -E 'Received.*Event|Creating initial fee|Recalculating fees'"
