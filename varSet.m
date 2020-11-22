%% VarSet - Set our experimental variables.
function [vars] = varSet(vars)

    % Set X and Y dimensions of the experiment window below.
    vars.resX = 1440;
    vars.resY = 900;
    
    % How many blocks?
    vars.numOfExpBlocks = 6;
    % How many trials per block? 
    % This MUST be a multiple of 3, so each arrow appears the same number
    % of times per block.
    vars.expBlockLength = 30;

    % Percent of correct trials for each reliability level.
    % Provide values as decimals from 0 to 1.
    vars.lowReliability = 0.5;
    vars.medReliability = 0.7;
    vars.highReliability = 0.9;
    
    % Colours to use for our cues, provided as RGB triplet
    vars.colourCode1 = [0.9290 0.6940 0.1250];
    vars.colourCode2 = [0.6350 0.0780 0.1840];
    vars.colourCode3 = [0, 0.4470, 0.7410];
    vars.colourNames = ['orange','red','blue'];
    
    % Based on the below two variables, the colours cuing each reliability
    % will swap every X trials +/- the variance value (so there is a range
    % of randomness in when the colours will change).
    vars.colourSwapEveryXTrials = 60;
    vars.variance = 10;

    % Max tokens on a single wager.
    vars.maxBet = 4;
    % How many tokens does feedback cost?
    vars.feedbackCost = 1;

    % How many tokens to start subjects with?
    vars.startingTokens = 10;
    % If we want to translate tokens into payment afterwards, how much is
    % each token worth?
    vars.tokenValue = 0.5;
    
    % Setting to skip instructions while debugging
    vars.do_instr = true;   
end