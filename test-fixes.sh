#!/bin/bash
# Test script for verifying all fixes
# Run this from project root

echo "================================"
echo "Testing All Frontend Fixes"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Start backend
echo "🚀 Starting backend services..."
cd /Users/nqd2005/Documents/Project_CNPM/cnpm-spring-react
docker compose up -d

echo ""
echo "⏳ Waiting 10 seconds for backend to start..."
sleep 10

# Test backend health
echo ""
echo "🏥 Checking backend health..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health)

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✅ Backend is healthy (HTTP $HTTP_CODE)"
else
    echo "❌ Backend health check failed (HTTP $HTTP_CODE)"
    echo "   Please check: docker compose logs"
    exit 1
fi

echo ""
echo "================================"
echo "Backend is ready!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Open frontend:"
echo "   cd frontend && npm run dev"
echo ""
echo "2. Login as ADMIN and test:"
echo ""
echo "   📋 Fee Period Tests:"
echo "   - Click 'Đợt thu phí' menu"
echo "   - Click 'Tạo đợt thu phí' → Check Network tab"
echo "   - Expected: NO GET /api/dot-thu-phi/undefined"
echo "   - Fill form → Submit"
echo "   - Expected: POST /api/dot-thu-phi (not PUT)"
echo "   - Click 'Chi tiết' on record"
echo "   - Expected: GET /api/dot-thu-phi/{id}"
echo "   - Modify → Submit"
echo "   - Expected: PUT /api/dot-thu-phi/{id}"
echo ""
echo "   🏠 Household Tests:"
echo "   - Click 'Hộ khẩu' menu"
echo "   - Click 'Thêm hộ khẩu' → Fill modal → Save"
echo "   - Click Close/Back"
echo "   - Expected: List refreshes, NO TypeError"
echo "   - Check console: 'Type: Array'"
echo ""
echo "   👤 Citizen Tests:"
echo "   - Create citizen age 10"
echo "   - Leave CCCD empty → Submit → Success ✅"
echo "   - Create citizen age 20"
echo "   - Leave CCCD empty → Frontend error ❌"
echo "   - Fill CCCD → Submit → Success ✅"
echo ""
echo "================================"
echo "View logs: docker compose logs -f"
echo "Stop services: docker compose down"
echo "================================"
