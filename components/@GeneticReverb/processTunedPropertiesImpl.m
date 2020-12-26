function processTunedPropertiesImpl(plugin)
% PROCESSTUNEDPROPERTIESIMPL Function to handle changes to plugin parameters
% Requires plugin object as input argument
%
  % Detect change in "toggle to save" parameter
  propChangeSave = isChangedProperty(plugin, 'SAVE_IR');

  % Detect change in "toggle to generate IRs" parameter
  propChangeIR = isChangedProperty(plugin, 'NEW_IR');

  % Save current impulse responses to file
  if propChangeSave, save_irs(plugin); end

  % Generate new impulse responses
  if propChangeIR, process_ir_change(plugin); end
end
