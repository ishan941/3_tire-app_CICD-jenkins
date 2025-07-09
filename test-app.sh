#!/bin/bash

echo "🧪 Testing 3-Tier Docker Application"
echo "=================================="

# Test backend health
echo -n "Backend Health: "
response=$(curl -s http://localhost:5050/)
if echo "$response" | grep -q "Backend API is running"; then
    echo "✅ OK"
else
    echo "❌ Failed"
    echo "Response: $response"
fi

# Test backend records endpoint
echo -n "Records Endpoint: "
records_response=$(curl -s http://localhost:5050/record/)
if [ $? -eq 0 ]; then
    echo "✅ OK"
    echo "Current records: $records_response"
else
    echo "❌ Failed"
fi

# Test frontend
echo -n "Frontend: "
frontend_response=$(curl -s http://localhost/ | head -1)
if echo "$frontend_response" | grep -q "<!doctype html>"; then
    echo "✅ OK"
else
    echo "❌ Failed"
    echo "Response: $frontend_response"
fi

# Test MongoDB connection (through backend)
echo -n "Database Connection: "
# Try to create a test record
test_record='{"name":"Test User","position":"Test Position","level":"Junior"}'
create_response=$(curl -s -X POST -H "Content-Type: application/json" -d "$test_record" http://localhost:5050/record/)
if [ $? -eq 0 ]; then
    echo "✅ OK (Test record created)"
    # Clean up - delete the test record if it was created
    sleep 1
    records=$(curl -s http://localhost:5050/record/)
    if echo "$records" | grep -q "Test User"; then
        # Extract the ID and delete the record
        record_id=$(echo "$records" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)
        if [ ! -z "$record_id" ]; then
            delete_response=$(curl -s -X DELETE http://localhost:5050/record/$record_id)
            echo "Test record cleaned up"
        fi
    fi
else
    echo "❌ Failed to create test record"
fi

echo ""
echo "📋 Service Status:"
echo "=================="
docker-compose ps

echo ""
echo "🌐 Access URLs:"
echo "==============="
echo "Frontend: http://localhost"
echo "Backend API: http://localhost:5050"
echo "MongoDB: localhost:27017"

echo ""
echo "📝 Quick Commands:"
echo "=================="
echo "View logs: docker-compose logs [service-name]"
echo "Stop app: docker-compose down"
echo "Restart: docker-compose restart"
echo "Clean up: docker-compose down -v && docker system prune -f"
echo "Development mode: docker-compose -f docker-compose.dev.yml up -d"
