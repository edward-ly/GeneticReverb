% Class file for VST2 plugin that performs IR-based reverb in real-time
% via frequency-domain partitioned convolution [1], while adding the ability to
% shape the impulse response using a genetic algorithm, as well as control the
% dry/wet mix and gain of the output signal.
%
% File: GeneticReverb.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 0.1.0
% Last Updated: 5 August 2019
%
% Usage: validate and generate the VST plugin, respectively, with:
%     validateAudioPlugin GeneticReverb
%     generateAudioPlugin GeneticReverb
% 
% Sources:
% [1] MATLAB Example 'audiopluginexample.FastConvolver'
%
% MIT License
%
% Copyright (c) 2019 Edward Ly
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

classdef (StrictDefaults) GeneticReverb < audioPlugin & matlab.System & ...
        matlab.system.mixin.Propagates
    properties % Public variables
        T60 = 1;
        ITDG = 0.1;
        EDT = 0.1;
        C80 = 0;
        BR = 1;
        GAIN = 0;
        WET = 100;

        % Load default impulse response
        ImpulseResponse = audioread(['.' filesep 'output' filesep 'ir.wav']).';
    end
    
    properties (Constant) % Interface parameters
        PluginInterface = audioPluginInterface( ...
            'InputChannels', 2, ...
            'OutputChannels', 2, ...
            'PluginName', 'Genetic Reverb', ... % 'Out Of The Box'
            audioPluginParameter('T60', ...
                'DisplayName', 'Total Time', ...
                'Label', 's', ...
                'Mapping', {'log', 0.1, 5}), ...
            audioPluginParameter('ITDG', ...
                'DisplayName', 'Intimacy', ...
                'Label', 's', ...
                'Mapping', {'lin', 0, 0.2}), ...
            audioPluginParameter('EDT', ...
                'DisplayName', 'Reverberance', ...
                'Label', 's', ...
                'Mapping', {'log', 0.1, 5}), ...
            audioPluginParameter('C80', ...
                'DisplayName', 'Clarity', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -5, 5}), ...
            audioPluginParameter('BR', ...
                'DisplayName', 'Bass Ratio', ...
                'Mapping', {'log', 0.5, 2}), ...
            audioPluginParameter('GAIN', ...
                'DisplayName', 'Gain', ...
                'Label', 'dB', ...
                'Mapping', {'pow', 1/3, -60, 6}), ...
            audioPluginParameter('WET', ...
                'DisplayName', 'Dry/Wet', ...
                'Label', '%', ...
                'Mapping', {'lin', 0, 100}) ...
        )
    end
    
    properties (Access = private, Nontunable)
        PartitionSize = 1024;
        
        % DSP Objects for partitioned convolution
        pFIR_L
        pFIR_R
    end
    
    % Plugin methods for frequency-domain partitioned convolution [1]
    % Modified for multi-channel, mutable IRs and output control
    methods (Access = protected)
        % Main process function
        function out = stepImpl (plugin, in)
            % Calculate next convolution step for each channel
            outL = step(plugin.pFIR_L, in(:, 1));
            outR = step(plugin.pFIR_R, in(:, 2));
            out = [outL outR];
            
            % Apply dry/wet mix
            out = in .* (1 - plugin.WET / 100) + out .* plugin.WET ./ 100;
            
            % Apply output gain
            ampGain = 10 ^ (plugin.GAIN / 20);
            out = out * ampGain;
        end

        % DSP initialization / setup
        function setupImpl (plugin, in)
            [numChannels, ~] = size(plugin.ImpulseResponse);
            if numChannels > 1
                % Stereo/multi-channel impulse response
                % Use only first two channels if more than two
                plugin.pFIR_L = dsp.FrequencyDomainFIRFilter( ...
                    'Numerator', plugin.ImpulseResponse(1, :), ...
                    'PartitionForReducedLatency', true, ...
                    'PartitionLength', plugin.PartitionSize);
                plugin.pFIR_R = dsp.FrequencyDomainFIRFilter( ...
                    'Numerator', plugin.ImpulseResponse(2, :), ...
                    'PartitionForReducedLatency', true, ...
                    'PartitionLength', plugin.PartitionSize);
            else
                % Single-channel impulse response
                dspFilter = dsp.FrequencyDomainFIRFilter( ...
                    'Numerator', plugin.ImpulseResponse, ...
                    'PartitionForReducedLatency', true, ...
                    'PartitionLength', plugin.PartitionSize);
                plugin.pFIR_L = dspFilter;
                plugin.pFIR_R = dspFilter;
            end
            setup(plugin.pFIR_L, in(:, 1));
            setup(plugin.pFIR_R, in(:, 2));
        end

        % Initialize / reset discrete-state properties
        function resetImpl (plugin)
            reset(plugin.pFIR_L);
            reset(plugin.pFIR_R);
        end
        
        % Generate and load new impulse response when reverb parameters change
        function processTunedPropertiesImpl (plugin)
            propChange = isChangedProperty(plugin, 'T60') || ...
                isChangedProperty(plugin, 'ITDG') || ...
                isChangedProperty(plugin, 'EDT') || ...
                isChangedProperty(plugin, 'C80') || ...
                isChangedProperty(plugin, 'BR');
            
            if propChange
                % TODO run genetic algorithm here
            end
        end
    
        %------------------------------------------------------------------
        % Propagators
        function varargout = isOutputComplexImpl (~)
            varargout{1} = false;
        end
        
        function varargout = getOutputSizeImpl (obj)
            varargout{1} = propagatedInputSize(obj, 1);
        end
        
        function varargout = getOutputDataTypeImpl (obj)
            varargout{1} = propagatedInputDataType(obj, 1);
        end
        
        function varargout = isOutputFixedSizeImpl (obj)
            varargout{1} = propagatedInputFixedSize(obj, 1);
        end
    end
end
