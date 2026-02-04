function roots = Omega_solution_number_singler_laser(params)
% clear;clc;close all;
% alpha = 5;
% tau = 1;
% kappa = 2.5;
% freq_ref = 2*pi/tau;

Omega_s = -30:0.1:30;

f = @(Omega_s) -params.W + params.kappa.*sqrt(1+params.alpha.^2) .* ...
    sin((Omega_s + params.freq_ref) .* params.tau_const + atan(params.alpha)) + Omega_s;
% Step 1: Sample the function densely
y = f(Omega_s);
% Step 2: Detect sign changes (zero crossings)
idx = find(diff(sign(y)));
% Step 3: Refine zero roots using fzero
roots = zeros(size(idx));
for i = 1:length(idx)
    x1 = Omega_s(idx(i));
    x2 = Omega_s(idx(i)+1);
    roots(i) = fzero(f, [x1, x2]);
end
% Optional: Remove duplicates due to numerical errors
roots = unique(round(roots, 6));

% Display roots
% disp(roots);
figure(11);clf;
set(gcf, 'Position', [100, 100, 600, 300]); % Set figure size to 800x600 pixels
plot(Omega_s, y,'LineWidth',2); hold on;
plot(Omega_s,zeros(1,length(Omega_s)),'k','LineWidth',2)
legend({'y_1','y_2'},'FontName','times new roman','Location','best')
xlabel('\Omega_s')
title(['$\kappa$ = ', num2str(params.kappa)],'Interpreter','latex')
set(gca,'fontsize',16)
xlim([-10,10])

end