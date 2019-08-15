function pop = init_pop(NUM_SAMPLES, POPULATION_SIZE, SAMPLE_RATE, T60)
% INIT_POP Generate an initial population.
%
% Input arguments:
% NUM_SAMPLES = length in samples of each impulse response
% POPULATION_SIZE = number of impulse responses to generate
% SAMPLE_RATE = sample rate of each impulse response
% T60 = T60 reverberation time for each impulse response
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
    if nargin < 4, error('Not enough input arguments.'); end
    if nargout < 1, error('Not enough output arguments.'); end

    pop = zeros(NUM_SAMPLES, POPULATION_SIZE);

    c = 340;                    % Sound velocity (m/s)
    fs = SAMPLE_RATE;           % Sample frequency (samples/s)
    beta = T60;                 % T60 Reverberation time (s)
    n = NUM_SAMPLES;            % Total reverberation time (samples)
    
    % Determine upper limit of room dimensions
    maxL = c * beta / (4 * log(10.0));
    
    for i = 1:POPULATION_SIZE
        % Room dimensions [x y z] (m)
        L = (1 - rand(1, 3) .^ 2) .* maxL;
        
        % Receiver position [x y z] (m)
        r = [rand * L(1, 1), rand * L(1, 2), rand * L(1, 3)];
        
        % Source position [x y z] (m)
        s = [rand * L(1, 1), rand * L(1, 2), rand * L(1, 3)];

        pop(:, i) = frir_generator(c, fs, r, s, L, beta, n);
    end
end
