function [pow,antPos] = umasFnc(N,K,pth,u,kappa,wavelength,l)
    % -------------------------------------------------------------------------
    % Description:
    % This MATLAB function computes the power allocation and array
    % configuration for the uniformly-spaced movable antennas using a 
    % custom PSO implmentation. More information in:
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
    % antPos        antenna positions as
    %               particle(1) -> x-coordinate ref. position
    %               particle(2) -> y-coordinate ref. position 
    %               particle(3) -> inter-antenna separation 
    %               particle(4) -> array orientation
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
        nvars = 2;
    else
        nvars = 4;
    end

    lBound = zeros(nvars,1);
    uBound = ones(nvars,1);

    cols = ceil(sqrt(N));
    rows = ceil(N/cols);
    shapeArray = [rows cols]';

    [X, Y] = meshgrid(1:cols, 1:rows);
    
    % Flatten and pair up
    x = X(:);
    y = Y(:);
    
    % Only take first N positions
    relPos = [x(1:N), y(1:N)]';

    %% initialization
    numParticles = min(150,10*nvars);       % number of particles
    maxIter = 200*nvars;                    % number of iterations
    
    inertiaWeightMax = 0.1;
    inertiaWeightMin = 1.1;
    inertiaWeight = inertiaWeightMax;
    
    c1 = 1.49;                              % personal learning factor
    c2 = 1.49;                              % global learning factor
    
    % set for reproducible results
    rng('default')
    
    % initial particles' positions
    particles = lBound + (uBound - lBound).*rand(nvars,numParticles);
    
    % initial particles' velocities
    velocities = -(uBound - lBound) + 2*(uBound - lBound).* rand(nvars,numParticles);
    
    % initialize the best known positions and fitness values for each particle
    personalBestPositions = particles;
    personalBestFitness = zeros(numParticles,1);
    parfor jj = 1:numParticles 
        personalBestFitness(jj) = fitnessFunction(particles(:,jj),relPos,shapeArray,u,N,K,pth,wavelength,kappa,l);
    end
    
    % find the global best position
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
            currentFitness = fitnessFunction(particles(:,jj),relPos,shapeArray,u,N,K,pth,wavelength,kappa,l);
    
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

function fncOutput = fitnessFunction(particle,relPos,shapeArray,u,N,K,pth,wavelength,kappa,l)    
    if N == 1
        % candidate antenna positions
        r = [-l/2; l/2] + [particle(1); -particle(2)]*l;
    else
        % rotation angle
        rAngle = particle(4)*2*pi;
    
        % shape of the array
        cols = shapeArray(2);
        rows = shapeArray(1);
    
        crA = cos(rAngle);
        srA = sin(rAngle);
    
        % standard rotation matrix
        R  = [crA -srA;  srA  crA];         
    
        deltaX = l/((cols-1)*abs(crA) + (rows-1)*abs(srA));
        deltaY = l/((cols-1)*abs(srA) + (rows-1)*abs(crA));
    
        deltaMax = min(deltaX,deltaY);
        delta = wavelength/2 + particle(3)*(deltaMax - wavelength/2);

        widthArray = (cols-1)*delta;
        heightArray = (rows-1)*delta;
        xCorners = [0, widthArray, 0, widthArray];
        yCorners = [0, 0, heightArray, heightArray];
    
        xRot = crA*xCorners - srA*yCorners;   
        yRot = srA*xCorners + crA*yCorners;   

        xMinRot = min(xRot);
        xMaxRot = max(xRot);
        yMinRot = min(yRot);
        yMaxRot = max(yRot);
    
        xMinAllow = -l/2 - xMinRot;
        xMaxAllow = l/2 - xMaxRot;
        yMinAllow = -l/2 - yMinRot;
        yMaxAllow = l/2 - yMaxRot;
    
        refPosX = xMinAllow + particle(1)*(xMaxAllow - xMinAllow);
        refPosY = yMaxAllow - particle(2)*(yMaxAllow - yMinAllow);
        refPos = [refPosX; refPosY];
    
        % candidate antenna positions
        r = refPos + R*(relPos-1)*delta;
    end

    % r has to have dimensions 3xN
    if isvector(r)
        r = [r(:).'; zeros(2,numel(r))];
    elseif size(r,1) == 2
        r = [r; zeros(1,size(r,2))];
    end

    % channel coefficients
    h = channelCoeffFnc(N,K,r,kappa,wavelength,u);

    if K == 1
        % single-device scenario
        % transmit power
        pow = pth*N/norm(h,1)^2;
    else
        % multi-user setting
        % transmit power
        pow = sdpSolution(h,N,K,pth);
    end

    fncOutput = pow;
end

