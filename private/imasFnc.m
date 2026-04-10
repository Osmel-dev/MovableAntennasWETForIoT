function [pow,antPos] = imasFnc(N,K,pth,u,kappa,wavelength,l)
    % -------------------------------------------------------------------------
    % Description:
    % This MATLAB function computes the power allocation and array
    % configuration for the independently-controlled movable antennas
    % using a custom PSO implmentation. More information in:
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
    % kappa         antennas' boresight gain
    % wavelength    wavelength [m]
    % l             side of the TX array [m]
    %
    % OUTPUTS: 
    % pow           power allocation
    % antPos        antenna positions [2,N]
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
    
    nvars = 2*N;
    %% initialization
    numParticles = min(150,10*nvars);             % number of particles
    maxIter = 200*2*nvars;                          % number of iterations

    lBound = -l/2*ones(nvars,1);
    uBound = l/2*ones(nvars,1);
    
    inertiaWeightMax = 0.1;
    inertiaWeightMin = 1.1;
    inertiaWeight = inertiaWeightMax;
    
    c1 = 1.49;                                  % personal learning factor
    c2 = 1.49;                                  % global learning factor
        
    % set for reproducible results
    rng('default')
    
    % initial particles' positions
    particles = lBound + (uBound - lBound).*rand(nvars,numParticles);
    
    % initial particles' velocities
    velocities = -(uBound - lBound) + 2*(uBound - lBound).* rand(nvars,numParticles);
    
    % Initialize the best known positions and fitness values for each particle
    personalBestPositions = particles;
    personalBestFitness = zeros(numParticles,1);
    for jj = 1:numParticles 
        personalBestFitness(jj) = fitnessFunction(particles(:,jj),u,N,K,delta,pth,wavelength,kappa);
    end
    
    % Find the global best position
    [globalBestFitness, bestIdx] = min(personalBestFitness);
    globalBestPosition = personalBestPositions(:,bestIdx);
    globalBestFitnessPrev = Inf;
    stallIterations = 0;
    stallMaxIterations = 10;
    
    %% main optimization loop
    for ii = 1:maxIter
        for jj = 1:numParticles
            e1 = rand(nvars,1);
            e2 = rand(nvars,1);
    
            % update particles' velocities
            velocities(:,jj) = inertiaWeight*velocities(:,jj) + c1*e1.*(personalBestPositions(:,jj) - particles(:,jj)) + ...
                c2*e2.*(globalBestPosition - particles(:,jj));
    
            % updates particles' positions
            particles(:,jj) = particles(:,jj) + velocities(:,jj);
    
            % project the particles' positions onto the antenna's boundaries
            particles(:,jj) = max(min(particles(:,jj), uBound), lBound);
    
            % evaluate the fitness function for the new positions
            currentFitness = fitnessFunction(particles(:,jj),u,N,K,delta,pth,wavelength,kappa);
    
            % update personal best if necessary 
            if currentFitness < personalBestFitness(jj)
                personalBestFitness(jj) = currentFitness;
                personalBestPositions(:,jj) = particles(:,jj);
            end
        end    
    
        % update global best if necessary 
        [currentBestFitness, bestIdx] = min(personalBestFitness);
        if currentBestFitness < globalBestFitness
            globalBestFitness = currentBestFitness;
            globalBestPosition = personalBestPositions(:,bestIdx);
        end
    
        % update inertia weight
        inertiaWeight = inertiaWeightMax - (inertiaWeightMax - inertiaWeightMin)*ii/maxIter;

        % simulation progress
        fprintf('Iteration %d: Best Fitness = %.4f\n', ii, globalBestFitness);

        % stop the algorithm if the relative change in the objective
        % function is less than 1e-4 for stallIterations
        if abs(globalBestFitness - globalBestFitnessPrev) <= 1e-4
            stallIterations = stallIterations + 1;
        else
            stallIterations = 0;
        end

        if stallIterations >= stallMaxIterations
            fprintf('PSO converged: Objective function change is below %.6f at iteration %d.\n', ...
                abs(globalBestFitness - globalBestFitnessPrev), ii);
            break;
        end

        globalBestFitnessPrev = globalBestFitness;
    end
    
    % antenna positions
    antPos = reshape(globalBestPosition,[2 N]);

    % transmit power
    pow = globalBestFitness;
end

function fncOutput = fitnessFunction(particle,u,N,K,delta,pth,wavelength,kappa)
    % reshape the candidate set of solutions
    r = reshape(particle,[2 N]); 

    % r has to have dimensions 3xN
    if isvector(r)
        rReshaped = [r(:).'; zeros(2,numel(r))];
    elseif size(r,1) == 2
        rReshaped = [r; zeros(1,size(r,2))];
    end

    % channel coefficients
    h = channelCoeffFnc(N,K,rReshaped,kappa,wavelength,u);

    % penalize solutions violating the minimum inter-antenna separation
    tau = 1e4;

    counter = 0;
    for n = 1:N-1
        for nn = n+1:N
            if norm(r(:,n) - r(:,nn)) < delta
                counter = counter + 1;
            end
        end
    end

    if K == 1
        % single-device scenario
        % transmit power
        pow = pth*N/norm(h,1)^2;
    else 
        % multi-user setting
        % transmit power
        pow = sdpSolution(h,N,K,pth);        
    end

    fncOutput = pow + tau*counter;
end

