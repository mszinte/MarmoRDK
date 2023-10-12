function [const] = runExp(scr,const,expDes,stim,my_key,mc)
% ----------------------------------------------------------------------
% [const] = runExp(scr,const,expDes,stim,my_key,mc)
% ----------------------------------------------------------------------
% Goal of the function :
% Launch experiment trials
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : experimental design
% stim : struct containing the RDK stimuli
% my_key : structure containing keyboard configurations
% mc : struct containing mcant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 02 / 07 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

% Save all settings
% -----------------
config.scr = scr;
config.const = const;
config.expDes = expDes;
config.my_key = my_key;
config.mc = mc;
save(const.mat_file, 'config')

% First mouse config
% ------------------
if const.expStart
    HideCursor;
end

% First keyboard config
% ---------------------
for keyb = 1:size(my_key.keyboard_idx,2)
    KbQueueFlush(my_key.keyboard_idx(keyb));
end

% Main trial
% ----------

% Write behavioral data header
behav_txt_head{1} = 'onset';                               behav_txt_head{2} = 'duration';
behav_txt_head{3} = 'run_number';                          behav_txt_head{4} = 'trial_number'; 
behav_txt_head{5} = 'signal_direction';                    behav_txt_head{6} = 'signal_soa';
behav_txt_head{7} = 'signal_coherence';                    behav_txt_head{8} = 'signal_sample';
behav_txt_head{9} = 'response_val';                        behav_txt_head{10} = 'reaction_time';
behav_txt_head{11} = 'touch_button_onset';                 behav_txt_head{12} = 'release_button_onset';               
behav_txt_head{13} = 'reward_touch_onset';                 behav_txt_head{14} = 'rdk_noise_onset';
behav_txt_head{15} = 'rdk_signal_onset';                   behav_txt_head{16} = 'touch_resp_onset';                   
behav_txt_head{17} = 'reward_resp_iti_onset';              behav_txt_head{18} = 'offset';
for sjctNum = 1:size(const.marmo_ID,2)
    head_line = [];
    for tab = 1:size(behav_txt_head,2)
        if tab == size(behav_txt_head,2); head_line = [head_line,sprintf('%s',behav_txt_head{tab})];
        else head_line = [head_line,sprintf('%s\t',behav_txt_head{tab})];
        end
    end
    fprintf(const.behav_file_fid{sjctNum},'%s\n',head_line);
end

% Define trial number
for sjctNum = 1:size(const.marmo_ID,2)
    t_trial{sjctNum} = 0;
end

% Main loop
auto_record = 1;
while auto_record
    
    % Check animal in chair
    if const.chair;expDes.in_chair_trigger = 0;else expDes.in_chair_trigger = 1;end
   
    % Check IR
    while ~expDes.in_chair_trigger       
        if strcmp(mc.IR.port_obj.UserData.event_value{end},'IR_1') || ...
            strcmp(mc.IR.port_obj.UserData.event_value{end},'IR_3')
            expDes.in_chair_trigger = 1;
        end
        
        % Check keyboard
        keyPressed = 0; keyCode = zeros(1,my_key.keyCodeNum);
        for keyb = 1:size(my_key.keyboard_idx,2)
            [keyP, keyC] = KbQueueCheck(my_key.keyboard_idx(keyb));
            keyPressed = keyPressed+keyP;
            keyCode = keyCode+keyC;
        end
        if keyPressed
            if keyCode(my_key.escape)
                fprintf(const.log_fid,'quit_program at %s\n', num2str(GetSecs));
                return
            end
        end
    end

    % Get RFID
    if const.chair
        expDes.trial_rfid = mc.RFID.port_obj.UserData.event_value{end};
    else
        expDes.trial_rfid = 'debug_tag';
    end
    
    
    if ~strcmp(expDes.trial_rfid, '?1')
        
        % Define subject and trial
        if ~const.chair
            expDes.sjctNum = 1;
        else
            for sjctNum = 1:size(const.marmo_ID,2)
                if strcmp(expDes.trial_rfid,const.marmo_ID{sjctNum})
                    expDes.sjctNum = sjctNum;
                end
            end
        end
        t_trial{expDes.sjctNum} = t_trial{expDes.sjctNum} + 1;
        
        % Define trial variable
        randVal1 = randperm(numel(expDes.oneR));    rand_rand1 = expDes.oneR(randVal1(1));
        randVal2 = randperm(numel(expDes.twoR));    rand_rand2 = expDes.twoR(randVal2(1));
        randVal3 = randperm(numel(expDes.threeR));  rand_rand3 = expDes.threeR(randVal3(1));
        randVal4 = randperm(numel(expDes.fourR));   rand_rand4 = expDes.fourR(randVal4(1));
        expDes.expMat{expDes.sjctNum}(t_trial{expDes.sjctNum},:) = [   NaN, NaN, const.runNum, t_trial{expDes.sjctNum}, ...
                                                                       rand_rand1, rand_rand2, rand_rand3, rand_rand4,...
                                                                       NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN];

        % Video demo
        if const.mkVideo
            txtVid = [];
            for tRand = 1:expDes.nb_rand 
                varMat(tRand) = input(sprintf('\n\tRAND %i = ',tRand)); 
                txtVid = [txtVid,sprintf('_rand%i-%i',tRand,varMat(tRand))];
            end  
            
            % Movie file
            if ~isfolder(sprintf('others/%s%s/',const.task_txt,txtVid));mkdir(sprintf('others/%s%s/',const.task_txt,txtVid));end
            const.movie_image_file = sprintf('others/%s%s/%s%s',const.task_txt,txtVid,const.task_txt,txtVid);
            const.movie_file = sprintf('others/%s%s.mp4',const.task_txt,txtVid);
         
            const.vid_obj = VideoWriter(const.movie_file,'MPEG-4');
            const.vid_obj.FrameRate = const.desiredFD;
            const.vid_obj.Quality = 100;
            open(const.vid_obj);
            
            for sjctNum = 1:size(const.marmo_ID,2); expDes.expMat{sjctNum}(t_trial{expDes.sjctNum},:) = [1 1 varMat];end
            auto_record = 0;
        end

        % Run trial
        [expDes] = runTrials(scr,const,expDes,stim,my_key,t_trial{expDes.sjctNum},mc);
        if expDes.expMat{expDes.sjctNum}(t_trial{expDes.sjctNum},9) == -7
            auto_record = 0; 
        end
        
        % Compute/Write behavioral data
        for res_num = 1:size(behav_txt_head,2)
            behav_mat_res{res_num} = expDes.expMat{expDes.sjctNum}(t_trial{expDes.sjctNum},res_num);
        end
        
        trial_line = [];
        for tab = 1:size(behav_mat_res,2)
            if tab == size(behav_mat_res,2)
                if isnan(behav_mat_res{tab}); trial_line = [trial_line,sprintf('n/a')];
                else trial_line = [trial_line,sprintf('%1.10g',behav_mat_res{tab})];
                end
            else
                if isnan(behav_mat_res{tab}); trial_line = [trial_line,sprintf('n/a\t')];
                else trial_line = [trial_line,sprintf('%1.10g\t',behav_mat_res{tab})];
                end
            end
        end
        fprintf(const.behav_file_fid{expDes.sjctNum},'%s\n',trial_line);
        
    else
        continue
    end
end

% Save all settings
const.session_end = datetime('now','Format','d-MMM-y HH:mm:ss');
fprintf(const.log_fid,'session_end : %s\n', const.session_end);
config.scr = scr;
config.const = const;
config.expDes = expDes;
config.my_key = my_key;
config.mc = mc;
save(const.mat_file, 'config')

end