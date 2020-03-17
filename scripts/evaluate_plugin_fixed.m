% Script to generate and evaluate IRs similar to an input IR from file.
%
% File: evaluate_plugin_fixed.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.1.1
% Last Updated: 17 March 2020
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
addpath ../Violinplot-Matlab-master

%% Script Parameters
NUM_IRS = 30;                  % Number of IRs to generate per iteration
VERBOSE = false;                % Display genetic algorithm status messages

%% Genetic Algorithm Parameters
% Settings should be the same as in plugin

gaParamsMax = struct( ...
    'POPULATION_SIZE', 50, ...
    'SELECTION_SIZE', 20, ...
    'NUM_GENERATIONS', 100, ...
    'PLATEAU_LENGTH', 20, ...
    'FITNESS_THRESHOLD', 0.1, ...
    'MUTATION_RATE', 0.001);

gaParamsHigh = struct( ...
    'POPULATION_SIZE', 50, ...
    'SELECTION_SIZE', 20, ...
    'NUM_GENERATIONS', 50, ...
    'PLATEAU_LENGTH', 10, ...
    'FITNESS_THRESHOLD', 0.1, ...
    'MUTATION_RATE', 0.001);

gaParamsMed = struct( ...
    'POPULATION_SIZE', 25, ...
    'SELECTION_SIZE', 10, ...
    'NUM_GENERATIONS', 50, ...
    'PLATEAU_LENGTH', 10, ...
    'FITNESS_THRESHOLD', 0.1, ...
    'MUTATION_RATE', 0.001);

gaParamsLow = struct( ...
    'POPULATION_SIZE', 25, ...
    'SELECTION_SIZE', 10, ...
    'NUM_GENERATIONS', 20, ...
    'PLATEAU_LENGTH', 5, ...
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

%% Initialize irParams Struct
irParams = struct( ...
    'SAMPLE_RATE', audioSampleRate, ...
    'NUM_SAMPLES', numAudioSamples, ...
    'T60', irValues.T60, ...
    'EDT', irValues.EDT, ...
    'ITDG', irValues.ITDG, ...
    'C80', irValues.C80, ...
    'BR', irValues.BR);

%% Generate and Evaluate New Impulse Responses
% Low Settings
[timesLow, fitnessesLow, lossesLow, conditionsLow] = ir_test_fixed(irParams, gaParamsLow, NUM_IRS);
print_stats(NUM_IRS, timesLow, fitnessesLow, lossesLow, conditionsLow, 'Low');

% Medium Settings
[timesMed, fitnessesMed, lossesMed, conditionsMed] = ir_test_fixed(irParams, gaParamsMed, NUM_IRS);
print_stats(NUM_IRS, timesMed, fitnessesMed, lossesMed, conditionsMed, 'Medium');

% High Settings
[timesHigh, fitnessesHigh, lossesHigh, conditionsHigh] = ir_test_fixed(irParams, gaParamsHigh, NUM_IRS);
print_stats(NUM_IRS, timesHigh, fitnessesHigh, lossesHigh, conditionsHigh, 'High');

% Max Settings
[timesMax, fitnessesMax, lossesMax, conditionsMax] = ir_test_fixed(irParams, gaParamsMax, NUM_IRS);
print_stats(NUM_IRS, timesMax, fitnessesMax, lossesMax, conditionsMax, 'Max');

%% Close Log File
diary off

%% Generate and Save Figures
labels = {'Low', 'Medium', 'High', 'Max'};

% Comparison of Run Times
figure('Position', [600 498 640 480])
violinplot([timesLow timesMed timesHigh timesMax], labels, 'ShowNotches', true);
title('Comparison of Run Times', 'FontSize', 12)
xlabel('Quality')
ylabel('Run Time (s)')
ylim([0 inf])
savefig(['results_' timestamp '_figure_time.fig'])

% Comparison of Fitness Values
figure('Position', [600 498 640 480])
violinplot([fitnessesLow fitnessesMed fitnessesHigh fitnessesMax], labels, 'ShowNotches', true);
xlabel('Quality')
ylabel('Fitness Value')
ylim([0 inf])
savefig(['results_' timestamp '_figure_fitness.fig'])

% Comparison of T60 Error Values
figure('Position', [600 498 640 480])
violinplot([[lossesLow.T60]' [lossesMed.T60]' [lossesHigh.T60]' [lossesMax.T60]'], labels, 'ShowNotches', true);
xlabel('Quality')
ylabel('Absolute Deviation of T60 (s)')
ylim([0 inf])
savefig(['results_' timestamp '_figure_T60.fig'])

% Comparison of EDT Error Values
figure('Position', [600 498 640 480])
violinplot([[lossesLow.EDT]' [lossesMed.EDT]' [lossesHigh.EDT]' [lossesMax.EDT]'], labels, 'ShowNotches', true);
xlabel('Quality')
ylabel('Absolute Deviation of EDT (s)')
ylim([0 inf])
savefig(['results_' timestamp '_figure_EDT.fig'])

% Comparison of C80 Error Values
figure('Position', [600 498 640 480])
violinplot([[lossesLow.C80]' [lossesMed.C80]' [lossesHigh.C80]' [lossesMax.C80]'], labels, 'ShowNotches', true);
xlabel('Quality')
ylabel('Absolute Deviation of C80 (dB)')
ylim([0 inf])
savefig(['results_' timestamp '_figure_C80.fig'])

% Comparison of BR Error Values
figure('Position', [600 498 640 480])
violinplot([[lossesLow.BR]' [lossesMed.BR]' [lossesHigh.BR]' [lossesMax.BR]'], labels, 'ShowNotches', true);
xlabel('Quality')
ylabel('Absolute Deviation of BR (dB)')
ylim([0 inf])
savefig(['results_' timestamp '_figure_BR.fig'])

% Comparison of Terminating Condition Occurrences
countsLow = [sum(strcmp(conditionsLow, 'Generations')), ...
    sum(strcmp(conditionsLow, 'Plateau')), ...
    sum(strcmp(conditionsLow, 'Threshold'))];
countsMed = [sum(strcmp(conditionsMed, 'Generations')), ...
    sum(strcmp(conditionsMed, 'Plateau')), ...
    sum(strcmp(conditionsMed, 'Threshold'))];
countsHigh = [sum(strcmp(conditionsHigh, 'Generations')), ...
    sum(strcmp(conditionsHigh, 'Plateau')), ...
    sum(strcmp(conditionsHigh, 'Threshold'))];
countsMax = [sum(strcmp(conditionsMax, 'Generations')), ...
    sum(strcmp(conditionsMax, 'Plateau')), ...
    sum(strcmp(conditionsMax, 'Threshold'))];
labels = {'Generations', 'Plateau', 'Threshold'};

figure('Position', [600 258 960 720])
t = tiledlayout(2, 2, 'TileSpacing', 'none', 'Padding', 'compact');
title(t, '\bf Termination Probability Per Condition vs. Quality Setting', 'FontSize', 14)

nexttile
p1 = pie(countsLow);
set(findobj(p1, 'Type', 'Text'), 'FontSize', 12);
title('Low', 'FontSize', 14)

nexttile
p2 = pie(countsMed);
set(findobj(p2, 'Type', 'Text'), 'FontSize', 12);
legend(labels, 'Location', 'bestoutside', 'FontSize', 12)
title('Medium', 'FontSize', 14)

nexttile
p3 = pie(countsHigh);
set(findobj(p3, 'Type', 'Text'), 'FontSize', 12);
title('High', 'FontSize', 14)

nexttile
p4 = pie(countsMax);
set(findobj(p4, 'Type', 'Text'), 'FontSize', 12);
title('Max', 'FontSize', 14)

savefig(['results_' timestamp '_figure_terminating.fig'])
