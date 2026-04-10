function pos = antPosULAFnc(N,delta)
    % -------------------------------------------------------------------------
    % Description:
    % This MATLAB function computes the antenna positions for the ULA with 
    % fixed antennas. More information in:
    %
    % [R1] O. M. Rosabal, O. A. López, M. Di Renzo, R. D. Souza, and H. Alves,
    %     “Movable antennas-aided wireless energy transfer for the Internet of Things,”
    %     arXiv preprint arXiv:2506.21966, Jun. 2025.
    %
    % -------------------------------------------------------------------------
    % INPUTS:
    % N             num. TX antennas
    % delta         inter-antenna separation
    %
    % OUTPUTS: 
    % pos           antenna positions
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
    
    if N == 1
        pos = 0;
    else
        ulaLength = (N-1)*delta;
        pos = linspace(-ulaLength/2,ulaLength,N);
    end

end

