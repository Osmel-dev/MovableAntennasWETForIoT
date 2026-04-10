% -------------------------------------------------------------------------
% Description:
% This MATLAB script partially reproduces Fig. 3 of the following manuscript:
%
% [R1] O. M. Rosabal, O. A. López, M. Di Renzo, R. D. Souza, and H. Alves,
%     “Movable antennas-aided wireless energy transfer for the Internet of Things,”
%     arXiv preprint arXiv:2506.21966, Jun. 2025.
%
% -------------------------------------------------------------------------
% Version:
% v1.0 - Last updated: 2026-04-10
%
% -------------------------------------------------------------------------
% License: 
% This code is licensed under the MIT License.
%
% If you use this code, in whole or in part, in research that results in
% publications, please cite [R1].
%
% This code is provided “as is”, without warranty of any kind, express or
% implied.
% -------------------------------------------------------------------------

close all; 
clear;

%% simulation parameters
N = 1:12;                   % num. of TX antennas
K = 3;                      % num. of devices
fc = 1e9;                   % frequency [Hz]
wavelength = 3e8/fc;        % wavelength [m]
delta = wavelength/2;       % min. inter-antenna separation [m]
pth = 1e-3;                 % received power requirement [W]
kappa = 2;                  % antennas' boresight gain
l = 1;                      % side of the TX array [m]
MCIter = 100;               % Monte Carlo iterations

%% Monte Carlo loop

% memory pre-allocation
imasPow = ones(numel(N),1);
umasPow = ones(numel(N),1);
ulaPow = ones(numel(N),1);
uraPow = ones(numel(N),1);

% iterate over the antennas config.
for n = 1:numel(N)

    for seed = 1:MCIter

        % devices' positions centered at [-4,4]x[-4,4]
        % seed control ensures reproducible results
        rng(seed)
        u = rand(3,K);
    
        u(1,:) = 8*u(1,:) - 4;
        u(2,:) = 8*u(2,:) - 4;
        u(3,:) = 3;

        % independently-controlled movable antennas
        imasPow(n) = imasPow(n) + imasFnc(N(n),K,pth,u,kappa,wavelength,l)/MCIter; 

        % uniformly-spaced movable antennas
        umasPow(n) = umasPow(n) + umasFnc(N(n),K,pth,u,kappa,wavelength,l)/MCIter;

        % uniform linear array with fixed antennas
        ulaPow(n) = ulaPow(n) + ulaFnc(N(n),K,pth,u,delta,kappa,wavelength)/MCIter;

        % uniform rectangular array with fixed antennas
        uraPow(n) = uraPow(n) + uraFnc(N(n),K,pth,u,delta,kappa,wavelength)/MCIter;
    end
end

%% plot results

% default figure position
Position = [2 7 24 12];

% default paper size
PaperSize = [24 12];

axisFontSize = 17;
lgdFontSize = 17;
ticksFontSize = 14;

fig = figure;
plotSettings(fig,Position,PaperSize)

hold on

plot(N,imasPow,'-o','Color','#0072BD','LineWidth',2,'MarkerSize',10);  
plot(N,umasPow,'-^','Color','#7E2F8E','LineWidth',2,'MarkerSize',10);
plot(N,ulaPow,'-s','Color','#77AC30','LineWidth',2,'MarkerSize',10);
plot(N,umasPow,'-*','Color','#D95319','LineWidth',2,'MarkerSize',10); 

hold off
grid on
box on
xlim([1 12])
set(gca,'FontSize',ticksFontSize)
xlabel('$N$','FontSize',axisFontSize,'Interpreter','latex')
ylabel('$p_T$ (W)','FontSize',axisFontSize,'Interpreter','latex')
legend('IMAs','UMAs','ULA','URA','FontSize', ...
    lgdFontSize,'Interpreter','latex')
