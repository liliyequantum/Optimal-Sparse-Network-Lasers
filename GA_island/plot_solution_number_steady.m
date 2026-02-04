clear;close all;
red_base = [0.85, 0.1, 0.1];
blue_base = [0.1, 0.45, 0.85];
blue = [0 0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290 0.6940 0.1250];
purple = [173, 0, 237]./255;%[0.4940 0.1840 0.5560];
green = [0.4660 0.6740 0.1880];
bright_blue = [0.3010 0.7450 0.9330];
dark_red = [0.6350 0.0780 0.1840];
%% \eta - F_i = -K_i sin(\eta + \phi)

% \eta - F_i = -K_i sin(\eta + \phi)
Delta_0 = 30;
tau = 3;
alpha = 5;
M = 24;
factor = tau*sqrt(1+alpha^2)*(M-1);

F_1 = -tau*Delta_0;
F_24 = tau*Delta_0;
kappa = 0.26;

phi = 0.4*pi;  % phase shift
eta_1 = -4.5*pi:0.1:4.5*pi;  % horizontal axis
eta_2 = -4.8*pi:0.1:4.8*pi;  

%% critical point
figure(1);clf;
plot(eta_2, eta_2 - F_1, '-.','LineWidth', 2,'Color',purple); hold on;   
plot(eta_2, eta_2 - F_24, '-.','LineWidth', 2,'Color',green); hold on;        
plot(eta_1, -kappa*factor*sin(eta_1 + phi), 'LineWidth', 2,'Color',blue_base); hold on; 
plot([0,0],[-200,200],'k', 'LineWidth', 1.5); hold on;         
plot([-5*pi,5*pi],[0,0],'k', 'LineWidth', 1.5); hold on;       

y = 1+ kappa*factor*cos(eta_2+phi);
% Find positive regions
positive_idx = find(y > 0);
% If you want contiguous filled regions (recommended), you can split into segments:
in_positive = y > 0;
d = diff([0 in_positive 0]);
start_idx = find(d == 1);
end_idx = find(d == -1) - 1;
for k = 1:length(start_idx)
    idx_range = start_idx(k):end_idx(k);
    fill_x = eta_2(idx_range);
    fill_y = y(idx_range);
    
    % Fill with dashed border
    h_fill = fill([fill_x, fliplr(fill_x)], [zeros(size(fill_y)), fliplr(fill_y)], ...
        blue_base, 'EdgeColor', 'k', 'LineStyle','--','LineWidth',1, 'FaceAlpha', 0.15);
end
axis off;
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

% d_array = 0:0.02:1;%0:0.1:3;%[0:0.05:3, 3.2:0.2:5];
% num_rng_w = 1;
% std_w = 14;
% data = load(['../all2all_coupling/data/update_R2_freq_diode_data_d_',num2str(d_array(2)-d_array(1)),'_',num2str(d_array(end)),...
%     '_M_',num2str(M),'_num_rng_w_',num2str(num_rng_w),'_std_w_',num2str(std_w),'_1.mat']);
% ave_S_array = data.ave_S_array;
% 
% kappa_array = [0:0.05:0.2, 0.26, 0.3:0.05:0.7, 0.8, 0.9, 1.0];
% num_solutions = [0, 0, 0, 0, 0, 1, 5, 10, 16, 21, 27, 33, 39, 44, 50, 61, 72, 83];
% figure(2);clf;hold on;
% set(gcf, 'Position', [100, 100, 600, 300]); 
% yyaxis right;
% set(gca, 'YColor', blue_base,'FontSize',18); % Set the color of the left-hand y-axis to blue    
% light_blue = 0.4 * blue_base + 0.6 * [1 1 1];  % Adjust weights as needed
% plot(d_array, ave_S_array,'-o','MarkerSize', 4,'color',light_blue,'LineWidth',1.5)
% ylabel('$\langle S\rangle$','Interpreter','latex')
% yyaxis left;
% set(gca, 'YColor', red_base,'FontSize',18); % Set the color of the left-hand y-axis to blue    
% plot(kappa_array, num_solutions,'-o','MarkerSize', 5,'LineWidth',3,'Color',red_base)
% ylabel('Solution No.')
% 
% yyaxis left;
% xlabel('$\kappa(\textnormal{ns}^{-1})$','Interpreter','latex')
% grid on;
% ax = gca;
% ax.XMinorGrid = 'on';
% ax.YMinorGrid = 'on';
% ax.MinorGridAlpha = 0.5;
