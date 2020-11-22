function [subject] = questionnaire(settings)

    settings.rawdata_path        = 'rawdata/';  % save paths in settings

    prompt = {'Subject ID:','Gender(m/f):','Age:','Experiment restarted? Yes=1 or No=0: '};
    answer = inputdlg(prompt); % Struct of answers from 'prompt' above

    %% Create Subject Struct
    
    subject.id          = str2double(answer{1});
    subject.gender      = str2double(answer{2});
    subject.age         = str2double(answer{3});
    subject.restart     = str2double(answer{4});
    subject.date        = date;
    subject.start_time  = clock;
    subject.name        = answer{1};  
    subject.screen      = 0;

    %% testing mode
    if isempty(subject.id) || isempty(subject.restart)
        warning('TESTING MODE');
        subject.male            = NaN;
        subject.age             = NaN;
        subject.right_handed    = NaN;
        subject.screen          = 0; % small size screen:1
        subject.name            = 'test';
        subject.id              = 999;
        subject.restart         = 0;
    end
    if isempty(subject.name)
        subject.name = 'test';
    end
    %% saving directory
        subject.dir = subject.name;
    % %% create directory if does not already exist
    if ~exist([settings.rawdata_path subject.dir '/behaviour'], 'dir') 
        mkdir([settings.rawdata_path subject.dir '/behaviour']);
    end

    %% Unique filename depending on computer clock (avoids overwriting)
    subject.fileName = [num2str(round(datenum(subject.start_time)*100000)) '_' num2str(subject.id)];

end