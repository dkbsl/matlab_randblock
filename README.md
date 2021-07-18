# Stratified Block Randomization
This matlab function performs stratified block randomization.
Example of use: distributing observations into training and test datasets.

Any number of blocks can be chosen, and each block can be given a different portion of observations.
Observations are stratified by any number of variables and categories. The function will seek to randomly assign observations to each block (with the set portion) for each stratification-combination. For example, the same number of Male/Female subjects in each block.
If multiple stratification variables are given, the combination of these will be distributed between the blocks. For example, gender (male/female) and diagnosis (healthy/sick). In this case, observations will be distributed between blocks for male-healthy, female-healthy, male-sick, and female-sick.