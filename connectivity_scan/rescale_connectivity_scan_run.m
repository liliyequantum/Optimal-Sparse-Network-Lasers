function rescale_connectivity_scan_run(method, coupling_connectivity, num_rng_w)
% 0<=coupling_connectivity<=1

     % clear;clc;
    maxNumCompThreads(1);
    addpath('../'); % to include two functions, lk_vcsel_dde23.m and lk_vcsel_abm4milshtein.m
     % diode laser parameters
    rng('shuffle');

    M = 24;
    % num_rng_w = 1;
    std_w = 14;
    d = 1;

    % method = 'dde23';
    % coupling_connectivity = 0.4;
    
    if coupling_connectivity == 0 || coupling_connectivity == 1
        num_repeat = 1;
    elseif coupling_connectivity > 0 && coupling_connectivity <1
       num_repeat = 1000;
    end

    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
    num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']);
    params.detuning = data.sorted_W;
    params.M = length(params.detuning);

    initial_state_noise_switch = 0; %with noise: 1, without: 0
    % 'abm4milshtein' for dde when noise_switch = 0; 
    % for time delay stochastic delay differential equation (sdde) when noise_switch = 1
    if strcmp(method, 'dde23')
        max_step = 1e-2; % for dde23
    elseif strcmp(method,  'abm4milshtein')
        h_abm = 1e-3; % for abm_noise
        noise_switch = 0; % for abm4milshtein, with noise: 1, without: 0
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
    params.Rsp = 5/I_bar; % GHz  spontaneous emission noise radius

    coupling_matrix_cell = gen_coupling(M, d, coupling_connectivity, num_repeat);
    ave_S_array = zeros(num_repeat,1);
    tic
    for i = 1:num_repeat
        params.coupling_matrix = coupling_matrix_cell{i,1};
         if strcmp(method, 'dde23')
            % dde23
            [~, t_cell, E_cell, ~,~, ~] = lk_dde23(max_step, ...
                params,initial_state_noise_switch);
        elseif strcmp(method,  'abm4milshtein')
            % abm
            [t_cell, E_cell, ~, ~, ~] = lk_abm4milshtein(h_abm, noise_switch,...
                params,initial_state_noise_switch);
        end
    
        t_sol = t_cell{1};
        E_sol = E_cell{1};
        % N_sol = N_cell{1};
        % Iss = Iss_cell{1};
        % Nss = Nss_cell{1};
    
        % Reconstruct the complex electric field E
        S = abs(sum(E_sol,1)).^2./sum(abs(E_sol).^2,1)./M;
        index = find(t_sol > round(t_sol(end)/2), 1);
        ave_S_array(i) = sum(S(index:end))./length(t_sol(index:end));
        disp(['progress: ', num2str(i/num_repeat)])
    end
    toc
    clear t_sol t_cell E_sol E_cell
    save(['./data/diode_data_connectivity_',num2str(coupling_connectivity),...
        '_num_rng_w_',num2str(num_rng_w),'.mat'],'-v7.3')
   

    function coupling_matrix_cell = gen_coupling(M, d,coupling_connectivity,num_repeat)
                coupling_matrix_cell = cell(num_repeat,1);
                if coupling_connectivity ==0 % all to all coupling
                       K = zeros(M,M);
                       for repIdx = 1:num_repeat
                           coupling_matrix_cell{repIdx,1} = K;
                       end
                elseif coupling_connectivity == 1 % identity coupling
                      K = d*(ones(M)-eye(M));  
                      for repIdx = 1:num_repeat
                           coupling_matrix_cell{repIdx,1} = K;
                      end
                elseif coupling_connectivity < 1 % spare coupling
                       for repIdx = 1:num_repeat
                           K = zeros(M,M);
                           numUpperDiagElements = (M * (M - 1)) / 2;
                           numOnes = round(numUpperDiagElements * coupling_connectivity);
                           upperDiagIndices = find(triu(ones(M), 1));
                           selectedIndices = randsample(upperDiagIndices, numOnes); % default no replacement
                           K(selectedIndices) =  d;
                           K = K + K';
                           coupling_matrix_cell{repIdx,1} = K;
                       end
                end
            end

end