function bifurcation_diagram_all2all_data_gen_1(dk,alpha)
% clear;close;close all;
% dk = 0.001;
% alpha = 5;

maxNumCompThreads(1);   
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq
% Parameters
M = 24; % Nodes (Adjacency Matrix Size)
W = zeros(M,1);

method = 'dde23';
kappa_array = 0:dk:1;

I_peak_cell = cell(length(kappa_array),M); % round(max_t/h_abm);
S_array=zeros(length(kappa_array),1);
RIN_2d=zeros(length(kappa_array),M);
tic
for kidx=1:length(kappa_array)
    kappa=kappa_array(kidx);
    all2all_coupling_matrix = kappa*(ones(M)-eye(M));
    [~, t_sol, E_sol, ~, Iss, ~, ~, ave_S] = Diode_Lang_Kobayashi_Eq_specify_alpha(alpha, method, W,  all2all_coupling_matrix);
    I_sol = abs(E_sol).^2/Iss;
    I_sol = I_sol(:,floor(end/2):end);
    t_sol = t_sol(floor(end/2):end);

    S_array(kidx) = ave_S;
    for Midx = 1:M
        y = I_sol(Midx,:);
        [peaks,~] = findpeaks(y, t_sol,'MinPeakDistance', 3);
        I_peak_cell{kidx,Midx} = peaks;
        RIN_2d(kidx, Midx) = std((y - mean(y))./mean(y)).^2;
    end
   
    disp(['progress: ',num2str(kidx/length(kappa_array))])
end
toc
save(['./data_bifurcation/disorder_free_all2all_dk_',...
    num2str(dk),'_alpha_',num2str(alpha),'_data.mat'],...
    'kappa_array','I_peak_cell','S_array','RIN_2d')
end

