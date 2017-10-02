function makeApertures(varargin)

ip = inputParser;
%#ok<*NVREPL> dont warn about addParamValue
addParamValue(ip,'smoothEdges', true, @islogical);
parse(ip,varargin{:});
input = ip.Results;


root = pwd;

wholesDir = fullfile(root,'whole');
apertureDir = fullfile(root,'apertures');
newApertureDir = fullfile(root,'apertures_new');

if ~exist(newApertureDir, 'dir')
   mkdir(newApertureDir); 
end

pairs = readtable('stimPairings.csv');

% nObjs = size(pairs,1);

apertures1 = arrayfun(@(x)...
    dir(fullfile(apertureDir,['object', num2str(x),'_*','ap1','.png'])),...
    pairs.pair1, 'UniformOutput',false);

[~, ~, alpha1] = cellfun(@(x) imread(fullfile(apertureDir,x.name)), apertures1, 'UniformOutput',false);
% ap1 = cellfun(@(x) imread(fullfile(apertureDir,x.name)), apertures1, 'UniformOutput',false);

[alpha1_centers, ~, ~] = cellfun(@(x) imfindcircles(x,[79,81],'Sensitivity',1,...
    'Method','TwoStage'), alpha1, 'UniformOutput',false);

alpha1_centers = cleanCenters(alpha1_centers);

baseAlpha = uint8(zeros(600,600));

newAlpha = cellfun(@(x) rgb2gray(insertShape(baseAlpha,'FilledCircle',[x(1,:),79],...
    'Opacity',1,'Color',repelem(255,3),'SmoothEdges',input.smoothEdges)),...
    alpha1_centers, 'UniformOutput',false);

wholesFile = arrayfun(@(x)...
    dir(fullfile(wholesDir,['object', num2str(x),'_*','.png'])),...
    pairs.pair1, 'UniformOutput',false);
[wholes_img, ~, wholes_alpha] = cellfun(@(x) imread(fullfile(wholesDir,x.name)), wholesFile, 'UniformOutput',false);

for i = 1:length(wholes_img)
    wholes_img{i}(wholes_img{i}==0) = 1;
%     wholes_img{i}(alpha1{i}==0) = 0;
    wholes_img{i}(newAlpha{i}~=0 & wholes_alpha{i}==0) = ceil(255 * .5);    
end

% alpha_out = cellfun(@(x,y) x.*y, wholes_alpha, newAlpha, 'UniformOutput', false);
alpha_out = newAlpha;

cellfun(@(x,y,z) imwrite(x,fullfile(newApertureDir,y.name), 'Alpha', z), ...
    wholes_img, apertures1, alpha_out, 'UniformOutput', false);
end


function centers = cleanCenters(centers)


centersToClean = [8, 22, 30, 130,140,202];
with = [9,15,12,15,2,4];

for c = 1:length(centersToClean)
    centers{centersToClean(c)}(1,:) = centers{centersToClean(c)}(with(c),:);
end

% imshow(alpha1{centersToClean(6)})
% arrayfun(@(x) viscircles(alpha1_centers{centersToClean(6)}(x,:),80), 1, 'UniformOutput',false)

end
