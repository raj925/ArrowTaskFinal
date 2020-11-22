%% Wagering Cue Reliability Experiment %%%%%%%%%%%
% Author - Sriraj Aiyer
% Contact - sriraj.aiyer@psy.ox.ac.uk

% This experiment has three cues that indicate to either a left or right
% box. Cues at different reliability and matched to different colours,
% which changes during the experiment without notice.
% Participants then wager tokens on one of the boxes. Participants either
% win their bet amount or lose double.
 
% Participants can choose to pay a token to view whether their previous
% trial was correct or incorrect.

%% Setup

close all;
clc;

% Folder to save data at.
vars.rawdata_path = 'rawdata/';

% Initial questionnaire for subject information.
[subject] = questionnaire(vars);                              

% Start timer
tic
% Initial experiment variables
[vars] = varSet(vars);

% You can resume an experiment at where it left off in case of a crash.
if (subject.restart)
    [filename, pathname] = uigetfile('*.mat', 'Pick last saved file ');
    load([pathname filename]);
    starttrial = t;
    vars.restarted = 1;
else
    starttrial=1;
end

% Psychtoolbox setup
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','TextRenderer',0);
Sc = start_psychtb([0 0 vars.resX vars.resY]);

% Use the above X and Y dimensions to derive the centre of the screen.
xy = Screen('Resolution',0);
centerX = vars.resX/2;
centerY = vars.resY/2;


% Define starting colours
colours = [vars.colourCode1; vars.colourCode2; vars.colourCode3];
colours = shuffle(colours);
vars.colours = colours; 

% Defines sizes of boxes for participants to choose from.
define_boxes;

% Generate the struct of trials and cues to be given on each trial.
[trials] = getTrials(vars);

% Starting number of tokens to wager with.
tokens = vars.startingTokens;

lastSwitch = 0;

%% Main trial loop
for t = starttrial : length(trials)
    % Time of start of trial.
    trials(t).trialStartTime = GetSecs;
    trials(t).currentTokens = tokens;
    
    % Keep running total of number of trials since last switch.
    if (trials(t).colourSwitch == 1)
        lastSwitch = 1;
    else
        lastSwitch = lastSwitch + 1;
    end
    trials(t).trialsSinceLastSwitch = lastSwitch;
    
    % Print to console how participant is doing for debugging or monitoring
    % purposes. Commented for now.
    
%     if t > 1
%         disp(['t: ' num2str(t-1)]);
%         disp(['correct: ' num2str(trials(t-1).correct)]);
%         disp(['wager: ' num2str(trials(t-1).wager)]);
%         disp(['total: ' num2str(trials(t-1).total)]);        
%     end
  
    % Draw the boxes.
    Screen('DrawLines',Sc.window,innerrect1out,3,255);
    Screen('DrawLines',Sc.window,innerrect2out,3,255);
    
    % Draw instructional text.
    Screen('TextSize',Sc.window,16);
    instruct = ['Use the left and right mouse buttons to increase/decrease your wager on the left or right box' newline newline 'Press space to confirm your answer'];
    DrawFormattedText(Sc.window,instruct,'center', centerY-(centerY/2), [0 0 0]);
    
    % Define centre of each box for drawing text.
    text1 = (innerrect1outer(1,1) + innerrect1out(1,2))/2;
    text2 = (innerrect2outer(1,1) + innerrect2out(1,2))/2;
    
%      [~, ~, ~] = DrawFormattedText2('LEFT','win',Sc.window,'sx',text1,'sy','center','xalign','center');
%      [~, ~, ~] = DrawFormattedText2('RIGHT','win',Sc.window,'sx',text2,'sy','center','xalign','center');

%     DrawFormattedText(Sc.window,'LEFT',text1-10,'center',[0 0 0]);
%     DrawFormattedText(Sc.window,'RIGHT',text2+10,'center',[0 0 0]);

    % Time of stimulus onset.
    trials(t).onsetstim = GetSecs;
    
    % The 0 and 180 in the brackets defines the rotation  s to the left.
    % Draw this arrow in the colour pulled from the trials struct.
    if (trials(t).cueAns == 1)
        draw_arrow(Sc.window,[centerX,centerY],180,trials(t).colour,[35,35,15,15]);
    else
        draw_arrow(Sc.window,[centerX,centerY],0,trials(t).colour,[35,35,15,15]);
    end
    
    Screen('Flip', Sc.window);
       
    hasconfirmed = false;  
    % The wager variable starts at 0 for each trial.
    % As the participant places wagers, the wager variable will be negative
    % for wagers placed on the left box, positive for wagers placed on the
    % right box.
    % eg a wager of 2 tokens on the left box means wager = -2.
    wager = 0;
    timeStart = WaitSecs(0);
    
    % Participants use the mouse buttons to place wagers
    % They then use the space bar to confirm their answer.
    % This loop waits for them to press the space bar.
    while ~hasconfirmed
%         FlushEvents('keyDown');
        % Check for input from the mouse or keyboard. 
        [x,y,buttons] = GetMouse;
        [pressed, resp_t, keycode] = KbCheck(); 
%         [secs , keyCode, ~] = KbWait([], [], timeStart+5);
        % If a mouse button has been pressed.
        if sum(buttons==1)>0
            % If left mouse button
            if(buttons(1))
                % Cap the wager so participants have a limit on how much
                % they can wager (defined in varSet).
                if wager > (vars.maxBet)*-1
                    % We subtract for the left box.
                    wager = wager - 1;
                 % Below is commented out code for restting wager when
                 % clicked after reaching the maximum bet.
                 % To cancel their wager, they simply click again when
                 % at the max wager for a box.
                % else
%                     wager = 0;
                end
                while 1
                    [x,y,buttons] = GetMouse; 
                    % This allos us to wait before the mouse button is
                    % released.
                    if(~buttons(1))
                        % We have to redraw everything we had on screen before 
                        % when we flip the screen to then show the wagers.
                        if (trials(t).cueAns == 1)
                            draw_arrow(Sc.window,[centerX,centerY],180,trials(t).colour,[35,35,15,15]);
                        else
                            draw_arrow(Sc.window,[centerX,centerY],0,trials(t).colour,[35,35,15,15]);
                        end
                        Screen('DrawLines',Sc.window,innerrect1out,3,255);
                        Screen('DrawLines',Sc.window,innerrect2out,3,255);
                        
                        % Add a wager token on the left or right box. 
                        % Represented as a circle on the box with the
                        % number of the tokens currently wagered shown.
                     
                        if wager < 0
                            Screen('FrameOval',Sc.window,[0 0 0],innerrect1outer);
                            DrawFormattedText(Sc.window,int2str(abs(wager)),text1-10,'center',[0 0 0]); 
                        elseif wager > 0
                            Screen('FrameOval',Sc.window,[0 0 0],innerrect2outer);
                            DrawFormattedText(Sc.window,int2str(abs(wager)),text2-10,'center',[0 0 0]);
                        end
                        DrawFormattedText(Sc.window, instruct,'center', centerY-(centerY/2), [0 0 0]);
                        Screen('Flip', Sc.window);
                        break; 
                    end
                end
            end
            % If right mouse button is pressed.
            if(buttons(2)||buttons(3))
                % Cap the wager so participants have a limit on how much
                % they can wager (defined in varSet).
                if wager < vars.maxBet
                    % We add to wager for the right box.
                    wager = wager + 1;
                  % Below is commented out code for restting wager when
                  % clicked after reaching the maximum bet.
%                 else
%                     wager = 0;
                end
                while 1
                    [x,y,buttons] = GetMouse; 
                    if(~buttons(2)&&~buttons(3))
                        if (trials(t).cueAns == 1)
                            draw_arrow(Sc.window,[centerX,centerY],180,trials(t).colour,[35,35,15,15]);
                        else
                            draw_arrow(Sc.window,[centerX,centerY],0,trials(t).colour,[35,35,15,15]);
                        end
                        Screen('DrawLines',Sc.window,innerrect1out,3,255);
                        Screen('DrawLines',Sc.window,innerrect2out,3,255);
                        if wager > 0
                            Screen('FrameOval',Sc.window,[0 0 0],innerrect2outer);
                            DrawFormattedText(Sc.window,int2str(abs(wager)),text2-10,'center',[0 0 0]);
                        elseif wager < 0
                            Screen('FrameOval',Sc.window,[0 0 0],innerrect1outer);
                            DrawFormattedText(Sc.window,int2str(abs(wager)),text1-10,'center',[0 0 0]);
                        end
                        DrawFormattedText(Sc.window, instruct,'center', centerY-(centerY/2), [0 0 0]);
                        Screen('Flip', Sc.window);  
                        break; 
                    end
                end
            end
        end 
%         If keyboard is pressed.
        if pressed && wager ~= 0      
            % Translate key code into key name
            name = KbName(keycode);
            % Only take first response if multiple responses
            if ~iscell(name), name = {name}; end
            name = name{1};
            % If the spacebar is pressed to confirm answer.
            if strcmp('space',name)
% 
%         if strcmp((KbName(keyCode)), 'space')
                trials(t).answerTime = GetSecs;
                % Add the subject's answer to trials.
                if wager < 0
                    trials(t).subjectAns = 0;
                elseif wager > 0
                    trials(t).subjectAns = 1;
                else
                    trials(t).subjectAns = [];
                end
                % Add the wager for this trial after the participant
                % confirms their answer.
                trials(t).wager = wager;
                % Regardless of feedback, we still add or subtract tokens
                % depending on if the answer is right or wrong.
                if trials(t).subjectAns == trials(t).trueAns
                    tokens = tokens + abs(wager);
                    trials(t).correct = 1;
                else
                    % Double loss compared to gain if right, to dissuade
                    % betting high unless sure.
                    tokens = tokens - abs(wager)*2;
                    trials(t).correct = 0;
                end
                % Set variables for wagers either for/against arrow
                if trials(t).subjectAns == trials(t).cueAns
                    trials(t).betOnArrow = abs(wager);
                    trials(t).betAgainstArrow = 0;
                else
                    trials(t).betOnArrow = 0;
                    trials(t).betAgainstArrow = abs(wager);
                end
                disp(tokens);      
                % Leave the loop.
                hasconfirmed = true;
            end    
        end  
    end
           
    % Ask subject if they want to see feedback.
    Screen('TextSize',Sc.window,18);
    DrawFormattedText(Sc.window, 'Would you like to pay 1 token to see feedback?','center', 'center', [0 0 0]);
    DrawFormattedText(Sc.window, 'Yes',text1, centerY+(centerY/2), [0 0 0]);
    DrawFormattedText(Sc.window, 'No',text2, centerY+(centerY/2), [0 0 0]);
    Screen('Flip', Sc.window);

    trials(t).onsetFeedback = GetSecs;
    feedback = 0;
    while(1)
        [x,y,buttons] = GetMouse;
        % If right mouse button ic clicked, no feedback is requested.
        if(buttons(2))||(buttons(3))
            trials(t).feedbackChosen = 0;
            while 1
                % Wait for mouse release.
                [x,y,buttons] = GetMouse; 
                % depends on mouse being used, hence we check if 2 or 3 is
                % the right mouse button.
                if(~buttons(2)&&~buttons(3))
                    trials(t).feedbackAnsTime = GetSecs;
                    break; 
                end
            end
        break;
        end
        % If left mouse button is clicked, feedback is requested.
        if(buttons(1))
            trials(t).feedbackChosen = 1;
            feedback = 1;
            % Subtract the cost of feedback.
            tokens = tokens - vars.feedbackCost;
            while 1
                [x,y,buttons] = GetMouse; 
                if(~buttons(1))
                    trials(t).feedbackAnsTime = GetSecs;
                    break; 
                end 
            end
        break;
        end
    end
    
    Screen('Flip', Sc.window);
    % Show feedback on the screen if chosen.
    if feedback
        if trials(t).correct
            feedbackText = 'You were correct!';
        else
            feedbackText = 'You were incorrect!';
        end
        feedbackText = [feedbackText newline newline 'Press space to continue'];
        DrawFormattedText(Sc.window, feedbackText,'center', 'center', [0 0 0]);
        Screen('Flip', Sc.window);
        hasconfirmed = false;
        % Wait for subject to confirm they are ready to move on.
        while ~hasconfirmed
            [pressed, resp_t, keycode] = KbCheck; 
            if pressed      
                % Translate key code into key name
                name = KbName(keycode);
                % Only take first response if multiple responses
                if ~iscell(name), name = {name}; end
                name = name{1};
                if strcmp('space',name)
                    while 1
                        [down,~,~] = KbCheck(); 
                        if ~down
                            break;
                        end
                    end
                    Screen('Flip', Sc.window);
                    break;
                end
            end
        end
    end
    
    % Calculate time taken for initial response and feedback choice based
    % on timing variables captured. 
    trials(t).rt1 = trials(t).answerTime - trials(t).onsetstim;
    trials(t).rt2 = trials(t).feedbackAnsTime - trials(t).onsetFeedback;
    trials(t).trialEndTime = GetSecs;
    
    % If this break trial, show the participant their performance up til
    % this point.
    if trials(t).break
        save([pwd '/' vars.rawdata_path num2str(subject.id) '/behaviour/' subject.fileName '_' num2str(round(t/vars.expBlockLength))],'trials', 'vars', 'subject', 't');
        correct = [trials(1:t).correct];
        text = ['You currently have ' num2str(tokens) ' tokens left' newline newline 'Your accuracy up until this point is ' num2str((sum(correct)/t)*100) '%'];
        text = [text newline newline newline 'You may now take a break. Press space to continue.'];
        DrawFormattedText(Sc.window, text,'center', 'center', [0 0 0]);
        Screen('Flip', Sc.window);
        hasconfirmed = false;
        % Wait for subject to confirm they are ready to move on.
        while ~hasconfirmed
            [pressed, resp_t, keycode] = KbCheck; 
            if pressed      
                % Translate key code into key name
                name = KbName(keycode);
                % Only take first response if multiple responses
                if ~iscell(name), name = {name}; end
                name = name{1};
                if strcmp('space',name)
                    Screen('Flip', Sc.window);
                    break;
                end
            end
        end
    end
end
save([vars.rawdata_path subject.id '/' subject.fileName '_final'],'trials', 'vars', 'subject', 't');
text = ['You have completed the experiment with ' num2str(tokens) newline newline 'Your total accuracy was ' num2str((sum(correct)/t)*100) '%'];
if (tokens > 0)
    text = [text newline newline newline 'You won £' num2str(vars.tokenValue*tokens) '!'];
end
text = [text newline newline 'Thank you for taking part in our experiment!'];
DrawFormattedText(Sc.window, text,'center', 'center', [0 0 0]);
Screen('Flip', Sc.window);
hasconfirmed = false;
% Wait for subject to confirm they are ready to move on.
while ~hasconfirmed
    [pressed, resp_t, keycode] = KbCheck; 
    if pressed      
        % Translate key code into key name
        name = KbName(keycode);
        % Only take first response if multiple responses
        if ~iscell(name), name = {name}; end
        name = name{1};
        if strcmp('space',name)
            Screen('Flip', Sc.window);
            break;
        end
    end
end