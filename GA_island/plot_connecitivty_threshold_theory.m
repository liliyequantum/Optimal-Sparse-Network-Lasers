clear;close all;

%% \eta - F_i = -K_i sin(\eta + \phi)

% \eta - F_i = -K_i sin(\eta + \phi)
F_i = 90;
K_i = F_i;  % setting K_i = F_i
tau = 3;
alpha = 5;
M = 24;
phi = 0.4*pi;  % phase shift
eta_1 = -2*pi:0.1:2*pi;  % horizontal axis
eta_2 = -2.5*pi:0.1:2.5*pi;  
eta_3 = -25*pi:0.1:25*pi;  

%% critical point
figure(1)
plot(eta_2, eta_2 - F_i, 'LineWidth', 2); hold on;       
plot(eta_2, eta_2 + F_i, 'LineWidth', 2); hold on;       
plot(eta_2, eta_2 - 20, 'LineWidth', 2); hold on;        
plot(eta_1, -30*sin(eta_1 + phi), 'LineWidth', 2); hold on;  
plot(eta_1, -150*sin(eta_1 + phi), 'LineWidth', 2); hold on; 

plot([0,0],[-200,200],'k', 'LineWidth', 2); hold on;         
plot([-3*pi,3*pi],[0,0],'k', 'LineWidth', 2); hold on;       

y = 1+ K_i*cos(eta_2+phi);

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
        [0.8 0.8 0.8], 'EdgeColor', 'k', 'LineStyle','--','LineWidth',1, 'FaceAlpha', 0.3);
end

axis off;
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

%% potential
figure(2);clf;
plot(eta_3, eta_3.^2 - 2*tau*sqrt(1+alpha^2)*0.4*23*cos(eta_3+phi), 'LineWidth', 2); hold on;  

axis off;
exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

%% potential
figure(3);clf;
plot(eta_2, eta_2 - F_i, 'LineWidth', 2); hold on;       
plot(eta_2, eta_2 + F_i, 'LineWidth', 2); hold on;       
plot(eta_2, eta_2 - 20, 'LineWidth', 2); hold on;        
plot(eta_1, -30*sin(eta_1 + phi), 'LineWidth', 2); hold on;  
plot(eta_1, -150*sin(eta_1 + phi), 'LineWidth', 2); hold on; 

plot([0,0],[-200,200],'k', 'LineWidth', 2); hold on;        
plot([-3*pi,3*pi],[0,0],'k', 'LineWidth', 2); hold on;       

y = 1+ K_i*cos(eta_2+phi);

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
        [0.8 0.8 0.8], 'EdgeColor', 'k', 'LineStyle','--','LineWidth',1, 'FaceAlpha', 0.3);
end