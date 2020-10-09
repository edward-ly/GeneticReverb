% Script for generating WAV files for all binary files in a specified folder.
% Any WAV files that have already been created are skipped.
%
% File: bins2wav.m
% Author: Edward Ly (edward.ly@pm.me)
% Version: 0.1.0
% Last Updated: 8 November 2019
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
% Add paths to any external functions used
addpath ../components

%% Choose a folder for input
filePath = uigetdir;
if ~filePath, fprintf('No folder selected, exiting...\n'); return; end
filePath = [filePath filesep];

%% Get names of all binary files in folder
fileNameList = ls([filePath '*.bin']);

%% Generate WAV file for each binary file
% Track number of files already created
skipCount = 0;

for i = 1:size(fileNameList, 1)
    fileName = deblank(fileNameList(i, :));
    [fileCreated, newFileName] = bin_to_wav(filePath, fileName);
    if fileCreated
        fprintf('Created file %s%s\n', filePath, newFileName);
    else
        skipCount = skipCount + 1;
    end
end

if skipCount > 0
    plural = '';
    if skipCount > 1, plural = 's'; end
    fprintf('Skipped %d file%s.\n', skipCount, plural);
end
