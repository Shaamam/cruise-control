%% Simulink Model Builder Script
% This script provides MATLAB commands to automatically build 
% a cruise control model in Simulink
% Run this after loading parameters with cruise_control_setup.m

function build_cruise_control_model()
    % Load parameters
    load('cruise_control_params.mat');
    
    % Create new Simulink model
    model_name = 'cruise_control_model';
    
    % Close model if already open
    try
        close_system(model_name, 0);
    catch
        % Model not open, continue
    end
    
    % Create new model
    new_system(model_name);
    open_system(model_name);
    
    % Add blocks to the model
    fprintf('Building Simulink model: %s\n', model_name);
    
    %% Input blocks
    % Reference speed constant
    add_block('simulink/Sources/Constant', [model_name '/Reference_Speed']);
    set_param([model_name '/Reference_Speed'], 'Value', 'v_desired');
    set_param([model_name '/Reference_Speed'], 'Position', [30, 100, 60, 130]);
    
    % Step input for testing (optional)
    add_block('simulink/Sources/Step', [model_name '/Step_Input']);
    set_param([model_name '/Step_Input'], 'Time', '30');
    set_param([model_name '/Step_Input'], 'Before', '0');
    set_param([model_name '/Step_Input'], 'After', 'v_desired');
    set_param([model_name '/Step_Input'], 'Position', [30, 160, 60, 190]);
    
    %% Error calculation
    % Sum block for error = reference - feedback
    add_block('simulink/Math Operations/Sum', [model_name '/Error_Sum']);
    set_param([model_name '/Error_Sum'], 'Inputs', '+-');
    set_param([model_name '/Error_Sum'], 'Position', [120, 100, 150, 130]);
    
    %% PID Controller
    add_block('simulink/Continuous/PID Controller', [model_name '/PID_Controller']);
    set_param([model_name '/PID_Controller'], 'P', 'Kp');
    set_param([model_name '/PID_Controller'], 'I', 'Ki');
    set_param([model_name '/PID_Controller'], 'D', 'Kd');
    set_param([model_name '/PID_Controller'], 'UpperSaturationLimit', 'throttle_max');
    set_param([model_name '/PID_Controller'], 'LowerSaturationLimit', 'throttle_min');
    set_param([model_name '/PID_Controller'], 'Position', [200, 95, 240, 135]);
    
    %% Engine Model
    % Transfer function: Kv/(tau_engine*s + 1)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Engine']);
    set_param([model_name '/Engine'], 'Numerator', '[Kv]');
    set_param([model_name '/Engine'], 'Denominator', '[tau_engine 1]');
    set_param([model_name '/Engine'], 'Position', [290, 95, 340, 135]);
    
    %% Disturbance Addition
    % Sum block for adding disturbances to engine force
    add_block('simulink/Math Operations/Sum', [model_name '/Force_Sum']);
    set_param([model_name '/Force_Sum'], 'Inputs', '++');
    set_param([model_name '/Force_Sum'], 'Position', [390, 95, 420, 125]);
    
    %% Vehicle Dynamics
    % Transfer function: 1/(m*s + b)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Vehicle']);
    set_param([model_name '/Vehicle'], 'Numerator', '[1]');
    set_param([model_name '/Vehicle'], 'Denominator', '[m b]');
    set_param([model_name '/Vehicle'], 'Position', [470, 95, 520, 135]);
    
    %% Disturbance Inputs
    % Road grade disturbance
    add_block('simulink/Sources/Step', [model_name '/Road_Grade']);
    set_param([model_name '/Road_Grade'], 'Time', 'grade_change_time');
    set_param([model_name '/Road_Grade'], 'Before', '0');
    set_param([model_name '/Road_Grade'], 'After', '-m*9.81*sin(new_grade*pi/180)');
    set_param([model_name '/Road_Grade'], 'Position', [290, 170, 320, 200]);
    
    % Wind disturbance
    add_block('simulink/Sources/Constant', [model_name '/Wind_Force']);
    set_param([model_name '/Wind_Force'], 'Value', '-0.6*wind_speed^2');
    set_param([model_name '/Wind_Force'], 'Position', [290, 210, 320, 240]);
    
    %% Output and Visualization
    % Speed scope
    add_block('simulink/Sinks/Scope', [model_name '/Speed_Scope']);
    set_param([model_name '/Speed_Scope'], 'Position', [570, 85, 600, 115]);
    
    % Throttle scope  
    add_block('simulink/Sinks/Scope', [model_name '/Throttle_Scope']);
    set_param([model_name '/Throttle_Scope'], 'Position', [290, 45, 320, 75]);
    
    % Error scope
    add_block('simulink/Sinks/Scope', [model_name '/Error_Scope']);
    set_param([model_name '/Error_Scope'], 'Position', [200, 45, 230, 75]);
    
    % To Workspace blocks for data export
    add_block('simulink/Sinks/To Workspace', [model_name '/Speed_Data']);
    set_param([model_name '/Speed_Data'], 'VariableName', 'speed_out');
    set_param([model_name '/Speed_Data'], 'Position', [570, 125, 600, 155]);
    
    add_block('simulink/Sinks/To Workspace', [model_name '/Throttle_Data']);
    set_param([model_name '/Throttle_Data'], 'VariableName', 'throttle_out');
    set_param([model_name '/Throttle_Data'], 'Position', [290, 15, 320, 35]);
    
    %% Connect all blocks
    fprintf('Connecting blocks...\n');
    
    % Main control loop connections
    add_line(model_name, 'Reference_Speed/1', 'Error_Sum/1');
    add_line(model_name, 'Error_Sum/1', 'PID_Controller/1');
    add_line(model_name, 'PID_Controller/1', 'Engine/1');
    add_line(model_name, 'Engine/1', 'Force_Sum/1');
    add_line(model_name, 'Force_Sum/1', 'Vehicle/1');
    
    % Feedback connection
    add_line(model_name, 'Vehicle/1', 'Error_Sum/2', 'autorouting', 'on');
    
    % Disturbance connections
    add_line(model_name, 'Road_Grade/1', 'Force_Sum/2');
    
    % Output connections
    add_line(model_name, 'Vehicle/1', 'Speed_Scope/1');
    add_line(model_name, 'Vehicle/1', 'Speed_Data/1');
    add_line(model_name, 'PID_Controller/1', 'Throttle_Scope/1');
    add_line(model_name, 'PID_Controller/1', 'Throttle_Data/1');
    add_line(model_name, 'Error_Sum/1', 'Error_Scope/1');
    
    %% Configure simulation parameters
    set_param(model_name, 'StopTime', 'T_sim');
    set_param(model_name, 'Solver', 'ode45');
    set_param(model_name, 'RelTol', '1e-6');
    
    %% Add annotations
    add_block('built-in/Note', [model_name '/Title_Note']);
    set_param([model_name '/Title_Note'], 'Position', [250, 20, 350, 40]);
    set_param([model_name '/Title_Note'], 'Text', 'Cruise Control System');
    
    fprintf('Model built successfully!\n');
    fprintf('Configure scope parameters and run simulation.\n');
    fprintf('Use sim(''%s'') to run from command line.\n', model_name);
    
    % Save the model
    save_system(model_name);
    
end

% Call the function to build the model
if ~exist('cruise_control_params.mat', 'file')
    warning('Parameters file not found. Run cruise_control_setup.m first.');
else
    build_cruise_control_model();
end
