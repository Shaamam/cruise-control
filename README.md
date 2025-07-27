# Cruise Control System Design Guide for Simulink

## Overview
This guide provides the complete design for a cruise control system using standard Simulink blocks. The system maintains a desired vehicle speed despite disturbances like road grade changes and wind.

## System Architecture

### Main Components:
1. **Controller (PID)** - Maintains desired speed
2. **Engine Model** - Converts throttle to force
3. **Vehicle Dynamics** - Converts force to speed
4. **Feedback Loop** - Speed measurement

## Block Diagram Structure

```
[Reference] → [Sum] → [PID Controller] → [Engine] → [Vehicle] → [Speed Output]
   (v_ref)      ↑                                              ↓
                |                                          [Scope]
                ← ← ← ← ← [Feedback] ← ← ← ← ← ← ← ← ←
```

## Detailed Block Configuration

### 1. Input Blocks
- **Constant Block**: Set to `v_desired` (29 m/s)
- **Step Block**: For testing speed changes
- **Ramp Block**: For gradual speed changes

### 2. Sum Block (Error Calculation)
- **Configuration**: Two inputs (`++` and `+-`)
- **Purpose**: Calculates error = reference - actual speed

### 3. PID Controller Block
- **Proportional Gain (P)**: `Kp`
- **Integral Gain (I)**: `Ki` 
- **Derivative Gain (D)**: `Kd`
- **Output Limits**: `[throttle_min, throttle_max]`

### 4. Engine Model (Transfer Function)
- **Block Type**: Transfer Function
- **Transfer Function**: `Kv / (tau_engine*s + 1)`
- **Parameters**: 
  - Numerator: `[Kv]`
  - Denominator: `[tau_engine 1]`

### 5. Vehicle Dynamics
- **Block Type**: Transfer Function  
- **Transfer Function**: `1 / (m*s + b)`
- **Parameters**:
  - Numerator: `[1]`
  - Denominator: `[m b]`

### 6. Disturbance Modeling

#### Road Grade Disturbance:
- **Block Type**: Step or Lookup Table
- **Purpose**: Simulates uphill/downhill forces
- **Force**: `m * 9.81 * sin(grade * pi/180)`

#### Wind Disturbance:
- **Block Type**: Constant or Band-Limited White Noise
- **Purpose**: Simulates aerodynamic disturbances

### 7. Output and Visualization
- **Scope Blocks**: For plotting speed, throttle, error
- **To Workspace**: For data analysis in MATLAB

## Step-by-Step Simulink Implementation

### Step 1: Create New Model
1. Open Simulink
2. File → New → Model
3. Save as `cruise_control_model.slx`

### Step 2: Add Input Blocks
1. Drag **Constant** block from Sources library
2. Set value to `v_desired`
3. Add **Step** block for testing (optional)

### Step 3: Add Sum Block
1. Drag **Sum** block from Math Operations
2. Configure signs as `|+-`
3. Connect reference to `+` input

### Step 4: Add PID Controller
1. Drag **PID Controller** from Continuous library
2. Set gains: P=`Kp`, I=`Ki`, D=`Kd`
3. Set output limits in "Output" tab

### Step 5: Add Engine Transfer Function
1. Drag **Transfer Fcn** from Continuous library
2. Set Numerator: `[Kv]`
3. Set Denominator: `[tau_engine 1]`

### Step 6: Add Vehicle Dynamics
1. Drag another **Transfer Fcn** block
2. Set Numerator: `[1]`
3. Set Denominator: `[m b]`

### Step 7: Add Feedback
1. Connect vehicle output to Sum block `-` input
2. Use signal lines to complete the loop

### Step 8: Add Disturbances (Optional)
1. Add **Sum** block after engine output
2. Connect disturbance forces to additional inputs

### Step 9: Add Outputs
1. Drag **Scope** blocks from Sinks library
2. Connect to view speed, throttle, and error signals
3. Add **To Workspace** blocks for data export

## Configuration Parameters

Before running the simulation:
1. Run `cruise_control_setup.m` in MATLAB
2. Set simulation time to `T_sim`
3. Choose solver (ode45 recommended)
4. Set relative tolerance to 1e-6

## Testing Scenarios

### Test 1: Step Response
- Input: Step from 0 to desired speed
- Expected: Speed reaches setpoint with minimal overshoot

### Test 2: Disturbance Rejection
- Add road grade at t=50s
- Expected: Speed returns to setpoint

### Test 3: Setpoint Change
- Change desired speed during simulation
- Expected: Smooth transition to new speed

## Performance Metrics
- **Rise Time**: Time to reach 90% of final value
- **Settling Time**: Time to stay within 2% of final value  
- **Overshoot**: Maximum deviation above setpoint
- **Steady-State Error**: Final error after settling

## Tuning Guidelines

### If system is unstable:
- Reduce Kp and Kd gains
- Increase Ki carefully

### If response is too slow:
- Increase Kp gain
- Increase Kd for faster response

### If steady-state error exists:
- Increase Ki gain
- Check for actuator saturation

## Files in this Package
- `cruise_control_setup.m` - Parameter definitions
- `cruise_control_simulation.py` - Python alternative
- `README.md` - This documentation

Run the setup script before building your Simulink model to load all necessary parameters into the workspace.
