% Record fitness values of impulse responses generated by the plugin.
%
% File: evaluate_plugin.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.5.5
% Last Updated: 11 April 2020
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
addpath ../Violinplot-Matlab-master

%% Output Parameters
NUM_IRS = 250;                  % Number of IRs to generate per iteration
VERBOSE = false;                % Display genetic algorithm status messages
T60s = [0.625, 1.25, 2.5, 5.0]; % List of T60 values to test

%% Load Genetic Algorithm Parameters
gaParamsMax = load('quality_settings.mat', 'Max').Max;
gaParamsHigh = load('quality_settings.mat', 'High').High;
gaParamsMed = load('quality_settings.mat', 'Medium').Medium;
gaParamsLow = load('quality_settings.mat', 'Low').Low;

%% Open new file to write results
timestamp = datestr(now, 'yyyymmdd_HHMMSSFFF');
outFileName = ['results_' timestamp '.txt'];
diary(outFileName)
fprintf('Test Date/Time = %s\n', timestamp);
fprintf('Group Size = %d\n\n', NUM_IRS);

%% Generate and Evaluate New Impulse Responses
% Initial Settings
[times, fitnesses, losses, conditions] = ir_test_init(gaParamsLow, NUM_IRS);
print_stats(NUM_IRS, times, fitnesses, losses, conditions, 'Initial');

% Low Settings, T60 = 0.625s
[timesLow1, fitnessesLow1, lossesLow1, conditionsLow1] = ir_test_rand(gaParamsLow, T60s(1), NUM_IRS);
print_stats(NUM_IRS, timesLow1, fitnessesLow1, lossesLow1, conditionsLow1, 'Low', T60s(1));

% Low Settings, T60 = 1.25s
[timesLow2, fitnessesLow2, lossesLow2, conditionsLow2] = ir_test_rand(gaParamsLow, T60s(2), NUM_IRS);
print_stats(NUM_IRS, timesLow2, fitnessesLow2, lossesLow2, conditionsLow2, 'Low', T60s(2));

% Low Settings, T60 = 2.5s
[timesLow3, fitnessesLow3, lossesLow3, conditionsLow3] = ir_test_rand(gaParamsLow, T60s(3), NUM_IRS);
print_stats(NUM_IRS, timesLow3, fitnessesLow3, lossesLow3, conditionsLow3, 'Low', T60s(3));

% Low Settings, T60 = 5s
[timesLow4, fitnessesLow4, lossesLow4, conditionsLow4] = ir_test_rand(gaParamsLow, T60s(4), NUM_IRS);
print_stats(NUM_IRS, timesLow4, fitnessesLow4, lossesLow4, conditionsLow4, 'Low', T60s(4));

% Medium Settings, T60 = 0.625s
[timesMed1, fitnessesMed1, lossesMed1, conditionsMed1] = ir_test_rand(gaParamsMed, T60s(1), NUM_IRS);
print_stats(NUM_IRS, timesMed1, fitnessesMed1, lossesMed1, conditionsMed1, 'Medium', T60s(1));

% Medium Settings, T60 = 1.25s
[timesMed2, fitnessesMed2, lossesMed2, conditionsMed2] = ir_test_rand(gaParamsMed, T60s(2), NUM_IRS);
print_stats(NUM_IRS, timesMed2, fitnessesMed2, lossesMed2, conditionsMed2, 'Medium', T60s(2));

% Medium Settings, T60 = 2.5s
[timesMed3, fitnessesMed3, lossesMed3, conditionsMed3] = ir_test_rand(gaParamsMed, T60s(3), NUM_IRS);
print_stats(NUM_IRS, timesMed3, fitnessesMed3, lossesMed3, conditionsMed3, 'Medium', T60s(3));

% Medium Settings, T60 = 5s
[timesMed4, fitnessesMed4, lossesMed4, conditionsMed4] = ir_test_rand(gaParamsMed, T60s(4), NUM_IRS);
print_stats(NUM_IRS, timesMed4, fitnessesMed4, lossesMed4, conditionsMed4, 'Medium', T60s(4));

% High Settings, T60 = 0.625s
[timesHigh1, fitnessesHigh1, lossesHigh1, conditionsHigh1] = ir_test_rand(gaParamsHigh, T60s(1), NUM_IRS);
print_stats(NUM_IRS, timesHigh1, fitnessesHigh1, lossesHigh1, conditionsHigh1, 'High', T60s(1));

% High Settings, T60 = 1.25s
[timesHigh2, fitnessesHigh2, lossesHigh2, conditionsHigh2] = ir_test_rand(gaParamsHigh, T60s(2), NUM_IRS);
print_stats(NUM_IRS, timesHigh2, fitnessesHigh2, lossesHigh2, conditionsHigh2, 'High', T60s(2));

% High Settings, T60 = 2.5s
[timesHigh3, fitnessesHigh3, lossesHigh3, conditionsHigh3] = ir_test_rand(gaParamsHigh, T60s(3), NUM_IRS);
print_stats(NUM_IRS, timesHigh3, fitnessesHigh3, lossesHigh3, conditionsHigh3, 'High', T60s(3));

% High Settings, T60 = 5s
[timesHigh4, fitnessesHigh4, lossesHigh4, conditionsHigh4] = ir_test_rand(gaParamsHigh, T60s(4), NUM_IRS);
print_stats(NUM_IRS, timesHigh4, fitnessesHigh4, lossesHigh4, conditionsHigh4, 'High', T60s(4));

% Max Settings, T60 = 0.625s
[timesMax1, fitnessesMax1, lossesMax1, conditionsMax1] = ir_test_rand(gaParamsMax, T60s(1), NUM_IRS);
print_stats(NUM_IRS, timesMax1, fitnessesMax1, lossesMax1, conditionsMax1, 'Max', T60s(1));

% Max Settings, T60 = 1.25s
[timesMax2, fitnessesMax2, lossesMax2, conditionsMax2] = ir_test_rand(gaParamsMax, T60s(2), NUM_IRS);
print_stats(NUM_IRS, timesMax2, fitnessesMax2, lossesMax2, conditionsMax2, 'Max', T60s(2));

% Max Settings, T60 = 2.5s
[timesMax3, fitnessesMax3, lossesMax3, conditionsMax3] = ir_test_rand(gaParamsMax, T60s(3), NUM_IRS);
print_stats(NUM_IRS, timesMax3, fitnessesMax3, lossesMax3, conditionsMax3, 'Max', T60s(3));

% Max Settings, T60 = 5s
[timesMax4, fitnessesMax4, lossesMax4, conditionsMax4] = ir_test_rand(gaParamsMax, T60s(4), NUM_IRS);
print_stats(NUM_IRS, timesMax4, fitnessesMax4, lossesMax4, conditionsMax4, 'Max', T60s(4));

%% Close Log File
diary off

%% Generate and Save Figures
% Suppress Warnings
warning('off', 'MATLAB:handle_graphics:Layout:NoPositionSetInTiledChartLayout')

labels = {'Low', 'Medium', 'High', 'Max'};

% Comparison of Run Times
figure('Position', [360 18 1280 960])
t1 = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t1, 'Comparison of Run Times', 'FontSize', 12)
xlabel(t1, 'Quality')
ylabel(t1, 'Run Time (s)')

t11 = nexttile;
violinplot([timesLow1 timesMed1 timesHigh1 timesMax1], ...
    labels, 'ShowData', false);
title('T60 = 0.625s')
y11 = ylim;

t12 = nexttile;
violinplot([timesLow2 timesMed2 timesHigh2 timesMax2], ...
    labels, 'ShowData', false);
title('T60 = 1.25s')
y12 = ylim;

t13 = nexttile;
violinplot([timesLow3 timesMed3 timesHigh3 timesMax3], ...
    labels, 'ShowData', false);
title('T60 = 2.5s')
y13 = ylim;

t14 = nexttile;
violinplot([timesLow4 timesMed4 timesHigh4 timesMax4], ...
    labels, 'ShowData', false);
title('T60 = 5s')
y14 = ylim;

linkaxes([t11 t12 t13 t14], 'y')
t11.YLim = [0 max([y11(2) y12(2) y13(2) y14(2)])];

savefig(['results_' timestamp '_figure_time.fig'])

% Comparison of Fitness Values
figure('Position', [360 18 1280 960])
t2 = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t2, 'Comparison of Fitness Values', 'FontSize', 12)
xlabel(t2, 'Quality')
ylabel(t2, 'Fitness Value')

t21 = nexttile;
violinplot([fitnessesLow1 fitnessesMed1 fitnessesHigh1 fitnessesMax1], ...
    labels, 'ShowData', false);
title('T60 = 0.625s')
y21 = ylim;

t22 = nexttile;
violinplot([fitnessesLow2 fitnessesMed2 fitnessesHigh2 fitnessesMax2], ...
    labels, 'ShowData', false);
title('T60 = 1.25s')
y22 = ylim;

t23 = nexttile;
violinplot([fitnessesLow3 fitnessesMed3 fitnessesHigh3 fitnessesMax3], ...
    labels, 'ShowData', false);
title('T60 = 2.5s')
y23 = ylim;

t24 = nexttile;
violinplot([fitnessesLow4 fitnessesMed4 fitnessesHigh4 fitnessesMax4], ...
    labels, 'ShowData', false);
title('T60 = 5s')
y24 = ylim;

linkaxes([t21 t22 t23 t24], 'y')
t21.YLim = [0 max([y21(2) y22(2) y23(2) y24(2)])];

savefig(['results_' timestamp '_figure_fitness.fig'])

% Comparison of T60 Error Values
figure('Position', [360 18 1280 960])
t3 = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t3, 'Comparison of T60 Error Values', 'FontSize', 12)
xlabel(t3, 'Quality')
ylabel(t3, 'Absolute Deviation of T60 (ms)')

t31 = nexttile;
violinplot([[lossesLow1.T60]' [lossesMed1.T60]' [lossesHigh1.T60]' [lossesMax1.T60]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 0.625s')
y31 = ylim;

t32 = nexttile;
violinplot([[lossesLow2.T60]' [lossesMed2.T60]' [lossesHigh2.T60]' [lossesMax2.T60]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 1.25s')
y32 = ylim;

t33 = nexttile;
violinplot([[lossesLow3.T60]' [lossesMed3.T60]' [lossesHigh3.T60]' [lossesMax3.T60]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 2.5s')
y33 = ylim;

t34 = nexttile;
violinplot([[lossesLow4.T60]' [lossesMed4.T60]' [lossesHigh4.T60]' [lossesMax4.T60]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 5s')
y34 = ylim;

linkaxes([t31 t32 t33 t34], 'y')
t31.YLim = [0 max([y31(2) y32(2) y33(2) y34(2)])];

savefig(['results_' timestamp '_figure_T60.fig'])

% Comparison of EDT Error Values
figure('Position', [360 18 1280 960])
t4 = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t4, 'Comparison of EDT Error Values', 'FontSize', 12)
xlabel(t4, 'Quality')
ylabel(t4, 'Absolute Deviation of EDT (ms)')

t41 = nexttile;
violinplot([[lossesLow1.EDT]' [lossesMed1.EDT]' [lossesHigh1.EDT]' [lossesMax1.EDT]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 0.625s')
y41 = ylim;

t42 = nexttile;
violinplot([[lossesLow2.EDT]' [lossesMed2.EDT]' [lossesHigh2.EDT]' [lossesMax2.EDT]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 1.25s')
y42 = ylim;

t43 = nexttile;
violinplot([[lossesLow3.EDT]' [lossesMed3.EDT]' [lossesHigh3.EDT]' [lossesMax3.EDT]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 2.5s')
y43 = ylim;

t44 = nexttile;
violinplot([[lossesLow4.EDT]' [lossesMed4.EDT]' [lossesHigh4.EDT]' [lossesMax4.EDT]'] .* 1000, ...
    labels, 'ShowData', false);
title('T60 = 5s')
y44 = ylim;

linkaxes([t41 t42 t43 t44], 'y')
t41.YLim = [0 max([y41(2) y42(2) y43(2) y44(2)])];

savefig(['results_' timestamp '_figure_EDT.fig'])

% Comparison of C80 Error Values
figure('Position', [360 18 1280 960])
t5 = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t5, 'Comparison of C80 Error Values', 'FontSize', 12)
xlabel(t5, 'Quality')
ylabel(t5, 'Absolute Deviation of C80 (dB)')

t51 = nexttile;
violinplot([[lossesLow1.C80]' [lossesMed1.C80]' [lossesHigh1.C80]' [lossesMax1.C80]'], ...
    labels, 'ShowData', false);
title('T60 = 0.625s')
y51 = ylim;

t52 = nexttile;
violinplot([[lossesLow2.C80]' [lossesMed2.C80]' [lossesHigh2.C80]' [lossesMax2.C80]'], ...
    labels, 'ShowData', false);
title('T60 = 1.25s')
y52 = ylim;

t53 = nexttile;
violinplot([[lossesLow3.C80]' [lossesMed3.C80]' [lossesHigh3.C80]' [lossesMax3.C80]'], ...
    labels, 'ShowData', false);
title('T60 = 2.5s')
y53 = ylim;

t54 = nexttile;
violinplot([[lossesLow4.C80]' [lossesMed4.C80]' [lossesHigh4.C80]' [lossesMax4.C80]'], ...
    labels, 'ShowData', false);
title('T60 = 5s')
y54 = ylim;

linkaxes([t51 t52 t53 t54], 'y')
t51.YLim = [0 max([y51(2) y52(2) y53(2) y54(2)])];

savefig(['results_' timestamp '_figure_C80.fig'])

% Comparison of BR Error Values
figure('Position', [360 18 1280 960])
t6 = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
title(t6, 'Comparison of BR Error Values', 'FontSize', 12)
xlabel(t6, 'Quality')
ylabel(t6, 'Absolute Deviation of BR (dB)')

t61 = nexttile;
violinplot([[lossesLow1.BR]' [lossesMed1.BR]' [lossesHigh1.BR]' [lossesMax1.BR]'], ...
    labels, 'ShowData', false);
title('T60 = 0.625s')
y61 = ylim;

t62 = nexttile;
violinplot([[lossesLow2.BR]' [lossesMed2.BR]' [lossesHigh2.BR]' [lossesMax2.BR]'], ...
    labels, 'ShowData', false);
title('T60 = 1.25s')
y62 = ylim;

t63 = nexttile;
violinplot([[lossesLow3.BR]' [lossesMed3.BR]' [lossesHigh3.BR]' [lossesMax3.BR]'], ...
    labels, 'ShowData', false);
title('T60 = 2.5s')
y63 = ylim;

t64 = nexttile;
violinplot([[lossesLow4.BR]' [lossesMed4.BR]' [lossesHigh4.BR]' [lossesMax4.BR]'], ...
    labels, 'ShowData', false);
title('T60 = 5s')
y64 = ylim;

linkaxes([t61 t62 t63 t64], 'y')
t61.YLim = [0 max([y61(2) y62(2) y63(2) y64(2)])];

savefig(['results_' timestamp '_figure_BR.fig'])

% Comparison of Terminating Condition Occurrences
countsLow1 = [sum(strcmp(conditionsLow1, 'Generations')), ...
    sum(strcmp(conditionsLow1, 'Plateau')), ...
    sum(strcmp(conditionsLow1, 'Threshold'))];
countsMed1 = [sum(strcmp(conditionsMed1, 'Generations')), ...
    sum(strcmp(conditionsMed1, 'Plateau')), ...
    sum(strcmp(conditionsMed1, 'Threshold'))];
countsHigh1 = [sum(strcmp(conditionsHigh1, 'Generations')), ...
    sum(strcmp(conditionsHigh1, 'Plateau')), ...
    sum(strcmp(conditionsHigh1, 'Threshold'))];
countsMax1 = [sum(strcmp(conditionsMax1, 'Generations')), ...
    sum(strcmp(conditionsMax1, 'Plateau')), ...
    sum(strcmp(conditionsMax1, 'Threshold'))];
countsLow2 = [sum(strcmp(conditionsLow2, 'Generations')), ...
    sum(strcmp(conditionsLow2, 'Plateau')), ...
    sum(strcmp(conditionsLow2, 'Threshold'))];
countsMed2 = [sum(strcmp(conditionsMed2, 'Generations')), ...
    sum(strcmp(conditionsMed2, 'Plateau')), ...
    sum(strcmp(conditionsMed2, 'Threshold'))];
countsHigh2 = [sum(strcmp(conditionsHigh2, 'Generations')), ...
    sum(strcmp(conditionsHigh2, 'Plateau')), ...
    sum(strcmp(conditionsHigh2, 'Threshold'))];
countsMax2 = [sum(strcmp(conditionsMax2, 'Generations')), ...
    sum(strcmp(conditionsMax2, 'Plateau')), ...
    sum(strcmp(conditionsMax2, 'Threshold'))];
countsLow3 = [sum(strcmp(conditionsLow3, 'Generations')), ...
    sum(strcmp(conditionsLow3, 'Plateau')), ...
    sum(strcmp(conditionsLow3, 'Threshold'))];
countsMed3 = [sum(strcmp(conditionsMed3, 'Generations')), ...
    sum(strcmp(conditionsMed3, 'Plateau')), ...
    sum(strcmp(conditionsMed3, 'Threshold'))];
countsHigh3 = [sum(strcmp(conditionsHigh3, 'Generations')), ...
    sum(strcmp(conditionsHigh3, 'Plateau')), ...
    sum(strcmp(conditionsHigh3, 'Threshold'))];
countsMax3 = [sum(strcmp(conditionsMax3, 'Generations')), ...
    sum(strcmp(conditionsMax3, 'Plateau')), ...
    sum(strcmp(conditionsMax3, 'Threshold'))];
countsLow4 = [sum(strcmp(conditionsLow4, 'Generations')), ...
    sum(strcmp(conditionsLow4, 'Plateau')), ...
    sum(strcmp(conditionsLow4, 'Threshold'))];
countsMed4 = [sum(strcmp(conditionsMed4, 'Generations')), ...
    sum(strcmp(conditionsMed4, 'Plateau')), ...
    sum(strcmp(conditionsMed4, 'Threshold'))];
countsHigh4 = [sum(strcmp(conditionsHigh4, 'Generations')), ...
    sum(strcmp(conditionsHigh4, 'Plateau')), ...
    sum(strcmp(conditionsHigh4, 'Threshold'))];
countsMax4 = [sum(strcmp(conditionsMax4, 'Generations')), ...
    sum(strcmp(conditionsMax4, 'Plateau')), ...
    sum(strcmp(conditionsMax4, 'Threshold'))];

labels = {'Generations', 'Plateau', 'Threshold'};

figure('Position', [360 18 1280 960])
t7 = tiledlayout(4, 4, 'TileSpacing', 'none', 'Padding', 'compact');
title(t7, '\bf Termination Probability Per Condition vs. Quality Setting and T60 Time', 'FontSize', 14)

nexttile
p = pie(countsLow1);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Low, 0.625s', 'FontSize', 14)

nexttile
p = pie(countsMed1);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Medium, 0.625s', 'FontSize', 14)

nexttile
p = pie(countsHigh1);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('High, 0.625s', 'FontSize', 14)

nexttile
p = pie(countsMax1);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
legend(labels, 'Location', 'bestoutside', 'FontSize', 12)
title('Max, 0.625s', 'FontSize', 14)

nexttile
p = pie(countsLow2);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Low, 1.25s', 'FontSize', 14)

nexttile
p = pie(countsMed2);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Medium, 1.25s', 'FontSize', 14)

nexttile
p = pie(countsHigh2);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('High, 1.25s', 'FontSize', 14)

nexttile
p = pie(countsMax2);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Max, 1.25s', 'FontSize', 14)

nexttile
p = pie(countsLow3);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Low, 2.5s', 'FontSize', 14)

nexttile
p = pie(countsMed3);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Medium, 2.5s', 'FontSize', 14)

nexttile
p = pie(countsHigh3);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('High, 2.5s', 'FontSize', 14)

nexttile
p = pie(countsMax3);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Max, 2.5s', 'FontSize', 14)

nexttile
p = pie(countsLow4);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Low, 5s', 'FontSize', 14)

nexttile
p = pie(countsMed4);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Medium, 5s', 'FontSize', 14)

nexttile
p = pie(countsHigh4);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('High, 5s', 'FontSize', 14)

nexttile
p = pie(countsMax4);
set(findobj(p, 'Type', 'Text'), 'FontSize', 12);
title('Max, 5s', 'FontSize', 14)

savefig(['results_' timestamp '_figure_terminating.fig'])
