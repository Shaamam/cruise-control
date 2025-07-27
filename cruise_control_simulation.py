#!/usr/bin/env python3
"""
Cruise Control System Simulation
Alternative implementation in Python that mimics Simulink block behavior
Author: Auto-generated
Date: July 27, 2025
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import control as ct

class CruiseControlSystem:
    def __init__(self):
        """Initialize cruise control system parameters"""
        # Vehicle parameters
        self.m = 1000          # Vehicle mass (kg)
        self.b = 50            # Drag coefficient (N⋅s/m)
        
        # Engine parameters  
        self.Kv = 500          # Engine gain (N/V)
        self.tau_engine = 0.5  # Engine time constant (s)
        
        # Control parameters
        self.v_desired = 29    # Desired speed (m/s) ≈ 65 mph
        self.Kp = 800         # Proportional gain
        self.Ki = 40          # Integral gain
        self.Kd = 40          # Derivative gain
        
        # Constraints
        self.throttle_max = 1.0
        self.throttle_min = 0.0
        
        # Simulation parameters
        self.dt = 0.01        # Time step (s)
        self.T_sim = 100      # Simulation time (s)
        
        # Create transfer functions (equivalent to Simulink blocks)
        self.create_transfer_functions()
        
        # Initialize state variables
        self.reset_states()
    
    def create_transfer_functions(self):
        """Create transfer functions for engine and vehicle dynamics"""
        # Engine transfer function: Kv / (tau_engine*s + 1)
        self.engine_tf = ct.tf([self.Kv], [self.tau_engine, 1])
        
        # Vehicle dynamics: 1 / (m*s + b)  
        self.vehicle_tf = ct.tf([1], [self.m, self.b])
        
        # Combined plant (engine + vehicle)
        self.plant_tf = ct.series(self.engine_tf, self.vehicle_tf)
        
        # PID controller
        self.controller_tf = ct.tf([self.Kd, self.Kp, self.Ki], [1, 0])
    
    def reset_states(self):
        """Reset all state variables"""
        self.v_current = 0.0      # Current vehicle speed
        self.throttle = 0.0       # Current throttle position
        self.error_integral = 0.0 # Integral of error
        self.error_prev = 0.0     # Previous error for derivative
        
        # Engine state (1st order system)
        self.engine_state = 0.0
        
        # Vehicle state  
        self.vehicle_state = 0.0
    
    def pid_controller(self, error):
        """PID controller implementation"""
        # Proportional term
        p_term = self.Kp * error
        
        # Integral term (with anti-windup)
        self.error_integral += error * self.dt
        i_term = self.Ki * self.error_integral
        
        # Derivative term
        d_term = self.Kd * (error - self.error_prev) / self.dt
        self.error_prev = error
        
        # Combined control signal
        control_signal = p_term + i_term + d_term
        
        # Apply saturation limits
        control_signal = np.clip(control_signal, self.throttle_min, self.throttle_max)
        
        # Anti-windup: Reset integral if saturated
        if control_signal >= self.throttle_max or control_signal <= self.throttle_min:
            self.error_integral -= error * self.dt
        
        return control_signal
    
    def engine_model(self, throttle_input):
        """First-order engine dynamics"""
        # dx/dt = (Kv*throttle - x) / tau_engine
        force_command = self.Kv * throttle_input
        self.engine_state += (force_command - self.engine_state) * self.dt / self.tau_engine
        return self.engine_state
    
    def vehicle_model(self, engine_force, disturbance_force=0):
        """Vehicle dynamics with drag"""
        # F = ma + bv, so a = (F - bv)/m
        total_force = engine_force - self.b * self.v_current + disturbance_force
        acceleration = total_force / self.m
        self.v_current += acceleration * self.dt
        return self.v_current
    
    def simulate(self, reference_speed=None, disturbances=None):
        """Run complete simulation"""
        if reference_speed is None:
            reference_speed = self.v_desired
        
        # Time vector
        time = np.arange(0, self.T_sim, self.dt)
        n_steps = len(time)
        
        # Initialize arrays for logging
        speed_log = np.zeros(n_steps)
        throttle_log = np.zeros(n_steps) 
        error_log = np.zeros(n_steps)
        force_log = np.zeros(n_steps)
        reference_log = np.zeros(n_steps)
        
        # Reset states
        self.reset_states()
        
        for i, t in enumerate(time):
            # Reference speed (can change during simulation)
            if callable(reference_speed):
                v_ref = reference_speed(t)
            else:
                v_ref = reference_speed
            
            # Calculate error
            error = v_ref - self.v_current
            
            # PID control
            throttle_cmd = self.pid_controller(error)
            
            # Engine dynamics
            engine_force = self.engine_model(throttle_cmd)
            
            # Disturbance forces
            dist_force = 0
            if disturbances:
                for dist_func in disturbances:
                    dist_force += dist_func(t)
            
            # Vehicle dynamics
            speed = self.vehicle_model(engine_force, dist_force)
            
            # Log data
            speed_log[i] = speed
            throttle_log[i] = throttle_cmd
            error_log[i] = error
            force_log[i] = engine_force
            reference_log[i] = v_ref
        
        return {
            'time': time,
            'speed': speed_log,
            'throttle': throttle_log,
            'error': error_log,
            'force': force_log,
            'reference': reference_log
        }
    
    def plot_results(self, results):
        """Plot simulation results"""
        fig, axes = plt.subplots(2, 2, figsize=(12, 8))
        fig.suptitle('Cruise Control System Response', fontsize=16)
        
        # Speed tracking
        axes[0,0].plot(results['time'], results['reference'], 'r--', label='Reference', linewidth=2)
        axes[0,0].plot(results['time'], results['speed'], 'b-', label='Actual Speed')
        axes[0,0].set_ylabel('Speed (m/s)')
        axes[0,0].set_title('Speed Tracking')
        axes[0,0].legend()
        axes[0,0].grid(True)
        
        # Control effort
        axes[0,1].plot(results['time'], results['throttle'], 'g-')
        axes[0,1].set_ylabel('Throttle')
        axes[0,1].set_title('Control Signal')
        axes[0,1].grid(True)
        
        # Tracking error
        axes[1,0].plot(results['time'], results['error'], 'r-')
        axes[1,0].set_ylabel('Error (m/s)')
        axes[1,0].set_xlabel('Time (s)')
        axes[1,0].set_title('Speed Error')
        axes[1,0].grid(True)
        
        # Engine force
        axes[1,1].plot(results['time'], results['force'], 'm-')
        axes[1,1].set_ylabel('Force (N)')
        axes[1,1].set_xlabel('Time (s)')
        axes[1,1].set_title('Engine Force')
        axes[1,1].grid(True)
        
        plt.tight_layout()
        plt.show()

def road_grade_disturbance(grade_percent, start_time=50):
    """Create road grade disturbance function"""
    def disturbance(t):
        if t >= start_time:
            grade_rad = grade_percent * np.pi / 180
            return -1000 * 9.81 * np.sin(grade_rad)  # Negative for uphill
        return 0
    return disturbance

def wind_disturbance(wind_speed_ms):
    """Create wind disturbance function"""
    def disturbance(t):
        # Simplified wind drag: F = 0.5 * rho * Cd * A * v_wind^2
        # Using approximate values: rho*Cd*A ≈ 1.2
        return -0.6 * wind_speed_ms**2  # Negative for headwind
    return disturbance

def step_reference(initial_speed, final_speed, step_time=30):
    """Create step reference function"""
    def reference(t):
        return final_speed if t >= step_time else initial_speed
    return reference

# Example usage and test scenarios
if __name__ == "__main__":
    # Create cruise control system
    cruise = CruiseControlSystem()
    
    print("Cruise Control System Simulation")
    print("=" * 40)
    print(f"Vehicle mass: {cruise.m} kg")
    print(f"Desired speed: {cruise.v_desired} m/s ({cruise.v_desired * 2.237:.1f} mph)")
    print(f"PID gains: Kp={cruise.Kp}, Ki={cruise.Ki}, Kd={cruise.Kd}")
    
    # Test 1: Basic step response
    print("\nTest 1: Step response to cruise speed...")
    results1 = cruise.simulate()
    
    # Test 2: Road grade disturbance  
    print("Test 2: Road grade disturbance (5% uphill at t=50s)...")
    grade_dist = road_grade_disturbance(5, start_time=50)
    results2 = cruise.simulate(disturbances=[grade_dist])
    
    # Test 3: Speed change command
    print("Test 3: Speed change (20 to 30 m/s at t=30s)...")
    speed_change = step_reference(20, 30, step_time=30)
    results3 = cruise.simulate(reference_speed=speed_change)
    
    # Plot all results
    cruise.plot_results(results1)
    cruise.plot_results(results2) 
    cruise.plot_results(results3)
    
    print("\nSimulation complete!")
