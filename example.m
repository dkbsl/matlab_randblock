load fisheriris
tbl = table(species,nan(numel(species),1),meas,'VariableNames',{'Species','Block','Measurement'});

% Randomize observations of the fish into two equal sized blocks, stratifying for species (same number of each species into each of the two blocks)
tbl.Block = rand_block(species,2); 
groupsummary(tbl,{'Block','Species'})

% As above but with 80% of observations going to first block, and 20% going to the second.
tbl.Block = rand_block(species,[.8 .2]); 
groupsummary(tbl,{'Block','Species'})

% As above but with 60% of observations going to first block, 20% going
% to the second, and 20% going to the third
tbl.Block = rand_block(species,[.6 .2 .2]); 
groupsummary(tbl,{'Block','Species'})


%%
clear,clc
load carsmall

% Example of multiple categories for more one stratification variable. The
% function will distribute the combination of all stratification variables
% according to the selected distribution between blocks (in this case
% evenly between 2 blocks).
tbl = table(Cylinders,Model_Year,nan(numel(Cylinders),1),'VariableNames',{'Cylinders','ModelYear','Block'});
tbl.Block = rand_block([Cylinders Model_Year],[.5 .5]); % Note that giving the input [.5 .5] yields the same results as giving the input [2]
groupsummary(tbl,{'Block','Cylinders','ModelYear'})

% As above... but this will sometimes generate a warning because a
% stratification-combination was not attained for all blocks. The function
% seeks to attain the balanced distribution between the blocks as given by
% the second input (B). However, this is not always possible.
tbl = table(Cylinders,Model_Year,nan(numel(Cylinders),1),'VariableNames',{'Cylinders','ModelYear','Block'});
tbl.Block = rand_block([Cylinders Model_Year],[.8 .2]); 
groupsummary(tbl,{'Block','Cylinders','ModelYear'})
