% -------------------------------------------------------------------------
% Description:
% This MATLAB script partially reproduces Fig. 4 of the following manuscript:
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
N = 9;                      % num. of TX antennas
K = 1:12;                   % num. of devices
fc = 1e9;                   % frequency [Hz]
wavelength = 3e8/fc;        % wavelength [m]
delta = wavelength/2;       % min. inter-antenna separation [m]
pth = 1e-3;                 % received power requirement [W]
kappa = 2;                  % antennas' boresight gain
l = 1;                      % side of the TX array [m]
MCIter = 100;               % Monte Carlo iterations

%% Monte Carlo loop

% memory pre-allocation
imasPow = ones(numel(K),1);
umasPow = ones(numel(K),1);
ulaPow = ones(numel(K),1);
uraPow = ones(numel(K),1);

% iterate over the users deployment
for k = 1:numel(K)

    for seed = 1:MCIter

        % devices' positions centered at [-4,4]x[-4,4]
        % seed control ensures reproducible results
        rng(seed)
        u = rand(3,K(k));
    
        u(1,:) = 8*u(1,:) - 4;
        u(2,:) = 8*u(2,:) - 4;
        u(3,:) = 3;

        % dependently-controlled movable antennas
        imasPow(k) = imasPow(k) + imasFnc(N,K(k),pth,u,kappa,wavelength,l)/MCIter; 

        % uniformly-spaced movable antennas
        umasPow(k) = umasPow(k) + umasFnc(N,K(k),pth,u,kappa,wavelength,l)/MCIter;

        % uniform linear array with fixed antennas
        ulaPow(k) = ulaPow(k) + ulaFnc(N,K(k),pth,u,delta,kappa,wavelength)/MCIter;

        % uniform rectangular array with fixed antennas
        uraPow(k) = uraPow(k) + uraFnc(N,K(k),pth,u,delta,kappa,wavelength)/MCIter;
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

plot(K,imasPow,'-o','Color','#0072BD','LineWidth',2,'MarkerSize',10);  
plot(K,umasPow,'-^','Color','#7E2F8E','LineWidth',2,'MarkerSize',10);
plot(K,ulaPow,'-s','Color','#77AC30','LineWidth',2,'MarkerSize',10);
plot(K,umasPow,'-*','Color','#D95319','LineWidth',2,'MarkerSize',10); 

hold off
grid on
box on
xlim([1 12])
set(gca,'FontSize',ticksFontSize)
xlabel('$K$','FontSize',axisFontSize,'Interpreter','latex')
ylabel('$p_T$ (W)','FontSize',axisFontSize,'Interpreter','latex')
legend('IMAs','UMAs','ULA','URA','FontSize', ...
    lgdFontSize,'Interpreter','latex')