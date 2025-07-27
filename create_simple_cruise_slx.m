%% Simplified Cruise Control Model Builder
% This creates a basic cruise control model that's easy to understand
% and modify. Perfect for learning Simulink fundamentals.

function create_simple_cruise_slx()
    
    % Load parameters
    if ~exist('cruise_control_params.mat', 'file')
        fprintf('Running parameter setup...\n');
        cruise_control_setup;
    else
        load('cruise_control_params.mat');
    end
    
    % Model name
    model_name = 'simple_cruise_control';
    
    % Close and delete existing model
    try
        close_system(model_name, 0);
    catch
    end
    
    if exist([model_name '.slx'], 'file')
        delete([model_name '.slx']);
    end
    
    % Create new model
    new_system(model_name, 'Model');
    open_system(model_name);
    
    fprintf('Creating simple cruise control model...\n');
    
    %% Basic Blocks Layout (Easy to Follow)
    
    % Row 1: Input and Reference
    add_block('simulink/Sources/Step', [model_name '/Speed_Command']);
    set_param([model_name '/Speed_Command'], 'Time', '5');
    set_param([model_name '/Speed_Command'], 'Before', '0');
    set_param([model_name '/Speed_Command'], 'After', 'v_desired');
    set_param([model_name '/Speed_Command'], 'Position', [30, 100, 70, 130]);
    
    % Row 2: Error Calculation
    add_block('simulink/Math Operations/Sum', [model_name '/Error']);
    set_param([model_name '/Error'], 'Inputs', '+-');
    set_param([model_name '/Error'], 'Position', [120, 100, 150, 130]);
    
    % Row 3: PID Controller
    add_block('simulink/Continuous/PID Controller', [model_name '/Controller']);
    set_param([model_name '/Controller'], 'P', 'Kp');
    set_param([model_name '/Controller'], 'I', 'Ki');
    set_param([model_name '/Controller'], 'D', 'Kd');
    set_param([model_name '/Controller'], 'Position', [200, 95, 240, 135]);
    
    % Row 4: Engine (1st Order Lag)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Engine']);
    set_param([model_name '/Engine'], 'Numerator', '[Kv]');
    set_param([model_name '/Engine'], 'Denominator', '[tau_engine 1]');
    set_param([model_name '/Engine'], 'Position', [290, 95, 340, 135]);
    
    % Row 5: Vehicle (Integrator with Drag)
    add_block('simulink/Continuous/Transfer Fcn', [model_name '/Vehicle']);
    set_param([model_name '/Vehicle'], 'Numerator', '[1]');
    set_param([model_name '/Vehicle'], 'Denominator', '[m b]');
    set_param([model_name '/Vehicle'], 'Position', [390, 95, 440, 135]);
    
    % Row 6: Speed Display
    add_block('simulink/Sinks/Scope', [model_name '/Speed_Display']);
    set_param([model_name '/Speed_Display'], 'Position', [490, 90, 530, 120]);
    
    % Additional monitoring
    add_block('simulink/Sinks/Scope', [model_name '/Throttle_Display']);
    set_param([model_name '/Throttle_Display'], 'Position', [290, 40, 330, 70]);
    
    add_block('simulink/Sinks/Display', [model_name '/Speed_Value']);
    set_param([model_name '/Speed_Value'], 'Position', [490, 130, 530, 160]);
    
    %% Connect Everything
    add_line(model_name, 'Speed_Command/1', 'Error/1');
    add_line(model_name, 'Error/1', 'Controller/1');
    add_line(model_name, 'Controller/1', 'Engine/1');
    add_line(model_name, 'Engine/1', 'Vehicle/1');
    add_line(model_name, 'Vehicle/1', 'Speed_Display/1');
    add_line(model_name, 'Vehicle/1', 'Speed_Value/1');
    
    % Feedback loop
    add_line(model_name, 'Vehicle/1', 'Error/2', 'autorouting', 'on');
    
    % Throttle monitoring
    add_line(model_name, 'Controller/1', 'Throttle_Display/1');
    
    %% Model Configuration
    set_param(model_name, 'StopTime', '50');
    set_param(model_name, 'Solver', 'ode45');
    
    %% Add Labels and Documentation
    add_block('built-in/Note', [model_name '/Title']);
    set_param([model_name '/Title'], 'Position', [200, 20, 300, 40]);
    set_param([model_name '/Title'], 'Text', 'Simple Cruise Control');
    set_param([model_name '/Title'], 'FontSize', '14');
    set_param([model_name '/Title'], 'FontWeight', 'bold');
    
    % Signal labels
    add_block('built-in/Note', [model_name '/Label1']);
    set_param([model_name '/Label1'], 'Position', [80, 80, 120, 90]);
    set_param([model_name '/Label1'], 'Text', 'Desired Speed');
    set_param([model_name '/Label1'], 'FontSize', '8');
    
    add_block('built-in/Note', [model_name '/Label2']);
    set_param([model_name '/Label2'], 'Position', [160, 80, 190, 90]);
    set_param([model_name '/Label2'], 'Text', 'Error');
    set_param([model_name '/Label2'], 'FontSize', '8');
    
    add_block('built-in/Note', [model_name '/Label3']);
    set_param([model_name '/Label3'], 'Position', [250, 80, 280, 90]);
    set_param([model_name '/Label3'], 'Text', 'Throttle');
    set_param([model_name '/Label3'], 'FontSize', '8');
    
    add_block('built-in/Note', [model_name '/Label4']);
    set_param([model_name '/Label4'], 'Position', [350, 80, 380, 90]);
    set_param([model_name '/Label4'], 'Text', 'Force');
    set_param([model_name '/Label4'], 'FontSize', '8');
    
    add_block('built-in/Note', [model_name '/Label5']);
    set_param([model_name '/Label5'], 'Position', [450, 80, 480, 90]);
    set_param([model_name '/Label5'], 'Text', 'Speed');
    set_param([model_name '/Label5'], 'FontSize', '8');
    
    %% Save Model
    save_system(model_name);
    
    fprintf('\n✅ Simple cruise control model created: %s.slx\n', model_name);
    fprintf('🎯 This model shows the basic cruise control loop clearly\n');
    fprintf('📊 Run simulation to see speed response\n\n');
    
end

% Run the function
create_simple_cruise_slx();
