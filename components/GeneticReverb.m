% Class file for a VST 2 plugin that performs IR-based reverb in real-time
% via frequency-domain partitioned convolution, while adding the ability to
% shape the impulse response using a genetic algorithm, as well as control the
% dry/wet mix and gain of the output signal.
%
% File: GeneticReverb.m
% Author: Edward Ly (m5222120@u-aizu.ac.jp)
% Version: 1.3.0
% Last Updated: 12 August 2019
%
% Usage: validate and generate the VST plugin, respectively, with:
%     validateAudioPlugin GeneticReverb
%     generateAudioPlugin GeneticReverb
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

classdef (StrictDefaults) GeneticReverb < audioPlugin & matlab.System
    properties
        % Public variables
        T60 = 0.5;        % Total reverberation time
        ITDG = 0;         % Initial time delay gap
        EDT = 0.1;        % Early decay time (T10)
        C80 = 0;          % Clarity
        BR = 1;           % Bass Ratio
        LGAIN = 0;        % Output gain (left channel)
        RGAIN = 0;        % Output gain (right channel)
        MIX = 100;        % Dry/Wet Mix
        STEREO = true;    % Enable stereo effect
        RESAMPLE = true;  % Enable resampling of IR to match audio
    end
    
    properties (Constant)
        % Interface parameters
        PluginInterface = audioPluginInterface( ...
            'InputChannels', 2, ...
            'OutputChannels', 2, ...
            'PluginName', 'Genetic Reverb', ... % 'Out Of The Box'
            audioPluginParameter('T60', ...
                'DisplayName', 'Decay Time', ...
                'Label', 's', ...
                'Mapping', {'log', 0.25, 1}), ...
            audioPluginParameter('ITDG', ...
                'DisplayName', 'Intimacy', ...
                'Label', 's', ...
                'Mapping', {'lin', 0, 0.2}), ...
            audioPluginParameter('EDT', ...
                'DisplayName', 'Reverberance', ...
                'Label', 's', ...
                'Mapping', {'log', 0.1, 1}), ...
            audioPluginParameter('C80', ...
                'DisplayName', 'Clarity', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -5, 5}), ...
            audioPluginParameter('BR', ...
                'DisplayName', 'Bass Ratio', ...
                'Mapping', {'log', 0.5, 2}), ...
            audioPluginParameter('LGAIN', ...
                'DisplayName', 'Left Gain', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -36, 36}), ...
            audioPluginParameter('RGAIN', ...
                'DisplayName', 'Right Gain', ...
                'Label', 'dB', ...
                'Mapping', {'lin', -36, 36}), ...
            audioPluginParameter('MIX', ...
                'DisplayName', 'Dry/Wet', ...
                'Label', '%', ...
                'Mapping', {'lin', 0, 100}), ...
            audioPluginParameter('STEREO', ...
                'DisplayName', 'Mono/Stereo', ...
                'Mapping', {'enum', 'Mono', 'Stereo'}), ...
            audioPluginParameter('RESAMPLE', ...
                'DisplayName', 'Resampling', ...
                'Mapping', {'enum', 'Off', 'On'}) ...
        )
    end
    
    properties (Nontunable)
        % Constant parameters
        IR_SAMPLE_RATE = 16000;  % Sample rate of generated IRs
        PARTITION_SIZE = 1024;   % Default partition length of filters
        BUFFER_LENGTH = 96000;   % Maximum number of samples in IR
    end
    
    properties
        % System objects for partitioned convolution of audio stream with IR
        pFIRFilterLeft
        pFIRFilterRight

        % System objects for resampling IR to audio sample rate
        pFIR22050     % 16 kHz to 22.05 kHz
        pFIR32000     % 16 kHz to 32 kHz
        pFIR44100     % 16 kHz to 44.1 kHz
        pFIR48000     % 16 kHz to 48 kHz
        pFIR88200     % 16 kHz to 88.2 kHz
        pFIR96000     % 16 kHz to 96 kHz
    end
    
    % Plugin methods for frequency-domain partitioned convolution
    methods (Access = protected)
        % Main process function
        function out = stepImpl (plugin, in)
            % Calculate next convolution step for both channels
            outL = step(plugin.pFIRFilterLeft, in(:, 1));
            outR = step(plugin.pFIRFilterRight, in(:, 2));
            out = [outL outR];
            
            % Apply dry/wet mix
            out = in .* (1 - plugin.MIX / 100) + out .* plugin.MIX ./ 100;
            
            % Apply output gain
            LGain = 10 ^ (plugin.LGAIN / 20);
            RGain = 10 ^ (plugin.RGAIN / 20);
            outLGain = out(:, 1) * LGain;
            outRGain = out(:, 2) * RGain;
            out = [outLGain outRGain];
        end

        % DSP initialization / setup
        function setupImpl (plugin, ~)
            % Initialize resampler objects:
            % 22.05/44.1/88.2 kHz sample rates are rounded to 22/44/88 kHz for
            % faster computation times
            plugin.pFIR22050 = dsp.FIRRateConverter(11, 8);
            plugin.pFIR32000 = dsp.FIRRateConverter(2, 1);
            plugin.pFIR44100 = dsp.FIRRateConverter(11, 4);
            plugin.pFIR48000 = dsp.FIRRateConverter(3, 1);
            plugin.pFIR88200 = dsp.FIRRateConverter(11, 2);
            plugin.pFIR96000 = dsp.FIRRateConverter(6, 1);

            % Initialize buffer
            numerator = zeros(1, plugin.BUFFER_LENGTH);
            
            % Initialize convolution filters
            plugin.pFIRFilterLeft = dsp.FrequencyDomainFIRFilter( ...
                'Numerator', numerator, ...
                'PartitionForReducedLatency', true, ...
                'PartitionLength', plugin.PARTITION_SIZE);
            plugin.pFIRFilterRight = dsp.FrequencyDomainFIRFilter( ...
                'Numerator', numerator, ...
                'PartitionForReducedLatency', true, ...
                'PartitionLength', plugin.PARTITION_SIZE);
        end

        % Initialize / reset discrete-state properties
        function resetImpl (plugin)
            reset(plugin.pFIRFilterLeft);
            reset(plugin.pFIRFilterRight);
            reset(plugin.pFIR22050);
            reset(plugin.pFIR32000);
            reset(plugin.pFIR44100);
            reset(plugin.pFIR48000);
            reset(plugin.pFIR88200);
            reset(plugin.pFIR96000);
        end
        
        % Generate and load new impulse response when reverb parameters change
        function processTunedPropertiesImpl (plugin)
            % Detect changes in reverb parameters
            propChange = isChangedProperty(plugin, 'T60') || ...
                isChangedProperty(plugin, 'ITDG') || ...
                isChangedProperty(plugin, 'EDT') || ...
                isChangedProperty(plugin, 'C80') || ...
                isChangedProperty(plugin, 'BR') || ...
                isChangedProperty(plugin, 'STEREO') || ...
                isChangedProperty(plugin, 'RESAMPLE');
            
            if propChange
                % Get current sample rate of plugin
                sampleRate = getSampleRate(plugin);
                
                if plugin.STEREO
                    % Generate new impulse responses
                    newIRLeft = genetic_rir( ...
                        plugin.IR_SAMPLE_RATE, plugin.T60, plugin.ITDG, ...
                        plugin.EDT, plugin.C80, plugin.BR);
                    newIRRight = genetic_rir( ...
                        plugin.IR_SAMPLE_RATE, plugin.T60, plugin.ITDG, ...
                        plugin.EDT, plugin.C80, plugin.BR);

                    % Resample/resize impulse responses
                    IRLeft = resample_ir(plugin, newIRLeft, sampleRate);
                    IRRight = resample_ir(plugin, newIRRight, sampleRate);

                    % Update convolution filters
                    plugin.pFIRFilterLeft.Numerator = IRLeft;
                    plugin.pFIRFilterRight.Numerator = IRRight;
                else
                    % Generate new impulse response
                    newIR = genetic_rir( ...
                        plugin.IR_SAMPLE_RATE, plugin.T60, plugin.ITDG, ...
                        plugin.EDT, plugin.C80, plugin.BR);

                    % Resample/resize impulse response
                    IR = resample_ir(plugin, newIR, sampleRate);

                    % Update convolution filters
                    plugin.pFIRFilterLeft.Numerator = IR;
                    plugin.pFIRFilterRight.Numerator = IR;
                end
            end
        end
    end
end
