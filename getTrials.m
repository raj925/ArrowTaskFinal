%% getTrials.m
% Setup the trials struct and generate all our trials.
function [trials] = getTrials(vars)
    
    % Total number of trials across the experiment.
    numOfExpTrials = vars.numOfExpBlocks*vars.expBlockLength;
    b = numOfExpTrials;

    % Column headings.
    trials = struct('trialNumber',cell(1,b),'block',cell(1,b),...
    'reliability',cell(1,b),'colour',cell(1,b),...
    'subjectAns',cell(1,b),'cueAns',cell(1,b),'cueCorrect',cell(1,b),...
    'trueAns',cell(1,b),'correct',cell(1,b),'wager',cell(1,b),'betOnArrow',cell(1,b),...
    'betAgainstArrow',cell(1,b),'currentTokens',cell(1,b),'trialsSinceLastSwitch',cell(1,b),...
    'break',cell(1,b),'trialStartTime',cell(1,b),'onsetstim',cell(1,b),...
    'answerTime',cell(1,b),'rt1',cell(1,b),'onsetFeedback',...
    cell(1,b),'feedbackAnsTime',cell(1,b),'colourSwitch',cell(1,b),...
    'rt2',cell(1,b),'feedbackChosen',cell(1,b),'trialEndTime',cell(1,b));

    blockCounter = 1;
    blockToAssign = 1;
    trialTot = 0;
    relArray = [];
    
    highAccs = [0,1];
    medAccs = [0,1];
    lowAccs = [0,1];
    
    % Each reliability level will be on an equal number of trials (b/3)
    % On b/3 trials, our var percent value tells us on how many trials 
    % it will be correct.
    highCorrCount = vars.highReliability*(b/3);
    medCorrCount = vars.medReliability*(b/3);
    lowCorrCount = vars.lowReliability*(b/3);
    
    % repelem repeats each element in an array (eg [0,1] above) a certain
    % number of times to create a new array.
    % So we want an array of 1s and 0s, where the number of 1s is the
    % number of times that reliability level is correct.
    highAccs = repelem(highAccs,[(b/3)-highCorrCount,highCorrCount]);
    medAccs = repelem(medAccs,[(b/3)-medCorrCount,medCorrCount]);
    lowAccs = repelem(lowAccs,[(b/3)-lowCorrCount,lowCorrCount]);
    
    % Shuffle the correct and incorrect trials.
    highAccs = randsample(highAccs,length(highAccs));
    medAccs = randsample(medAccs,length(medAccs));
    lowAccs = randsample(lowAccs,length(lowAccs));
    
    relArray = repelem([1,2,3],vars.expBlockLength/3);
    % We then shuffle up the order that each reliability cue is given.
    relArray = randsample(relArray, length(relArray));
    
    for n = 1:b
        % Load up trial numbers.
        trials(n).trialNumber = n;
        trials(n).colourSwitch = 0;
        trials(n).break = 0;
        trialTot = vars.expBlockLength;
        trials(n).block = blockToAssign;
        
        % We assign block numbers to each trial based on how many trials we
        % know is in each block.
        if blockCounter == trialTot
            blockCounter = 1;
            trials(n).break = 1;
            blockToAssign = blockToAssign + 1;
        else
            blockCounter = blockCounter + 1;
        end
        
        % Randomly decide what is our correct answer for each trial.
        % 0 is left box, 1 is right box.
        trials(n).trueAns = round(rand(1));
    end
    
    % We generate on which trials the colour cue will switch.
    % The -1 is because we don't need to switch colour on the last trial.
    colourChangeTrials = repelem([vars.colourSwapEveryXTrials],(b/vars.colourSwapEveryXTrials)-1);
    for i = 1:size(colourChangeTrials,2)
        % Randomly decide on a value between -variance and variance value
        % to deviate from the colourSwapEveryXTrials variable in terms of
        % switching colour.
        variance = round((vars.variance*2).*rand(1,1) - vars.variance);
        if i == 1
            colourChangeTrials(i) = colourChangeTrials(i) + variance;
        else
            colourChangeTrials(i) = (colourChangeTrials(i) + variance) + colourChangeTrials(i-1);
        end
    end
    
    blockTrialCount = 1;
    for n = 1:b
        % We tierate through each trial, check the reliability level of
        % that trial, check the current mapping of colours to get the right
        % colour cue and then if we reach one of the colour change trials,
        % switch the colours round (using shuffle.m)
        rel = relArray(blockTrialCount);
        blockTrialCount = blockTrialCount + 1;
        trials(n).reliability = rel;
        trials(n).colour = vars.colours(rel,:);
        % A reliability value 1 is high, 3 is low.
        if trials(n).break == 1
            blockTrialCount = 1;
            relArray = repelem([1,2,3],vars.expBlockLength/3);
            % We then shuffle up the order that each reliability cue is given.
            relArray = randsample(relArray, length(relArray));
        end
        switch rel
            case 1
                % Check if cue is right or wrong for this trial based on
                % our array of 0s and 1s that we made.
                trials(n).cueCorrect = highAccs(1);
                highAccs(1)=[];
            case 2
                trials(n).cueCorrect = medAccs(1);
                medAccs(1)=[];
            case 3
                trials(n).cueCorrect = lowAccs(1);
                lowAccs(1)=[];
        end
        % Do we show the cue giving the right or wrong answer?
        if trials(n).cueCorrect == 1
            trials(n).cueAns = trials(n).trueAns;
        else
            trials(n).cueAns = abs(trials(n).trueAns-1);
        end
        % Check if it is time to shuffle colours.
        if ~isempty(colourChangeTrials)
            if n == colourChangeTrials(1)
                vars.colours = shuffle(vars.colours);
                colourChangeTrials(1) = [];
                trials(n+1).colourSwitch = 1;
            end
        end
    end
    
    
end