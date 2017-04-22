function finalStruct = filterStructs(a,b)
    % merges the two structs into one
    % values in struct b get removed from the final result in the event of field name collision
    M = [fieldnames(a)' fieldnames(b)'; struct2cell(a)' struct2cell(b)'];     
    [~, rows] = unique(M(1,:), 'first');
    M=M(:, rows);
    finalStruct=struct(M{:});
end
