clear;close;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

load('data_LK.mat') % 100 different frequency disorders with 100 optimized sparse matrix by island-based genetic algorithm
% The \Delta_i = 14 Gaussian(0,1) rad/ns with 100 random seeds rng(0-99).

W = detuning_2d(:,2);
best_coupling_matrix = optimized_K(:,:,2);
M = 24;
method = 'dde23';
[sol, t_sol, E_sol, N_sol, Iss, Nss, S, ave_S] = ...
    Diode_Lang_Kobayashi_Eq(method, W,  best_coupling_matrix);

x_start = 10;
y_min = 0.3;
y_max = 2.3;
M_array = 1:M;%[2, 4,7,8,13,14,19,20];

figure(1);clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
for Midx = 1:1:length(M_array)
    signal = abs(E_sol(M_array(Midx), :)).^2 / Iss;  % Power signal
    time = t_sol;

    plot(time, signal, 'LineWidth', 1); hold on;
   
end
set(gca,'fontsize',22,'LineWidth',1)
xlabel('$t(ns)$','Interpreter','latex')
ylabel('$I/I_s$','Interpreter','latex')
xlim([50,100])
ylim([y_min,y_max])


figure(2);clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for Midx = 1:1:length(M_array)
    plot(t_sol,cos(angle(E_sol(M_array(Midx),:))),'DisplayName',['M = ',num2str(M_array(Midx))],'LineWidth',1);hold on;
end
ylim([-1,1])
set(gca,'fontsize',18,'FontName','times new roman')
xlabel('$t (ns)$','Interpreter','latex')
ylabel('$cos(\phi)$','Interpreter','latex')
xlim([50,100])

figure(3);clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for Midx = 1:1:length(M_array)
    plot(t_sol,N_sol(M_array(Midx),:)./Nss,'DisplayName',['M = ',num2str(M_array(Midx))],'LineWidth',1);hold on;
end
% legend('Fontsize',16,'interpreter','latex','Location','bestoutside')
ylim([y_min,y_max])
set(gca,'fontsize',18,'FontName','times new roman')
xlabel('$t (ns)$','Interpreter','latex')
ylabel('$N/N_s$','Interpreter','latex')
xlim([x_start,100])

figure(4);clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for Midx=1:length(M_array)
plot(abs(E_sol(M_array(Midx),:)).^2./Iss,N_sol(M_array(Midx),:)./Nss,'LineWidth',1);hold on;
end
xlabel('$I/I_s$','Interpreter','latex')
ylabel('$N/N_s$','Interpreter','latex')
xlim([0,2.3])
ylim([0.98,1.03])
set(gca,'fontsize',18,'FontName','times new roman')

figure(5);clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
plot(t_sol,S,'LineWidth',1);hold on;
ylim([0,1])
set(gca,'fontsize',18,'FontName','times new roman')
xlabel('$t (ns)$','Interpreter','latex')
ylabel('$\langle S\rangle$','Interpreter','latex')
xlim([0,100])

% Compute cosine of phase
cos_phi = cos(angle(E_sol));  % M x t_len
[~,t_len] = size(E_sol);
% Create time and index grid
t_grid = repmat(t_sol(:)', M, 1);          % M x t_len
M_grid = repmat((1:M)', 1, t_len);         % M x t_len

figure(6); clf;
set(gcf, 'Position', [100, 100, 600, 400]); % Set figure size to 800x600 pixels
surf(t_grid, M_grid, cos_phi, 'EdgeColor', 'none');
view(2);  % 2D top-down view
colormap(parula)
clim([-1, 1])
colorbar
axis tight
xlim([90,100])
xlabel('$t (ns)$','Interpreter','latex')
ylabel('No. Laser')
set(gca, 'FontSize', 22,'LineWidth',1)
% title('$\mathbf{\cos(\phi_i(t))}$', 'Interpreter', 'latex','FontSize', 20)
% exportgraphics(gcf, 'GA_island_cosphi_all2all_coupling.png', 'Resolution', 300);
% exportgraphics(gcf, 'GA_island_cosphi_sparse_engineering.png', 'Resolution', 300);
%% fft power spectrum
if strcmp(method, 'dde23')
    % for dde23
    t_start = 50; % ns
    L = 10000; % Number of time points
    x = linspace(t_start,t_sol(end),L); % start from 7.5 ns to aviod the transient dynamics

    y = deval(x,sol); % interpolation check, compare with abm and dde23
    E_matrix = zeros(M,L);
    cosphase_matrix = zeros(M,L);
    current_matrix = zeros(M,L);
    for Midx = 1:M
        E_matrix(Midx,:) = y(Midx,:) + 1i*y(Midx+M,:);
        cosphase_matrix(Midx,:) = cos(angle(E_matrix(Midx,:))); %abs(fmt(y(1:2,:))).^2;
        current_matrix(Midx,:) = y(Midx,:).^2 + y(Midx+M,:).^2; %abs(fmt(y(1:2,:))).^2;
    end
   
elseif strcmp(method,  'abm4milshtein')
    % for abm
    t_start = 50; % ns
    h_abm = t_sol(2)-t_sol(1);
    x = t_sol(t_start/h_abm+1:end);

    y = E_sol(:,t_start/h_abm+1:end);
    cosphase_matrix = cos(angle(y));
    current_matrix = abs(y).^2;
    L = length(x); % Number of time points
end

dx = x(2) - x(1);      % Time step (assumed uniform)
Fs = 1 / dx;                   % Sampling frequency in GHz
f = Fs * (0:(L/2)) / L;        % Frequency axis (one-sided)

%% cos(\phi_i(t)) fft
spectrum_2d = zeros(M,L/2+1);
for Midx = 1:M
    % Midx= 1;
    cos_phi = cosphase_matrix(Midx,:);
    Y = fft(cos_phi, [], 2);        % FFT along time axis (dim 2)
    P2 = abs(Y / L);                % Normalize
    P1 = P2(:, 1:L/2+1);            % One-sided spectrum
    P1(:, 2:end-1) = 2 * P1(:, 2:end-1);  % Double non-DC terms
    spectrum_2d(Midx,:) = P1;     % Average over oscillators
end

figure(7); clf; hold on;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for Midx = 1:M
 plot(f, spectrum_2d(Midx,:), 'LineWidth', 1.5);
end
xlabel('Frequency (GHz)')
ylabel('Amplitude')
title('FFT of $cos(\phi_{i}(t))$','Interpreter','latex')
xlim([0, 20])                 % Optional: Zoom to Nyquist
grid on
set(gca,'fontsize',18,'FontName','Times New Roman')

%% current fft
RIN_2d = zeros(M,L/2);
for Midx = 1:M
    current = current_matrix(Midx,:);
    ave_power = mean(current);

    %RF power spectrum
    temp = abs(fft(current-ave_power)./L).^2; % Compute Power Spectrum Using FFT in [-Fs/2, Fs/2] 
    % Index 1 -> DC Component f=0
    % index 2 to L/2 -> Positive frequency f =[df, 2df, ..., Fs/2 - df]
    % index L/2 +1 to L -> Negative frequency f = [-Fs/2, ..., -df]
    Iff = 2.*temp(1:(L/2)); %  Extract One-Sided Spectrum  
    % FFT output is symmetric for real signals, only half the data is needed
    Iff(1) = temp(1); % The DC component (frequency = 0) should not be doubled.
    
    Fs = 1/dx; %  sampling frequency
    df = Fs/L; % frequency resolution (spacing between frequency bins)
    f = 0:df:Fs/2-df;   %GHz;frequency axis from 0 to Nyquist frequency (Fs/2), shift df to get exactly L/2 points
    RIN_2d(Midx,:) = 10.*log10(Iff/ave_power^2);
    %Nyquist frequency (Fs/2=1/(2dx)) highest frequency that can be accurately resolved 
end

figure(8);clf;hold on;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
for Midx =1:M
    plot(f,RIN_2d(Midx,:));
end
xlim([0.1 20]);
ylabel('RIN [dBc/GHz]'); %%%%% check
xlabel('frequency [GHz]');
% title(['$\kappa$ = ',num2str(params.kappa),' $ns^{-1}$'],'Interpreter','latex')
% title(['I = ',num2str(current_pump),' mA'],'Interpreter','latex');
set(gca,'FontSize',16,'FontName','times new roman')
grid on;

