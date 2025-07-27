%% Cruise Control System Parameters and Setup
% This script defines parameters for a cruise control model in Simulink
% Author: Auto-generated
% Date: July 27, 2025

clear all;
close all;
clc;

%% Vehicle Parameters
% Mass of the vehicle (kg)
m = 1000;

% Aerodynamic drag coefficient
b = 50;

% Engine gain (N/V) - relates throttle voltage to force
Kv = 500;

% Engine time constant (s)
tau_engine = 0.5;

%% Control System Parameters
% Desired cruise speed (m/s) - equivalent to ~65 mph
v_desired = 29;

% PID Controller gains
Kp = 800;    % Proportional gain
Ki = 40;     % Integral gain  
Kd = 40;     % Derivative gain

% Controller limits
throttle_max = 1;    % Maximum throttle (normalized)
throttle_min = 0;    % Minimum throttle (normalized)

%% Simulation Parameters
% Simulation time
T_sim = 100;

% Sample time for discrete blocks (if needed)
Ts = 0.01;

% Initial conditions
v_initial = 0;      % Initial vehicle speed (m/s)
throttle_initial = 0; % Initial throttle position

%% Disturbance Parameters
% Road grade (as percentage, positive = uphill)
road_grade = 0;     % Flat road initially
grade_change_time = 50; % Time when grade changes (s)
new_grade = 5;      % New grade percentage

% Wind disturbance
wind_speed = 0;     % Headwind speed (m/s)

%% Display Parameters
fprintf('Cruise Control System Parameters:\n');
fprintf('Vehicle mass: %.0f kg\n', m);
fprintf('Drag coefficient: %.1f N⋅s/m\n', b);
fprintf('Engine gain: %.0f N/V\n', Kv);
fprintf('Engine time constant: %.1f s\n', tau_engine);
fprintf('Desired speed: %.1f m/s (%.1f mph)\n', v_desired, v_desired*2.237);
fprintf('PID gains - Kp: %.0f, Ki: %.0f, Kd: %.0f\n', Kp, Ki, Kd);

%% Save parameters to workspace
% These variables will be available when you run this script before
% opening your Simulink model

save('cruise_control_params.mat', 'm', 'b', 'Kv', 'tau_engine', ...
     'v_desired', 'Kp', 'Ki', 'Kd', 'throttle_max', 'throttle_min', ...
     'T_sim', 'Ts', 'v_initial', 'throttle_initial', 'road_grade', ...
     'grade_change_time', 'new_grade', 'wind_speed');

fprintf('\nParameters saved to cruise_control_params.mat\n');
fprintf('Run this script before opening your Simulink model.\n');
