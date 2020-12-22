% Generates an impulse response according to reverb parameters.
% Also applies the impulse response to an input audio signal from a WAV file via
% convolution, and saves the impulse response and output audio to WAV files.
%
% File: main.m
% Author: Edward Ly (edward.ly@pm.me)
% Version: 0.12.0
% Last Updated: 13 October 2020
%
% Usage: Adjust parameter values to your liking, then click on "Editor > Run" or
% run `main` in the MATLAB command window under the project root directory. Two
% file dialog windows will then appear in succession, one for selecting the
% input (dry) audio file and one for specifying the location and name of the
% output (wet) audio file. Another audio file containing the impulse response
% generated will also be saved in the same location.
%
%
% BSD 3-Clause License
%
% Copyright (c) 2020, Edward Ly
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

%% Preamble
% Clear workspace and figures
clear; close all;

% Add paths to any external functions used
addpath ../components

%% Output Parameters
NORMALIZE_AUDIO = true;    % Normalize audio after applying reverb
VERBOSE = true;            % Display genetic algorithm status messages
SHOW_FIGURES = true;       % Display figures plotting IR and output audio

%% Genetic Algorithm Parameters
% POPULATION_SIZE = Number of impulse responses in population
% SELECTION_SIZE = Number of impulse responses to keep in each generation
% NUM_GENERATIONS = Maximum number of generations to run in the algorithm
% PLATEAU_LENGTH = If there is no new best impulse response after some number
%     of generations, stop early
% FITNESS_THRESHOLD = If fitness value is below threshold value, stop early
% MUTATION_RATE = Probability of each sample in impulse response randomly
%     changing value in each generation

gaParams = struct( ...
  'POPULATION_SIZE', 50, ...
  'SELECTION_SIZE', 20, ...
  'NUM_GENERATIONS', 250, ...
  'PLATEAU_LENGTH', 50, ...
  'FITNESS_THRESHOLD', 0.001, ...
  'MUTATION_RATE', 0.001);

%% Impulse Response Parameters
% SAMPLE_RATE = Sample rate of impulse response (Hz)
% NUM_SAMPLES = Number of samples in IR to record / length of IR
% PREDELAY = Delay time before onset of first early reflection (samples)
% T60 = Total reverberation time (s)
% EDT = Early decay time (s)
% C80 = Clarity, or relative loudness of early reverberations over
%     late reverberations (dB)
% BR = Warmth vs. brilliance, calculated as "bass ratio" (ratio of
%     low frequency to high frequency content) (dB)

irParams = struct( ...
  'SAMPLE_RATE', 44100, ...
  'NUM_SAMPLES', 0, ...
  'PREDELAY', 0, ...
  'T60', 0.3914, ...
  'EDT', 0.0644, ...
  'C80', 12.3611, ...
  'BR', 0.7041);

irParams.PREDELAY = round(0.002 * irParams.SAMPLE_RATE);
irParams.NUM_SAMPLES = round(1.5 * irParams.T60 * irParams.SAMPLE_RATE);

%% Load/Save UI
% Specify audio file for input
[fileName, filePath] = uigetfile( ...
  {'*.wav', 'WAV Files (*.wav)'}, 'Open WAV File...');
if ~fileName, fprintf('No file selected, exiting...\n'); return; end

% Specify location to save output files
newFileName = replace(fileName, '.wav', '_wet.wav');
[outFileName, outFilePath] = uiputfile( ...
  {'*.wav', 'WAV Files (*.wav)'}, 'Save Audio As...', newFileName);
if ~outFileName, fprintf('No file selected, exiting...\n'); return; end

%% Read Input Audio File
[drySignal, audioSampleRate] = audioread([filePath fileName]);
[numAudioSamples, numAudioChannels] = size(drySignal);

%% Generate New Impulse Response
[irBest, ~, fitnessCurve] = genetic_rir(gaParams, irParams, VERBOSE);

%% Impulse Response Post-Processing
numSamples = irParams.NUM_SAMPLES;

% Normalize impulse response gain
irBest = normalize_signal(irBest, 0.25);

% Add Predelay
irBest = [zeros(irParams.PREDELAY, 1); irBest(1:(end - irParams.PREDELAY))];

% Resample IR sample rate to match audio sample rate, if necessary
if irParams.SAMPLE_RATE ~= audioSampleRate
  irBest = resample(irBest, audioSampleRate, irParams.SAMPLE_RATE);
  numSamples = numel(irBest);
end

% Apply impulse response to input audio signal via convolution. Each
% column/channel of the impulse response will filter the corresponding
% column/channel in the audio
wetSignal = zeros(numAudioSamples + numSamples - 1, numAudioChannels);
for i = 1:numAudioChannels
  wetSignal(:, i) = conv(irBest, drySignal(:, i));
end

% Normalize wet signal only to prevent clipping
if max(abs(wetSignal), [], 'all') > 0.99
  wetSignal = normalize_signal(wetSignal, 0.99, 'all');
end

%% Save Output to Files
% Impulse response to WAV file
irFileName = ['ir_' datestr(now, 'yyyymmdd_HHMMSSFFF') '.wav'];
audiowrite([outFilePath irFileName], irBest, audioSampleRate);
fprintf('\nSaved impulse response to %s%s\n', outFilePath, irFileName);

% Reverb audio to WAV file
audiowrite([outFilePath outFileName], wetSignal, audioSampleRate);
fprintf('Saved output audio to %s%s\n', outFilePath, outFileName);

%% Display Figures
if SHOW_FIGURES
  % Plot output impulse response
  figure
  plot((1:numSamples) ./ audioSampleRate, irBest)
  grid on
  xlabel('Time (s)')
  ylabel('Amplitude')
  
  % Plot output impulse response in decibels
  irBest2 = 10 .* log10(irBest .* irBest);
  [~, sirdB] = schroeder(irBest);
  
  figure
  hold on
  plot((1:numSamples) ./ audioSampleRate, irBest2)
  plot((1:numSamples) ./ audioSampleRate, sirdB)
  grid on
  xlabel('Time (s)')
  ylabel('Relative Gain (dB)')
  
  % Plot best fitness value over time (in generations)
  figure
  plot(0:gaParams.NUM_GENERATIONS, fitnessCurve)
  grid on
  axis([-inf inf 0 inf])
  xlabel('Generation')
  ylabel('Fitness Value')
end
