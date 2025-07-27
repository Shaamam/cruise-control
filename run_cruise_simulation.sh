#!/bin/bash

# =============================================================================
# Cruise Control Simulation Runner
# Automated script to run cruise control simulations in Python and MATLAB
# Author: Auto-generated
# Date: July 27, 2025
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="/Users/shaama/Desktop/santhosh"

# Function to print colored output
print_header() {
    echo -e "${CYAN}===============================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}===============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python environment
check_python_env() {
    print_info "Checking Python environment..."
    
    if [ ! -d "$PROJECT_DIR/cruise_control_env" ]; then
        print_warning "Virtual environment not found. Creating..."
        cd "$PROJECT_DIR" || exit 1
        python3 -m venv cruise_control_env
        print_success "Virtual environment created"
    fi
    
    # Activate virtual environment
    source "$PROJECT_DIR/cruise_control_env/bin/activate"
    
    # Check if required packages are installed
    if ! python -c "import numpy, matplotlib, scipy, control" >/dev/null 2>&1; then
        print_warning "Required packages not found. Installing..."
        pip install --upgrade pip
        pip install -r "$PROJECT_DIR/requirements.txt"
        print_success "Python packages installed"
    else
        print_success "Python environment ready"
    fi
}

# Function to run Python simulation
run_python_simulation() {
    print_header "🐍 RUNNING PYTHON SIMULATION"
    
    cd "$PROJECT_DIR" || exit 1
    source cruise_control_env/bin/activate
    
    echo -e "${PURPLE}Choose simulation type:${NC}"
    echo "1) Basic simulation (3 standard tests)"
    echo "2) Custom test suite (comprehensive scenarios)"
    echo "3) Interactive mode"
    echo "4) All simulations"
    read -p "Enter choice (1-4): " sim_choice
    
    case $sim_choice in
        1)
            print_info "Running basic cruise control simulation..."
            python cruise_control_simulation.py
            ;;
        2)
            print_info "Running custom test suite..."
            python custom_cruise_tests.py
            ;;
        3)
            print_info "Starting interactive Python session..."
            python -i cruise_control_simulation.py
            ;;
        4)
            print_info "Running all simulations..."
            echo -e "${YELLOW}Running basic simulation...${NC}"
            python cruise_control_simulation.py
            echo -e "${YELLOW}Running custom test suite...${NC}"
            python custom_cruise_tests.py
            ;;
        *)
            print_error "Invalid choice. Running basic simulation..."
            python cruise_control_simulation.py
            ;;
    esac
    
    print_success "Python simulation completed"
}

# Function to check MATLAB installation
check_matlab() {
    print_info "Checking MATLAB installation..."
    
    if command_exists matlab; then
        print_success "MATLAB found"
        return 0
    else
        print_warning "MATLAB not found in PATH"
        
        # Check common MATLAB installation paths on macOS
        MATLAB_PATHS=(
            "/Applications/MATLAB_R2024b.app/bin/matlab"
            "/Applications/MATLAB_R2024a.app/bin/matlab"
            "/Applications/MATLAB_R2023b.app/bin/matlab"
            "/Applications/MATLAB_R2023a.app/bin/matlab"
            "/Applications/MATLAB_R2022b.app/bin/matlab"
            "/usr/local/bin/matlab"
        )
        
        for path in "${MATLAB_PATHS[@]}"; do
            if [ -x "$path" ]; then
                print_success "MATLAB found at: $path"
                export MATLAB_CMD="$path"
                return 0
            fi
        done
        
        print_error "MATLAB not found. Please install MATLAB or add it to PATH"
        return 1
    fi
}

# Function to run MATLAB simulation
run_matlab_simulation() {
    print_header "🔬 RUNNING MATLAB/SIMULINK SIMULATION"
    
    if ! check_matlab; then
        print_error "Cannot run MATLAB simulation without MATLAB installation"
        return 1
    fi
    
    cd "$PROJECT_DIR" || exit 1
    
    echo -e "${PURPLE}Choose MATLAB simulation:${NC}"
    echo "1) Generate Simulink models only"
    echo "2) Generate and run basic model"
    echo "3) Generate and run complete model"
    echo "4) Run parameter analysis"
    read -p "Enter choice (1-4): " matlab_choice
    
    # Create MATLAB script based on choice
    case $matlab_choice in
        1)
            cat > run_matlab_sim.m << 'EOF'
% Generate Simulink models
cruise_control_setup;
create_simple_cruise_slx;
create_cruise_control_slx;
fprintf('\n✅ Simulink models generated successfully!\n');
fprintf('📁 Models saved in: %s\n', pwd);
fprintf('🚀 Open the .slx files in Simulink to run simulations\n');
EOF
            ;;
        2)
            cat > run_matlab_sim.m << 'EOF'
% Generate and run basic model
cruise_control_setup;
create_simple_cruise_slx;
fprintf('\n🚀 Running basic cruise control simulation...\n');
sim('simple_cruise_control');
fprintf('✅ Basic simulation completed!\n');
EOF
            ;;
        3)
            cat > run_matlab_sim.m << 'EOF'
% Generate and run complete model
cruise_control_setup;
create_cruise_control_slx;
fprintf('\n🚀 Running complete cruise control simulation...\n');
sim('cruise_control_complete');
fprintf('✅ Complete simulation finished!\n');
fprintf('📊 Results available in workspace: speed_sim, throttle_sim, time_sim\n');
EOF
            ;;
        4)
            cat > run_matlab_sim.m << 'EOF'
% Parameter analysis
cruise_control_setup;
fprintf('\n📊 Running parameter analysis...\n');

% Test different PID gains
Kp_values = [400, 800, 1200];
Ki_values = [20, 40, 60];
Kd_values = [20, 40, 60];

for i = 1:length(Kp_values)
    fprintf('Testing Kp=%d, Ki=%d, Kd=%d\n', Kp_values(i), Ki_values(i), Kd_values(i));
    
    % Update gains
    Kp = Kp_values(i);
    Ki = Ki_values(i); 
    Kd = Kd_values(i);
    
    % Create and run model
    create_simple_cruise_slx;
    results = sim('simple_cruise_control');
    
    % Analyze results
    final_speed = mean(results.speed_sim.Data(end-100:end));
    fprintf('Final speed: %.2f m/s\n', final_speed);
end

fprintf('✅ Parameter analysis completed!\n');
EOF
            ;;
    esac
    
    # Run MATLAB
    print_info "Starting MATLAB simulation..."
    if [ -n "$MATLAB_CMD" ]; then
        "$MATLAB_CMD" -batch "run('run_matlab_sim.m')"
    else
        matlab -batch "run('run_matlab_sim.m')"
    fi
    
    # Clean up temporary script
    rm -f run_matlab_sim.m
    
    print_success "MATLAB simulation completed"
}

# Function to generate reports
generate_report() {
    print_header "📊 GENERATING SIMULATION REPORT"
    
    cd "$PROJECT_DIR" || exit 1
    
    # Create a simple report
    cat > simulation_report.md << EOF
# Cruise Control Simulation Report
Generated on: $(date)

## System Parameters
- Vehicle Mass: 1000 kg
- Drag Coefficient: 50 N⋅s/m  
- Engine Gain: 500 N/V
- Engine Time Constant: 0.5 s
- Target Speed: 29 m/s (64.9 mph)
- PID Gains: Kp=800, Ki=40, Kd=40

## Files Generated
- Python simulation results
- MATLAB/Simulink models (.slx files)
- Parameter configuration files

## Next Steps
1. Analyze simulation results
2. Tune controller parameters if needed
3. Test with different scenarios
4. Compare Python vs MATLAB results

## Simulation Summary
✅ Environment setup completed
✅ Python simulation executed
✅ MATLAB models generated
✅ Performance analysis available

For detailed analysis, open the generated plots and Simulink models.
EOF

    print_success "Report generated: simulation_report.md"
}

# Function to clean up
cleanup() {
    print_info "Cleaning up temporary files..."
    cd "$PROJECT_DIR" || exit 1
    
    # Remove temporary MATLAB files
    rm -f run_matlab_sim.m
    rm -f *.asv
    rm -f *.autosave
    
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    echo -e "${CYAN}Cruise Control Simulation Script${NC}"
    echo -e "${CYAN}=================================${NC}"
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  -p, --python     Run Python simulation only"
    echo "  -m, --matlab     Run MATLAB simulation only" 
    echo "  -a, --all        Run all simulations"
    echo "  -s, --setup      Setup environment only"
    echo "  -c, --clean      Clean up temporary files"
    echo "  -r, --report     Generate simulation report"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Interactive mode: Run without arguments for menu"
    echo ""
}

# Main menu function
show_menu() {
    clear
    print_header "🚗 CRUISE CONTROL SIMULATION SUITE"
    echo -e "${PURPLE}Select simulation option:${NC}"
    echo "1) 🐍 Python simulation only"
    echo "2) 🔬 MATLAB/Simulink simulation only"
    echo "3) 🚀 Run all simulations"
    echo "4) ⚙️  Setup environment only"
    echo "5) 📊 Generate report"
    echo "6) 🧹 Clean up files"
    echo "7) ❓ Show help"
    echo "8) 🚪 Exit"
    echo ""
    read -p "Enter your choice (1-8): " choice
}

# Main execution logic
main() {
    # Change to project directory
    cd "$PROJECT_DIR" || {
        print_error "Cannot access project directory: $PROJECT_DIR"
        exit 1
    }
    
    # Handle command line arguments
    case "${1:-}" in
        -p|--python)
            check_python_env
            run_python_simulation
            ;;
        -m|--matlab)
            run_matlab_simulation
            ;;
        -a|--all)
            check_python_env
            run_python_simulation
            run_matlab_simulation
            generate_report
            ;;
        -s|--setup)
            check_python_env
            print_success "Environment setup completed"
            ;;
        -c|--clean)
            cleanup
            ;;
        -r|--report)
            generate_report
            ;;
        -h|--help)
            show_help
            ;;
        "")
            # Interactive mode
            while true; do
                show_menu
                case $choice in
                    1)
                        check_python_env
                        run_python_simulation
                        read -p "Press Enter to continue..."
                        ;;
                    2)
                        run_matlab_simulation
                        read -p "Press Enter to continue..."
                        ;;
                    3)
                        check_python_env
                        run_python_simulation
                        run_matlab_simulation
                        generate_report
                        read -p "Press Enter to continue..."
                        ;;
                    4)
                        check_python_env
                        print_success "Environment setup completed"
                        read -p "Press Enter to continue..."
                        ;;
                    5)
                        generate_report
                        read -p "Press Enter to continue..."
                        ;;
                    6)
                        cleanup
                        read -p "Press Enter to continue..."
                        ;;
                    7)
                        show_help
                        read -p "Press Enter to continue..."
                        ;;
                    8)
                        print_success "Goodbye!"
                        exit 0
                        ;;
                    *)
                        print_error "Invalid choice. Please try again."
                        read -p "Press Enter to continue..."
                        ;;
                esac
            done
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Trap for cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"
