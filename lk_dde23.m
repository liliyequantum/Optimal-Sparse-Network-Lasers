function [sol, t_cell, E_cell, N_cell, Iss_cell, Nss_cell] = lk_dde23(max_step, ...
    params,initial_state_noise_switch)

% clear; clc; close all;
maxNumCompThreads(1);
rng('shuffle');

params.W = params.detuning;%3 * sqrt(2 * pi) * randn(params.M, 1);  % Disorder for each laser
params.sigma = 1; % unit of frequency, GHz = ns^-1

% time config.
max_t = 100;
rel_tol = 1e-3;
abs_tol = 1e-6;

% Initial free laser steady state condition
abs2_E0_1 = (params.j0 - params.gamma_n * (params.gamma/params.g_E + params.N0));
abs2_E0_2 = params.gamma * (params.g_N/params.g_E + params.gamma_n * params.s / params.g_E);
abs2_E0 = abs2_E0_1/abs2_E0_2; % corresponds to Nathan Iss
abs_E0 = sqrt(abs2_E0);
steady_N0 = params.gamma / params.g_E * (1 + params.s * abs2_E0) + params.N0;

Iss_cell = {abs2_E0};
Nss_cell = {steady_N0};

% Define the history function
if initial_state_noise_switch == 0
    history = @(t) [abs_E0 * cos(params.W * t);
                           abs_E0 * sin(params.W * t);
                           steady_N0*ones(params.M,1)];
else
    history = @(t) [abs_E0 * cos(params.W * t).*(1+1e-6.*randn(params.M,1));
                           abs_E0 * sin(params.W * t).*(1+1e-6.*randn(params.M,1));
                           max(steady_N0*ones(params.M,1).*(1+1e-6.*randn(params.M,1)),0)];
end

% Set solver options with tighter tolerances 
options = ddeset('MaxStep', max_step, 'RelTol', rel_tol ,'AbsTol', abs_tol);

% Call dde23 to solve the system with delay
tspan = [0, max_t];  % Time span
% tic
sol = dde23(@(t,y,y_tau) lg_system(t, y, y_tau, params), params.tau_const, history, tspan, options);
% toc
% Extract the solutions for E and N from the solution
t_sol = sol.x;
y_sol = sol.y;

% Reshape solutions back to original form
E_real_sol= y_sol(1:params.M,:);
E_imag_sol = y_sol(params.M+1:2*params.M,:);
E_sol = E_real_sol + 1i * E_imag_sol;
N_sol = y_sol(2*params.M+1:end,:);

t_cell = {t_sol};
E_cell = {E_sol};
N_cell = {N_sol};

%% Define the DDE System with matrix-based parallel computation (optimized to avoid for loops)
function dydt = lg_system(t, y, y_tau, params)
    % t     - current time
    % y     - current value of x(t)
    % y_tau - delayed value x(t-tau)
    % gainfun - gain function
    % params - parameters for the LK equation

    M = params.M;

    % Reshape delayed variables (x_tau) into real and imaginary parts
    E_real_delayed = y_tau(1:M);
    E_imag_delayed = y_tau(M+1:2*M);

    % Reshape current variables
    E_real = y(1:M);
    E_imag = y(M+1:2*M);
    N = y(2*M+1:end); 
    
    % Recombine real and imaginary parts to form complex E fields
    E = E_real + 1i * E_imag; 
    E_delayed = E_real_delayed + 1i * E_imag_delayed; 
    interaction =  params.coupling_matrix * E_delayed;

    % Gain calculation
    gain_E = params.g_E .* (N - params.N0) ./ (1 + params.s .* abs(E).^2);
    gain_N = params.g_N .* (N - params.N0) ./ (1 + params.s .* abs(E).^2);
    % Compute dE/dt for real and imaginary parts
    dEdt = (1 + 1i .* params.alpha) .* 0.5 .* (gain_E - params.gamma) .* E + ...
         1i * params.sigma .* params.W .* E + ...
          interaction;

    % Compute dN/dt (population inversion)
    dNdt = params.j0 - params.gamma_n .* N - gain_N .* abs(E).^2;

    % Reshape the derivatives back into a vector for dde23
    dydt = [real(dEdt); imag(dEdt); dNdt];
end

end

