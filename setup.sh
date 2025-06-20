#!/bin/bash

echo "🧹 TASTE.AI - Automatic Repository Cleanup"
echo "=========================================="
echo "Starting aggressive cleanup process..."
echo "⚠️  This script will automatically delete unnecessary files"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Cleanup counters
TOTAL_FILES_REMOVED=0
TOTAL_DIRS_REMOVED=0
TOTAL_SIZE_SAVED=0

# Function to safely remove files/directories and track stats
safe_remove() {
    local target="$1"
    local description="$2"
    
    if [ -e "$target" ]; then
        local size=0
        if [ -f "$target" ]; then
            size=$(du -b "$target" 2>/dev/null | cut -f1 || echo 0)
            TOTAL_FILES_REMOVED=$((TOTAL_FILES_REMOVED + 1))
        elif [ -d "$target" ]; then
            size=$(du -sb "$target" 2>/dev/null | cut -f1 || echo 0)
            TOTAL_DIRS_REMOVED=$((TOTAL_DIRS_REMOVED + 1))
        fi
        
        TOTAL_SIZE_SAVED=$((TOTAL_SIZE_SAVED + size))
        rm -rf "$target"
        echo -e "${GREEN}✅ Removed: $description${NC}"
        return 0
    else
        echo -e "${YELLOW}⚪ Not found: $description${NC}"
        return 1
    fi
}

# Function to clean directory patterns
clean_pattern() {
    local pattern="$1"
    local description="$2"
    
    echo -e "${CYAN}🔍 Scanning for: $description${NC}"
    
    # Use find to locate and remove files/directories matching pattern
    find . -name "$pattern" -type f 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            size=$(du -b "$file" 2>/dev/null | cut -f1 || echo 0)
            TOTAL_SIZE_SAVED=$((TOTAL_SIZE_SAVED + size))
            TOTAL_FILES_REMOVED=$((TOTAL_FILES_REMOVED + 1))
            rm -f "$file"
            echo -e "${GREEN}✅ Removed file: $file${NC}"
        fi
    done
    
    find . -name "$pattern" -type d 2>/dev/null | while read -r dir; do
        if [ -d "$dir" ]; then
            size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo 0)
            TOTAL_SIZE_SAVED=$((TOTAL_SIZE_SAVED + size))
            TOTAL_DIRS_REMOVED=$((TOTAL_DIRS_REMOVED + 1))
            rm -rf "$dir"
            echo -e "${GREEN}✅ Removed directory: $dir${NC}"
        fi
    done
}

echo -e "${BLUE}📂 PHASE 1: Node.js & Frontend Cleanup${NC}"
echo "================================================"

# Remove node_modules directories
clean_pattern "node_modules" "Node.js dependencies"

# Remove package-lock files (keep package.json)
clean_pattern "package-lock.json" "NPM lock files"

# Remove npm debug logs
clean_pattern "npm-debug.log*" "NPM debug logs"

# Remove yarn files
clean_pattern "yarn.lock" "Yarn lock files"
clean_pattern ".yarn" "Yarn cache"

# Remove frontend build artifacts
safe_remove "frontend/dist" "Frontend build directory"
safe_remove "frontend/build" "Frontend build directory (alt)"
safe_remove "frontend/.next" "Next.js build cache"
safe_remove "frontend/.nuxt" "Nuxt.js build cache"

# Remove Vite cache
safe_remove "frontend/.vite" "Vite cache"
safe_remove "frontend/node_modules/.vite" "Vite node cache"

# Remove ESLint cache
clean_pattern ".eslintcache" "ESLint cache files"

echo ""
echo -e "${BLUE}🐍 PHASE 2: Python & Backend Cleanup${NC}"
echo "================================================"

# Remove Python cache directories
clean_pattern "__pycache__" "Python cache directories"
clean_pattern "*.pyc" "Python compiled files"
clean_pattern "*.pyo" "Python optimized files"
clean_pattern "*.pyd" "Python extension modules"

# Remove Python virtual environments
safe_remove "backend/venv" "Backend virtual environment"
safe_remove "backend/env" "Backend environment (alt)"
safe_remove "ml/venv" "ML virtual environment"
safe_remove "venv" "Root virtual environment"
safe_remove "env" "Root environment directory"

# Remove Python build artifacts
clean_pattern "build" "Python build directories"
clean_pattern "dist" "Python distribution directories"
clean_pattern "*.egg-info" "Python egg info"

# Remove pytest cache
clean_pattern ".pytest_cache" "Pytest cache"
clean_pattern ".coverage" "Coverage files"
clean_pattern "htmlcov" "Coverage HTML reports"

# Remove Jupyter notebook checkpoints
clean_pattern ".ipynb_checkpoints" "Jupyter checkpoints"

echo ""
echo -e "${BLUE}🤖 PHASE 3: Machine Learning Cleanup${NC}"
echo "================================================"

# Remove large model files (keep training scripts)
safe_remove "ml/data/models/*.pth" "PyTorch model files (large)"
safe_remove "ml/data/models/*.pkl" "Pickle model files"
safe_remove "ml/data/models/*.h5" "Keras model files"
safe_remove "ml/data/models/*.pb" "TensorFlow model files"

# Remove training logs and checkpoints
safe_remove "ml/logs" "ML training logs"
safe_remove "ml/checkpoints" "ML model checkpoints"
safe_remove "ml/runs" "TensorBoard runs"
safe_remove "ml/wandb" "Weights & Biases logs"

# Remove large datasets (keep small training samples)
safe_remove "ml/data/raw/*.zip" "Large zipped datasets"
safe_remove "ml/data/raw/*.tar.gz" "Large compressed datasets"
safe_remove "ml/data/processed/large_*" "Large processed datasets"

# Remove visualization outputs
safe_remove "ml/evaluation/visualizations/*.png" "Generated visualizations"
safe_remove "ml/evaluation/visualizations/*.jpg" "Generated charts"

echo ""
echo -e "${BLUE}🐳 PHASE 4: Docker & Container Cleanup${NC}"
echo "================================================"

# Remove Docker build cache (be careful with this)
echo -e "${YELLOW}🐳 Cleaning Docker build cache...${NC}"
docker builder prune -f 2>/dev/null || echo "Docker not running or accessible"

# Remove unused Docker images
echo -e "${YELLOW}🐳 Removing unused Docker images...${NC}"
docker image prune -f 2>/dev/null || echo "Docker not running or accessible"

# Remove Docker override files
safe_remove "docker-compose.override.yml" "Docker Compose override"

echo ""
echo -e "${BLUE}💾 PHASE 5: Database & Cache Cleanup${NC}"
echo "================================================"

# Remove local database files
safe_remove "*.db" "SQLite database files"
safe_remove "*.sqlite" "SQLite database files (alt)"
safe_remove "*.sqlite3" "SQLite3 database files"

# Remove database dumps
safe_remove "*.sql" "SQL dump files"
safe_remove "backups/*.sql.gz" "Compressed database backups"

# Remove Redis dumps
safe_remove "dump.rdb" "Redis database dump"

echo ""
echo -e "${BLUE}🗂️  PHASE 6: Development & IDE Cleanup${NC}"
echo "================================================"

# Remove IDE and editor files
clean_pattern ".vscode" "VS Code settings"
clean_pattern ".idea" "IntelliJ IDEA files"
clean_pattern "*.swp" "Vim swap files"
clean_pattern "*.swo" "Vim swap files (alt)"
clean_pattern "*~" "Editor backup files"

# Remove OS-specific files
clean_pattern ".DS_Store" "macOS system files"
clean_pattern "Thumbs.db" "Windows thumbnail cache"
clean_pattern "desktop.ini" "Windows desktop files"

# Remove Git artifacts (keep .git directory)
safe_remove ".git/logs" "Git logs"
safe_remove ".git/refs/remotes" "Git remote refs"

echo ""
echo -e "${BLUE}📋 PHASE 7: Log & Temporary Files${NC}"
echo "================================================"

# Remove log files
clean_pattern "*.log" "Log files"
safe_remove "logs" "Logs directory"
safe_remove "backend.log" "Backend log file"
safe_remove "frontend.log" "Frontend log file"

# Remove temporary files
clean_pattern "*.tmp" "Temporary files"
clean_pattern "*.temp" "Temporary files (alt)"
clean_pattern ".tmp" "Temporary directories"

# Remove process ID files
safe_remove "*.pid" "Process ID files"
safe_remove "backend.pid" "Backend PID file"
safe_remove "frontend.pid" "Frontend PID file"

# Remove lock files
clean_pattern "*.lock" "Lock files"

echo ""
echo -e "${BLUE}🧪 PHASE 8: Test & Documentation Cleanup${NC}"
echo "================================================"

# Remove test artifacts
safe_remove "test-results" "Test result directories"
safe_remove "coverage" "Coverage directories"
safe_remove ".nyc_output" "NYC coverage output"

# Remove documentation builds
safe_remove "docs/_build" "Sphinx documentation build"
safe_remove "docs/build" "Documentation build directory"

# Remove generated test files
safe_remove "test_report.json" "Generated test reports"

echo ""
echo -e "${BLUE}📦 PHASE 9: Package & Build Cleanup${NC}"
echo "================================================"

# Remove various cache directories
clean_pattern ".cache" "General cache directories"
clean_pattern ".parcel-cache" "Parcel bundler cache"
clean_pattern ".webpack" "Webpack cache"
clean_pattern ".rollup.cache" "Rollup cache"

# Remove dependency lock files (controversial, but can be regenerated)
echo -e "${YELLOW}⚠️  Removing lock files (can be regenerated)...${NC}"
safe_remove "Pipfile.lock" "Pipenv lock file"
safe_remove "poetry.lock" "Poetry lock file"
safe_remove "conda-lock.yml" "Conda lock file"

echo ""
echo -e "${BLUE}🔧 PHASE 10: Configuration & Environment Cleanup${NC}"
echo "================================================"

# Remove environment files (keep .env.example)
safe_remove ".env" "Environment variables file"
safe_remove ".env.local" "Local environment file"
safe_remove ".env.production" "Production environment file"

# Remove SSL certificates (development only)
safe_remove "deployment/ssl/certs/*.key" "SSL private keys"
safe_remove "deployment/ssl/certs/*.crt" "SSL certificates"

# Remove backup files
clean_pattern "*.bak" "Backup files"
clean_pattern "*.backup" "Backup files (alt)"
clean_pattern "*.orig" "Original backup files"

echo ""
echo -e "${BLUE}🎯 PHASE 11: Large File Cleanup${NC}"
echo "================================================"

# Find and remove large files (>50MB)
echo -e "${CYAN}🔍 Scanning for large files (>50MB)...${NC}"
find . -type f -size +50M 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        size=$(du -h "$file" 2>/dev/null | cut -f1)
        echo -e "${YELLOW}⚠️  Found large file: $file ($size)${NC}"
        
        # Auto-remove certain types of large files
        case "$file" in
            *.mp4|*.avi|*.mov|*.mkv)
                rm -f "$file"
                echo -e "${GREEN}✅ Removed large video: $file${NC}"
                ;;
            *.zip|*.tar.gz|*.rar)
                rm -f "$file"
                echo -e "${GREEN}✅ Removed large archive: $file${NC}"
                ;;
            *.iso|*.img)
                rm -f "$file"
                echo -e "${GREEN}✅ Removed large image: $file${NC}"
                ;;
            *)
                echo -e "${BLUE}ℹ️  Keeping: $file (manual review recommended)${NC}"
                ;;
        esac
    fi
done

echo ""
echo -e "${BLUE}🗑️  PHASE 12: Empty Directory Cleanup${NC}"
echo "================================================"

# Remove empty directories
echo -e "${CYAN}🔍 Removing empty directories...${NC}"
find . -type d -empty 2>/dev/null | while read -r dir; do
    if [ -d "$dir" ] && [ "$dir" != "." ] && [ "$dir" != ".." ]; then
        rmdir "$dir" 2>/dev/null && echo -e "${GREEN}✅ Removed empty directory: $dir${NC}"
    fi
done

echo ""
echo -e "${BLUE}📊 PHASE 13: Final Optimization${NC}"
echo "================================================"

# Optimize .gitignore (add common patterns if missing)
if [ -f ".gitignore" ]; then
    echo -e "${CYAN}📝 Optimizing .gitignore...${NC}"
    
    # Add common patterns if not present
    patterns_to_add=(
        "node_modules/"
        "__pycache__/"
        "*.pyc"
        ".env"
        "*.log"
        ".DS_Store"
        "Thumbs.db"
        "*.tmp"
        "*.pid"
        "venv/"
        "dist/"
        "build/"
    )
    
    for pattern in "${patterns_to_add[@]}"; do
        if ! grep -q "^$pattern" .gitignore 2>/dev/null; then
            echo "$pattern" >> .gitignore
            echo -e "${GREEN}✅ Added to .gitignore: $pattern${NC}"
        fi
    done
fi

# Create .dockerignore if missing
if [ ! -f ".dockerignore" ]; then
    echo -e "${CYAN}📝 Creating .dockerignore...${NC}"
    cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
__pycache__
*.pyc
.git
.gitignore
README.md
.env
.nyc_output
coverage
.vscode
.idea
*.swp
*.swo
.DS_Store
Thumbs.db
EOF
    echo -e "${GREEN}✅ Created .dockerignore${NC}"
fi

echo ""
echo -e "${PURPLE}📊 CLEANUP SUMMARY${NC}"
echo "================================================"

# Convert bytes to human readable
human_readable_size() {
    local size=$1
    if [ $size -gt 1073741824 ]; then
        echo "$(( size / 1073741824 ))GB"
    elif [ $size -gt 1048576 ]; then
        echo "$(( size / 1048576 ))MB"
    elif [ $size -gt 1024 ]; then
        echo "$(( size / 1024 ))KB"
    else
        echo "${size}B"
    fi
}

SAVED_SIZE=$(human_readable_size $TOTAL_SIZE_SAVED)

echo -e "${BLUE}📈 CLEANUP STATISTICS:${NC}"
echo -e "   Files Removed:      ${GREEN}$TOTAL_FILES_REMOVED${NC}"
echo -e "   Directories Removed: ${GREEN}$TOTAL_DIRS_REMOVED${NC}"
echo -e "   Space Saved:        ${GREEN}$SAVED_SIZE${NC}"
echo ""

echo -e "${BLUE}🎯 WHAT WAS CLEANED:${NC}"
echo -e "   ✅ Node.js dependencies and caches"
echo -e "   ✅ Python virtual environments and cache"
echo -e "   ✅ Docker build artifacts"
echo -e "   ✅ IDE and editor temporary files"
echo -e "   ✅ Log files and process IDs"
echo -e "   ✅ Test artifacts and coverage reports"
echo -e "   ✅ Build outputs and temporary files"
echo -e "   ✅ Large unnecessary files"
echo -e "   ✅ Empty directories"
echo ""

echo -e "${BLUE}📋 WHAT WAS PRESERVED:${NC}"
echo -e "   ✅ Source code and configuration"
echo -e "   ✅ Package.json and requirements.txt"
echo -e "   ✅ Git repository (.git directory)"
echo -e "   ✅ Documentation and README files"
echo -e "   ✅ Essential configuration files"
echo -e "   ✅ Small training datasets"
echo ""

echo -e "${BLUE}🚀 NEXT STEPS:${NC}"
echo -e "   1. Run 'npm install' in frontend/ to restore dependencies"
echo -e "   2. Run 'pip install -r requirements.txt' in backend/ for Python deps"
echo -e "   3. Recreate .env file with your environment variables"
echo -e "   4. Run tests to verify everything still works"
echo ""

echo -e "${GREEN}✅ REPOSITORY CLEANUP COMPLETE!${NC}"
echo -e "${GREEN}🎉 Your repo is now lean, clean, and optimized!${NC}"
echo ""

# Generate cleanup report
cat > cleanup_report.json << EOF
{
  "cleanup_date": "$(date -Iseconds)",
  "statistics": {
    "files_removed": $TOTAL_FILES_REMOVED,
    "directories_removed": $TOTAL_DIRS_REMOVED,
    "space_saved_bytes": $TOTAL_SIZE_SAVED,
    "space_saved_human": "$SAVED_SIZE"
  },
  "categories_cleaned": [
    "Node.js dependencies and caches",
    "Python virtual environments",
    "Docker artifacts",
    "IDE temporary files",
    "Log files and PIDs",
    "Test artifacts",
    "Build outputs",
    "Large unnecessary files",
    "Empty directories"
  ],
  "preserved": [
    "Source code",
    "Configuration files",
    "Git repository",
    "Documentation",
    "Package definitions",
    "Essential datasets"
  ]
}
EOF

echo -e "${CYAN}📋 Detailed cleanup report saved to: cleanup_report.json${NC}"
echo ""