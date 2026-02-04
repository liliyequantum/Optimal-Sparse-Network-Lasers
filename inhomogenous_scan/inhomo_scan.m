function inhomo_scan(var,kappa,num_sample)
    maxNumCompThreads(1);
    % clear;close;close all;
    addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq
    rng('shuffle');
    % Parameters
    % var = 0.1;
    % kappa = 0.4;
    % num_sample = 10;
    
    
    M = 24; % Nodes (Adjacency Matrix Size)
    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_1_std_w_14.mat']); 
    W = data.sorted_W; % detuning
    method = 'dde23';
    
    K_cell = cell(num_sample,1);
    for i = 1:num_sample
        all2all = kappa*(ones(M) - eye(M));
        all2all = all2all + var*randn(M);
        all2all = triu(all2all,1);
        K_cell{i} = all2all + all2all';
    end
    
    ave_S_sample = zeros(num_sample,1);
    std_S_sample = zeros(num_sample,1);
    tic
    for i = 1:num_sample
        coupling_matrix = K_cell{i};
        [~, t_sol, ~, ~, ~, ~, S, ave_S_sample(i)] = ...
            Diode_Lang_Kobayashi_Eq(method, W,  coupling_matrix);
        index = find(t_sol > round(t_sol(end)/2), 1);
        std_S_sample(i) = std(S(index:end));
        disp(['progress: ',num2str(i/num_sample)])
    end
    toc
    % mkdir('data_homo')
    save(['./data_inhomo/var_',num2str(var),'_kappa_',num2str(kappa),'_num_sample_',num2str(num_sample),'.mat'])
end