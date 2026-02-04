clear;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

% Parameters
M = 24; % Nodes (Adjacency Matrix Size)
type_freq_disorder = 'gaussian';

std_w = 14;

K_3d = zeros(M,M,3);
K_3d(:,:,1) = 0.4*(ones(M)-eye(M));
K_3d(:,:,2) = ones(M)-eye(M);
K_3d(:,:,3) = 3*(ones(M)-eye(M));

t_start = 50; % ns
t_end = 100; % ns
L = (t_end-t_start)/1e-3;
t = linspace(t_start,t_end,L); 
dt = t(2)-t(1);
tau = 3;

data = load(['../freq_disorders/M_',num2str(M),'/freq_disorder_M_',num2str(M),'_num_rng_w_1',...
'_std_w_',num2str(std_w),'.mat']); 
W = data.sorted_W; % detuning

S_array = zeros(3,L);
R2_array = zeros(3,L);
intensity = zeros(3,M,L);
for kidx = 1:3
    
    tic
    [sol, ~, ~, ~, ~, ~, ~, ~] = ...
        Diode_Lang_Kobayashi_Eq('dde23', W,  K_3d(:,:,kidx));
    y = deval(t,sol); % interpolation check, compare with abm and dde23
    toc

    E_sol = zeros(M,L);
    for Midx = 1:M
        E_sol(Midx,:) = y(Midx,:)+1i*y(Midx+M,:);
    end
    intensity(kidx,:,:) = abs(E_sol).^2;

    % Reconstruct the complex electric field E
    S_array(kidx,:) = abs(sum(E_sol,1)).^2./sum(abs(E_sol).^2,1)./M;
    R2_array(kidx,:) = abs(sum(E_sol./abs(E_sol),1)).^2./M.^2;

end

% for i = 1:3
%     figure(i);clf;hold on;
%     plot(t, S_array(i,:)-R2_array(i,:))
%     xlabel('$t$(ns)','Interpreter','latex')
%     ylabel('$S(t) - R^2(t)$','Interpreter','latex')
%     set(gca, 'fontsize', 20, 'linewidth', 1.5)
%     axis tight
% end

for i = 1:3
    figure(i);clf;hold on;
    plot(t, S_array(i,:),'-','LineWidth',2)
    plot(t, R2_array(i,:),'-','LineWidth',2)
    ylim([0,1])
    legend({'S','R^2'},'Location','best')
    xlabel('$t$(ns)','Interpreter','latex')
    ylabel('Sync.','Interpreter','latex')
    set(gca, 'fontsize', 20, 'linewidth', 1.5)
    axis tight
end

for i = 1:3
    figure(i+3);clf;hold on;
    for Midx = 1:M
        plot(t, squeeze(reshape(intensity(i, Midx, :), [L, 1])))
    end
    xlabel('$t$(ns)','Interpreter','latex')
    ylabel('$|E_i(t)|^2$','Interpreter','latex')
    set(gca, 'fontsize', 20, 'linewidth', 1.5)
    axis tight
end



