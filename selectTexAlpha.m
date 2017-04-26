function alpha_tex = selectTexAlpha(alphas, tick)

if isempty(alphas)
   alpha_tex = 0;
else 
   alpha_tex = alphas(min(length(alphas), tick)); 
end

end