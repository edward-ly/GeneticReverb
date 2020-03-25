% Script to generate and save an IR similar to an input IR from file.
%
% File: generate_similar_ir.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.1.1
% Last Updated: 24 March 2020
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

%% Preamble
% Clear workspace and figures
clear; close all;

% Add paths to any external functions used
addpath ../components

%% Script Parameters
NUM_IRS = 12;                   % Number of IRs to generate
IR_SAMPLE_RATE = 44100;         % Sample rate of desired IR
VERBOSE = false;                % Display genetic algorithm status messages

%% Genetic Algorithm Parameters
gaParams = struct( ...
    'POPULATION_SIZE', 50, ...
    'SELECTION_SIZE', 20, ...
    'NUM_GENERATIONS', 150, ...
    'PLATEAU_LENGTH', 30, ...
    'FITNESS_THRESHOLD', 0.001, ...
    'MUTATION_RATE', 0.001);

%% Load/Save UI
% Specify IR file for input
[fileName, filePath] = uigetfile( ...
    {'*.wav', 'WAV Files (*.wav)'}, 'Open Impulse Response WAV File...');
if ~fileName, fprintf('No file selected, exiting...\n'); return; end

% Specify location to save output files
newFileName = replace(fileName, '.wav', '_ga.wav');
[outFileName, outFilePath] = uiputfile( ...
    {'*.wav', 'WAV Files (*.wav)'}, 'Save New Impulse Response As...', newFileName);
if ~outFileName, fprintf('No file selected, exiting...\n'); return; end

%% Read Input Audio File
[drySignal, audioSampleRate] = audioread([filePath fileName]);
[numAudioSamples, numAudioChannels] = size(drySignal);

%% Calculate and display parameter values (Channel 1 only)
fprintf('Acoustics values of impulse response in file "%s%s"...\n', ...
    filePath, fileName);

irValues = calc_ir_values(drySignal(:, 1), numAudioSamples, audioSampleRate) %#ok<*NOPTS>

%% Initialize irParams Struct
irParams = struct( ...
    'SAMPLE_RATE', IR_SAMPLE_RATE, ...
    'NUM_SAMPLES', round(numAudioSamples * IR_SAMPLE_RATE / audioSampleRate), ...
    'T60', irValues.T60, ...
    'EDT', irValues.EDT, ...
    'ITDG', irValues.ITDG, ...
    'C80', irValues.C80, ...
    'BR', irValues.BR);

%% Generate New Impulse Response
irs = zeros(irParams.NUM_SAMPLES, NUM_IRS);
fitnesses = zeros(NUM_IRS, 1);

parfor i = 1:NUM_IRS
    [irs(:, i), fitnesses(i)] = genetic_rir(gaParams, irParams, VERBOSE);
end

[bestFitness, bestFitnessIndex] = min(fitnesses);
bestIR = irs(:, bestFitnessIndex);

% Add predelay
delay = round(irValues.PREDELAY * IR_SAMPLE_RATE);
bestIR = [zeros(delay, 1); bestIR(1:(end - delay))];

%% Display and Save Output
audiowrite([outFilePath outFileName], bestIR, IR_SAMPLE_RATE);
fprintf('\nSaved new impulse response to %s%s\n', outFilePath, outFileName);

fprintf('Acoustics values of new impulse response...\n');

irValues = calc_ir_values(bestIR, irParams.NUM_SAMPLES, IR_SAMPLE_RATE) %#ok<*NOPTS>

fprintf('Fitness value: %f\n', bestFitness);