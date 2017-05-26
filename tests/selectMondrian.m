function whichMondrian = selectMondrian(nMondrians, varargin)

whichMondrian = randsample(1:nMondrians,1);
if nargin == 2
    while varargin{1} == whichMondrian
        whichMondrian = randsample(1:nMondrians,1);
    end
end
end
