function pos = antPosURAFnc(N,delta)
    % -------------------------------------------------------------------------
    % Description:
    % This MATLAB function computes the antenna positions in the URA with 
    %  fixed antennas. More information in:
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
        rows = 1;
        cols = 1;
    elseif N == 2
        rows = 1;
        cols = 2;
    elseif N == 3 || N == 4
        rows = 2;
        cols = 2;
    elseif N == 5 || N == 6
        rows = 2;
        cols = 3;
    elseif N >= 7 && N <= 9
        rows = 3;
        cols = 3;
    elseif N >= 10 && N <= 12
        rows = 3;
        cols = 4;
    end

    % add the actual inter-antenna separation
    [x, y] = meshgrid(1:cols, 1:rows);
    x = x*delta;
    y = y*delta;

    % center the array
    x = x - mean(x(:));
    y = y - mean(y(:));

    pos = [x(1:N); y(1:N); zeros(1,N)];
end

