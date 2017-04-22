function [ mondrians, window ] = makeMondrianTexes( window )
%makeMondrians create mask of mondrians
%   Contrast values will be adjusted during the presentation of the mask

% mondrian vars
totalFrame = 450; % Frame length of the total frame (size of Mondrians)

% Maximum and minimum length of suppressor rects
maxL = 60; 
minL = 15;
nSquares = 1000; % number of squares to draw
nSlides = 50; % limit number of mondrians made to this value

% intensity values of squares in mondrian
% generate as many mondrians with average intensity that changes for each
% second, meaning mondrianHertz per each slide.
% intensities = NaN(nSquares, nSlides);
% first = 1:expParams.mondrianHertz:nSlides-expParams.mondrianHertz+1;
% last = expParams.mondrianHertz:expParams.mondrianHertz:nSlides;
% i = 0;
% for mu = linspace(.6,.01,nSlides/10)
%     i = i + 1;
%     intensities(:,first(i):last(i)) = truncnormrnd([nSquares,expParams.mondrianHertz],mu,.1,0,1);
% end

intensities = truncnormrnd([nSquares,nSlides],.5,10,0,1);

% positions of squares in mondrian
positions(1,:,:) = randi([-maxL,totalFrame],[1, nSquares, nSlides]);
positions(2,:,:) = randi([-maxL,totalFrame],[1, nSquares, nSlides]);
positions(3,:,:) = min(positions(1,:,:) + repmat(minL,[1,nSquares,nSlides]) +...
    randi(maxL-minL,[1,nSquares,nSlides]),totalFrame);
positions(4,:,:) = min(positions(2,:,:) + repmat(minL,[1,nSquares,nSlides]) +...
    randi(maxL-minL,[1,nSquares,nSlides]),totalFrame);

% shift mondrians to center of screen
window.shifts = CenterRect([0 0 totalFrame-maxL totalFrame-maxL], Screen('Rect',window.pointer));
shifts2 = repmat([window.shifts(1:2)';window.shifts(1:2)'],[1,nSquares,nSlides]);
positions = positions + shifts2;

mondrians(1:nSlides) = struct('tex',NaN([window.res.width, window.res.height]));
for slide=1:nSlides
    
    mondrians(slide).tex = Screen('OpenOffScreenWindow', window.screenNumber, ...
        window.bgColor);
    
    Screen('FillRect', mondrians(slide).tex, repmat(intensities(:,slide)',[3,1]), squeeze(positions(:,:,slide)));
    %         Screen('FillRect', mondrians(slide).tex, intensities(:,slide)', squeeze(positions(:,:,slide)));
    
end

end

