% Generates an impulse response according to reverb parameters.
% Also applies the impulse response to an audio signal from a WAV file.
% The impulse response and output audio are also saved as WAV files.

% File: main.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Last Updated: 15 June 2019

%% Clear workspace, command window, and figures.
clear; clc; close all;

%% Add paths to any external functions used.
addpath components
addpath utilities

%% Open an audio file.
[ file_name, file_path ] = uigetfile( '*.wav', 'Open audio file' );
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

%% Genetic Algorithm.

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
    [ ir_pop, ir_fitness ] = pop_sort( ir_pop, ir_fitness );
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

%% Save best impulse response as audio file.
% Normalize impulse response.
ir_best = normalize_signal( ir_best, 1, "each" );

% Duplicate impulse response to accommodate number of audio channels, if necessary.
if NUM_CHANNELS < num_audio_channels
    ir_best = repmat( ir_best, 1, ceil( num_audio_channels / NUM_CHANNELS ) );
end

% Keep only channels that will affect input audio.
ir_best = ir_best( :, 1:num_audio_channels );

% Write to WAV file.
audiowrite( "output/ir.wav", ir_best, SAMPLE_RATE );

%% Apply the impulse response to the input audio signal.

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

% Write to WAV file.
output_file_name = strcat( "output/", replace( file_name, ".wav", "_wet.wav" ) );
audiowrite( output_file_name, wet_signal, SAMPLE_RATE );

%% END OF SCRIPT
fprintf("Done.\n");
