function [fileCreated, newFileName] = bin_to_wav(filePath, fileName)
% BIN_TO_WAV Creates a WAV file from the input BIN file generated by the plugin.
%
% Input arguments:
% filePath = directory containing binary file (with filesep character appended)
% fileName = name of binary file
%
% Output arguments:
% fileCreated = true if a new WAV file was created, otherwise false (optional)
% newFileName = name of generated WAV file (optional)
%
    % Require input arguments
    if nargin < 2, error('Not enough input arguments.'); end

    % If WAV file already exists, do nothing
    newFileName = replace(fileName, '.bin', '.wav');
    if isfile([filePath newFileName]), fileCreated = false; return; end

    % Open and read current binary file
    binID = fopen([filePath fileName]);
    if binID == -1, error('Unable to open file \"%s%s\".'); end
    ir = fread(binID, 'double');
    ir = reshape(ir, [], 2); % reshape into 2 columns (channels)
    fclose(binID);

    % Get sample rate from filename
    fileNameParams = split(fileName, '_');
    sampleRate = fileNameParams(contains(fileNameParams, 'Hz'));
    if isempty(sampleRate), error('Unable to retrieve sample rate.'); end
    sampleRate = double(erase(string(sampleRate), 'Hz'));

    % Write IR to audio file
    audiowrite([filePath newFileName], ir, sampleRate);
    fileCreated = true;
end
