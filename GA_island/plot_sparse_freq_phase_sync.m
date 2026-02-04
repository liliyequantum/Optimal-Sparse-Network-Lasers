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

data = load('S_R2_delta_fit_varphi_data.mat');
original_delta = data.original_delta;%(num_wrng,M);
delta_fit_mean_array = data.delta_fit_mean_array;%(num_wrng,M);
delta_fit_std_array = data.delta_fit_std_array;%(num_wrng,M);
varphi_mean_array = data.varphi_mean_array;%(num_wrng,M);
varphi_std_array = data.varphi_std_array;%(num_wrng,M);
S_array = data.S_array;%(num_wrng,L);
R2_array = data.R2_array;%(num_wrng,L);
M = data.M;
num_wrng = data.num_wrng;

original_delta_mean = mean(original_delta,2);
delta_fit = mean(delta_fit_mean_array,2);
delta_fit_M_std = std(delta_fit_mean_array,0,2);
delta_fit_max_std = max(delta_fit_std_array,[],2);
S_ave = mean(S_array,2);
R2_ave = mean(R2_array,2);
S_std = std(S_array,0,2);
R2_std = std(R2_array,0,2);

%% tailored to the specific phase case, how to move the zero average
varphi_mean_unbias = mod(varphi_mean_array - mean(varphi_mean_array,2)+pi,2*pi)-pi;
varphi_mean_unbias = mod(varphi_mean_unbias - mean(varphi_mean_unbias,2)+pi,2*pi)-pi;
index = find(varphi_mean_unbias(:)>2);
varphi_mean_unbias(index) = varphi_mean_unbias(index)-2*pi;
varphi_mean_unbias = mod(varphi_mean_unbias - mean(varphi_mean_unbias,2)+pi,2*pi)-pi;

figure(1);clf; hold on;
set(gcf, 'Position', [817   612   800   350]); % Set figure size to 800x600 pixels
% set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
for i = 1:num_wrng

    x = i;
    y1 = S_ave(i);
    y2 = R2_ave(i);
    err1 = S_std(i);
    err2 = R2_std(i);
    
    h1 = errorbar(x, y1, err1, 'o',...
        'Color', orange,...
        'MarkerFaceColor', orange,...
        'MarkerSize', 4,...
        'CapSize', 4,...
        'LineWidth', 1); 
    h2 = errorbar(x, y2, err2, 'o',...
        'Color', bright_blue,...
        'MarkerFaceColor', bright_blue,...
        'MarkerSize', 4,...
        'CapSize', 4,...
        'LineWidth', 1); 

   
     if i<num_wrng
        set(h1, 'HandleVisibility', 'off');
        set(h2, 'HandleVisibility', 'off');
     else
         legend({'$\langle S\rangle$','$\langle R^{2}\rangle$'},'interpreter','latex');
     end


end
h1 = plot([0, 100],[mean(S_ave),mean(S_ave)],'-','Color',blue,'LineWidth',2);hold on;
set(h1, 'HandleVisibility', 'off');
ylim([0.9,1])
xlabel('Frequency Disorder Realization No.')
ylabel('Sync.','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
box on
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

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
plot([-2, 1], [-1.06+6/3, -1.06+6/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 2], [-1.06+5/3, -1.06+5/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06+4/3, -1.06+4/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06+3/3, -1.06+3/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06+2/3, -1.06+2/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06+1/3, -1.06+1/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06, -1.06], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06-1/3, -1.06-1/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06-2/3, -1.06-2/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06-3/3, -1.06-3/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06-4/3, -1.06-4/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
plot([-2, 1], [-1.06-5/3, -1.06-5/3], '--', 'LineWidth', 0.5,'Color',[0,0,0,0.4]);
xlim([-2,2])
set(gca,'FontSize',22,'FontName','Times New Roman');
box off;
xlabel('$\bar{f}_{\textnormal{initial}}$(GHz)','Interpreter','latex')
ylabel('$\bar{f}_{\textnormal{final}}$ (GHz)','Interpreter','latex')
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 600);

figure(3);clf;
set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
for i = 1:M
  
    x = original_delta(2,i)/2/pi;
    y = delta_fit_mean_array(2,i)/2/pi;
    err = delta_fit_std_array(2,i)/2/pi;

    h = errorbar(x, y, err, 'o',...
        'Color', purple,...
        'MarkerFaceColor', purple,...
        'MarkerSize', 6,...
        'CapSize', 4,...
        'LineWidth', 1);
    set(h, 'HandleVisibility', 'off'); hold on;
    
end
set(gca,'FontSize',26,'FontName','Times New Roman');
xlabel('$f_{\textnormal{initial}}$(GHz)','Interpreter','latex')
ylabel('$f_{\textnormal{final}}$ (GHz)','Interpreter','latex')
ylim([-1.4,-1.388])

% ylim([-1.3,-1.4])
figure(4);clf;
set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
min_val = min(varphi_mean_unbias(:));
max_val = max(varphi_mean_unbias(:));
edges = min_val : (max_val - min_val)/10 : max_val;
bin_centers = edges(1:end-1) + diff(edges)/2;
[counts_vaphi_mean, ~] = histcounts(varphi_mean_unbias(:), edges);
hold on;
bar(bin_centers, counts_vaphi_mean/num_wrng/M/(edges(2)-edges(1)), 1, 'FaceColor', green, 'FaceAlpha', 1, 'EdgeColor', 'none');
set(gca,'FontSize',22,'FontName','Times New Roman');
xlim([-pi,pi])
xticks([-pi,-0.5*pi,-0.2*pi,0.2*pi,0.5*pi,pi])
xticklabels({'-\pi','-\pi/2','-0.2\pi','0.2\pi','\pi/2','\pi'})
xlabel('mean $\varphi_{\textnormal{win}}$','Interpreter','latex')
ylabel('PDF','Interpreter','latex')

figure(5);
set(gcf, 'Position', [817   612   480   420]); % Set figure size to 800x600 pixels
min_val = min(varphi_std_array(:));
max_val = max(varphi_std_array(:));
edges = min_val : (max_val - min_val)/10 : max_val;
bin_centers = edges(1:end-1) + diff(edges)/2;
[counts_varphi_std, ~]  = histcounts(varphi_std_array(:), edges);
bar(bin_centers, counts_varphi_std/num_wrng/M/(edges(2)-edges(1)), 1, 'FaceColor', green, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
set(gca,'FontSize',25,'FontName','Times New Roman');
xlim([0, 0.02*pi])
xticks([0, 0.01*pi, 0.02*pi])
xticklabels({'0','0.01\times\pi','0.02\times\pi'})
xlabel('std $\varphi_{\textnormal{win}}$','Interpreter','latex')
ylabel('PDF','Interpreter','latex')

% check normalization of phase, the tailored method
figure(6); hold on;
set(gcf, 'Position', [817   612   1200   400]); % Set figure size to 800x600 pixels
for i = 1:num_wrng
    for Midx = 1:M
        x = i;
        y = mod(varphi_mean_array(i,Midx)+pi,2*pi)-pi;
        err = varphi_std_array(i,Midx);

        h = errorbar(x, y, err, 'o',...
            'Color', green,...
            'MarkerFaceColor', green,...
            'MarkerSize', 4,...
            'CapSize', 4,...
            'LineWidth', 1);
        set(h, 'HandleVisibility', 'off');
    end
    plot([i,i], [-pi,pi], 'k--', 'LineWidth', 1);
    % plot([i,i], [-500,1000], 'k--', 'LineWidth', 1);
end
ylim([-1.5*pi,1.5*pi])
yticks([-pi,0,pi])
yticklabels({'-\pi','0','\pi'})
xlabel('Realization No.','Interpreter','latex')
ylabel('mean $\varphi_{\textnormal{win}}$','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
box off
% exportgraphics(gcf, 'figure_without_margins.png', 'Resolution', 300);

% check normalization of phase, the tailored method
figure(7); hold on;
set(gcf, 'Position', [817   612   1200   400]); % Set figure size to 800x600 pixels
for i = 1:num_wrng
    for Midx = 1:M
        x = i;
        y = varphi_mean_unbias(i,Midx);
        err = varphi_std_array(i,Midx);

        h = errorbar(x, y, err, 'o',...
            'Color', green,...
            'MarkerFaceColor', green,...
            'MarkerSize', 4,...
            'CapSize', 4,...
            'LineWidth', 1);
        set(h, 'HandleVisibility', 'off');
    end
    plot([i,i], [-pi,pi], 'k--', 'LineWidth', 1);
    % plot([i,i], [-500,1000], 'k--', 'LineWidth', 1);
end
ylim([-0.2*pi,0.2*pi])
yticks([-0.2*pi,-0.1*pi,0,0.1*pi,0.2*pi])
yticklabels({'-0.2\times\pi','-0.1\times\pi','0','0.1\times\pi','0.2\times\pi'})
xlabel('Realization No.','Interpreter','latex')
ylabel('mean $\varphi_{\textnormal{win}}$','Interpreter','latex')
set(gca, 'fontsize', 20, 'linewidth', 1.5)
box off
