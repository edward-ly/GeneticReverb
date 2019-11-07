% Generates an impulse response according to reverb parameters.
% Also applies the impulse response to an input audio signal from a WAV file via
% convolution, and saves the impulse response and output audio to WAV files.
%
% File: main.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.8.0
% Last Updated: 15 August 2019
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
NORMALIZE_IR = true;
NORMALIZE_AUDIO = true;

%% Genetic algorithm parameters.
POPULATION_SIZE = 50;
SELECTION_SIZE = 20;
NUM_GENERATIONS = 50;
STOP_GENERATIONS = 5;
FITNESS_THRESHOLD = 1e-3;
MUTATION_RATE = 0.001;

%% Impulse response parameters.
% SAMPLE_RATE = Sample rate of impulse response (Hz)
% T60 = Total reverberation time (s)
% ITDG = Initial delay (s)
% EDT = Early decay time (s)
% C80 = Clarity, or relative loudness of early reverberations over
%     late reverberations (dB)
% BR = Warmth vs. brilliance, calculated as "bass ratio" (ratio of
%     low frequency to high frequency reverberation)

irParams = struct( ...
    'SAMPLE_RATE', 44100, ...
    'T60', 1.0, ...
    'ITDG', 0.01, ...
    'EDT', 0.1, ...
    'C80', 0, ...
    'BR', 1);

% Calculate number of samples to record in impulse response
numSamples = round(2 * irParams.T60 * irParams.SAMPLE_RATE);

%% Specify an audio file for input.
[fileName, filePath] = uigetfile( ...
    {'*.wav', 'WAV Files (*.wav)'}, 'Open WAV File...');
if ~fileName, fprintf('No file selected, exiting...\n'); return; end

%% Specify location to save audio files.
newFileName = replace(fileName, '.wav', '_wet.wav');
[outFileName, outFilePath] = uiputfile( ...
    {'*.wav', 'WAV Files (*.wav)'}, 'Save Audio As...', newFileName);
if ~outFileName, fprintf('No file selected, exiting...\n'); return; end

%% Read input audio file.
[drySignal, audioSampleRate] = audioread([filePath fileName]);
[numAudioSamples, numAudioChannels] = size(drySignal);

%% Genetic Algorithm.

% Initialize population.
fprintf('Initializing population...\n');
irPopulation = init_pop(numSamples, POPULATION_SIZE, irParams.SAMPLE_RATE, irParams.T60);
irFitness = Inf(POPULATION_SIZE, 1);
irBestFitness = Inf;
currentGen = 0;
currentStopGen = 0;

fitnessOverTime = zeros(NUM_GENERATIONS + 1, 1);

while true
    % Evaluate population.
    for i = 1:POPULATION_SIZE
        irFitness(i) = fitness(irPopulation(:, i), irParams);
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
        numSamples);

    % Mutate entire population.
    irPopulation = mutate(irPopulation, MUTATION_RATE);
end

%% Show impulse response plot.
figure
plot((1:numSamples) ./ irParams.SAMPLE_RATE, irBest)
grid on
xlabel('Time (s)')
ylabel('Amplitude')

%% Show impulse response plot in decibels.
irBest2 = 10 .* log10(irBest .* irBest);

figure
plot((1:numSamples) ./ irParams.SAMPLE_RATE, irBest2)
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
if irParams.SAMPLE_RATE ~= audioSampleRate
    irBest = resample(irBest, audioSampleRate, irParams.SAMPLE_RATE);
    numSamples = numel(irBest);
end

% Normalize impulse response.
if NORMALIZE_IR, irBest = normalize_signal(irBest, 0.99); end

% Write to WAV file.
irFileName = ['ir_' datestr(now, 'yyyymmdd_HHMMSSFFF') '.wav'];
audiowrite([outFilePath irFileName], irBest, audioSampleRate);

%% Apply impulse response to input audio signal.

% Apply impulse response via convolution. Each column/channel of the impulse
% response will filter the corresponding column/channel in the audio.
wetSignal = zeros(numAudioSamples + numSamples - 1, numAudioChannels);
for i = 1:numAudioChannels
    wetSignal(:, i) = conv(irBest, drySignal(:, i));
end

% Normalize audio.
if NORMALIZE_AUDIO, wetSignal = normalize_signal(wetSignal, 0.99, 'all'); end

% Write to WAV file.
audiowrite([outFilePath outFileName], wetSignal, audioSampleRate);

%% END OF SCRIPT
fprintf('Saved impulse response to %s%s\n', outFilePath, irFileName);
fprintf('Saved output audio to %s%s\n', outFilePath, outFileName);
