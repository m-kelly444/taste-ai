#!/bin/bash

echo "🔍 TASTE.AI - Repository Structure Verification"
echo "==============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if taste-ai directory exists
if [ ! -d "taste-ai" ]; then
    echo -e "${RED}❌ ERROR: taste-ai directory not found!${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Repository Structure Analysis:${NC}"
echo ""

# Check for duplicate files/directories that should have been removed
SHOULD_BE_GONE=(
    "backend"
    "frontend" 
    "ml"
    "docker-compose.yml"
    "docker-compose.services-only.yml"
    ".dockerignore"
)

duplicates_found=0

echo -e "${YELLOW}🔍 Checking for removed duplicates:${NC}"
for item in "${SHOULD_BE_GONE[@]}"; do
    if [ -e "$item" ]; then
        echo -e "${RED}❌ Duplicate still exists: $item${NC}"
        duplicates_found=$((duplicates_found + 1))
    else
        echo -e "${GREEN}✅ Removed: $item${NC}"
    fi
done

echo ""

# Check that taste-ai directory has complete structure
REQUIRED_TASTE_AI_ITEMS=(
    "taste-ai/backend"
    "taste-ai/frontend"
    "taste-ai/ml"
    "taste-ai/docker-compose.yml"
    "taste-ai/README.md"
    "taste-ai/backend/app/main.py"
    "taste-ai/frontend/package.json"
    "taste-ai/ml/training"
    "taste-ai/deployment"
)

missing_items=0

echo -e "${YELLOW}🔍 Verifying taste-ai/ completeness:${NC}"
for item in "${REQUIRED_TASTE_AI_ITEMS[@]}"; do
    if [ -e "$item" ]; then
        echo -e "${GREEN}✅ Present: ${item#taste-ai/}${NC}"
    else
        echo -e "${RED}❌ Missing: ${item#taste-ai/}${NC}"
        missing_items=$((missing_items + 1))
    fi
done

echo ""
echo -e "${BLUE}📊 Verification Results:${NC}"
echo "======================="

if [ $duplicates_found -eq 0 ]; then
    echo -e "${GREEN}✅ Duplicates: All removed successfully${NC}"
else
    echo -e "${RED}❌ Duplicates: $duplicates_found items still present${NC}"
fi

if [ $missing_items -eq 0 ]; then
    echo -e "${GREEN}✅ Completeness: taste-ai/ has all required components${NC}"
else
    echo -e "${RED}❌ Completeness: $missing_items items missing from taste-ai/${NC}"
fi

echo ""

# Overall status
if [ $duplicates_found -eq 0 ] && [ $missing_items -eq 0 ]; then
    echo -e "${GREEN}🎉 VERIFICATION PASSED: Repository is properly organized!${NC}"
    echo ""
    echo -e "${BLUE}📋 Summary:${NC}"
    echo "  ✅ No duplicate files in root directory"
    echo "  ✅ Complete TASTE.AI project in taste-ai/"
    echo "  ✅ All required components present"
    echo ""
    echo -e "${BLUE}🚀 Ready to use:${NC}"
    echo "  1. cd taste-ai/"
    echo "  2. docker-compose up -d"
    echo "  3. Open http://localhost:3002"
    
    exit_code=0
else
    echo -e "${RED}❌ VERIFICATION FAILED: Issues detected${NC}"
    echo ""
    if [ $duplicates_found -gt 0 ]; then
        echo -e "${YELLOW}🔧 To fix duplicates:${NC}"
        echo "  Run: ./cleanup_duplicate_repo.sh"
    fi
    if [ $missing_items -gt 0 ]; then
        echo -e "${YELLOW}🔧 To fix missing items:${NC}"
        echo "  Check if taste-ai/ directory is complete"
        echo "  Re-extract or restore missing components"
    fi
    
    exit_code=1
fi

echo ""
echo -e "${BLUE}📁 Current Directory Contents:${NC}"
echo "============================="

# Show current directory structure (first level only)
for item in *; do
    if [ -d "$item" ]; then
        if [ "$item" = "taste-ai" ]; then
            echo -e "${GREEN}📁 $item/ (✅ TASTE.AI project)${NC}"
        else
            echo -e "${BLUE}📁 $item/${NC}"
        fi
    else
        echo -e "${BLUE}📄 $item${NC}"
    fi
done

echo ""
echo -e "${BLUE}📁 taste-ai/ Contents:${NC}"
echo "===================="

if [ -d "taste-ai" ]; then
    cd taste-ai
    for item in *; do
        if [ -d "$item" ]; then
            echo -e "${GREEN}📁 $item/${NC}"
        else
            echo -e "${GREEN}📄 $item${NC}"
        fi
    done
    cd ..
fi

exit $exit_code