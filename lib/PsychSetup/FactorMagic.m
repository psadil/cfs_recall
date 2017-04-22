function [factor_mat, rand_mat] = FactorMagic(varargin)
ip = inputParser;
addRequired(ip,'nTrials', @isnumeric);
addParamValue(ip,'factors', {struct()}, @(x) iscell(x) && all(cellfun(@isstruct,x)));
addParamValue(ip,'nFactors',@isnumeric);
parse(ip,varargin{:}); 
nTrials = ip.Results.nTrials;
factors = ip.Results.factors;
nFactors = ip.Results.nFactors; %#ok<NASGU>

nesteds = cellfun( @(x) any(strcmp('nested', fieldnames(x))), factors,'Unif',false);
deltas =diff([nesteds{:}]);

if any(deltas >0) && sum(deltas) ==1
    overcount = length(deltas)- find(deltas==1);
elseif any(deltas ~=0) && sum(deltas) ~= 1 
    overcount = sum(abs(find(deltas==1) - find(deltas == -1) -1));
elseif all(deltas ==0)
    overcount = 0;
end

nFactors = numel(factors) - overcount;
factor_mat = cell(nTrials,nFactors);
rand_mat = zeros(nTrials,nFactors);
col_is_numeric=false(1,size(factor_mat,2));

for i=1:numel(factors)
    f = factors{i};
    n = length(f.levels);

    if all(cellfun(@isnumeric,f.levels))
        col_is_numeric(i) = true;
    end

    if ~strcmp('weights',fieldnames(f))
        f.weights=repmat(1/n,1,n);
        factors{i}.weights=repmat(1/n,1,n);
    end

    if i == 1 && ~any(strcmp('nested',fieldnames(f)))
        wghts=f.weights; %#ok<*AGROW>
    elseif i > 1 && ~any(strcmp('nested',fieldnames(f)))
        what = cellfun(@(x) x.weights,factors(1:i),'Unif',false); % get the actual weights out of the cell array of structs
        tmp_wghts = CombVec(what{end:-1:1}); % get all the possible combinations       
        cols = prod(cellfun(@(x) numel(x.levels), factors(1:i-1))); % gets the right number of columns for the weight matrix
        wghts = reshape(prod(tmp_wghts,1), [ cols, i]);
    elseif i > 1 && any(strcmp('nested',fieldnames(f)))
        a = cellfun(@(x) x.levels,factors(1:i-1),'Unif',false); % a is all the possible levels 
        c = cellfun(@(x) any(strcmp('nested',fieldnames(x))), factors(1:i-1),'Unif',false); % use c to ignore any previously nested factors
        b = cellfun(@(x) any(strcmp(f.nested{:},x)), a,'Unif',0); % b tells you which struct to get the weights out, based on which factor has the nesting level
        what = cellfun(@(x) x.weights,factors(1:i),'Unif',false);
        nest_wghts = factors{[b{:}]}.weights;
        nest_wghts = nest_wghts(strcmp(f.nested{:},factors{[b{:}]}.levels));
        tmp_wghts = CombVec(f.weights, nest_wghts, what{1:find([b{:}])-1});
        cols = prod(cellfun(@(x) numel(x.levels), factors([c{:}]==[b{:}])));% gets the right number of columns for the weight matrix
        wghts = reshape(prod(tmp_wghts,1), cols,[]);
    end
    w = nTrials*reshape(wghts,numel(wghts),1);
    if any(strcmp('nested',fieldnames(f)))
        within = f.nested{:};
        fill_col =find([b{:}])+1;
        if isnumeric(within)
            places = find([factor_mat{col_is_numeric}] == within);
        elseif ischar(within)
            places = find(strcmp(factor_mat(:,~col_is_numeric(1:i-1)),within));
        end
        fill(w,places,f,fill_col);
    else
        places = 1:length(factor_mat);
        fill_col =i;
    end
    fill(w,places,f,fill_col);
    if any(strcmp('shuffle',fieldnames(f))) && strcmp(f.shuffle, 'parent')
        nLevels=length(factors{i-1}.levels);
        l = ceil(sum(w)/nLevels);
        for j = 1:nLevels; % number of levels in previous factor
            tmp = (1:l)+(l*(j-1));
            rand_mat(tmp,i) = tmp(randperm(l));
        end
    elseif any(strcmp('shuffle',fieldnames(f))) && strcmp(f.shuffle, 'within')
        nLevels=length(f.levels);
        l = ceil(sum(w)/nLevels);
        for j = 1:nLevels; % number of levels in previous factor
            tmp = (1:l)+(l*(j-1));
            rand_mat(tmp,i) = tmp(randperm(l));
        end
    elseif any(strcmp('shuffle',fieldnames(f))) && strcmp(f.shuffle, 'full')
        order = 1:nTrials;
        order = order(randperm(nTrials));
        rand_mat(:,fill_col) = rand_mat(order,fill_col);
    elseif any(strcmp('nested',fieldnames(f))) && any(strcmp('shuffle',fieldnames(factors{fill_col-1}))) 
        match = strcmp(f.nested,factor_mat(:,fill_col-1));
        rand_mat(match,fill_col) = rand_mat(match,fill_col-1);
    else
        rand_mat(:,fill_col) = 1:length(rand_mat);
    end
end


    function  fill(w,places,f,fill_col)
        levels = repmat(f.levels',numel(w)/numel(f.levels),1);
        start =1;
        for x=1:length(levels)
            nReps = ceil(w(x));
            stop = start+nReps - 1 ;
            fill_data = repmat(levels(x),nReps,1);
            factor_mat(places(start):places(stop),fill_col) = fill_data;
            start =  stop+1;
        end
    end
end
