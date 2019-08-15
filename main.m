% Generates an impulse response according to reverb parameters.
% Also applies the impulse response to an input audio signal from a WAV file via
% convolution, and saves the impulse response and output audio to WAV files.
%
% File: main.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.7.1
% Last Updated: 5 August 2019
%
% BSD 3-Clause License
% 
% Copyright (c) 2019, Edward Ly
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

%% Clear workspace and figures.
clear; close all;

%% Add paths to any external functions used.
addpath components

%% Output parameters.
OUTPUT_DIR = 'output';
NORMALIZE_IR = true;
NORMALIZE_AUDIO = true;

%% Genetic algorithm parameters.
POPULATION_SIZE = 50;
SELECTION_SIZE = 20;
NUM_GENERATIONS = 50;
STOP_GENERATIONS = 5;
FITNESS_THRESHOLD = 1e-3;
MUTATION_RATE = 0.001;

%% User input (reverb fitness) parameters.
T60 = 1.0;   % Total reverberation time (s)
ITDG = 0.01; % Initial delay (s)
EDT = 0.1;   % Early decay time (s)
C80 = 0;     % Clarity, or relative loudness of early reverberations over late
             % reverberations (dB)
BR = 1;      % Warmth vs. brilliance, calculated as "bass ratio" (ratio of low
             % frequency to high frequency reverberation)

%% Impulse response parameters.
SAMPLE_RATE = 44100;
NUM_SAMPLES = round(2 * T60 * SAMPLE_RATE);
% ZERO_THRESHOLD = 1e-6;
% Only one impulse response channel per individual.
% NUM_CHANNELS = 1;

%% Open an audio file for input.
[fileName, filePath] = uigetfile('*.wav', 'Open audio file');
[drySignal, audioSampleRate] = audioread(strcat(filePath, fileName));
[numAudioSamples, numAudioChannels] = size(drySignal);

%% Genetic Algorithm.

% Initialize population.
fprintf('Initializing population...\n');
irPopulation = init_pop(NUM_SAMPLES, POPULATION_SIZE, SAMPLE_RATE, T60);
irFitness = Inf(POPULATION_SIZE, 1);
irBestFitness = Inf;
currentGen = 0;
currentStopGen = 0;

fitnessOverTime = zeros(NUM_GENERATIONS + 1, 1);

while true
    % Evaluate population.
    for i = 1:POPULATION_SIZE
        irFitness(i) = fitness( ...
            irPopulation(:, i), SAMPLE_RATE, T60, ITDG, EDT, C80, BR);
    end

    % Sort population by fitness value and update best individual.
    [irPopulation, irFitness] = sort_pop(irPopulation, irFitness);
    if irFitness(1) < irBestFitness
        irBestFitness = irFitness(1);
        irBest = irPopulation(:, 1);
        currentStopGen = 0;
    else
        currentStopGen = currentStopGen + 1;
    end
    fitnessOverTime(currentGen + 1) = irBestFitness;

    fprintf('Generation %d: best fitness value %d\n', ...
        currentGen, irBestFitness);

    % Stop if fitness value is within threshold.
    if irBestFitness < FITNESS_THRESHOLD
        fprintf('Optimal solution found.\n');
        break
    end

    % Stop if fitness value is not updated after some number of generations.
    if currentStopGen >= STOP_GENERATIONS
        fprintf('Local optimal solution found.\n');
        break
    end

    % Go to next generation (or stop if max number of generations reached).
    currentGen = currentGen + 1;
    if currentGen > NUM_GENERATIONS
        fprintf('Maximum number of generations reached.\n');
        break
    end

    % Select best individuals and generate children to replace remaining
    % individuals.
    irPopulation = crossover(irPopulation, SELECTION_SIZE, POPULATION_SIZE, ...
        NUM_SAMPLES);

    % Mutate entire population.
    irPopulation = mutate(irPopulation, MUTATION_RATE);
end

%% Show impulse response plot.
figure
plot((1:NUM_SAMPLES) ./ SAMPLE_RATE, irBest)
grid on
xlabel('Time (s)')
ylabel('Amplitude')

%% Show impulse response plot in decibels.
irBest2 = 10 .* log10(irBest .* irBest);

figure
plot((1:NUM_SAMPLES) ./ SAMPLE_RATE, irBest2)
grid on
xlabel('Time (s)')
ylabel('Relative Gain (dB)')

%% Show best fitness value over generations.
figure
plot(0:NUM_GENERATIONS, fitnessOverTime)
grid on
axis([-inf inf 0 inf])
xlabel('Generation')
ylabel('Fitness Value')

%% Save best impulse response as audio file.
% Resample IR sample rate to match audio sample rate, if necessary.
if SAMPLE_RATE ~= audioSampleRate
    irBest = resample(irBest, audioSampleRate, SAMPLE_RATE);
    NUM_SAMPLES = numel(irBest);
end

% Normalize impulse response.
if NORMALIZE_IR, irBest = normalize_signal(irBest, 0.99); end

% Create output folder if it doesn't already exist.
if ~isfolder(OUTPUT_DIR), mkdir(OUTPUT_DIR); end

% Write to WAV file.
audiowrite([OUTPUT_DIR filesep 'ir.wav'], irBest, audioSampleRate);

%% Apply impulse response to input audio signal.

% Apply impulse response via convolution. Each column/channel of the impulse
% response will filter the corresponding column/channel in the audio.
wetSignal = zeros(numAudioSamples + NUM_SAMPLES - 1, numAudioChannels);
for i = 1:numAudioChannels
    wetSignal(:, i) = conv(irBest, drySignal(:, i));
end

% Normalize audio.
if NORMALIZE_AUDIO, wetSignal = normalize_signal(wetSignal, 0.99, 'all'); end

% Write to WAV file.
outputFileName = [OUTPUT_DIR filesep replace(fileName, '.wav', '_wet.wav')];
audiowrite(outputFileName, wetSignal, audioSampleRate);

%% END OF SCRIPT
fprintf('Done.\n');
