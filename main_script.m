% Generates an impulse response according to reverb parameters and saves it to a WAV file ("ir.wav").
% Also applies the impulse response to an audio signal from a file upon user request
% and saves the output ("output.wav").

% File: main.m
% Author: Edward Ly (m5222120)
% Last Updated: 14 June 2019

%% Clear workspace, command window, and figures.
clear; clc; close all;

%% Add paths to any external functions used.
addpath utilities

%% Open an audio file.
[ file_name, file_path ] = uigetfile( '*.wav', 'Open audio file' ); % open file dialog box
[ dry_signal, audio_sample_rate ] = audioread( strcat( file_path, file_name ) );
[ num_audio_samples, num_audio_channels ] = size(dry_signal);

%% Genetic algorithm parameters.
POPULATION_SIZE = 20;
SELECTION_SIZE = 10;
NUM_GENERATIONS = 200;
FITNESS_THRESHOLD = 1e-4;
MUTATION_RATE = 0.02;

%% User input (reverb fitness) parameters.
T60 = 1;
ITDG = 0.005;
EDT = 0.2;
C80 = 1;
BR = 1.1;

%% Impulse response parameters.
SAMPLE_RATE = audio_sample_rate;
NUM_SAMPLES = round( ( T60 * 1.1 ) * SAMPLE_RATE );
NUM_CHANNELS = 1;
ZERO_THRESHOLD = 1e-6;

%% Genetic Algorithm

% Initialize population.
fprintf("Initializing. Please wait...\n");
ir_pop = init_pop( NUM_SAMPLES, NUM_CHANNELS, POPULATION_SIZE, SAMPLE_RATE, T60 );
ir_fitness = Inf( 1, POPULATION_SIZE );
ir_best_fitness = Inf;
current_gen = 0;

fitness_over_time = zeros( NUM_GENERATIONS + 1, 1 );

while true
    % Evaluate population.
    for i = 1:POPULATION_SIZE
        ir_fitness( 1, i ) = fitness( ir_pop( :, :, i ), ...
            SAMPLE_RATE, ZERO_THRESHOLD, T60, ITDG, EDT, C80 );
    end

    % Sort population by fitness value and update best individual.
    [ ir_pop, ir_fitness ] = ir_sort( ir_pop, ir_fitness );
    if ir_fitness( 1, 1 ) < ir_best_fitness
        ir_best_fitness = ir_fitness( 1, 1 );
        ir_best = ir_pop( :, :, 1 );
    end
    fitness_over_time( current_gen + 1, 1 ) = ir_best_fitness;

    fprintf( "Generation %d: best fitness value %d\n", current_gen, ir_best_fitness );

    % Stop if fitness value is within threshold.
    if ir_best_fitness < FITNESS_THRESHOLD
        fprintf("Found optimal solution.\n");
        break
    end

    % Go to next generation (or stop if max number of generations reached).
    current_gen = current_gen + 1;
    if current_gen > NUM_GENERATIONS
        fprintf("Maximum number of generations reached.\n");
        break
    end

    % Select best individuals and generate children.
    ir_pop = crossover( ir_pop, SELECTION_SIZE, POPULATION_SIZE );
    % Mutate population.
    ir_pop = mutate( ir_pop, MUTATION_RATE );
end

%% Show impulse response plot.
figure
plot( ir_best( :, 1 ) )
grid on
xlabel('Sample')
ylabel('Amplitude')

%% Show fitness over time.
figure
plot( 0:NUM_GENERATIONS, fitness_over_time )
grid on
xlabel('Generation')
ylabel('Fitness')

%% Write best impulse response to audio file.
% Normalize impulse response.
ir_best = normalize_signal( ir_best, 1, "each" );

% Duplicate impulse response to accommodate number of audio channels, if necessary.
if NUM_CHANNELS < num_audio_channels
    ir_best = repmat( ir_best, 1, ceil( num_audio_channels / NUM_CHANNELS ) );
end

% Keep only channels that will affect input audio.
ir_best = ir_best( :, 1:num_audio_channels );

% Write to file.
audiowrite( "output/ir.wav", ir_best, SAMPLE_RATE );

%% Apply the impulse response to the audio signal.

% Add silence to the end of the dry signal with duration equal to duration
% of impulse response (to ensure trailing samples of wet signal don't get
% cut off).
dry_signal = cat( 1, dry_signal, zeros( NUM_SAMPLES, num_audio_channels ) );

% Apply impulse response(s) to each channel separately.
wet_signal = zeros( num_audio_samples + NUM_SAMPLES, num_audio_channels );
for i = 1:num_audio_channels
    wet_signal( :, i ) = fftfilt( ir_best( :, i ), dry_signal( :, i ) );
end

% Normalize audio.
wet_signal = normalize_signal( wet_signal, 0.99, "all" );

% Write to file.
output_file_name = strcat( "output/", replace( file_name, ".wav", "_wet.wav" ) );
audiowrite( output_file_name, wet_signal, SAMPLE_RATE );

%% END OF SCRIPT
fprintf("Done.\n");

%% FUNCTIONS

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

function f = fitness( ir, SAMPLE_RATE, ZERO_THRESHOLD, T60, ITDG, EDT, C80 )
% FITNESS Calculate fitness value of impulse response.
% ir = impulse response
% f = fitness value
    % Find highest sample and ignore previous samples for some descriptors.
    [ impulse_max_amplitude, impulse_max_sample ] = max( ir( :, 1 ) );
    impulse_max_dB = 20 * log10( abs(impulse_max_amplitude) );
    IR = ir( ( impulse_max_sample + 1 ):end, 1 );

    % ITDG (initial time delay gap)
    ir_ITDG = impulse_max_sample / SAMPLE_RATE;

    % T60
    impulse_T60_sample = find( ...
        ( IR > ZERO_THRESHOLD ) & ( 20 * log10(IR) - impulse_max_dB < -60 ), 1 ...
    );
    if isempty(impulse_T60_sample)
        impulse_T60_sample = Inf;
    end
    ir_T60 = impulse_T60_sample / SAMPLE_RATE;

    % EDT (early decay time, a.k.a. T10)
    impulse_EDT_sample = find( ...
        ( IR > ZERO_THRESHOLD ) & ( 20 * log10(IR) - impulse_max_dB < -10 ), 1 ...
    );
    if isempty(impulse_EDT_sample)
        impulse_EDT_sample = Inf;
    end
    ir_EDT = impulse_EDT_sample / SAMPLE_RATE;

    % C80 (clarity)
    sample_80ms = 0.08 * SAMPLE_RATE;
    early_reflections = ir( 1:sample_80ms, 1 );
    late_reflections = ir( ( sample_80ms + 1 ):end, 1 );
    early_energy = sum( early_reflections .^ 2 );
    late_energy = sum( late_reflections .^ 2 );
    ir_C80 = 10 * log10( early_energy / late_energy );

    f = ( ir_T60 - T60 )^2 + ...
        ( ir_ITDG - ITDG )^2 + ...
        ( ir_EDT - EDT )^2 + ...
        ( ir_C80 - C80 )^2;
end

function [ sorted_pop, sorted_fitness ] = ir_sort( pop, fitness )
% IR_SORT Sort population by fitness value.
% sorted_pop = sorted population
% sorted_fitness = fitness values of sorted population
% pop = unsorted population
% fitness = fitness values of unsorted population
    [ sorted_fitness, indices ] = sort(fitness);
    sorted_pop = pop;
    for i = 1:numel(indices)
        sorted_pop( :, :, i ) = pop( :, :, indices( 1, i ) );
    end
end

function out_pop = crossover( in_pop, SELECTION_SIZE, POPULATION_SIZE )
% CROSSOVER Generate children and replace least fit individuals.
% out_pop = output population
% in_pop = input population
% Current algorithm: replace each worst individual with the weighted
% average of two random parents from the selection pool.
% The weights are random for each crossover.
    out_pop = in_pop;
    for i = ( SELECTION_SIZE + 1 ):POPULATION_SIZE
        parents = randperm( SELECTION_SIZE, 2 );

        weight = rand;
        parent1 = weight .* in_pop( :, :, parents(1) );
        parent2 = ( 1 - weight ) .* in_pop( :, :, parents(2) );
        out_pop( :, :, i ) = parent1 + parent2;
    end
end

function out_pop = mutate( in_pop, MUTATION_RATE )
% MUTATE Changes the population's values with some probability.
% out_pop = output population
% in_pop = input population
% Current algorithm: for each affected sample,
% add to it a random number from the normal distribution
% (standard deviation = 0.05).
    out_pop = in_pop;
    [ I, J, K ] = size(out_pop);
    mut_values = double( rand( I, J, K ) < MUTATION_RATE ) .* randn( I, J, K ) .* 0.1;
    out_pop = out_pop + mut_values;
end
