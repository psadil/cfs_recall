'%!in%' <- function(x,y)!('%in%'(x,y))


findMatches <- function(d, cutoff=3){
  
  # distance of this response from each other potential target (all rows, all elements)
  
  distsOfAllTargets <- map(d$response_cue, .f=function(x) map(d$targets, .f=function(y) stringdist(x, y, method="dl")))
  
  # index of minimum distance from each potential target
  indsOfCloseEnoughTargets <- at_depth(distsOfAllTargets,.depth=2, min) %>%
    map_int(., .f=function(x) ifelse(min(as_vector(x))<cutoff,
                                     which.min(as_vector(x)),
                                     NA_integer_)) %>%
    as_vector(.)
  return(indsOfCloseEnoughTargets)
}


countSwaps <- function(d, condition){
  sapply(X=d$potentialMatches, FUN=function(x) d[x, ]$condition==condition) %>%
    unlist(.) %>% 
    sum(.)
}

listSwapConds <- function(d){
  
  sapply(X=d$potentialMatches, FUN=function(x) d[x, ]$condition) %>%
    unlist(.)
}

nSwaps <- function(d,condition){
  map_int(d$condOfSwaps, .f=function(y)
    sum(equals(y,condition))
  ) %>%
    as_vector(.)
}



