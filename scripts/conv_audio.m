% Generates a wet audio signal from two audio files (a dry signal and an IR).
%
% File: conv_audio.m
% Author: Edward Ly (edward.ly@pm.me)
% Version: 0.1.2
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

%% Output Parameters
NORMALIZE_AUDIO = true;    % Normalize audio after applying convolution
STEREO = false;            % Convolve audio using all IR channels if possible,
% otherwise use only 1st channel of IR

%% Load/Save UI
% Specify audio file for dry signal input
[dryFileName, dryFilePath] = uigetfile( ...
  {'*.wav', 'WAV Files (*.wav)'}, 'Open Audio WAV File...');
if ~dryFileName, fprintf('No file selected, exiting...\n'); return; end

% Specify audio file for impulse response
[irFileName, irFilePath] = uigetfile( ...
  {'*.wav', 'WAV Files (*.wav)'}, 'Open Impulse Response WAV File...');
if ~irFileName, fprintf('No file selected, exiting...\n'); return; end

% Specify location to save output files
newFileName = replace(dryFileName, '.wav', '_wet.wav');
[outFileName, outFilePath] = uiputfile( ...
  {'*.wav', 'WAV Files (*.wav)'}, 'Save Audio As...', newFileName);
if ~outFileName, fprintf('No file selected, exiting...\n'); return; end

%% Read Input Audio Files
% Dry Signal
[drySignal, audioSampleRate] = audioread([dryFilePath dryFileName]);
[numAudioSamples, numAudioChannels] = size(drySignal);

% Impulse Response
[ir, irSampleRate] = audioread([irFilePath irFileName]);
[irSamples, irChannels] = size(ir);

%% Create Wet Signal
% Resample IR sample rate to match audio sample rate, if necessary
if irSampleRate ~= audioSampleRate
  ir = resample(ir, audioSampleRate, irSampleRate);
  [irSamples, irChannels] = size(ir);
end

% Apply impulse response to input audio signal via convolution. Each
% column/channel of the impulse response will filter the corresponding
% column/channel in the audio
wetSignal = zeros(numAudioSamples + irSamples - 1, numAudioChannels);
if STEREO
  for i = 1:numAudioChannels %#ok<*UNRCH>
    wetSignal(:, i) = conv(ir(:, mod(i, irChannels) + 1), drySignal(:, i));
  end
else
  for i = 1:numAudioChannels
    wetSignal(:, i) = conv(ir(:, 1), drySignal(:, i));
  end
end

% Normalize audio
if NORMALIZE_AUDIO, wetSignal = normalize_signal(wetSignal, 0.99, 'all'); end

%% Save Output to File
% Reverb audio to WAV file
audiowrite([outFilePath outFileName], wetSignal, audioSampleRate);
fprintf('Saved output audio to %s%s\n', outFilePath, outFileName);
