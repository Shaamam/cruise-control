# 🚗 Cruise Control Simulation Scripts

## 📜 **Available Scripts**

### 1. **`run_cruise_simulation.sh`** - Full Featured Script
Complete automation script with interactive menu and multiple options.

**Features:**
- ✅ Interactive menu system
- ✅ Python simulation automation
- ✅ MATLAB/Simulink model generation
- ✅ Environment setup and validation
- ✅ Multiple simulation scenarios
- ✅ Report generation
- ✅ Cleanup utilities

**Usage:**
```bash
# Interactive mode (recommended)
./run_cruise_simulation.sh

# Command line options
./run_cruise_simulation.sh --python     # Python only
./run_cruise_simulation.sh --matlab     # MATLAB only  
./run_cruise_simulation.sh --all        # All simulations
./run_cruise_simulation.sh --setup      # Setup only
./run_cruise_simulation.sh --help       # Show help
```

### 2. **`quick_run.sh`** - Simple Quick Runner
Fast execution for basic Python simulation.

**Usage:**
```bash
./quick_run.sh
```

---

## 🚀 **How to Run**

### **Option 1: Full Interactive Experience**
```bash
cd /Users/shaama/Desktop/santhosh
./run_cruise_simulation.sh
```

**Menu Options:**
1. 🐍 Python simulation only
2. 🔬 MATLAB/Simulink simulation only
3. 🚀 Run all simulations
4. ⚙️ Setup environment only
5. 📊 Generate report
6. 🧹 Clean up files
7. ❓ Show help
8. 🚪 Exit

### **Option 2: Quick Python Simulation**
```bash
cd /Users/shaama/Desktop/santhosh
./quick_run.sh
```

### **Option 3: Command Line Arguments**
```bash
# Python simulation only
./run_cruise_simulation.sh --python

# MATLAB simulation only  
./run_cruise_simulation.sh --matlab

# Run everything
./run_cruise_simulation.sh --all

# Just setup environment
./run_cruise_simulation.sh --setup
```

---

## 🔧 **What the Scripts Do**

### **Automatic Environment Setup:**
- ✅ Creates Python virtual environment
- ✅ Installs required packages (numpy, matplotlib, scipy, control)
- ✅ Validates MATLAB installation (if needed)
- ✅ Checks for missing dependencies

### **Python Simulation Options:**
1. **Basic simulation** - 3 standard test scenarios
2. **Custom test suite** - Comprehensive scenarios with different parameters
3. **Interactive mode** - Manual parameter testing
4. **All simulations** - Runs everything

### **MATLAB/Simulink Options:**
1. **Generate models only** - Creates .slx files
2. **Generate and run basic** - Simple cruise control model
3. **Generate and run complete** - Full featured model with disturbances
4. **Parameter analysis** - Tests different PID gains

### **Additional Features:**
- 📊 **Report generation** - Creates markdown summary
- 🧹 **Cleanup utilities** - Removes temporary files
- 🎨 **Colored output** - Easy to read terminal output
- ⚠️ **Error handling** - Graceful failure management

---

## 📊 **Expected Outputs**

### **After Running Python Simulation:**
- Multiple plot windows showing:
  - Speed tracking performance
  - Control effort (throttle position)
  - Error signals
  - Engine force output
- Console output with performance metrics

### **After Running MATLAB Simulation:**
- Generated Simulink models (.slx files):
  - `simple_cruise_control.slx`
  - `cruise_control_complete.slx`
- Simulation results in MATLAB workspace
- Scope displays showing real-time performance

### **Generated Files:**
```
📁 /Users/shaama/Desktop/santhosh/
├── 📄 simulation_report.md           ← Summary report
├── 📄 simple_cruise_control.slx      ← Basic Simulink model
├── 📄 cruise_control_complete.slx    ← Full Simulink model
├── 📄 cruise_control_params.mat      ← MATLAB parameters
└── 🗂️ cruise_control_env/            ← Python environment
```

---

## 🎯 **Quick Start Commands**

### **Just want to see it work?**
```bash
./quick_run.sh
```

### **Want full control?**
```bash
./run_cruise_simulation.sh
```

### **Python simulation only?**
```bash
./run_cruise_simulation.sh --python
```

### **MATLAB models only?**
```bash
./run_cruise_simulation.sh --matlab
```

The scripts handle everything automatically - environment setup, package installation, simulation execution, and result generation! 🚀
