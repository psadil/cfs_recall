function makeSampleApertures( nStims, nPixels, ...
    nApertures, radius )
% makeSampleApertures Rejection sampling method of generating circular
% apertures
%{

Place this function in same folder as object stimuli

INPUT:
  nStims: number of stims to search through (for picture objects, 220)
  nPixels: number of pixels along both dims (assumes square images)
  nApertures: number of apertures to generate
  radius: how large (in pixels) of a radius should the apertures have?

OUTPUT:
  Saves all apertures to newly generated directory: apertures

ASSUMES:
  - The name + location of the directory you will want the apertures created
  in
  - Images are of png format
  - Images are square
  - Images are in grayscale (i.e., just luminance and alpha channel)
  - A particular naming convention of all of the objects

% NOTE: 
  - Have since discovered function 'insertShape'. That function is super 
    useful in that it can add some smoothness to the edge of the circle.
    It's also super nice in that it automates the calculation of which
    pixels are inside of a given circle.


EXAMPLE CALL
  makeSampleApertures(220, 600, 2, 80)

%}

%% Directory Setup

% whole images will be searched for in here.
% apertures will be generated in subfolder of root
root = pwd;
apertureDir = fullfile(root, 'apertures');
if ~exist(apertureDir, 'dir')
    mkdir(apertureDir);
end


%% Other preliminaries

% aperture area to be used later in creating aperture mask
apArea = 2*pi*radius^2;

% collect all images
stim = 1:nStims;
trials = struct('stim', num2cell(stim));

% gather all of the images in one huge collection of cells
% you'd need to change this if your images are named in a particular way
[images_original, ~, alpha_original] = ...
    arrayfun(@(x) ...
    imread(fullfile(root, ...
    ['object', num2str(x.stim), '_noBkgrd']), 'png'), ...
    trials, 'UniformOutput', false);

[W,H] = meshgrid(1:nPixels, 1:nPixels);

for apertureSample = 1:nApertures
    
    tryAgain = 1;
    imIdx = 0;
    while tryAgain
           
        images = images_original;
        alpha = alpha_original;
        
        centers = randi([radius, nPixels-radius],2,nStims);
        idxCell = num2cell(centers',1);
        linIdxMat = sub2ind(size(zeros(nPixels,nPixels)),idxCell{:});
        
        cells = num2cell(linIdxMat);
        
        while imIdx < nStims
            imIdx = imIdx + 1;
            
            % Most of the magic happens in these next couple of lines
            [i,j] = ind2sub([nPixels,nPixels],cells{imIdx});
            
            % Generate masking circle of all images less than some radius
            % away from center
            mask = sqrt((W-i).^2 + (H-j).^2) < radius;
            
            % Set alpha channel to 0 for every pixels outside of this mask
            alpha{imIdx}(~mask) = 0;
            
            % How much of the mask is background
            allGrey = sum(alpha{imIdx}(:) < 255);
            ratioGrey = allGrey/apArea;
                          
            % If the new ratio of background to obect is awful, just try
            % again.
            if ratioGrey < sum(alpha_original{imIdx}(:) < 255)/(nPixels^2);
                tryAgain = 1;
                imIdx = imIdx-1;
                break;
            end
            
            % it ratio is fine, write out this image with new alpha
            % channel
            imwrite(images{imIdx}, ...
                fullfile(apertureDir,...
                ['object',num2str(imIdx),...
                '_aperture', num2str(apertureSample),'.png']),...
                'Alpha', alpha{imIdx});
            if imIdx == nStims
                tryAgain = 0;
            end
        end
    end
end


end