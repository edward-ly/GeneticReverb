function pop = init_pop_old(gaParams, irParams)
% INIT_POP Generate an initial population.
%
% Input arguments:
% gaParams = struct containing genetic algorithm parameters
% irParams = struct containing impulse response parameters
%
% Output arguments:
% pop = output population
%
% Current algorithm: use the fast RIR generator by McGovern to generate rooms.
% The receiver, source, and room parameters are randomly determined for each
% individual.
% The room dimensions are biased towards higher values, with a maximum limit
% automatically determined from T60.
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    pop = zeros(irParams.NUM_SAMPLES, gaParams.POPULATION_SIZE);

    c = 340;                    % Sound velocity (m/s)
    fs = irParams.SAMPLE_RATE;  % Sample frequency (samples/s)
    beta = irParams.T60;        % T60 Reverberation time (s)
    n = irParams.NUM_SAMPLES;   % Total reverberation time (samples)
    
    % Determine upper limit of room dimensions
    maxL = c * beta / (4 * log(10.0));
    
    for i = 1:gaParams.POPULATION_SIZE
        % Room dimensions [x y z] (m)
        L = (1 - rand(1, 3) .^ 2) .* maxL;
        
        % Receiver position [x y z] (m)
        r = [rand * L(1, 1), rand * L(1, 2), rand * L(1, 3)];
        
        % Source position [x y z] (m)
        s = [rand * L(1, 1), rand * L(1, 2), rand * L(1, 3)];

        pop(:, i) = frir_generator(c, fs, r, s, L, beta, n);
    end
end
