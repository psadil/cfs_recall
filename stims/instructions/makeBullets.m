clearvars; close all;

root = pwd;

pairs = table;
pairs.pair1 = [212; 215];
pairs.pair2 = [215; 212];

apertures1 = arrayfun(@(x)...
    dir(fullfile(root,['object', num2str(x),'_*','ap1','.png'])),...
    pairs.pair1, 'UniformOutput',false);
apertures2 = arrayfun(@(x)...
    dir(fullfile(root,['object', num2str(x),'_*','ap2','.png'])),...
    pairs.pair1, 'UniformOutput',false);

[~, ~, alpha1] = cellfun(@(x) imread(fullfile(root,x.name)), apertures1, 'UniformOutput',false);
[~, ~, alpha2] = cellfun(@(x) imread(fullfile(root,x.name)), apertures2, 'UniformOutput',false);

alpha_inv = cellfun(@(x,y) uint8(x==0).*uint8(y==0), alpha1,alpha2, 'UniformOutput',false);

wholesFile = arrayfun(@(x)...
    dir(fullfile(root,['object', num2str(x),'_noBkgrd.png'])),...
    pairs.pair1, 'UniformOutput',false);
[wholes_img, ~, wholes_alpha] = cellfun(@(x) imread(fullfile(root,x.name)), wholesFile, 'UniformOutput',false);

bullet = cellfun(@(x,y) x.*y, wholes_img, alpha_inv, 'UniformOutput',false);

alpha_out = cellfun(@(x,y) x.*y, wholes_alpha, alpha_inv, 'UniformOutput',false);

cellfun(@(x,y,z) imwrite(x, fullfile(root,[y.name,'bullet.png']), 'Alpha',z),...
    bullet, apertures, alpha_out,'UniformOutput',false);


