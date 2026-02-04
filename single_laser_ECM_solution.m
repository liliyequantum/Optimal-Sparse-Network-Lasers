function [solution, fit_error] = single_laser_ECM_solution(initial_guess, params)
% clear;clc;close all;

% VCSEL parameters
params.kappa = params.coupling_matrix; % scaler, feedback coupling strength
if imag(params.kappa)<1e-5
    params.kappa = real(params.kappa);
end
% Initial guess for [Ns, rs, Omega_s]
% initial_guess = [5e5, 100, 1]; % Choose a reasonable starting point

% Solve using fsolve
options = optimset('Display', 'none', 'TolFun', 1e-9, 'TolX', 1e-9);
solution = fsolve(@(vars) myEquations(vars, params), initial_guess, options);

% % Extract solutions
% Ns_solution = solution(1);
% rs_solution = solution(2);
% Omega_s_solution = solution(3);

% % Display results
% fprintf('N^s = %.6f\n', Ns_solution);
% fprintf('r^s = %.6f\n', rs_solution);
% fprintf('\\Omega^s = %.6f\n', Omega_s_solution);

fit_error = myEquations(solution, params);
% disp(F_test); % Should be close to [0, 0, 0]
end

function F = myEquations(vars, params)
    % Extract variables
    Ns = vars(1); % N^s
    rs = vars(2); % r^s
    Omega_s = vars(3); % Omega^s

    % (Continue for all parameters in your equation)
    gain_E = params.g_E .* (Ns - params.N0) ./ (1 + params.s .* rs.^2);
    gain_N = params.g_N .* (Ns - params.N0) ./ (1 + params.s .* rs.^2);
    % Define the system of equations
    F(1) = gain_E - params.gamma + 2 .* params.kappa .* cos((Omega_s + params.freq_ref) .* params.tau_const); % First equation involving Ns, rs, Omega_s
    F(2) = -params.W + Omega_s + params.kappa .* sqrt(1 + params.alpha.^2) .* ...
        sin((Omega_s + params.freq_ref) .* params.tau_const + atan(params.alpha)); % Omega_s
    F(3) = params.j0 - params.gamma_n .* Ns - gain_N .* rs.^2; % Third equation involving Ns, rs

end

