function pop = init_pop( NUM_SAMPLES, NUM_CHANNELS, POPULATION_SIZE, SAMPLE_RATE, T60 )
% INIT_POP Generate an initial population.
% pop = output population
% Current algorithm: use rir_generator by Habets to generate simulated
% rooms. The receiver, source, and room parameters are also randomly
% generated for each individual.
    pop = zeros( NUM_SAMPLES, NUM_CHANNELS, POPULATION_SIZE );

    for i = 1:POPULATION_SIZE
        for j = 1:NUM_CHANNELS
            room_dim = abs( randn( 1, 3 ) ) .* 10 + 5;
            r_pos = [ rand * room_dim( 1, 1 ), rand * room_dim( 1, 2 ), rand * room_dim( 1, 3 ) ];
            s_pos = [ rand * room_dim( 1, 1 ), rand * room_dim( 1, 2 ), rand * room_dim( 1, 3 ) ];

            c = 340;                    % Sound velocity (m/s)
            fs = SAMPLE_RATE;           % Sample frequency (samples/s)
            r = r_pos;                  % Receiver position [x y z] (m)
            s = s_pos;                  % Source position [x y z] (m)
            L = room_dim;               % Room dimensions [x y z] (m)
            beta = T60;                 % T60 Reverberation time (s)
            n = NUM_SAMPLES;            % Number of samples (total reverberation time)
            mtype = 'omnidirectional';  % Type of microphone
            order = -1;                 % -1 equals maximum reflection order!
            dim = 3;                    % Room dimension
            orientation = 0;            % Microphone orientation (rad)
            hp_filter = 1;              % Enable high-pass filter

            h = rir_generator( c, fs, r, s, L, beta, n, mtype, order, dim, orientation, hp_filter );
            pop( :, j, i ) = h';
        end
    end
end
