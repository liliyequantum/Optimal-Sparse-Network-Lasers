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
F_12 = 20;
kappa = 0.4;

% K_12 = 0.1*factor;  
K_24 = kappa*factor;

phi = 0.4*pi;  % phase shift
eta_1 = -5*pi:0.1:5*pi;  % horizontal axis
eta_2 = -5.8*pi:0.1:6*pi;  
eta_3 = -25*pi:0.1:12*pi;
eta_4 = -12*pi:0.1:25*pi;

%% critical point
figure(1);clf;
plot(eta_2, eta_2 - F_24, '-.','LineWidth', 3,'Color',green); hold on;        
plot(eta_2, eta_2 - F_1, '-.','LineWidth', 3,'Color',purple); hold on;        
plot(eta_1, -K_24*sin(eta_1 + phi), 'LineWidth', 3,'Color',orange); hold on; 
plot([0,0],[-200,200],'k', 'LineWidth', 2); hold on;         
plot([-6*pi,6.3*pi],[0,0],'k', 'LineWidth', 2); hold on;       

y = 1+ K_24*cos(eta_2+phi);
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
        orange, 'EdgeColor', 'k', 'LineStyle','--','LineWidth',1, 'FaceAlpha', 0.15);
end
axis off;
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

%% potential
figure(3);clf;
% U_12 = eta_3.^2 - 2*F_12*eta_3 - 2*K_12*cos(eta_3+phi);
% U_24 = eta_3.^2 - 2*F_24*eta_3 - 2*K_24*cos(eta_3+phi);
% plot(eta_3, U_12, 'LineWidth', 2,'Color',purple); hold on;  
% plot(eta_3, U_24, 'LineWidth', 2,'Color',green); hold on;  
U = eta_4.^2 - 2*K_24*cos(eta_4+phi);
% U1 = eta_3.^2 - 2*5*K_12*cos(eta_3+phi);
U2 = eta_3.^2 - 2*K_24*cos(eta_3+phi);
% plot(eta_3, U1, 'LineWidth', 2,'Color',purple); hold on;  
plot(eta_3, U2+2*30*eta_3, 'LineWidth', 3,'Color',purple); hold on;  
plot(eta_4, U-2*30*eta_4, 'LineWidth', 3,'Color',green); hold on;
axis off; %
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);