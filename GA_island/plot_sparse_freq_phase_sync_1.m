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

data = load('S_R2_delta_fit_varphi_data_1.mat');
intensity_mean_array = data.intensity_mean_array;
intensity_std_array = data.intensity_std_array;
original_delta = data.original_delta;%(num_wrng,M);
delta_fit_mean_array = data.delta_fit_mean_array;%(num_wrng,M);
delta_fit_std_array = data.delta_fit_std_array;%(num_wrng,M);
S_array = data.S_array;%(num_wrng,L);
% R2_array = data.R2_array;%(num_wrng,L);
M = data.M;
num_wrng = data.num_wrng;

original_delta_mean = mean(original_delta,2);
delta_fit = mean(delta_fit_mean_array,2);
delta_fit_M_std = std(delta_fit_mean_array,0,2);
delta_fit_max_std = max(delta_fit_std_array,[],2);
S_ave = mean(S_array,2);
% R2_ave = mean(R2_array,2);
S_std = std(S_array,0,2);
% R2_std = std(R2_array,0,2);

figure(1);clf; hold on;
set(gcf, 'Position', [817   612   800   400]); % Set figure size to 800x600 pixels
for i = 1:num_wrng

    x = i;
    y1 = S_ave(i);
    % y2 = R2_ave(i);
    err1 = S_std(i);
    % err2 = R2_std(i);
    
    errorbar(x, y1, err1, 'o',...
        'Color', orange,...
        'MarkerFaceColor', orange,...
        'MarkerSize', 4,...
        'CapSize', 4,...
        'LineWidth', 1); 

end
h1 = plot([0, 100],[mean(S_ave),mean(S_ave)],'-','Color',orange,'LineWidth',2);hold on;
ylim([0.9,1])
xlabel('Frequency Disorder Realization No.')
ylabel('$\langle S\rangle$','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
box on
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);
std(S_ave)

figure(2); clf;
set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
for i = 1:num_wrng
  
    x = original_delta_mean(i)/2/pi;
    y = delta_fit(i)/2/pi;
    err = delta_fit_M_std(i)/2/pi+delta_fit_max_std(i)/2/pi;

    h = errorbar(x, y, err, 'o',...
        'Color', purple,...
        'MarkerFaceColor', purple,...
        'MarkerSize', 6,...
        'CapSize', 4,...
        'LineWidth', 1);
    set(h, 'HandleVisibility', 'off'); hold on;
    
end
% scatter(mean_true_f(:), final_f(:), 50, 'filled', 'MarkerFaceColor','k','Marker','o');hold on;
plot(-2:0.1:1, -2:0.1:1, 'k-.','LineWidth',1);hold on;
plot([-2, 2], [-1.06+6/3, -1.06+6/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06+5/3, -1.06+5/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06+4/3, -1.06+4/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06+3/3, -1.06+3/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06+2/3, -1.06+2/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06+1/3, -1.06+1/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06, -1.06], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06-1/3, -1.06-1/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06-2/3, -1.06-2/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06-3/3, -1.06-3/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06-4/3, -1.06-4/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
plot([-2, 2], [-1.06-5/3, -1.06-5/3], '--', 'LineWidth', 1,'Color',[0,0,0,0.8]);
xlim([-2,2])
set(gca,'FontSize',22,'FontName','Times New Roman');
box off;
xlabel('$\langle f_{\textnormal{initial}}\rangle$(GHz)','Interpreter','latex')
ylabel('$f_{\textnormal{final}}$ (GHz)','Interpreter','latex')
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

% ylim([-1.3,-1.4])
figure(3);clf;
set(gcf, 'Position', [817   612   800   350]); % Set figure size to 800x600 pixels
% set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
min_val = min(intensity_mean_array(:));
max_val = max(intensity_mean_array(:));
edges = min_val : (max_val - min_val)/50 : max_val;
bin_centers = edges(1:end-1) + diff(edges)/2;
[counts_intensity_mean, ~] = histcounts(intensity_mean_array(:), edges);
hold on;
bar(bin_centers, counts_intensity_mean/num_wrng/M/(edges(2)-edges(1)), 1, 'FaceColor', green, 'FaceAlpha', 1, 'EdgeColor', 'none');
set(gca,'FontSize',22,'FontName','Times New Roman','linewidth',1);
xlim([0.8,1.2])
% xticks([-pi,-0.5*pi,-0.2*pi,0.2*pi,0.5*pi,pi])
% xticklabels({'-\pi','-\pi/2','-0.2\pi','0.2\pi','\pi/2','\pi'})
xlabel('$\langle I(t)\rangle$','Interpreter','latex')
ylabel('PDF','Interpreter','latex')
box on

figure(4);clf;
set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
min_val = min(intensity_std_array(:));
max_val = max(intensity_std_array(:));
edges = min_val : (max_val - min_val)/10 : max_val;
bin_centers = edges(1:end-1) + diff(edges)/2;
[counts_intensity_std, ~] = histcounts(intensity_std_array(:), edges);
hold on;
bar(bin_centers, counts_intensity_std/num_wrng/M/(edges(2)-edges(1)), 1, 'FaceColor', green, 'FaceAlpha', 1, 'EdgeColor', 'none');
set(gca,'FontSize',22,'FontName','Times New Roman');
% xlim([-pi,pi])
% xticks([-pi,-0.5*pi,-0.2*pi,0.2*pi,0.5*pi,pi])
% xticklabels({'-\pi','-\pi/2','-0.2\pi','0.2\pi','\pi/2','\pi'})
xlabel('std($I(t)$)','Interpreter','latex')
ylabel('PDF','Interpreter','latex')