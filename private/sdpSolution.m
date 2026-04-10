function pow = sdpSolution(h,N,K,pth)
    % -------------------------------------------------------------------------
    % Description:
    % This MATLAB function computes the power allocation using an SDP
    % relaxation. More information in:
    %
    % [R1] O. M. Rosabal, O. A. López, M. Di Renzo, R. D. Souza, and H. Alves,
    %     “Movable antennas-aided wireless energy transfer for the Internet of Things,”
    %     arXiv preprint arXiv:2506.21966, Jun. 2025.
    %
    % -------------------------------------------------------------------------
    % INPUTS:
    % h             complex channel coefficients [N,K]
    % N             num. TX antennas
    % K             num. devices
    % pth           received power requirement [W]
    %
    % OUTPUTS: 
    % pow           power allocation
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

    % auxiliary channel matrix SDP formulation
    H = zeros(N,N,K);
    for k = 1:K
        H(:,:,k) = h(:,k)*h(:,k)';
    end

    % optimal beamforming via SDP relaxation
    cvx_begin sdp quiet
    variable W(N,N) hermitian semidefinite
    variable xi nonnegative
    maximize ( xi )
    subject to 
        for k = 1:K
            real(trace(H(:,:,k)*W)) >= xi
        end

        for n = 1:N
            for nn = 1:N
                abs(W(n,nn)) <= 1/N
            end
        end
    cvx_end

    [V,D] = eig(W);

    % solution recovery via Gaussian randomization
    GaussSamples = 1e6;
    rng('default')
    rndPrecoders = V*sqrt(D)/sqrt(2)*(randn(N,GaussSamples) + 1i*randn(N,GaussSamples));

    [pow,~] = min(max(pth*N./abs(h'*exp(1i*angle(rndPrecoders))).^2));
end