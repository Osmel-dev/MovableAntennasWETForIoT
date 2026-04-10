function h = channelCoeffFnc(N,K,r,kappa,wavelength,u)
    % -------------------------------------------------------------------------
    % Description:
    % This MATLAB function computes the complex channel coefficients
    % according to a near-field model. More information in:
    %
    % [R1] O. M. Rosabal, O. A. López, M. Di Renzo, R. D. Souza, and H. Alves,
    %     “Movable antennas-aided wireless energy transfer for the Internet of Things,”
    %     arXiv preprint arXiv:2506.21966, Jun. 2025.
    %
    % -------------------------------------------------------------------------
    % INPUTS:
    % N             num. TX antennas
    % K             num. devices
    % r             antenna positions [2,N]
    % kappa         antennas' boresight gain
    % wavelength    wavelength [m]
    % u             devices' positions [3,K]
    %
    % OUTPUTS: 
    % h             complex channel coefficients [N,K]
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

    % memory pre-allocation
    h = zeros(N,K);

    % channel coefficients
    for k = 1:K
        for n = 1:N
            dAnt2Dev = norm(r(:,n) - u(:,k));        
            cosVartheta = u(3,k)/dAnt2Dev;        
            F = 2*(kappa+1)*cosVartheta^kappa;        
            h(n,k) = sqrt(F)*wavelength*exp(-1i*2*pi*dAnt2Dev/wavelength)/(4*pi*dAnt2Dev);
        end
    end
end

