#!/bin/bash

# =============================================================================
# Quick Cruise Control Simulation Runner
# Simple script to run cruise control simulations quickly
# =============================================================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="/Users/shaama/Desktop/santhosh"

echo -e "${BLUE}🚗 Quick Cruise Control Simulation${NC}"
echo "=================================="

# Change to project directory
cd "$PROJECT_DIR" || exit 1

# Setup Python environment if needed
if [ ! -d "cruise_control_env" ]; then
    echo -e "${YELLOW}Setting up Python environment...${NC}"
    python3 -m venv cruise_control_env
    source cruise_control_env/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
else
    source cruise_control_env/bin/activate
fi

echo -e "${GREEN}✅ Environment ready${NC}"

# Run the simulation
echo -e "${BLUE}🚀 Running cruise control simulation...${NC}"
python cruise_control_simulation.py

echo -e "${GREEN}✅ Simulation completed!${NC}"
echo ""
echo "📊 Check the generated plots for results"
echo "🔧 To run custom tests: python custom_cruise_tests.py"
echo "🔬 For MATLAB models, open MATLAB and run: cruise_control_setup; create_cruise_control_slx"
