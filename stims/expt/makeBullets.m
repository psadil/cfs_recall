clearvars; close all;

root = pwd;

wholesDir = fullfile(root,'whole');
apertureDir = fullfile(root,'apertures');
bulletDir = fullfile(root,'bullets');

if ~exist(bulletDir, 'dir')
   mkdir(bulletDir); 
end

pairs = readtable('stimPairings.csv');

% nObjs = size(pairs,1);

apertures1 = arrayfun(@(x)...
    dir(fullfile(apertureDir,['object', num2str(x),'_*','ap1','.png'])),...
    pairs.pair1, 'UniformOutput',false);
apertures2 = arrayfun(@(x)...
    dir(fullfile(apertureDir,['object', num2str(x),'_*','ap2','.png'])),...
    pairs.pair1, 'UniformOutput',false);
% apertures3 = arrayfun(@(x)...
%     dir(fullfile(apertureDir,['object', num2str(x),'_*','ap3','.png'])),...
%     pairs.pair1, 'UniformOutput',false);

[~, ~, alpha1] = cellfun(@(x) imread(fullfile(apertureDir,x.name)), apertures1, 'UniformOutput',false);
[~, ~, alpha2] = cellfun(@(x) imread(fullfile(apertureDir,x.name)), apertures2, 'UniformOutput',false);
% [~, ~, alpha3] = cellfun(@(x) imread(fullfile(apertureDir,x.name)), apertures3, 'UniformOutput',false);

alpha1_inv = cellfun(@(x) uint8(x==0), alpha1, 'UniformOutput',false);
alpha2_inv = cellfun(@(x) uint8(x==0), alpha2, 'UniformOutput',false);
% alpha3_inv = cellfun(@(x) uint8(x==0), alpha3, 'UniformOutput',false);

wholesFile = arrayfun(@(x)...
    dir(fullfile(wholesDir,['object', num2str(x),'_*','.png'])),...
    pairs.pair1, 'UniformOutput',false);
[wholes_img, ~, wholes_alpha] = cellfun(@(x) imread(fullfile(wholesDir,x.name)), wholesFile, 'UniformOutput',false);

bullet = cellfun(@(x,y,z) x.*y.*z, wholes_img, alpha1_inv, alpha2_inv, 'UniformOutput', false);
% bullet1 = cellfun(@(x,y,z) x.*y.*z, wholes_img, alpha1_inv, alpha1_inv(pairs.pair2), 'UniformOutput',false);
% bullet2 = cellfun(@(x,y,z) x.*y.*z, wholes_img, alpha2_inv, alpha2_inv(pairs.pair2), 'UniformOutput',false);
% bullet3 = cellfun(@(x,y,z) x.*y.*z, wholes_img, alpha3_inv, alpha3_inv(pairs.pair2), 'UniformOutput',false);

alpha_out = cellfun(@(x,y,z) x.*y.*z, wholes_alpha, alpha1_inv, alpha2_inv, 'UniformOutput', false);
% alpha1_out = cellfun(@(x,y,z) x.*y.*z, wholes_alpha, alpha1_inv, alpha1_inv(pairs.pair2), 'UniformOutput',false);
% alpha2_out = cellfun(@(x,y,z) x.*y.*z, wholes_alpha, alpha2_inv, alpha2_inv(pairs.pair2), 'UniformOutput',false);
% alpha3_out = cellfun(@(x,y,z) x.*y.*z, wholes_alpha, alpha3_inv, alpha3_inv(pairs.pair2), 'UniformOutput',false);


cellfun(@(x,y,z) imwrite(x,fullfile(bulletDir,y.name), 'Alpha', z), ...
    bullet, apertures1, alpha_out, 'UniformOutput', false);
% cellfun(@(x,y,z) imwrite(x, fullfile(bulletDir,y.name), 'Alpha',z),...
%     bullet1, apertures1, alpha1_out,'UniformOutput',false);
% cellfun(@(x,y,z) imwrite(x, fullfile(bulletDir,y.name), 'Alpha',z),...
%     bullet2, apertures2, alpha2_out,'UniformOutput',false);
% cellfun(@(x,y,z) imwrite(x, fullfile(bulletDir,y.name), 'Alpha',z),...
%     bullet3, apertures3, alpha3_out,'UniformOutput',false);


