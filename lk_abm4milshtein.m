function [t_cell, E_cell, N_cell, Iss_cell, Nss_cell] = lk_abm4milshtein(h_abm, noise_switch,...
    params,initial_state_noise_switch)

% clear; clc; close all;
maxNumCompThreads(1);
rng('shuffle');

params.W = params.detuning;%3 * sqrt(2 * pi) * randn(params.M, 1);  % Disorder for each laser
params.sigma = 1; % unit of frequency, GHz = ns^-1

% time config.
max_t = 100;
params.max_t = max_t;
params.h = h_abm; % time step size

% Initial free laser steady state condition
abs2_E0_1 = (params.j0 - params.gamma_n * (params.gamma/params.g_E + params.N0));
abs2_E0_2 = params.gamma * (params.g_N/params.g_E + params.gamma_n * params.s / params.g_E);
abs2_E0 = abs2_E0_1/abs2_E0_2; % corresponds to Nathan Iss
abs_E0 = sqrt(abs2_E0);
steady_N0 = params.gamma / params.g_E * (1 + params.s * abs2_E0) + params.N0;

Iss_cell = {abs2_E0};
Nss_cell = {steady_N0};

% Time setup
tspan = [0,params.max_t];
num_steps = round((tspan(2)-tspan(1))/params.h);
t = linspace(tspan(1),tspan(2),num_steps);

% Define the history function
buffer_length = ceil(max(params.tau_const) / params.h);
t_delay_array = linspace(-params.tau_const, 0, buffer_length);
if initial_state_noise_switch == 0
    delay_buffer = [abs_E0 .* cos(params.W .* t_delay_array);
                           abs_E0 .* sin(params.W .* t_delay_array);
                           steady_N0.*ones(params.M,buffer_length)];
else
    delay_buffer = [abs_E0 .* cos(params.W .* t_delay_array).*(1+1e-6.*randn(params.M,buffer_length));
                           abs_E0 .* sin(params.W .* t_delay_array).*(1+1e-6.*randn(params.M,buffer_length));
                           max(steady_N0*ones(params.M,buffer_length).*(1+1e-6.*randn(params.M,buffer_length)),0)];
end
% Initialize arrays to store results and delayed values
y_sol = zeros(3*params.M, num_steps);
y0 = delay_buffer(:,end);
y_sol(:,1) = y0;

% % Stochastic noise terms based on autocorrelation definitions
if noise_switch == 1
    wiener_process = sqrt(params.h) * randn(3*params.M, num_steps); % dw_i(t)
    wiener_process(1:2*params.M,:) = sqrt(params.Rsp / 2) * wiener_process(1:2*params.M,:);  % update 
    N_dw_2 = 0.25 * params.gamma_n_noise *  wiener_process(2*params.M+1:end,:).^2;
    N_dw_1 = sqrt(params.gamma_n_noise) * wiener_process(2*params.M+1:end,:);
end
% noise_process = wiener_process(1:2*params.M,:);
% histogram(noise_process(:))
% set(gcf, 'Color', 'w');
% title('Distribution')

abm_buffer = [y0]; % four elements
% Runge-Kutta 4th order stochastic Milshtein with delay for the first 3 steps (initialization for ABM)
for n = 1:3
    % Calculate delays using buffer indices
    tau_idx = n;
    y_tau = delay_buffer(:, tau_idx); % 2M x M^2

    if noise_switch == 1
    wiener_process(2*params.M+1:end,n) = N_dw_2(:,n)+ ...
                sqrt(y_sol(2*params.M+1:end,n)).*N_dw_1(:,n);
    end
 
    % Calculate k1, k2, k3, k4 using f_with_delay_noise
    k1 = f_with_delay_noise(t(n), y_sol(:,n), y_tau, params);
    k2 = f_with_delay_noise(t(n) + 0.5 * params.h, y_sol(:,n) + 0.5 * params.h * k1, y_tau, params);
    k3 = f_with_delay_noise(t(n) + 0.5 * params.h, y_sol(:,n) + 0.5 * params.h * k2, y_tau, params);
    k4 = f_with_delay_noise(t(n) + params.h, y_sol(:,n) + params.h * k3, y_tau, params);

    % Update y_sol using RK4 formula
    if noise_switch == 0
        y_sol(:,n+1) = y_sol(:,n) + (params.h / 6) * (k1 + 2 * k2 + 2 * k3 + k4);
    else
        y_sol(:,n+1) = y_sol(:,n) + (params.h / 6) * (k1 + 2 * k2 + 2 * k3 + k4)+ wiener_process(:,n);
    end

    % Update delay buffer with the new solution value      
    abm_buffer =  [abm_buffer, y_sol(:,n+1)];

end

% Main loop for Adams-Bashforth-Moulton stochastic Milshtein with delay
for n = 4:num_steps-1
    % Calculate delays using buffer indices        
    tau_idx_np1 = mod(max(1, n + 1)-1,buffer_length)+1;
    tau_idx_n = mod(max(1, n)-1,buffer_length)+1;
    tau_idx_nm1 = mod(max(1, n - 1)-1,buffer_length)+1;
    tau_idx_nm2 = mod(max(1, n - 2)-1,buffer_length)+1;
    tau_idx_nm3 = mod(max(1, n - 3)-1,buffer_length)+1;

    y_tau_np1 = delay_buffer(:, tau_idx_np1); % 3M x 1
    y_tau_n = delay_buffer(:, tau_idx_n); % 3M x 1
    y_tau_nm1 = delay_buffer(:, tau_idx_nm1); % 3M x 1
    y_tau_nm2 = delay_buffer(:, tau_idx_nm2); % 3M x 1
    y_tau_nm3 = delay_buffer(:, tau_idx_nm3); % 3M x 1

    if noise_switch == 1
    wiener_process(2*params.M+1:end,n) = N_dw_2(:,n)+ ...
                sqrt(y_sol(2*params.M+1:end,n)).*N_dw_1(:,n);
    end
    % Predictor (Adams-Bashforth)
    dydt_pred = (55*f_with_delay_noise(t(n), y_sol(:,n), y_tau_n, params) ...
                - 59*f_with_delay_noise(t(n-1), y_sol(:,n-1), y_tau_nm1, params) ...
                + 37*f_with_delay_noise(t(n-2), y_sol(:,n-2), y_tau_nm2, params) ...
                - 9*f_with_delay_noise(t(n-3), y_sol(:,n-3), y_tau_nm3, params)) / 24;
    
    if noise_switch == 0
        y_pred = y_sol(:,n) + params.h * dydt_pred;
    else
        y_pred = y_sol(:,n) + params.h * dydt_pred  + wiener_process(:,n);
    end
      
    % Corrector (Adams-Moulton)
    dydt_corr = (9*f_with_delay_noise(t(n+1), y_pred, y_tau_np1, params) ...
                + 19*f_with_delay_noise(t(n), y_sol(:,n), y_tau_n, params) ...
                - 5*f_with_delay_noise(t(n-1), y_sol(:,n-1), y_tau_nm1, params) ...
                + f_with_delay_noise(t(n-2), y_sol(:,n-2), y_tau_nm2, params)) / 24;

    if noise_switch == 0
        y_sol(:,n+1) = y_sol(:,n) + params.h * dydt_corr;
    else
        y_sol(:,n+1) = y_sol(:,n) + params.h * dydt_corr + wiener_process(:,n);
    end
   
    index = mod(max(1, n - 3)-1,buffer_length)+1; % delay four steps to update history
    delay_buffer(:,index) = abm_buffer(:,1);
    abm_buffer(:,1) = [];
    abm_buffer = [abm_buffer, y_sol(:,n+1)];
 
    % disp(n/num_steps)

end

t_sol = t;
% Reshape solutions back to original form
E_real_sol= y_sol(1:params.M,:);
E_imag_sol = y_sol(params.M+1:2*params.M,:);
E_sol = E_real_sol + 1i * E_imag_sol;
N_sol = y_sol(2*params.M+1:end,:);

t_cell = {t_sol};
E_cell = {E_sol};
N_cell = {N_sol};

function dydt = f_with_delay_noise(t, y, y_tau, params)
    % y with 3 M x 1
    % y_tau with 3M x 1
    M = params.M;
    
    E_real = y(1:M,1);
    E_imag = y(M+1:2*M,1);
    E = E_real + 1i * E_imag;
    N = y(2*M+1:end,1);
  
    E_real_delayed = y_tau(1:M,1); 
    E_imag_delayed = y_tau(M+1:2*M,1);
    E_delayed = E_real_delayed + 1i * E_imag_delayed;
    interaction = params.coupling_matrix * E_delayed;
    
    % Drift terms (deterministic part)
    gain_E = params.g_E .* (N - params.N0) ./ (1 + params.s .* abs(E).^2);
    gain_N = params.g_N .* (N - params.N0) ./ (1 + params.s .* abs(E).^2);
    dEdt = (1 + 1i .* params.alpha) .* 0.5 .* (gain_E - params.gamma) .* E ...
               + 1i .* params.sigma .* params.W .* E +...
               interaction;
    dNdt = params.j0 - params.gamma_n .* N - gain_N .* abs(E).^2;
    
    % Combine results into dydt
    dydt = [real(dEdt); imag(dEdt); dNdt];
end
end