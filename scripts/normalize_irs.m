% Script to normalize 2 audio files so that RMS levels are equal.
%
% File: normalize_irs.m
% Author: Edward Ly (edward.ly@pm.me)
% Version: 0.1.0
% Last Updated: 24 March 2020
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

%% Load/Save UI
% Specify files for input
[fileName1, filePath1] = uigetfile( ...
    {'*.wav', 'WAV Files (*.wav)'}, 'Open WAV File...');
if ~fileName1, fprintf('No file selected, exiting...\n'); return; end

[fileName2, filePath2] = uigetfile( ...
    {'*.wav', 'WAV Files (*.wav)'}, 'Open WAV File...');
if ~fileName2, fprintf('No file selected, exiting...\n'); return; end

%% Read Input Audio Files
[signal1, fs1] = audioread([filePath1 fileName1]);
[signal2, fs2] = audioread([filePath2 fileName2]);

%% Calculate RMS Levels and Normalize
[outSignal1, outSignal2] = normalize_rms(signal1(:, 1), signal2(:, 1));
out = normalize_signal([outSignal1 outSignal2], 0.99);

%% Save Output
audiowrite([filePath1 fileName1], out(:, 1), fs1);
audiowrite([filePath2 fileName2], out(:, 2), fs2);
