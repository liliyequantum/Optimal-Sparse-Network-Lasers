function figS7_1_run_basin(rng_ga_1, rng_ga_2)
    % clear;
    maxNumCompThreads(1);
    addpath('../')
    rng('shuffle')
    
    % rng_ga_1 = 0; % rng_ga
    % rng_ga_2 = 1; % rng_ga
    
    s_array = 0:0.1:1;
    num_repeat = 100;
    
    M = 24;
    num_rng_w = 1;
    std_w = 14;
    
    %% load detuning
    data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_',...
        num2str(num_rng_w),'_std_w_',num2str(std_w),'.mat']);
    detuning = data.sorted_W;
    
    %% load coupling matrix
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w),...
            '_rngga_',num2str(rng_ga_1),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    K_1 = data.bestAdjMatrix;
    data = load(['./data/updated_GA_island_gaussian_rngw_',num2str(num_rng_w),...
            '_rngga_',num2str(rng_ga_2),'_popSize_200_numGen_200_numIs_4_case_type_slow.mat']);
    K_2 = data.bestAdjMatrix;
    K_12 = K_1 - K_2;
    
    %% generate K_t to transit
    
    % Find link differences in the upper triangle (excluding diagonal)
    [row_idx_m1, col_idx_m1] = find(triu(K_12, 1) == -1);
    links_m1 = [row_idx_m1, col_idx_m1];
    
    [row_idx_1, col_idx_1] = find(triu(K_12, 1) == 1);
    links_1 = [row_idx_1, col_idx_1];
    
    % Randomly sample a portion s of each type separately
    
    K_t_4d = zeros(M,M,length(s_array),num_repeat);
    
    for sidx  = 1:length(s_array)
        for repeat_idx = 1:num_repeat
            s = s_array(sidx);
    
            % For -1 links
            Nm1 = size(links_m1, 1);
            m_m1 = round(s * Nm1);
            idx_m1 = randperm(Nm1, m_m1);
            subset_links_m1 = links_m1(idx_m1, :);
            
            % For +1 links
            N1 = size(links_1, 1);
            m_1 = round(s * N1);
            idx_1 = randperm(N1, m_1);
            subset_links_1 = links_1(idx_1, :);
            
            % Apply modifications on a copy of K_1
            K_t = triu(K_1);  % only upper triangle
            
            % Flip selected links
            K_t(sub2ind([M, M], subset_links_m1(:,1), subset_links_m1(:,2))) = 1;
            K_t(sub2ind([M, M], subset_links_1(:,1), subset_links_1(:,2))) = 0;
            
            % Optionally symmetrize the matrix if needed
            K_t = K_t + K_t';  % for undirected networks
        
            % sum(sum(K_1))
            % sum(sum(abs(K_t - K_2)))
            K_t_4d(:,:,sidx,repeat_idx) = K_t;
        end
    end
    
    
    
    %% generate sync. measure <S>
    ave_S_2d = zeros(length(s_array),num_repeat);
    time_1 = tic;
    for sidx  = 1:length(s_array)
        tic
        for repeat_idx = 1:num_repeat
            adjMatrix = K_t_4d(:,:,sidx,repeat_idx);
            [~, ~,~,~,~, ~, ~, ave_S] = Diode_Lang_Kobayashi_Eq('dde23', detuning, adjMatrix);
            ave_S_2d(sidx,repeat_idx) = ave_S;  
        end
        toc
        disp(['progress: ',num2str(sidx/length(s_array))])
    end
    toc(time_1)
    
    mkdir('data_basin')
    save(['./data_basin/ave_S_rng_',num2str(rng_ga_1),'_',num2str(rng_ga_2),'.mat'],'-v7.3')
end

