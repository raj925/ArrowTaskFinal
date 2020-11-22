%% Shuffle.m
% Takes a matrix of N X M and returns a matrix of the same dimensions, with
% the order of rows shuffled. 
% This keeps running until it finds a solution whereby all the rows are in
% a different position to where they were before the shuffle.

% Eg:
% The matrix 

%   1 2 3
%   4 5 6
%   7 8 9 

% The following is not a valid shuffle (since first row is unchanged):
%   1 2 3
%   7 8 9
%   4 5 6

% So this function will make sure to change all row positions.

function [shuffled] = shuffle(matrix)
    rows = size(matrix,1);
    shuffled = [];
    rowCheck = 0;
    shuffle = [];
    while 1
        % shuffle holds an array of row indexes to shuffle up.
        % randsample starts with 1,2,3,4... and gives us an array of same
        % length sampled.
        shuffle = randsample(1:rows,rows);
        % We check each row after the shuffle attempt to see if that row
        % was in the same place that it was in before.
        for y = 1:rows
            % If for example the number 2 is at index 2, we know the
            % shuffle has failed.
            if shuffle(y) ~= y
                rowCheck = rowCheck+1;
            end     
        end
        % If all rows have changed position, we can stop shuffling.
        if rowCheck == rows
            break;
        else
            rowCheck = 0;
        end
    end
    % Add shuffled matrix to output.
    for n = 1:rows
        shuffled(n,:) = matrix(shuffle(n),:);
    end
end