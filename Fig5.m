% -------------------------------------------------------------------------
% Description:
% This MATLAB script partially reproduces Fig. 5 of the following manuscript:
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
K = 3;                      % num. of devices
fc = 1e9;                   % frequency [Hz]
wavelength = 3e8/fc;        % wavelength [m]
delta = wavelength/2;       % min. inter-antenna separation [m]
pth = 1e-3;                 % received power requirement [W]
kappa = 2;                  % antennas' boresight gain
l = 1;                      % side of the TX array
MCIter = 100;               % Monte Carlo iterations
deploymentDistVec = 2:9;    % size of the service area side [m] 

% memory pre-allocation
imasProb = ones(numel(deploymentDistVec),1);
umasProb = ones(numel(deploymentDistVec),1);
ulaProb = ones(numel(deploymentDistVec),1);
uraProb = ones(numel(deploymentDistVec),1);

% iterate over the users deployment
for ii = 1:numel(deploymentDistVec)

    for seed = 1:MCIter

        % devices' positions centered at [-4,4]x[-4,4]
        % seed control ensures reproducible results
        rng(seed)
        u = rand(3,K);
    
        u(1,:) = deploymentDistVec(ii)*u(1,:) - deploymentDistVec(ii)/2;
        u(2,:) = deploymentDistVec(ii)*u(2,:) - deploymentDistVec(ii)/2;
        u(3,:) = 3;

        % dependently-controlled movable antennas
        [~,imasPos] = imasFnc(N,K,pth,u,kappa,wavelength,l);
        imasProb(ii) = imasProb(ii) + nfDevsProb(u,N,K,l,imasPos,wavelength,'IMAs')/MCIter;

        % uniformly-spaced movable antennas
        [~,umasPos] = umasFnc(N,K,pth,u,kappa,wavelength,l);
        umasProb(ii) = umasProb(ii) + nfDevsProb(u,N,K,l,umasPos,wavelength,'UMAs')/MCIter;

        % uniform linear array with fixed antennas
        ulaPos = antPosULAFnc(N,delta);
        ulaProb(ii) = ulaProb(ii) + nfDevsProb(u,N,K,l,ulaPos,wavelength,'ULA')/MCIter;
            
        % uniform rectangular array with fixed antennas
        uraPos = antPosURAFnc(N,delta);
        uraProb(ii) = uraProb(ii) + nfDevsProb(u,N,K,l,uraPos,wavelength,'URA')/MCIter;
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

plot(deploymentDistVec,imasProb,'-o','Color','#0072BD','LineWidth',2,'MarkerSize',10);  
plot(deploymentDistVec,umasProb,'-^','Color','#7E2F8E','LineWidth',2,'MarkerSize',10);
plot(deploymentDistVec,ulaProb,'-s','Color','#77AC30','LineWidth',2,'MarkerSize',10);
plot(deploymentDistVec,umasProb,'-*','Color','#D95319','LineWidth',2,'MarkerSize',10); 

hold off
grid on
box on
xlim([1 12])
set(gca,'FontSize',ticksFontSize)
xlabel('$a_x, a_y$ (m)','FontSize',axisFontSize,'Interpreter','latex')
ylabel('Near-field probability','FontSize',axisFontSize,'Interpreter','latex')
legend('IMAs','UMAs','ULA','URA','FontSize', ...
    lgdFontSize,'Interpreter','latex')