%% Block Randomization
% Randomizes an input vector, G, of one or more values a number of blocks.
% Each value of G will be represented by the same fraction in each block. 
% The number of blocks is the number of elements in B and the fraction of 
% distribution is the the value of each element of B, and thus it's sum
% must be 1. The distribution can vary by 1 if the number of elements of
% the same value in G cannot be distributed exactly by the given fraction.
%
% If G is a matrix, each column will be treated as its own type, and
% combinations of types (columns) will be distributed according to B.
%
% If B is a positive integer, G will be distributed into evenly between B
% number of blocks.
% If B is a vector, G will be distributed into a number of blocks
% corresponding the to the number of elements in B. The distribution of G 
% between blocks is determined by the fraction each element in B of the sum
% of B.
%
% Use:
%   [I] = rand_block(G, B)
%
% Input:
%   G : Matrix or vector of values
%   B : Number of blocks/segments. If B is a vector, the number of blocks
%   is the length of the vector, and each block will contain a fraction
%   of B./sum(B) elements of G.
%
% Output:
%   I : Index vector of same number of rows as G.
%       Each element in I correspond to the element in G of same index. The
%       value of I is the block number assigned to the corresponding 
%       element in G.
%
% Written by: Bjarke Skogstad Larsen, 2015-12-08
%             dkbsl@acarix.com
%
% Updated by: Bjarke Skogstad Larsen, 2016-01-13
%       Note: Function is now able to distribute multiple variables. For
%             this purpuse input G can be a matrix with a source variable
%             for each column. A vector input G is still supported and
%             treated as a single source variable.
%             Function is now able to distribute into different sized
%             blocks. If different sized blocks are desired, input B is a
%             vector of weights for each block. Meaning that the number of
%             elements in B will be the number of blocks.
%
% Updated by: Bjarke Skogstad Larsen, 2016-09-20
%       Note: Some code simplifications and optimizations.
%
function [I] = rand_block(G, B)
    % Make B into a distribution column vector with a sum of 1 (if not already the case)
    if isvector(B) && numel(B) > 1 && all(B>0) % B is a vector of positive values
        B = B(:)./sum(B);
    elseif numel(B)==1 && mod(B,1)==0 && B > 0 % B is a positive integer
        B = ones(B,1)./B;
    else
        error('Invalid value for B: Must either be a vector of positive values or a positive integer.');
    end
    % Convert source variables into group indices
    T = nan(size(G)); % Initialize vector of assigned numbers for source variable numbers
    uT = cell(1,size(G,2)); % Initialize cell array of unique assigned numbers for source variable values
    for ii=1:size(G,2)
        T(:,ii) = grp2idx(G(:,ii)); % Assign a number to each unique value of 
        uT{ii} = unique(T(:,ii)).'; % Find unique numbers for each source variable
    end
    % Create combinational matrix containing all possible combinations of 
    % different possible values between all source variables. Each row 
    % in M will correspond to one possible combination.
    C = combvec(uT{:}).'; % Combinational matrix
    
    % Create combinational vector: each row of T receives a number
    % corresponding to the combination of feature values for that row.
    CI = zeros(size(T,1),1); % Initialize combinational vector
    for ii=1:size(C,1) % Iterate through unique combinations
        I = logical(prod(T == repmat(C(ii,:),size(T,1),1),2)); % Find instances of unique combination
        CI(I) = ii; % Combinational index
    end
    
    % Do block randomization on combinational vector
    I = rand_block_vector(CI,B); % I contains the assigned block indices
end


%% Block Randomization of single vector
% Randomizes an input vector, T, of one or more values a number of blocks.
% Each value of T will be represented by the same fraction in each block. 
% The number of blocks is the number of elements in B and the fraction of 
% distribution is the the value of each element of B, and thus it's sum
% must be 1. The distribution can vary by 1 if the number of elements of
% the same value in T cannot be distributed exactly by the given fraction.
%
% Use:
%   [I] = rand_block(T, B)
%
% Input:
%   T : Vector of values
%       This could be a vector of subject sex, such as ['M';'F';'F';'M']
%   B : Vector of distribution fractions.
%       This could be [.5 .5] for an even distribution between two blocks.
%       Note that the sum must be 1.
%
% Output:
%   I : Index vector of same size as T.
%       Each element in I correspond to the element in T of same index. The
%       value of I is the block or segment number assigned to the
%       corresponding element in T.
%
function [I] = rand_block_vector(T, B)
    B = B(:); % Make sure B is a column vector
    uT = unique(T);
    cT = nonzeros(histcounts(T));
    %% Determine number of each type in each block
    nTxB = floor(repmat(cT,1,numel(B)).*repmat(B.',numel(uT),1)); % Initial distribution
    cXT = cT-sum(nTxB,2); % Extra number of instances remaining to be distributed for each type
    % Distribute remaining instances of each type
    [~,I] = sort(rand(size(nTxB)),2);
    for ii=1:numel(cXT)
        I2 = I(ii,1:cXT(ii));
        nTxB(ii,I2) = nTxB(ii,I2)+1;
    end
	% Notify if any block does not contain at least one instance of each type 
    if any(any(nTxB == 0))
        warning('Number instances of one or more feature combinations were less than the number of groups. Not all blocks will contain members of these combinations.');
    end
    
    %% Create randomization
    I = zeros(size(T)); % Initialize
    for ii=1:numel(uT)
        iT = find(T==uT(ii)); % Index in pool for all of this T
        nT = numel(iT); % Number of this T in pool
        [~,rT] = sort(rand(nT,1)); % Create randomized index
        i1 = 1;
        for jj=1:numel(B)
            i2 = i1+nTxB(ii,jj)-1;
            I(iT(rT(i1:i2))) = jj; % Set block number
            i1 = i2+1;
        end
    end
end