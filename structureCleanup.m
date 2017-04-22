function structureCleanup(constants, varargin)
% receives structures of values relating to experiment and saves them all.
% constants must be defined so that it is known where to save the variables

constants.exp_end = GetSecs;

% save every list that has been given to windowCleanup
for nin = 1:nargin
    save([constants.fName,inputname(nin),'.mat'],varargin{nin});
end

end
