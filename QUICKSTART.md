## Quick Start Guide

### For MATLAB/Simulink Users:

1. **Setup Parameters**: 
   ```matlab
   run('cruise_control_setup.m')
   ```

2. **Build Model Automatically**:
   ```matlab
   run('build_simulink_model.m')
   ```

3. **Manual Building**: Follow the detailed instructions in `README.md`

4. **Run Simulation**: Click "Run" in Simulink or use:
   ```matlab
   sim('cruise_control_model')
   ```

### For Python Users:

1. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run Simulation**:
   ```bash
   python cruise_control_simulation.py
   ```

### Block Summary for Simulink:

**Essential Blocks Needed:**
- Constant (reference speed)
- Sum (error calculation) 
- PID Controller
- Transfer Function × 2 (engine + vehicle)
- Scope × 3 (monitoring)
- Step (disturbances)

**Key Parameters:**
- Vehicle mass: 1000 kg
- Drag coefficient: 50 N⋅s/m
- Engine gain: 500 N/V
- PID gains: Kp=800, Ki=40, Kd=40

The Python simulation provides the same functionality as the Simulink model for testing and verification.
