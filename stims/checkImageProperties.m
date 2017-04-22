% function checkImageProperties( nStims, stylePart, widthPart, heightPart )
%UNTITLED2 Summary of this function goes here
%   nStims: number of stims to search through (for picture objects, 220)
%   styleBase: name of whole stim and extension(object1.jpg, scene4.jpeg, objectInScene...)
%   stylePart: name of whole stim and extension(_part.jpg, _part.jpeg...)

% first, make sure tha tall parts are here an of a proper size
widthPart=600;
heightPart=600;

fix=0;
for i=1:200
    index = num2str(i);
    %     stimFile = [pwd '\apertures\object', index, '*_ap1.png'];
    stimFile = dir([ cd, '\apertures\', 'object', index, '_paired*_ap1.png']);
    width = widthPart;
    height = heightPart;
    
    %     testExistence = ~exist(stimFile, 'file');
    %     testExistence = ~exist([pwd '\apertures\' stimFile.name], 'file');
    testExistence = sum(size(stimFile)) ~= 2;
    if testExistence    % if the stimulus doesn't exist
        err='IMPENDING err: %s does not exist. Check extension';
        fprintf(err, stimFile.name)
        fix=fix+1
        index
        
    elseif ~testExistence   %For when the stimulus does exist...
        info = imfinfo([pwd, '\apertures\', stimFile.name]);
        
        colorCheck = strdist(info.ColorType, 'grayscale');
        if colorCheck
            err='IMPENDING err: %s has incorrect color format';
            fprintf(err, stimFile);
            fix=fix+1
            index
        end
        
        testWidth = ~(info.Width==width);
        if testWidth
            err='IMPENDING err: $s has width %d, but should be %d.\n';
            fprintf(err, stimFile, info.Width, width)
            fix=fix+1
            index
        end
        
        testHeight = ~(info.Height==height);
        if testHeight
            err='IMPENDING err: %s has height %d, but should be %d.\n';
            fprintf(err, stimFile, info.Height, height)
            fix=fix+1
            index
        end
    end
    
    
    
end
fprintf('files left to fix: %d \n', fix)


% if fix == 0
%     %% now, adjust images
%
%     % find sets of possible aperture centers
%     radius = 80;
%     apArea = 2*pi*radius^2;
%
%
%     % collect all images in
%     stim = 1:nStims;
%     trials = struct('stim', num2cell(stim));
%
%     % gather all of the images in one huge collection of cells (images)
%     [images, ~, transperancy] = ...
%         arrayfun(@(x) ...
%         imread( [pwd, '/object', num2str(x.stim), '_1'], 'jpg'), trials, 'UniformOutput', 0);
%
%     % take out each color channel
%     rS = cellfun(@(x) x(:,:,1),images,'UniformOutput',false);
%     gS = cellfun(@(x) x(:,:,2),images,'UniformOutput',false);
%     bS = cellfun(@(x) x(:,:,3),images,'UniformOutput',false);
%
%
%
%
%     %     tooMuchGrey = ones(1,nStims);
%     %     while any(tooMuchGrey)
%     %         % define random centers (far enough from edges to allow a full
%     %         % aperture
%     %         centers = randi([radius,widthPart-radius],2,nStims);
%     %
%     %         idxCell = num2cell(centers',1);
%     %         linIdxMat = sub2ind(size(zeros(600,600)),idxCell{:});
%     %
%     %         testR = zeros(1,nStims);
%     %         testG = zeros(1,nStims);
%     %         testB = zeros(1,nStims);
%     %         for img = 1:nStims
%     %             testR(img) = rS{img}(linIdxMat(img));
%     %             testG(img) = gS{img}(linIdxMat(img));
%     %             testB(img) = bS{img}(linIdxMat(img));
%     %
%     %             if testR(img)==161 && testG(img)==161 && testB(img)==161
%     %                 tooMuchGrey(img)=1;
%     %                 break
%     %                 % test for radius above
%     %             elseif rS{img}(linIdxMat(img)-80)==161 ...
%     %                     && gS{img}(linIdxMat(img)-80)==161 ...
%     %                     && bS{img}(linIdxMat(img)-80)==161
%     %                 tooMuchGrey(img)=1;
%     %                 break
%     %                 % test for radius below
%     %             elseif rS{img}(linIdxMat(img)+80)==161 ...
%     %                     && gS{img}(linIdxMat(img)+80)==161 ...
%     %                     && bS{img}(linIdxMat(img)+80)==161
%     %                 tooMuchGrey(img)=1;
%     %                 break
%     %             end
%     %         end
%     %
%     %     end % end of while too much grey
%
%     % convert images to greyscale
%     imgs_grey = cellfun(@rgb2gray, images, 'UniformOutput', 0);
%     [W,H]=meshgrid(1:600,1:600);
%
%     for attempt = 1:20
%
%         tryAgain = 1;
%         imIdx = 0;
%         while tryAgain
%
%             images = imgs_grey;
%
%             centers = randi([radius,widthPart-radius],2,nStims);
%             idxCell = num2cell(centers',1);
%             linIdxMat = sub2ind(size(zeros(600,600)),idxCell{:});
%
%             cells = num2cell(linIdxMat);
%
%             %          [i,j] = cellfun(@(x) ind2sub(size(zeros(600,600)),x), cells,'UniformOutput',0  );
%
%             %          masks = cellfun(@(x,y) sqrt((W-i{x}).^2 + (H-j{y}).^2) < radius, i,j, 'UniformOutput',0);
%
%             while imIdx < nStims
%                 imIdx = imIdx + 1;
%                 [i,j] = ind2sub([600,600],cells{imIdx});
%                 mask = sqrt((W-i).^2 + (H-j).^2) < radius;
%                 images{imIdx}(~mask)=162;
%
%                 allGrey = sum(sum(imgs_grey{imIdx}==161));
%                 ratioGrey = allGrey/(600^2);
%
% %                 if ratioGrey > .7
% %                    ratioGrey = .7;
% %                 else
%                     ratioGrey(ratioGrey > .45) = .45;
% %                 end
%
%
%                 if sum(sum(images{imIdx}==161))/apArea > ratioGrey;
%                     tryAgain = 1;
%                     imIdx = imIdx-1;
%                     break;
%                 end
%
%                 imwrite(images{imIdx},['newAperturesFuller/object',num2str(imIdx),'_aperture', num2str(attempt),'.png']);
%                 if imIdx == nStims
%                     tryAgain = 0;
%
%                 end
%
%             end
%
%         end
%
%     end
%
%
%
% end
%
%
% im = imread('newAperturesFuller/object1_aperture1.png');
% imshow(im)
%
% new=image(im);
%
% alphaMask = ones(size(im));
% alphaMask(im==161)=0;
%
% new.AlphaData = alphaMask;
%
% im.AlphaData


