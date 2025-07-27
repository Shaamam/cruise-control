#!/usr/bin/env python3
"""
Custom Cruise Control Test Script
Shows how to run different scenarios with custom parameters
"""

from cruise_control_simulation import CruiseControlSystem, road_grade_disturbance, wind_disturbance, step_reference
import numpy as np

def custom_cruise_test():
    """Example of running cruise control with custom parameters"""
    
    # Create system
    cruise = CruiseControlSystem()
    
    # 🎛️ CUSTOMIZE PARAMETERS HERE:
    
    # Change vehicle mass (lighter car)
    cruise.m = 800  # kg
    
    # Change desired speed (55 mph ≈ 24.6 m/s)
    cruise.v_desired = 24.6  # m/s
    
    # More aggressive PID tuning
    cruise.Kp = 1000
    cruise.Ki = 50
    cruise.Kd = 60
    
    # Longer simulation
    cruise.T_sim = 150  # seconds
    
    # Recreate transfer functions with new parameters
    cruise.create_transfer_functions()
    
    print("🚗 Custom Cruise Control Test")
    print(f"Vehicle mass: {cruise.m} kg")
    print(f"Target speed: {cruise.v_desired} m/s ({cruise.v_desired * 2.237:.1f} mph)")
    print(f"PID gains: Kp={cruise.Kp}, Ki={cruise.Ki}, Kd={cruise.Kd}")
    print(f"Simulation time: {cruise.T_sim} seconds")
    
    # 📊 TEST SCENARIOS:
    
    # Scenario 1: Basic cruise control
    print("\n🔵 Test 1: Basic cruise engagement...")
    results1 = cruise.simulate()
    
    # Scenario 2: Highway speed change (55 mph → 70 mph)
    print("🔵 Test 2: Speed increase (55→70 mph)...")
    speed_change = step_reference(24.6, 31.3, step_time=60)  # 55→70 mph
    results2 = cruise.simulate(reference_speed=speed_change)
    
    # Scenario 3: Steep hill (8% grade)
    print("🔵 Test 3: Steep hill climbing...")
    steep_hill = road_grade_disturbance(8, start_time=40)
    results3 = cruise.simulate(disturbances=[steep_hill])
    
    # Scenario 4: Multiple disturbances
    print("🔵 Test 4: Multiple disturbances...")
    hill = road_grade_disturbance(3, start_time=30)
    wind = wind_disturbance(10)  # 10 m/s headwind
    results4 = cruise.simulate(disturbances=[hill, wind])
    
    # Plot results
    cruise.plot_results(results1)
    cruise.plot_results(results2)
    cruise.plot_results(results3)
    cruise.plot_results(results4)
    
    return results1, results2, results3, results4

def highway_scenario():
    """Realistic highway driving scenario"""
    
    cruise = CruiseControlSystem()
    
    # Highway vehicle (heavier SUV)
    cruise.m = 2000  # kg
    cruise.b = 80    # Higher drag
    
    # Highway speed (70 mph)
    cruise.v_desired = 31.3  # m/s
    
    # Conservative tuning for comfort
    cruise.Kp = 600
    cruise.Ki = 30
    cruise.Kd = 50
    
    cruise.T_sim = 200
    cruise.create_transfer_functions()
    
    print("\n🛣️  Highway Driving Scenario")
    print("Heavy SUV on highway with multiple disturbances")
    
    # Create realistic disturbances
    def highway_disturbances(t):
        total_force = 0
        
        # Rolling hills
        if 50 <= t < 80:
            total_force += -cruise.m * 9.81 * np.sin(2 * np.pi / 180)  # 2% uphill
        elif 80 <= t < 100:
            total_force += cruise.m * 9.81 * np.sin(3 * np.pi / 180)   # 3% downhill
        elif 120 <= t < 150:
            total_force += -cruise.m * 9.81 * np.sin(4 * np.pi / 180)  # 4% uphill
        
        # Variable wind (gusts)
        wind_base = 5 + 3 * np.sin(0.1 * t)  # 5±3 m/s wind
        total_force += -0.6 * wind_base**2
        
        return total_force
    
    # Speed changes (highway traffic)
    def highway_speed(t):
        if t < 40:
            return 31.3      # 70 mph
        elif t < 60:
            return 26.8      # 60 mph (traffic)
        elif t < 140:
            return 31.3      # 70 mph
        else:
            return 35.8      # 80 mph (passing)
    
    results = cruise.simulate(
        reference_speed=highway_speed,
        disturbances=[highway_disturbances]
    )
    
    cruise.plot_results(results)
    return results

def performance_analysis():
    """Analyze system performance with different tuning"""
    
    tuning_sets = [
        {"name": "Conservative", "Kp": 400, "Ki": 20, "Kd": 30},
        {"name": "Balanced", "Kp": 800, "Ki": 40, "Kd": 40},
        {"name": "Aggressive", "Kp": 1200, "Ki": 60, "Kd": 80},
    ]
    
    print("\n📊 Performance Analysis - Different PID Tunings")
    
    all_results = {}
    
    for tuning in tuning_sets:
        cruise = CruiseControlSystem()
        cruise.Kp = tuning["Kp"]
        cruise.Ki = tuning["Ki"] 
        cruise.Kd = tuning["Kd"]
        cruise.create_transfer_functions()
        
        print(f"\n🔧 Testing {tuning['name']} tuning:")
        print(f"   Kp={tuning['Kp']}, Ki={tuning['Ki']}, Kd={tuning['Kd']}")
        
        # Test step response
        results = cruise.simulate()
        all_results[tuning["name"]] = results
        
        # Calculate performance metrics
        final_speed = results['speed'][-1000:].mean()  # Last 10 seconds average
        rise_time_idx = np.where(results['speed'] >= 0.9 * cruise.v_desired)[0]
        rise_time = results['time'][rise_time_idx[0]] if len(rise_time_idx) > 0 else None
        
        overshoot = (results['speed'].max() - cruise.v_desired) / cruise.v_desired * 100
        
        print(f"   Rise time: {rise_time:.1f}s")
        print(f"   Overshoot: {overshoot:.1f}%")
        print(f"   Final speed: {final_speed:.1f} m/s")
    
    return all_results

# 🚀 MAIN EXECUTION
if __name__ == "__main__":
    print("=" * 60)
    print("🚗 CRUISE CONTROL CUSTOM TEST SUITE")
    print("=" * 60)
    
    # Run different test scenarios
    print("\n1️⃣ Running custom parameter tests...")
    custom_results = custom_cruise_test()
    
    print("\n2️⃣ Running highway scenario...")
    highway_results = highway_scenario()
    
    print("\n3️⃣ Running performance analysis...")
    performance_results = performance_analysis()
    
    print("\n✅ All tests completed!")
    print("\nTo run individual tests, you can call:")
    print("- custom_cruise_test()")
    print("- highway_scenario()")
    print("- performance_analysis()")
