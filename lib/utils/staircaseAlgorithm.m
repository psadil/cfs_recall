function stParams  = staircaseAlgorithm( y, stParams )
% Purpose:
%   Implements a staircase algorithm for determining a log contrast value 
%   within a desired stable window using a set number of intervals.
% Arguments:
%   y          - An observed RT value
%   stParams   - struct including the following:
%     x_cur      - The current alpha (opacity) value
%     x_change   - The amount to increment the log alpha value up or down
%     interval   - A vector of size N_width containing the previous
%                  RTs
%     stable_win - The lower and upper boundaries of the stable window
%     cnt        - The current count, which resets once N_width trials 
%                  occur
% Returns:
%   The updated alpha value and the updated count

% Set window for moving average
stParams.N_width = size( stParams.interval, 2 );
stParams.interval( 1:(stParams.N_width-1) ) = stParams.interval( 2:stParams.N_width );
stParams.interval( stParams.N_width ) = y;

x_change = stParams.x_change(stParams.inc);

% est_ac = 0; 
if stParams.count == stParams.N_width
    
    est_ac = mean( stParams.interval );
    
    if est_ac < min(stParams.stable_win)
        stParams.x_cur = stParams.x_cur + x_change;
    end
    
    if est_ac > max(stParams.stable_win)
        stParams.x_cur = stParams.x_cur - x_change;
    end
    
    stParams.count = 1; % Reset index
else
    stParams.count = stParams.count + 1; % Increment index
end


if stParams.count == 1
    stParams.inc = stParams.inc + 1;
end

end

