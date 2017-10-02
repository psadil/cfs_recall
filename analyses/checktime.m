

files = dir('data/**/*CFSgonogo_constants.mat');

for f = 1:36
   c(f) = load(fullfile(files(f).folder, files(f).name));
end

t = arrayfun(@(x) x.constants.exp_end - x.constants.exp_start, c, 'UniformOutput',false);
t = cell2mat(t) ./ 60;

[min(t), max(t)]
