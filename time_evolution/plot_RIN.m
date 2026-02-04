clear;close;close all;
addpath('../'); % to include two functions, lk_dde23.m, lk_abm4milshtein.m, Diode_Lang_Kobayashi_Eq

blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];

load('data_LK.mat') % 100 different frequency disorders with 100 optimized sparse matrix by island-based genetic algorithm
% The \Delta_i = 14 Gaussian(0,1) rad/ns with 100 random seeds rng(0-99).

W = detuning_2d(:,2);
best_coupling_matrix = optimized_K(:,:,2);
M = 24;
[sol, ~, ~, ~, Iss, ~, ~, ~] = ...
    Diode_Lang_Kobayashi_Eq('dde23', W,  best_coupling_matrix);

t_start = 50; % ns
t_end = 100; % ns
L = 10000;
t = linspace(t_start,t_end,L); 

y = deval(t,sol); % interpolation check, compare with abm and dde23
E = zeros(M, L);
for Midx = 1:M
   E(Midx,:) = y(Midx,:) + 1i*y(Midx+M,:);
end
total_intensity = abs(sum(E,1)).^2;
norm_total_intensity = (total_intensity - mean(total_intensity))./total_intensity;
figure(1);clf;
set(gcf, 'Position', [100, 100, 600, 350]); % Set figure size to 800x600 pixels
plot(t, norm_total_intensity, 'LineWidth', 1,'Color',green); hold on;
set(gca,'fontsize',22,'LineWidth',1)
xlabel('$t$(ns)','Interpreter','latex')
% ylabel('$|\sum_i E_i|^2/(I_{s}M^2)$','Interpreter','latex')
ylabel('$\tilde{I}_{\rm tot}(t)$','Interpreter','latex')
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
axis tight
ylim([-1,1.1])
std(norm_total_intensity).^2

% plot(t,total_intensity)
% ylim([0.5,1.5])
[f, spec] = spectrum(t, total_intensity);
figure(2);clf;
set(gcf, 'Position', [100, 100, 700, 350]); % Set figure size to 800x600 pixels
plot(f, spec, 'LineWidth', 3,'Color',green); hold on;
set(gca,'fontsize',22,'LineWidth',1)
xlabel('$f$(GHz)','Interpreter','latex')
ylabel('PSD (dB/Hz)','Interpreter','latex')
xlim([-40,40])
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

function [f, spec] = spectrum(time_data_1d, time_series_data_1d)
%https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
    dt = time_data_1d(2) - time_data_1d(1);
    L = length(time_series_data_1d);
    Fs = 1 / dt; % sampling frequency
    df = Fs / L; % df = 1/T = 1/(dt*L), inverse of the total time horizon, frequency resolution, bin width

    % Centering FFT by removing mean (for RIN), but can comment out for total spectrum
    ave_power = mean(time_series_data_1d);
    signal = time_series_data_1d;%-ave_power;

    % Compute full FFT and power spectrum
    % temp = abs(fft(signal)).^2/(L^2*df*1e9); % PSD power spectrum density, Fs*L = df*L^2
    % PSD = 2.*temp(1:(L/2)); %  Extract One-Sided Spectrum  
    % PSD(1) = temp(1); % The DC component (frequency = 0) should not be doubled.
    % PSD = 10*log10(PSD); % dB/Hz
    % f = 0:df:Fs/2-df; 

    temp = abs(fftshift(fft(signal))).^2/(L^2*df*1e9); % or PSD power spectrum density, i.e. power per unit frequency in dB/Hz 
    PSD = 10*log10(temp); % dB/Hz
    % fft defulat to give [0,Fs/2] then [-Fs/2,0)
    f = (-L/2:L/2-1) * df; % Frequency vector from -Fs/2 to Fs/2

    % RIN = 10 .* log10(temp./ave_power.^2); % dBc/Hz

    spec = PSD;
end
