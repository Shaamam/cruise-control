function create_cruise_control_slx()
%% Comprehensive Cruise Control Simulink Model Generator
% This function creates a complete cruise control model (.slx file)
% Run this script in MATLAB to generate the Simulink model
% 
% Prerequisites: 
% 1. Run cruise_control_setup.m first to load parameters
% 2. Have Simulink installed
%
% Usage: create_cruise_control_slx()

    % Check if parameters are loaded
    if ~exist('m', 'var') || ~exist('Kp', 'var')
        fprintf('Loading cruise control parameters...\n');
        cruise_control_setup;
    end
    
    % Model name
    model_name = 'cruise_control_complete';
    
    % Close existing model if open
    try
        close_system(model_name, 0);
    catch
        % Model not open, continue
    end
    
    % Delete existing model file if it exists
    if exist([model_name '.slx'], 'file')
        delete([model_name '.slx']);
    end
    
    % Create new model
    new_system(model_name, 'Model');
    open_system(model_name);
    
    fprintf('Creating cruise control Simulink model: %s.slx\n', model_name);
    
    %% Configure Model Settings
    set_param(model_name, 'StopTime', 'T_sim');
    set_param(model_name, 'Solver', 'ode45');
    set_param(model_name, 'RelTol', '1e-6');
    set_param(model_name, 'MaxStep', 'auto');
    set_param(model_name, 'SolverType', 'Variable-step');
    
    %% Main Control Loop Blocks
    
    % Reference Speed Input
    add_block('simulink/Sources/Constant', [model_name '/Reference_Speed']);
    set_param([model_name '/Reference_Speed'], 'Value', 'v_desired');
    set_param([model_name '/Reference_Speed'], 'Position', [50, 200, 90, 230]);
    
    % Error Sum Block (Reference - Feedback)
    add_block('simulink/Math Operations/Sum', [model_name '/Error_Sum']);
    set_param([model_name '/Error_Sum'], 'Inputs', '+-');
    set_param([model_name '/Error_Sum'], 'Position', [150, 195, 180, 235]);
    
    % PID Controller
    add_block('simulink/Continuous/PID Controller', [model_name '/PID_Controller']);
    set_param([model_name '/PID_Controller'], 'P', 'Kp');
    set_param([model_name '/PID_Controller'], 'I', 'Ki');
    set_param([model_name '/PID_Controller'], 'D', 'Kd');
    set_param([model_name '/PID_Controller'], 'UpperSaturationLimit', 'throttle_max');
    set_param([model_name '/PID_Controller'], 'LowerSaturationLimit', 'throttle_min');
    set_param([model_name '/PID_Controller'], 'Position', [220, 190, 280, 240]);
    
    % Engine Transfer Function: Kv/(tau_engine*s + 1)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Engine_Dynamics']);
    set_param([model_name '/Engine_Dynamics'], 'Numerator', '[Kv]');
    set_param([model_name '/Engine_Dynamics'], 'Denominator', '[tau_engine 1]');
    set_param([model_name '/Engine_Dynamics'], 'Position', [320, 190, 380, 240]);
    
    % Force Summation (Engine + Disturbances)
    add_block('simulink/Math Operations/Sum', [model_name '/Force_Sum']);
    set_param([model_name '/Force_Sum'], 'Inputs', '+++');
    set_param([model_name '/Force_Sum'], 'Position', [420, 190, 450, 240]);
    
    % Vehicle Dynamics: 1/(m*s + b)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Vehicle_Dynamics']);
    set_param([model_name '/Vehicle_Dynamics'], 'Numerator', '[1]');
    set_param([model_name '/Vehicle_Dynamics'], 'Denominator', '[m b]');
    set_param([model_name '/Vehicle_Dynamics'], 'Position', [490, 190, 550, 240]);
    
    %% Disturbance Inputs
    
    % Road Grade Disturbance
    add_block('simulink/Sources/Step', [model_name '/Road_Grade_Step']);
    set_param([model_name '/Road_Grade_Step'], 'Time', 'grade_change_time');
    set_param([model_name '/Road_Grade_Step'], 'Before', '0');
    set_param([model_name '/Road_Grade_Step'], 'After', 'new_grade');
    set_param([model_name '/Road_Grade_Step'], 'Position', [250, 300, 290, 330]);
    
    % Grade to Force Conversion: -m*g*sin(grade*pi/180)
    add_block('simulink/Math Operations/Gain', [model_name '/Grade_to_Force']);
    set_param([model_name '/Grade_to_Force'], 'Gain', '-m*9.81*pi/180');
    set_param([model_name '/Grade_to_Force'], 'Position', [320, 300, 360, 330]);
    
    % Sin function for grade conversion
    add_block('simulink/Math Operations/Trigonometric Function', [model_name '/Sin_Grade']);
    set_param([model_name '/Sin_Grade'], 'Operator', 'sin');
    set_param([model_name '/Sin_Grade'], 'Position', [290, 300, 310, 320]);
    
    % Wind Disturbance
    add_block('simulink/Sources/Constant', [model_name '/Wind_Disturbance']);
    set_param([model_name '/Wind_Disturbance'], 'Value', '-0.6*wind_speed^2');
    set_param([model_name '/Wind_Disturbance'], 'Position', [320, 260, 380, 290]);
    
    %% Alternative Input Sources
    
    % Step Reference for Testing
    add_block('simulink/Sources/Step', [model_name '/Step_Reference']);
    set_param([model_name '/Step_Reference'], 'Time', '30');
    set_param([model_name '/Step_Reference'], 'Before', '0');
    set_param([model_name '/Step_Reference'], 'After', 'v_desired');
    set_param([model_name '/Step_Reference'], 'Position', [50, 120, 90, 150]);
    
    % Manual Switch for Reference Selection
    add_block('simulink/Signal Routing/Manual Switch', [model_name '/Reference_Switch']);
    set_param([model_name '/Reference_Switch'], 'Position', [120, 160, 140, 200]);
    
    %% Output and Monitoring
    
    % Speed Output Scope
    add_block('simulink/Sinks/Scope', [model_name '/Speed_Scope']);
    set_param([model_name '/Speed_Scope'], 'Position', [600, 180, 650, 210]);
    set_param([model_name '/Speed_Scope'], 'YMin', '0');
    set_param([model_name '/Speed_Scope'], 'YMax', '35');
    
    % Throttle Scope
    add_block('simulink/Sinks/Scope', [model_name '/Throttle_Scope']);
    set_param([model_name '/Throttle_Scope'], 'Position', [320, 120, 370, 150]);
    set_param([model_name '/Throttle_Scope'], 'YMin', '0');
    set_param([model_name '/Throttle_Scope'], 'YMax', '1.2');
    
    % Error Scope
    add_block('simulink/Sinks/Scope', [model_name '/Error_Scope']);
    set_param([model_name '/Error_Scope'], 'Position', [200, 120, 250, 150]);
    set_param([model_name '/Error_Scope'], 'YMin', '-5');
    set_param([model_name '/Error_Scope'], 'YMax', '30');
    
    % Engine Force Scope
    add_block('simulink/Sinks/Scope', [model_name '/Force_Scope']);
    set_param([model_name '/Force_Scope'], 'Position', [420, 120, 470, 150]);
    
    % Data Export to Workspace
    add_block('simulink/Sinks/To Workspace', [model_name '/Speed_Out']);
    set_param([model_name '/Speed_Out'], 'VariableName', 'speed_sim');
    set_param([model_name '/Speed_Out'], 'Position', [600, 220, 650, 250]);
    
    add_block('simulink/Sinks/To Workspace', [model_name '/Throttle_Out']);
    set_param([model_name '/Throttle_Out'], 'VariableName', 'throttle_sim');
    set_param([model_name '/Throttle_Out'], 'Position', [320, 80, 370, 110]);
    
    add_block('simulink/Sinks/To Workspace', [model_name '/Time_Out']);
    set_param([model_name '/Time_Out'], 'VariableName', 'time_sim');
    set_param([model_name '/Time_Out'], 'Position', [600, 260, 650, 290]);
    
    % Clock for time vector
    add_block('simulink/Sources/Clock', [model_name '/Clock']);
    set_param([model_name '/Clock'], 'Position', [550, 260, 580, 290]);
    
    %% Performance Measurement Blocks
    
    % RMS Error Calculation
    add_block('simulink/Math Operations/Math Function', [model_name '/Error_Squared']);
    set_param([model_name '/Error_Squared'], 'Operator', 'square');
    set_param([model_name '/Error_Squared'], 'Position', [200, 340, 230, 370]);
    
    add_block('simulink/Discrete/Discrete-Time Integrator', [model_name '/RMS_Integrator']);
    set_param([model_name '/RMS_Integrator'], 'Position', [250, 340, 290, 370]);
    
    %% Signal Connections
    fprintf('Connecting model blocks...\n');
    
    % Main control loop
    add_line(model_name, 'Reference_Switch/1', 'Error_Sum/1');
    add_line(model_name, 'Error_Sum/1', 'PID_Controller/1');
    add_line(model_name, 'PID_Controller/1', 'Engine_Dynamics/1');
    add_line(model_name, 'Engine_Dynamics/1', 'Force_Sum/1');
    add_line(model_name, 'Force_Sum/1', 'Vehicle_Dynamics/1');
    
    % Feedback loop
    add_line(model_name, 'Vehicle_Dynamics/1', 'Error_Sum/2', 'autorouting', 'on');
    
    % Reference inputs
    add_line(model_name, 'Reference_Speed/1', 'Reference_Switch/1');
    add_line(model_name, 'Step_Reference/1', 'Reference_Switch/2');
    
    % Disturbances
    add_line(model_name, 'Road_Grade_Step/1', 'Grade_to_Force/1');
    add_line(model_name, 'Grade_to_Force/1', 'Force_Sum/2');
    add_line(model_name, 'Wind_Disturbance/1', 'Force_Sum/3');
    
    % Monitoring outputs
    add_line(model_name, 'Vehicle_Dynamics/1', 'Speed_Scope/1');
    add_line(model_name, 'Vehicle_Dynamics/1', 'Speed_Out/1');
    add_line(model_name, 'PID_Controller/1', 'Throttle_Scope/1');
    add_line(model_name, 'PID_Controller/1', 'Throttle_Out/1');
    add_line(model_name, 'Error_Sum/1', 'Error_Scope/1');
    add_line(model_name, 'Engine_Dynamics/1', 'Force_Scope/1');
    add_line(model_name, 'Clock/1', 'Time_Out/1');
    
    % Performance measurement
    add_line(model_name, 'Error_Sum/1', 'Error_Squared/1');
    add_line(model_name, 'Error_Squared/1', 'RMS_Integrator/1');
    
    %% Add Annotations and Documentation
    
    % Title annotation
    annotation_h = add_block('built-in/Note', [model_name '/Title']);
    set_param(annotation_h, 'Position', [300, 50, 400, 80]);
    set_param(annotation_h, 'Text', ['Cruise Control System' newline 'Created: ' datestr(now)]);
    set_param(annotation_h, 'FontSize', '14');
    set_param(annotation_h, 'FontWeight', 'bold');
    
    % Parameter annotation
    param_text = sprintf(['System Parameters:' newline ...
                         'Vehicle Mass: %.0f kg' newline ...
                         'Drag Coeff: %.1f N·s/m' newline ...
                         'Target Speed: %.1f m/s (%.1f mph)' newline ...
                         'PID Gains: Kp=%.0f, Ki=%.0f, Kd=%.0f'], ...
                         m, b, v_desired, v_desired*2.237, Kp, Ki, Kd);
    
    param_h = add_block('built-in/Note', [model_name '/Parameters']);
    set_param(param_h, 'Position', [50, 400, 250, 500]);
    set_param(param_h, 'Text', param_text);
    set_param(param_h, 'FontSize', '10');
    
    % Instructions annotation
    instr_text = ['Instructions:' newline ...
                  '1. Use Reference_Switch to select input' newline ...
                  '2. Position 1: Constant speed' newline ...
                  '3. Position 2: Step input for testing' newline ...
                  '4. Adjust Road_Grade_Step for hills' newline ...
                  '5. Monitor scopes for performance'];
    
    instr_h = add_block('built-in/Note', [model_name '/Instructions']);
    set_param(instr_h, 'Position', [400, 350, 600, 450]);
    set_param(instr_h, 'Text', instr_text);
    set_param(instr_h, 'FontSize', '10');
    
    %% Configure Scope Properties
    
    % Configure Speed Scope
    speed_scope_handle = get_param([model_name '/Speed_Scope'], 'Handle');
    set_param(speed_scope_handle, 'TimeRange', 'auto');
    set_param(speed_scope_handle, 'Title', 'Vehicle Speed (m/s)');
    
    % Configure Throttle Scope  
    throttle_scope_handle = get_param([model_name '/Throttle_Scope'], 'Handle');
    set_param(throttle_scope_handle, 'Title', 'Throttle Position');
    
    % Configure Error Scope
    error_scope_handle = get_param([model_name '/Error_Scope'], 'Handle');
    set_param(error_scope_handle, 'Title', 'Speed Error (m/s)');
    
    %% Save the Model
    save_system(model_name);
    
    fprintf('\n✅ SUCCESS! Cruise control model created: %s.slx\n', model_name);
    fprintf('📁 Model saved in: %s\n', pwd);
    fprintf('\n🚀 To run simulation:\n');
    fprintf('   1. Click "Run" button in Simulink\n');
    fprintf('   2. Or use: sim(''%s'')\n', model_name);
    fprintf('\n📊 Monitor the scopes for real-time performance\n');
    fprintf('📈 Data will be exported to workspace variables:\n');
    fprintf('   - speed_sim, throttle_sim, time_sim\n');
    
    % Auto-arrange the model layout
    try
        Simulink.BlockDiagram.arrangeSystem(model_name);
    catch
        fprintf('Note: Auto-layout not available in this MATLAB version\n');
    end
    
end

% Auto-run if parameters exist
if exist('cruise_control_params.mat', 'file')
    fprintf('Found parameter file. Creating model...\n');
    load('cruise_control_params.mat');
    create_cruise_control_slx();
else
    fprintf('❌ Parameter file not found!\n');
    fprintf('Please run cruise_control_setup.m first, then run this script.\n');
end
