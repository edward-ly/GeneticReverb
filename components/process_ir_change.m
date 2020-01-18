function process_ir_change(plugin, sampleRate)
% PROCESS_IR_CHANGE Handles plugin process for generating new IRs
%
% Input arguments:
% plugin = plugin object containing IR properties
% sampleRate = sample rate of plugin
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end

    % =========================================================================

    % Calculate number of samples needed for impulse response
    % (before and after resampling)
    plugin.IR_NUM_SAMPLES = ceil( ...
        1.5 * plugin.T60 * plugin.IR_SAMPLE_RATE);
    plugin.NUM_SAMPLES = ceil( ...
        plugin.IR_NUM_SAMPLES * sampleRate / plugin.IR_SAMPLE_RATE);

    % Determine filter with smallest possible buffer length
    filterIndex = ceil(log2(plugin.NUM_SAMPLES / 22500));
    if filterIndex < 0, filterIndex = 0; end

    % Extend NUM_SAMPLES to length of an entire buffer
    plugin.NUM_SAMPLES = 22500 * 2 ^ filterIndex;

    % Generate new impulse responses
    [irLeft, irRight] = generate_rirs(plugin, sampleRate);

    % Assign new IRs to appropriate filters
    if plugin.NUM_SAMPLES == 22500
        plugin.pFIRFilterLeft22500.Numerator = irLeft(1:22500);
        plugin.pFIRFilterRight22500.Numerator = irRight(1:22500);
    elseif plugin.NUM_SAMPLES == 45000
        plugin.pFIRFilterLeft45000.Numerator = irLeft(1:45000);
        plugin.pFIRFilterRight45000.Numerator = irRight(1:45000);
    elseif plugin.NUM_SAMPLES == 90000
        plugin.pFIRFilterLeft90000.Numerator = irLeft(1:90000);
        plugin.pFIRFilterRight90000.Numerator = irRight(1:90000);
    elseif plugin.NUM_SAMPLES == 180000
        plugin.pFIRFilterLeft180000.Numerator = irLeft(1:180000);
        plugin.pFIRFilterRight180000.Numerator = irRight(1:180000);
    elseif plugin.NUM_SAMPLES == 360000
        plugin.pFIRFilterLeft360000.Numerator = irLeft(1:360000);
        plugin.pFIRFilterRight360000.Numerator = irRight(1:360000);
    elseif plugin.NUM_SAMPLES == 720000
        plugin.pFIRFilterLeft720000.Numerator = irLeft(1:720000);
        plugin.pFIRFilterRight720000.Numerator = irRight(1:720000);
    elseif plugin.NUM_SAMPLES == 1440000
        plugin.pFIRFilterLeft1440000.Numerator = irLeft(1:1440000);
        plugin.pFIRFilterRight1440000.Numerator = ...
            irRight(1:1440000);
    elseif plugin.NUM_SAMPLES == 2880000
        plugin.pFIRFilterLeft2880000.Numerator = irLeft(1:2880000);
        plugin.pFIRFilterRight2880000.Numerator = ...
            irRight(1:2880000);
    end
end

