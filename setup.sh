#!/bin/bash

echo "🔍 TASTE.AI - Diagnose Frontend White Screen"

cd taste-ai

echo "1. 📋 Checking frontend process..."
ps aux | grep -E "(npm|node|vite)" | grep -v grep

echo -e "\n2. 🌐 Testing frontend response..."
echo "Raw HTTP response:"
curl -v http://localhost:3002/ 2>&1 | head -20

echo -e "\n3. 📁 Checking frontend files..."
cd frontend
echo "Files in frontend directory:"
ls -la

echo -e "\nChecking critical files:"
echo "index.html: $([ -f index.html ] && echo "✅ EXISTS" || echo "❌ MISSING")"
echo "src/index.js: $([ -f src/index.js ] && echo "✅ EXISTS" || echo "❌ MISSING")"
echo "src/App.js: $([ -f src/App.js ] && echo "✅ EXISTS" || echo "❌ MISSING")"
echo "package.json: $([ -f package.json ] && echo "✅ EXISTS" || echo "❌ MISSING")"
echo "vite.config.js: $([ -f vite.config.js ] && echo "✅ EXISTS" || echo "❌ MISSING")"

if [ -f index.html ]; then
    echo -e "\nindex.html content (first 10 lines):"
    head -10 index.html
fi

echo -e "\n4. 📊 Checking Vite logs..."
echo "Last 10 lines of Vite output:"
# Get the PID and check if it's running
FRONTEND_PID=$(ps aux | grep "vite.*3002" | grep -v grep | awk '{print $2}' | head -1)
if [ ! -z "$FRONTEND_PID" ]; then
    echo "Frontend PID: $FRONTEND_PID"
else
    echo "❌ No Vite process found on port 3002"
fi

echo -e "\n5. 🧪 Testing with curl and browser headers..."
echo "Testing HTML content:"
RESPONSE=$(curl -s http://localhost:3002/)
if [ ! -z "$RESPONSE" ]; then
    echo "✅ Got response from server"
    echo "Response length: $(echo "$RESPONSE" | wc -c) characters"
    echo "First 200 characters:"
    echo "$RESPONSE" | head -c 200
    echo ""
    
    # Check if it contains expected content
    if echo "$RESPONSE" | grep -q "TASTE.AI"; then
        echo "✅ Contains TASTE.AI content"
    else
        echo "❌ Missing TASTE.AI content"
    fi
    
    if echo "$RESPONSE" | grep -q "react"; then
        echo "✅ Contains React references"
    else
        echo "❌ Missing React references"
    fi
else
    echo "❌ No response from server"
fi

echo -e "\n6. 🔧 Browser compatibility check..."
echo "Checking for JavaScript errors (simulated):"
# Check if the HTML has proper script tags
if [ -f index.html ]; then
    grep -n "script" index.html || echo "No script tags found"
fi

echo -e "\n💡 Troubleshooting suggestions:"
echo "1. Try opening browser developer tools (F12) and check Console tab"
echo "2. Check Network tab to see if files are loading"
echo "3. Try hard refresh (Ctrl+F5 or Cmd+Shift+R)"
echo "4. Try different browser"
echo "5. Check if there are any JavaScript errors in console"

cd ..