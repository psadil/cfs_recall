function window = setupWindow(constants)

window.screenNumber = max(Screen('Screens')); % Choose a monitor to display on
window.res = Screen('Resolution',window.screenNumber,[],[],120); % get screen resolution, set refresh rate

checkRefreshRate(120, 120, constants);

try
    %     Screen('Preference', 'ConserveVRAM', 4096);

    
    PsychImaging('PrepareConfiguration');
    %     PsychImaging('AddTask', 'LeftView', 'StereoCrosstalkReduction', 'SubtractOther', .6);
    %     PsychImaging('AddTask', 'RightView', 'StereoCrosstalkReduction', 'SubtractOther', .6);

    PsychImaging('AddTask','General','UseFastOffScreenWindows');
    window.bgColor = GrayIndex(window.screenNumber);
    window.white = WhiteIndex(window.screenNumber);
    [window.pointer, window.winRect] = PsychImaging('OpenWindow',...
        window.screenNumber, window.bgColor, [], [], [], 1);
    Screen('BlendFunction', window.pointer, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    topPriorityLevel = MaxPriority(window.pointer);
    Priority(topPriorityLevel);
    
    
    % define some landmark locations to be used throughout
    [window.xCenter, window.yCenter] = RectCenter(window.winRect);
    window.center = [window.xCenter, window.yCenter];
    window.left_half=[window.winRect(1),window.winRect(2),window.winRect(3)/2,window.winRect(4)];
    window.right_half=[window.winRect(3)/2,window.winRect(2),window.winRect(3),window.winRect(4)];
    window.top_half=[window.winRect(1),window.winRect(2),window.winRect(3),window.winRect(4)/2];
    window.bottom_half=[window.winRect(1),window.winRect(4)/2,window.winRect(3),window.winRect(4)];
    window.imagePlace = CenterRect([0 0 300 300], Screen('Rect',window.pointer));
    fixCrossDimPix = 10;
    fixXCoords = [-fixCrossDimPix, fixCrossDimPix, 0, 0];
    fixYCoords = [0, 0, -fixCrossDimPix, fixCrossDimPix];
    window.fixCrossCoords = [fixXCoords; fixYCoords];
    
    [xc, yc] = RectCenter(window.imagePlace);
    window.noiseTexesRect = ScaleRect(window.imagePlace, 2, 2);
    window.noiseTexesRect = CenterRectOnPoint(window.noiseTexesRect,xc,yc);

    
    
    % Get some the inter-frame interval, refresh rate, and the size of our window
    window.ifi = Screen('GetFlipInterval', window.pointer);
    window.hertz = FrameRate(window.pointer); % hertz = 1 / ifi
    [window.width, window.height] = Screen('DisplaySize', window.screenNumber); %in mm CAUTION, MIGHT BE WRONG!!
    
    
    % Font Configuration
    Screen('TextFont',window.pointer, 'Arial');  % Set font to Arial
    Screen('TextSize',window.pointer, 28);       % Set font size to 28
    Screen('TextStyle', window.pointer, 1);      % 1 = bold font
    Screen('TextColor', window.pointer, [0 0 0]); % Black text
catch
    psychrethrow(psychlasterror);
    windowCleanup(constants)
end
end

function checkRefreshRate(trueHertz, requestedHertz, constants)

if abs(trueHertz - requestedHertz) > 2
    windowCleanup(constants);
    disp('Set the refresh rate to the requested rate')
end

end
