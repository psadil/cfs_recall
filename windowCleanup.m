function windowCleanup(constants)
% receives structures of values relating to experiment and saves them all.
% constants must be defined so that it is known where to save the variables

rmpath(constants.lib_dir, constants.root_dir);

% return refresh rate
% window.res = Screen('Resolution',max(Screen('Screens')),[],[],60); 
ListenChar(0);
% Screen('ColorRange', p.window, 255);
Priority(0);
sca; % alias for screen('CloseAll')
end
