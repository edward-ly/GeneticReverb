function pop = init_pop(NUM_SAMPLES, POPULATION_SIZE, SAMPLE_RATE, T60)
% INIT_POP Generate an initial population.
% pop = output population
% Current algorithm: use rir_generator by Habets to generate simulated rooms.
% The receiver, source, and room parameters are also randomly generated for each
% individual.
    % Require all arguments
    if nargin < 4, error('Not enough input arguments.'); end

    pop = zeros(NUM_SAMPLES, POPULATION_SIZE);

    for i = 1:POPULATION_SIZE
        % Randomly set room dimensions and receiver/source positions.
        roomDims = abs(randn(1, 3)) .* 10 + 5;
        rPos = [ ...
            rand * roomDims(1, 1), ...
            rand * roomDims(1, 2), ...
            rand * roomDims(1, 3)];
        sPos = [ ...
            rand * roomDims(1, 1), ...
            rand * roomDims(1, 2), ...
            rand * roomDims(1, 3)];

        c = 340;                    % Sound velocity (m/s)
        fs = SAMPLE_RATE;           % Sample frequency (samples/s)
        r = rPos;                   % Receiver position [x y z] (m)
        s = sPos;                   % Source position [x y z] (m)
        L = roomDims;               % Room dimensions [x y z] (m)
        beta = T60;                 % T60 Reverberation time (s)
        n = NUM_SAMPLES;            % Total reverberation time (samples)

        pop(:, i) = frir_generator(c, fs, r, s, L, beta, n);
    end
end