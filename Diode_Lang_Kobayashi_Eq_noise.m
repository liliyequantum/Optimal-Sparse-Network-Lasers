function [sol, t_sol, E_sol, N_sol, Iss, Nss, S, ave_S] = ...
    Diode_Lang_Kobayashi_Eq_noise(method, detuning, adjMatrix,...
    init_state_noise_switch, init_noise_var, dynamic_noise_switch, dynamic_noise_var)
 % clear;clc;
    maxNumCompThreads(1);
   
     % diode laser parameters
    rng('shuffle');

    % method = 'dde23';

    params.detuning = detuning;
    params.M = length(params.detuning);
    params.coupling_matrix = adjMatrix;

    % initial_state_noise_switch = 0; %with noise: 1, without: 0
    % 'abm4milshtein' for dde when noise_switch = 0; 
    % for time delay stochastic delay differential equation (sdde) when noise_switch = 1
    if strcmp(method, 'dde23')
        max_step = 1e-2; % for dde23
    elseif strcmp(method,  'abm4milshtein')
        h_abm = 0.5e-3; % for abm_noise
        % noise_switch = 0; % for abm4milshtein, with noise: 1, without: 0
    end
    
    N_bar = 1;%2e8;
    I_bar = 1;%5.5e5;
    tau = 3; % 3 ns for diode; 1 ns for vcsel
    % rescale diode parameters
    params.freq_ref = 2*pi/tau; % tau 
    params.tau_const = tau;%1; % time delay, ns
    params.alpha = 5;% linewidth enhancement factor
    params.N0 = 1.5e8/N_bar; %  number of carriers at transparency
    params.s = 2e-7*I_bar; % gain saturation coefficient
    params.g = 1.5e-5; % gain coefficient, ns^-1 with efficiency \eta_i = 90%
    params.g_E = params.g*N_bar;
    params.g_N = params.g*I_bar;
    params.gamma = 500;%500; % cavity loss, ns^-1
    params.gamma_n = 0.5;%0.5; % carrier loss, ns^-1
    params.gamma_n_noise = params.gamma_n/N_bar;
    params.j0 = 1/N_bar * 4 * params.gamma_n * (params.N0 * N_bar + params.gamma / params.g); % pump current, ns^-1
    params.Rsp = dynamic_noise_var/I_bar; % GHz  spontaneous emission noise radius
    params.sigma_init = init_noise_var;

     if strcmp(method, 'dde23')
        % dde23
        [sol,  t_cell, E_cell, N_cell, Iss_cell, Nss_cell] = lk_dde23_noise_specified(max_step, ...
            params, init_state_noise_switch);
    elseif strcmp(method,  'abm4milshtein')
        % abm
        [t_cell, E_cell, N_cell, Iss_cell, Nss_cell] = lk_abm4milshtein_noise_specified(params, h_abm,...
               init_state_noise_switch, dynamic_noise_switch);
        sol = 1;
    end
    
    t_sol = t_cell{1};
    E_sol = E_cell{1};
    N_sol = N_cell{1};
    Iss = Iss_cell{1};
    Nss = Nss_cell{1};

    S = abs(sum(E_sol,1)).^2./sum(abs(E_sol).^2,1)./params.M;
    index = find(t_sol > round(t_sol(end)/2), 1);
    ave_S = sum(S(index:end))./length(t_sol(index:end));


end

