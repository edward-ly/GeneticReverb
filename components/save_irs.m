function save_irs(plugin, sampleRate)
% SAVE_IRS Save current impulse responses in plugin to file
%
% Input arguments:
% plugin = plugin object containing IRs and IR properties
% sampleRate = sample rate of plugin
%
    % Require all arguments
    if nargin < 2, error('Not enough input arguments.'); end

    irData = horzcat( ...
        plugin.pFIRFilterLeft.Numerator', ...
        plugin.pFIRFilterRight.Numerator');

    % Save IR parameter values and random ID number to file name
    numChannels = '1ch';
    if plugin.STEREO, numChannels = '2ch'; end
    id = randi([intmin('uint32'), intmax('uint32')], 'uint32');

    irFileName = ['ir_' ...
        'T' sprintf('%.3f', plugin.T60)    '_' ...
        'E' sprintf('%.3f', plugin.EDT)    '_' ...
        'I' sprintf('%.3f', plugin.ITDG)   '_' ...
        'C' sprintf('%.3f', plugin.C80)    '_' ...
        'W' sprintf('%.3f', plugin.WARMTH) '_' ...
        numChannels '_' ...
        sprintf('%.0f', sampleRate) 'Hz_' ...
        sprintf('%010u', id) '.bin'];

    % Write to binary file ('audiowrite' function currently not
    % supported for code generation)
    fileID = fopen(irFileName, 'w');
    fwrite(fileID, irData, 'double');
    fclose(fileID);

    % audiowrite(irFileName, irData, sampleRate);
end
