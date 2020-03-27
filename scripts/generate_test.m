% Performs mass convolution and normalization for evaluation purposes.
%
% File: generate_test.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.1.0
% Last Updated: 27 March 2020
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

%% Load/Save UI
FILE_PATH = '../ir_test/';
irFiles = ls([FILE_PATH 'ir_*.wav']);
[numIRs, ~] = size(irFiles);

%% Read Input Audio Files
% Dry Signal 1
[speech, speechSampleRate] = audioread([FILE_PATH 'speech.wav']);
[speechSamples, speechAudioChannels] = size(speech);

% Dry Signal 2
[drums, drumSampleRate] = audioread([FILE_PATH 'drums.wav']);
[drumSamples, drumAudioChannels] = size(drums);

%% Generate Audio
for i = 1:numIRs
    % Open next IR
    irFileName = strtrim(irFiles(i, :));
    [ir, irSampleRate] = audioread([FILE_PATH irFileName]);

    % Resample IR sample rate to match speech sample rate, if necessary
    if irSampleRate ~= speechSampleRate
        ir = resample(ir, speechSampleRate, irSampleRate);
    end
    [irSamples, ~] = size(ir);
    
    % Apply convolution
    wetSpeech = zeros(speechSamples + irSamples - 1, speechAudioChannels);
    for j = 1:speechAudioChannels
        wetSpeech(:, j) = conv(ir(:, 1), speech(:, j));
    end
    wetSpeech = normalize_signal(wetSpeech, 0.99);
    
    % Wet speech to WAV file
    outFileName = replace(irFileName, 'ir_', 'speech_');
    audiowrite([FILE_PATH outFileName], wetSpeech, speechSampleRate);
    fprintf('Saved %s%s\n', FILE_PATH, outFileName);

    % =========================================================================

    % Resample IR sample rate to match drums sample rate, if necessary
    [ir, irSampleRate] = audioread([FILE_PATH irFileName]);
    if irSampleRate ~= drumSampleRate
        ir = resample(ir, drumSampleRate, irSampleRate);
    end
    [irSamples, ~] = size(ir);
    
    % Apply convolution
    wetDrums = zeros(drumSamples + irSamples - 1, drumAudioChannels);
    for j = 1:drumAudioChannels
        wetDrums(:, j) = conv(ir(:, 1), drums(:, j));
    end
    wetDrums = normalize_signal(wetDrums, 0.99);
    
    % Wet speech to WAV file
    outFileName = replace(irFileName, 'ir_', 'drums_');
    audiowrite([FILE_PATH outFileName], wetDrums, drumSampleRate);
    fprintf('Saved %s%s\n', FILE_PATH, outFileName);
end

%% Normalize New Files
speechFilesOrig = ls([FILE_PATH 'speech_*_ch1.wav']);
speechFilesHigh = ls([FILE_PATH 'speech_*_ch1_ga_high.wav']);
speechFilesMax = ls([FILE_PATH 'speech_*_ch1_ga_max.wav']);
[numFiles, ~] = size(speechFilesOrig);

for i = 1:numFiles
    file1 = strtrim(speechFilesOrig(i, :));
    file2 = strtrim(speechFilesHigh(i, :));
    file3 = strtrim(speechFilesMax(i, :));
    [signal1, fs1] = audioread([FILE_PATH file1]);
    [signal2, fs2] = audioread([FILE_PATH file2]);
    [signal3, fs3] = audioread([FILE_PATH file3]);

    [outSignal1, outSignal2] = normalize_rms(signal1(:, 1), signal2(:, 1));
    [~,          outSignal3] = normalize_rms(signal1(:, 1), signal3(:, 1));
    out = normalize_signal([outSignal1 outSignal2 outSignal3], 0.99);

    audiowrite([FILE_PATH file1], out(:, 1), fs1);
    audiowrite([FILE_PATH file2], out(:, 2), fs2);
    audiowrite([FILE_PATH file3], out(:, 3), fs3);
end

drumFilesOrig = ls([FILE_PATH 'drums_*_ch1.wav']);
drumFilesHigh = ls([FILE_PATH 'drums_*_ch1_ga_high.wav']);
drumFilesMax = ls([FILE_PATH 'drums_*_ch1_ga_max.wav']);
[numFiles, ~] = size(drumFilesOrig);

for i = 1:numFiles
    file1 = strtrim(drumFilesOrig(i, :));
    file2 = strtrim(drumFilesHigh(i, :));
    file3 = strtrim(drumFilesMax(i, :));
    [signal1, fs1] = audioread([FILE_PATH file1]);
    [signal2, fs2] = audioread([FILE_PATH file2]);
    [signal3, fs3] = audioread([FILE_PATH file3]);

    [outSignal1, outSignal2] = normalize_rms(signal1(:, 1), signal2(:, 1));
    [~,          outSignal3] = normalize_rms(signal1(:, 1), signal3(:, 1));
    out = normalize_signal([outSignal1 outSignal2 outSignal3], 0.99);

    audiowrite([FILE_PATH file1], out(:, 1), fs1);
    audiowrite([FILE_PATH file2], out(:, 2), fs2);
    audiowrite([FILE_PATH file3], out(:, 3), fs3);
end
