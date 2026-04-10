function [pow,antPos] = uraFnc(N,K,pth,u,delta,kappa,wavelength)
    % -------------------------------------------------------------------------
    % Description:
    % This MATLAB function computes the power allocation and array
    % configuration for the URA with fixed antennas. More information in:
    %
    % [R1] O. M. Rosabal, O. A. López, M. Di Renzo, R. D. Souza, and H. Alves,
    %     “Movable antennas-aided wireless energy transfer for the Internet of Things,”
    %     arXiv preprint arXiv:2506.21966, Jun. 2025.
    %
    % -------------------------------------------------------------------------
    % INPUTS:
    % N             num. TX antennas
    % K             num. devices
    % pth           received power requirement [W]
    % u             devices' positions [3,K] 
    % delta         inter-antenna separation
    % kappa         antennas' boresight gain
    % wavelength    wavelength [m]
    % l             side of the TX array [m]
    %
    % OUTPUTS: 
    % pow           power allocation
    % antPos        antenna positions [3,N]
    % -------------------------------------------------------------------------
    %
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
    
    % single-antenna PB
    if N == 1        
        % antenna position (Origin)
        r = antPosULAFnc(N,delta);

        % channel coefficients
        h = channelCoeffFnc(N,K,r,kappa,wavelength,u);

        % transmit power
        pow = max(pth./abs(h).^2);
        
        return;
    end 

    % single-device scenario
    if K == 1
        % antenna positions 
        r = antPosULAFnc(N,delta);

        % r has to have dimensions 3xN
        if isvector(r)
            r = [r(:).'; zeros(2,numel(r))];
        elseif size(r,1) == 2
            r = [r; zeros(1,size(r,2))];
        end

        % return antenna positions
        antPos = r;

        % channel coefficients
        h = channelCoeffFnc(N,K,r,kappa,wavelength,u);
        
        pow = pth*N/norm(h,1)^2;

        return;
    end

    % multi-antenna PB & multi-user setting
    
    % antenna positions 
    r = antPosULAFnc(N,delta);

    % r has to have dimensions 3xN
    if isvector(r)
        r = [r(:).'; zeros(2,numel(r))];
    elseif size(r,1) == 2
        r = [r; zeros(1,size(r,2))];
    end

    % return antenna positions
    antPos = r;

    % channel coefficients
    h = channelCoeffFnc(N,K,r,kappa,wavelength,u);

    % power allocation using SDP-relaxation 
    pow = sdpSolution(h,N,K,pth);
end

