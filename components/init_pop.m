function pop = init_pop( ...
    NUM_SAMPLES, NUM_CHANNELS, POPULATION_SIZE, SAMPLE_RATE, T60 ...
)
% INIT_POP Generate an initial population.
% pop = output population
% Current algorithm: use rir_generator by Habets to generate simulated rooms.
% The receiver, source, and room parameters are also randomly generated for each
% individual.
    pop = zeros(NUM_SAMPLES, NUM_CHANNELS, POPULATION_SIZE);

    for i = 1:POPULATION_SIZE
        for j = 1:NUM_CHANNELS
            % Randomly set room dimensions and receiver/source positions.
            roomDims = abs(randn(1, 3)) .* 10 + 5;
            rPos = [ ...
                rand * roomDims(1, 1), ...
                rand * roomDims(1, 2), ...
                rand * roomDims(1, 3)  ...
            ];
            sPos = [ ...
                rand * roomDims(1, 1), ...
                rand * roomDims(1, 2), ...
                rand * roomDims(1, 3)  ...
            ];

            c = 340;                    % Sound velocity (m/s)
            fs = SAMPLE_RATE;           % Sample frequency (samples/s)
            r = rPos;                   % Receiver position [x y z] (m)
            s = sPos;                   % Source position [x y z] (m)
            L = roomDims;               % Room dimensions [x y z] (m)
            beta = T60;                 % T60 Reverberation time (s)
            n = NUM_SAMPLES;            % Total reverberation time (samples)
            mtype = 'omnidirectional';  % Type of microphone
            order = -1;                 % -1 equals maximum reflection order!
            dim = 3;                    % Room dimension
            orientation = 0;            % Microphone orientation (rad)
            hpf = 1;                    % Enable high-pass filter

            h = rir_generator(c, fs, r, s, L, beta, ...    % required params
                n, mtype, order, dim, orientation, hpf ... % optional params
            );
            pop(:, j, i) = h';
        end
    end
end
