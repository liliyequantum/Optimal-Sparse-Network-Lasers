function bifurcation_diagram_all2all_data_gen(dk,phase_idx)
% clear;close;close all;
% dk = 0.01;
% phase_idx = 0;
maxNumCompThreads(1);   
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq
% Parameters
M = 24; % Nodes (Adjacency Matrix Size)
W = zeros(M,1);

method = 'dde23';
kappa_array = 0:dk:1;

I_peak_cell = cell(length(kappa_array),1); % round(max_t/h_abm);
S_array=zeros(length(kappa_array),1);
tic
for kIdx=1:length(kappa_array)
    kappa=kappa_array(kIdx);
    all2all_coupling_matrix = kappa*exp(-1i*phase_idx*pi/8)*(ones(M)-eye(M));
    [~, t_sol, E_sol, ~, Iss, ~, ~, ave_S] = Diode_Lang_Kobayashi_Eq(method, W,  all2all_coupling_matrix);
    I_sol = abs(E_sol).^2/Iss;
    [peaks,~] = findpeaks(I_sol(1,floor(end/2):end), t_sol(floor(end/2):end),'MinPeakDistance', 3);
    I_peak_cell{kIdx,1} = peaks;
    S_array(kIdx) = ave_S;
    disp(['progress: ',num2str(kIdx/length(kappa_array))])
end
toc
save(['./data_bifurcation/bifurcation_all2allCoupling_phase_idx_',num2str(phase_idx),'_dk_',...
    num2str(dk),'_data.mat'],'kappa_array','I_peak_cell','S_array','phase_idx')
end

% x_start = 10;
% y_min = 0.5;
% y_max = 1.5;
% M_array = [1];%1:M;%[2, 4,7,8,13,14,19,20];
% 
% figure(1);clf;
% % [peaks,locs] = findpeaks(I_sol(1,floor(end/2):end),  t_sol(floor(end/2):end), 'MinPeakDistance', 3);
% set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
% for Midx = 1:1:length(M_array)
%     plot(t_sol,abs(E_sol(M_array(Midx),:)).^2./Iss,'DisplayName',['M = ',num2str(M_array(Midx))],'LineWidth',1);hold on;
% end
% plot(locs, peaks, 'ro', 'MarkerFaceColor', 'r');  % Local maxima
% ylim([y_min,y_max])
% set(gca,'fontsize',18,'FontName','times new roman')
% xlabel('$t(ns)$','Interpreter','latex')
% ylabel('$I/I_s$','Interpreter','latex')
% xlim([50,100])

% figure(2);clf;
% set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
% for Midx = 1:1:length(M_array)
%     plot(t_sol,cos(angle(E_sol(M_array(Midx),:))),'DisplayName',['M = ',num2str(M_array(Midx))],'LineWidth',1);hold on;
% end
% ylim([-1,1])
% set(gca,'fontsize',18,'FontName','times new roman')
% xlabel('$t (ns)$','Interpreter','latex')
% ylabel('$cos(\phi)$','Interpreter','latex')
% xlim([95,100])
% 
% figure(3);clf;
% set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
% for Midx = 1:1:length(M_array)
%     plot(t_sol,N_sol(M_array(Midx),:)./Nss,'DisplayName',['M = ',num2str(M_array(Midx))],'LineWidth',1);hold on;
% end
% % legend('Fontsize',16,'interpreter','latex','Location','bestoutside')
% ylim([y_min,y_max])
% set(gca,'fontsize',18,'FontName','times new roman')
% xlabel('$t (ns)$','Interpreter','latex')
% ylabel('$N/N_s$','Interpreter','latex')
% xlim([x_start,100])
% 
% figure(4);clf;
% plot(abs(E_sol(M_array(Midx),:)).^2./Iss,N_sol(M_array(Midx),:)./Nss,'LineWidth',1);hold on;
% xlabel('$I/I_s$','Interpreter','latex')
% ylabel('$N/N_s$','Interpreter','latex')
% xlim([0,2])
% ylim([0.94,1.08])
% set(gca,'fontsize',18,'FontName','times new roman')
% 
% figure(5);clf;
% set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
% plot(t_sol,S,'LineWidth',1);hold on;
% ylim([0,1])
% set(gca,'fontsize',18,'FontName','times new roman')
% xlabel('$t (ns)$','Interpreter','latex')
% ylabel('$\langle S\rangle$','Interpreter','latex')
% xlim([0,100])
% 
% 
% %% RF (radio frequency) power spectrum
% if strcmp(method, 'dde23')
%     % for dde23
%     t_start = 50; % ns
%     L = 10000;
%     x = linspace(t_start,t_sol(end),L); % start from 7.5 ns to aviod the transient dynamics
%     dx = x(2)-x(1);
%     y = deval(x,sol); % interpolation check, compare with abm and dde23
%     current_matrix = zeros(M,L);
%     for Midx = 1:M
%         current_matrix(Midx,:) = y(Midx,:).^2 + y(Midx+M,:).^2; %abs(fmt(y(1:2,:))).^2;
%     end
% elseif strcmp(method,  'abm4milshtein')
%     % for abm
%     t_start = 50; % ns
%     h_abm = t_sol(2)-t_sol(1);
%     x = t_sol(t_start/h_abm+1:end);
%     dx = x(2)-x(1);
%     y = E_sol(:,t_start/h_abm+1:end);
%     current_matrix = abs(y).^2;
%     L = length(x);
% end
% ave_power_array = mean(current_matrix,2); % for each Midx, mean time series
% RIN = zeros(M,round(L/2));
% for Midx = 1:M
%     % Midx=1;
%     current = current_matrix(Midx,:);
%     ave_power = ave_power_array(Midx);
%     %RF power spectrum
%     temp = abs(fft(current-ave_power)./L).^2; % Compute Power Spectrum Using FFT in [-Fs/2, Fs/2] 
%     % Index 1 -> DC Component f=0
%     % index 2 to L/2 -> Positive frequency f =[df, 2df, ..., Fs/2 - df]
%     % index L/2 +1 to L -> Negative frequency f = [-Fs/2, ..., -df]
%     Iff = 2.*temp(1:(L/2)); %  Extract One-Sided Spectrum  
%     % FFT output is symmetric for real signals, only half the data is needed
%     Iff(1) = temp(1); % The DC component (frequency = 0) should not be doubled.
% 
%     Fs = 1/dx; %  sampling frequency
%     df = Fs/L; % frequency resolution (spacing between frequency bins)
%     f = 0:df:Fs/2-df;   %GHz;frequency axis from 0 to Nyquist frequency (Fs/2), shift df to get exactly L/2 points
%     RIN(Midx,:) = 10.*log10(Iff/ave_power^2);
%     %Nyquist frequency (Fs/2=1/(2dx)) highest frequency that can be accurately resolved 
% end
% 
% figure(6);clf;
% set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
% hold on;
% for Midx=1:M
%     plot(f,RIN(Midx,:));
% end
% xlim([0.1 20]);
% ylabel('RIN [dBc/GHz]'); %%%%% check
% xlabel('frequency [GHz]');
% set(gca,'FontSize',16,'FontName','times new roman')
% grid on;
% 
% % Compute cosine of phase
% cos_phi = cos(angle(E_sol));  % M x t_len
% [~,t_len] = size(E_sol);
% % Create time and index grid
% t_grid = repmat(t_sol(:)', M, 1);          % M x t_len
% M_grid = repmat((1:M)', 1, t_len);         % M x t_len
% 
% figure(7); clf;
% set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
% surf(t_grid, M_grid, cos_phi, 'EdgeColor', 'none');
% view(2);  % 2D top-down view
% colormap(parula)
% clim([-1, 1])
% colorbar
% axis tight
% xlim([50,100])
% xlabel('Time')
% ylabel('No. Laser')
% title('$\cos(\phi_i(t))$', 'Interpreter', 'latex')
% set(gca, 'FontSize', 16,'FontName','Times New Roman')
