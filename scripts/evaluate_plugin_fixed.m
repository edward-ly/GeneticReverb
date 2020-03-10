% Script to generate and evaluate IRs similar to an input IR from file.
%
% File: evaluate_plugin_fixed.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.1.0
% Last Updated: 10 March 2020
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
NUM_IRS = 100;                  % Number of IRs to generate
VERBOSE = false;                % Display genetic algorithm status messages

%% Genetic Algorithm Parameters
% Settings should be the same as in plugin

gaParamsHigh = struct( ...
    'POPULATION_SIZE', 20, ...
    'SELECTION_SIZE', 8, ...
    'NUM_GENERATIONS', 20, ...
    'PLATEAU_LENGTH', 5, ...
    'FITNESS_THRESHOLD', 0.1, ...
    'MUTATION_RATE', 0.001);

gaParamsMedium = struct( ...
    'POPULATION_SIZE', 20, ...
    'SELECTION_SIZE', 8, ...
    'NUM_GENERATIONS', 10, ...
    'PLATEAU_LENGTH', 3, ...
    'FITNESS_THRESHOLD', 0.1, ...
    'MUTATION_RATE', 0.001);

gaParamsLow = struct( ...
    'POPULATION_SIZE', 10, ...
    'SELECTION_SIZE', 4, ...
    'NUM_GENERATIONS', 10, ...
    'PLATEAU_LENGTH', 3, ...
    'FITNESS_THRESHOLD', 0.1, ...
    'MUTATION_RATE', 0.001);

%% Choose an audio file for input
[fileName, filePath] = uigetfile( ...
    {'*.wav', 'WAV Files (*.wav)'}, 'Open WAV File...');
if ~fileName, fprintf('No file selected, exiting...\n'); return; end

[drySignal, audioSampleRate] = audioread([filePath fileName]);
[numAudioSamples, numAudioChannels] = size(drySignal);

%% Open new file to write results
timestamp = datestr(now, 'yyyymmdd_HHMMSSFFF');
outFileName = ['results_' timestamp '.txt'];
diary(outFileName)
fprintf('Test Date/Time = %s\n', timestamp);
fprintf('Group Size = %d\n\n', NUM_IRS);

%% Calculate and display parameter values (Channel 1 only)
fprintf('Acoustics values of impulse response in file "%s%s"...\n', ...
    filePath, fileName);

irValues = calc_ir_values(drySignal(:, 1), numAudioSamples, audioSampleRate) %#ok<*NOPTS>

%% Define irParams Struct
irParams = struct( ...
    'SAMPLE_RATE', audioSampleRate, ...
    'NUM_SAMPLES', numAudioSamples, ...
    'T60', irValues.T60, ...
    'EDT', irValues.EDT, ...
    'ITDG', irValues.ITDG, ...
    'C80', irValues.C80, ...
    'BR', irValues.BR);

%% Generate and Evaluate New Impulse Responses (Low Settings)
[timesLow, fitnessesLow, lossesLow, conditionsLow] = ir_test_fixed(irParams, gaParamsLow, NUM_IRS);

% Show Data Statistics
fprintf('Summary (Low Settings):\n');
fprintf('Run Time: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(timesLow), median(timesLow), max(timesLow), mean(timesLow), std(timesLow));
fprintf('Fitness: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(fitnessesLow), median(fitnessesLow), max(fitnessesLow), mean(fitnessesLow), std(fitnessesLow));
fprintf('T60 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesLow.T60]), median([lossesLow.T60]), max([lossesLow.T60]), mean([lossesLow.T60]), std([lossesLow.T60]));
fprintf('EDT Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesLow.EDT]), median([lossesLow.EDT]), max([lossesLow.EDT]), mean([lossesLow.EDT]), std([lossesLow.EDT]));
fprintf('C80 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesLow.C80]), median([lossesLow.C80]), max([lossesLow.C80]), mean([lossesLow.C80]), std([lossesLow.C80]));
fprintf('BR Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesLow.BR]), median([lossesLow.BR]), max([lossesLow.BR]), mean([lossesLow.BR]), std([lossesLow.BR]));

[countsLow, groupsLow] = groupcounts(conditionsLow);
fprintf('\nTerminating conditions:\n');
for i = 1:size(groupsLow)
    fprintf('%s: %i (%.1f%%)\n', groupsLow(i), countsLow(i), countsLow(i) * 100 / NUM_IRS);
end
fprintf('\n');

%% Generate and Evaluate New Impulse Responses (Medium Settings)
[timesMed, fitnessesMed, lossesMed, conditionsMed] = ir_test_fixed(irParams, gaParamsMedium, NUM_IRS);

% Show Data Statistics
fprintf('Summary (Medium Settings):\n');
fprintf('Run Time: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(timesMed), median(timesMed), max(timesMed), mean(timesMed), std(timesMed));
fprintf('Fitness: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(fitnessesMed), median(fitnessesMed), max(fitnessesMed), mean(fitnessesMed), std(fitnessesMed));
fprintf('T60 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesMed.T60]), median([lossesMed.T60]), max([lossesMed.T60]), mean([lossesMed.T60]), std([lossesMed.T60]));
fprintf('EDT Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesMed.EDT]), median([lossesMed.EDT]), max([lossesMed.EDT]), mean([lossesMed.EDT]), std([lossesMed.EDT]));
fprintf('C80 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesMed.C80]), median([lossesMed.C80]), max([lossesMed.C80]), mean([lossesMed.C80]), std([lossesMed.C80]));
fprintf('BR Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesMed.BR]), median([lossesMed.BR]), max([lossesMed.BR]), mean([lossesMed.BR]), std([lossesMed.BR]));

[countsMed, groupsMed] = groupcounts(conditionsMed);
fprintf('\nTerminating conditions:\n');
for i = 1:size(groupsMed)
    fprintf('%s: %i (%.1f%%)\n', groupsMed(i), countsMed(i), countsMed(i) * 100 / NUM_IRS);
end
fprintf('\n');

%% Generate and Evaluate New Impulse Responses (High Settings)
[timesHigh, fitnessesHigh, lossesHigh, conditionsHigh] = ir_test_fixed(irParams, gaParamsHigh, NUM_IRS);

% Show Data Statistics
fprintf('Summary (High Settings):\n');
fprintf('Run Time: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(timesHigh), median(timesHigh), max(timesHigh), mean(timesHigh), std(timesHigh));
fprintf('Fitness: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min(fitnessesHigh), median(fitnessesHigh), max(fitnessesHigh), mean(fitnessesHigh), std(fitnessesHigh));
fprintf('T60 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesHigh.T60]), median([lossesHigh.T60]), max([lossesHigh.T60]), mean([lossesHigh.T60]), std([lossesHigh.T60]));
fprintf('EDT Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesHigh.EDT]), median([lossesHigh.EDT]), max([lossesHigh.EDT]), mean([lossesHigh.EDT]), std([lossesHigh.EDT]));
fprintf('C80 Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesHigh.C80]), median([lossesHigh.C80]), max([lossesHigh.C80]), mean([lossesHigh.C80]), std([lossesHigh.C80]));
fprintf('BR Absolute Deviation: min = %f, med = %f, max = %f, mean = %f, std = %f\n', ...
    min([lossesHigh.BR]), median([lossesHigh.BR]), max([lossesHigh.BR]), mean([lossesHigh.BR]), std([lossesHigh.BR]));

[countsHigh, groupsHigh] = groupcounts(conditionsHigh);
fprintf('\nTerminating conditions:\n');
for i = 1:size(groupsHigh)
    fprintf('%s: %i (%.1f%%)\n', groupsHigh(i), countsHigh(i), countsHigh(i) * 100 / NUM_IRS);
end
fprintf('\n');

%% Close Log File
diary off
