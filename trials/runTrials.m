function [expDes]=runTrials(scr,const,expDes,stim,my_key,t_trial,mc)
% ----------------------------------------------------------------------
%  [expDes]=runTrials(scr,const,expDes,my_key,t_trial,mc)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw stimuli of each indivual trial and waiting for inputs.
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : experimental design
% stim : struct containing the RDK stimuli
% my_key : structure containing keyboard configurations
% t_trial : trial meter
% mc : struct containing mcant configurations
% ----------------------------------------------------------------------
% Output(s):
% expDes : experimental design
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 02 / 07 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

% specify trials
sjct = const.sjct{expDes.sjctNum};
rand1 = expDes.expMat{expDes.sjctNum}(t_trial,5);    % signal direction
switch rand1
    case 1; correct_button_coords = [const.button_coords(1)+const.button_dist,const.button_coords(2)];
            incorrect_button_coords = [const.button_coords(1)-const.button_dist,const.button_coords(2)]; 
    case 2; correct_button_coords = [const.button_coords(1)-const.button_dist,const.button_coords(2)];
            incorrect_button_coords = [const.button_coords(1)+const.button_dist,const.button_coords(2)];
end

rand2 = expDes.expMat{expDes.sjctNum}(t_trial,6);    % signal soa
rand3 = expDes.expMat{expDes.sjctNum}(t_trial,7);    % signal kappa
rand4 = expDes.expMat{expDes.sjctNum}(t_trial,8);    % signal example
rdk = stim.rdk{rand1,rand2,rand3,rand4};

init_touch = 1;
reward_touch = 1;
rdk_resp = 1;
reward_resp_iti = 1;

if const.mkVideo;vid_num = 0;end

if const.checkTrial && const.expStart == 0
    fprintf(1,'\n\n============== %s - trial = %3.0f ================\n',const.sjct{expDes.sjctNum},t_trial);
    fprintf(1,'\n\tRDK signal direction   :   %s\n',expDes.txt_rand1{rand1});
    fprintf(1,'\n\tRDK signal soa         :   %s\n',expDes.txt_rand2{rand2});
    fprintf(1,'\n\tRDK signal coherence   :   %s\n',expDes.txt_rand3{rand3});
    fprintf(1,'\n\tRDK sample             :   %s\n',expDes.txt_rand4{rand4});
end

% Draw touch button
% -----------------
if init_touch
    quit_touch = 0;
    touch_button = 0;
    init_touch_trigger = 1;
    SetMouse(0, 0, scr.main);
    touch_nbf = 0;
    while ~quit_touch
        
        Screen('FillRect',scr.main,const.gray);
        draw_buttons(scr,const,const.button_coords(1),const.button_coords(2),'center')
        vbl = Screen('Flip',scr.main);
        touch_nbf = touch_nbf + 1;
        
        if init_touch_trigger 
            onset = vbl;
            fprintf(const.log_fid,'onset %s trial trial %i at %s\n', sjct, t_trial, num2str(onset));
            init_touch_trigger = 0; 
            expDes.expMat{expDes.sjctNum}(t_trial,1) = onset;
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
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -7; % response
                expDes.expMat{expDes.sjctNum}(t_trial,10) = NaN; % reaction time
                reward_touch = 0; rdk_resp = 0; reward_resp_iti = 0;
                offset = vbl;
                fprintf(const.log_fid,'offset %s trial trial %i at %s\n', sjct, t_trial, num2str(offset));
                expDes.expMat{expDes.sjctNum}(t_trial,18) = offset;
                duration_ = offset - onset;
                fprintf(const.log_fid,'duration %s trial trial %i at %s\n', sjct, t_trial, num2str(duration_));
                expDes.expMat{expDes.sjctNum}(t_trial,2) = duration_;
                touch_button = 1;
                fprintf(const.log_fid,'quit_program at %s\n', num2str(offset));
            end
        end
        
        % Check touch screen cursor within ellipse
        [xCursor,yCursor,buttons] = GetMouse(scr.main);
        ellipse_equation = (xCursor-const.button_coords(1))^2/(const.button_out_rim_rad(1)^2) + ...
                           (yCursor-const.button_coords(2))^2/(const.button_out_rim_rad(2)^2);
        if ellipse_equation <= 1 && ~touch_button
            touch_button = 1;
            touch_button_onset = GetSecs;
            fprintf(const.log_fid,'touch_button_onset %s trial trial %i at %s\n', sjct, t_trial, num2str(touch_button_onset));
            expDes.expMat{expDes.sjctNum}(t_trial,11) = touch_button_onset;
        end
        
        if touch_button && sum(buttons) == 0
            quit_touch = 1;
            release_button_onset = GetSecs;
            fprintf(const.log_fid,'release_button_onset %s trial trial %i at %s\n', sjct, t_trial, num2str(release_button_onset));
            expDes.expMat{expDes.sjctNum}(t_trial,12) = release_button_onset;
            continue
        end
        
        % Make video
        if const.mkVideo
            vid_num = vid_num + 1;
            image_vid = Screen('GetImage', scr.main);
            imwrite(image_vid,sprintf('%s_frame_%i.png',const.movie_image_file,vid_num));
            writeVideo(const.vid_obj,image_vid);
        end
        
        % Timeout
        if touch_nbf >= const.touch_timeout_nbf
            if xCursor == 0 && yCursor == 0
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -1; % response_val = no touch
            else
                if touch_button == 0
                    % not precise touch
                    expDes.expMat{expDes.sjctNum}(t_trial,9) = -2; % response_val = unprecise touch
                elseif touch_button == 1
                    expDes.expMat{expDes.sjctNum}(t_trial,9) = -3; % response_val = correct touch but no release
                end
            end
            expDes.expMat{expDes.sjctNum}(t_trial,10) = NaN;
            offset = vbl;
            fprintf(const.log_fid,'touch_timeout at %s\n', num2str(offset));
            fprintf(const.log_fid,'offset %s trial trial %i at %s\n', sjct, t_trial, num2str(offset));
            expDes.expMat{expDes.sjctNum}(t_trial,18) = offset;
            duration_ = offset - onset;
            fprintf(const.log_fid,'duration %s trial trial %i at %s\n', sjct, t_trial, num2str(duration_));
            expDes.expMat{expDes.sjctNum}(t_trial,2) = duration_;
            
            reward_touch = 0; rdk_resp = 0; reward_resp_iti = 0;
            touch_button = 1;
        end
    end
end

% Draw fixation dot during reward
% -------------------------------
if reward_touch

    reward1 = 0;
    for nbf = 1:const.reward1_nbf
        
        % Screen presentation
        Screen('FillRect',scr.main,const.gray);
        draw_fix(scr,const,const.stim_coords(1),const.stim_coords(2))
        vbl = Screen('Flip',scr.main);
        if nbf == 1 
            reward_touch_onset = vbl;
            fprintf(const.log_fid,'reward_touch_onset %s trial trial %i at %s\n', sjct, t_trial, num2str(reward_touch_onset));
            expDes.expMat{expDes.sjctNum}(t_trial,13) = reward_touch_onset;
        end
        
        % Send reward
        if const.chair
            if ~reward1;send_reward(mc.RW, const.reward1_rev);reward1=1;end
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
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -7;  % response_val
                expDes.expMat{expDes.sjctNum}(t_trial,10) = NaN;
                rdk_resp = 0; reward_resp_iti = 0;
                offset = vbl;                 
                fprintf(const.log_fid,'offset %s trial trial %i at %s\n', sjct, t_trial, num2str(offset));                 
                expDes.expMat{expDes.sjctNum}(t_trial,18) = offset;
                duration_ = offset - onset;
                fprintf(const.log_fid,'duration %s trial trial %i at %s\n', sjct, t_trial, num2str(duration_));
                expDes.expMat{expDes.sjctNum}(t_trial,2) = duration_;
                fprintf(const.log_fid,'quit_program at %s\n', num2str(offset));
                break
            end
        end
        
        % Make video
        if const.mkVideo
            vid_num = vid_num + 1;
            image_vid = Screen('GetImage', scr.main);
            imwrite(image_vid,sprintf('%s_frame_%i.png',const.movie_image_file,vid_num))
            writeVideo(const.vid_obj,image_vid);
        end
    end
end

% RDK + response buttons
% ----------------------
SetMouse(0, 0, scr.main);
if rdk_resp
    
    for nbf = 1:size(rdk.posi,2)+const.resp_timeout_nbf
        
        % Screen presentation
        Screen('FillRect',scr.main,const.gray);
        if nbf <= size(rdk.posi,2); Screen('DrawDots',scr.main, round(rdk.posi{nbf})', rdk.siz, rdk.col, rdk.cent,2);end
        draw_buttons(scr,const,const.button_coords(1),const.button_coords(2),'sides')
        vbl = Screen('Flip',scr.main);

        if nbf == 1
            rdk_noise_onset = vbl;
            fprintf(const.log_fid,'rdk_noise_onset %s trial %i at %s\n', sjct, t_trial, num2str(rdk_noise_onset));
            expDes.expMat{expDes.sjctNum}(t_trial,14) = rdk_noise_onset;
        elseif nbf == const.signal_soa_nbf(rand2)+1
            rdk_signal_onset = vbl;
            fprintf(const.log_fid,'rdk_signal_onset %s trial %i at %s\n', sjct, t_trial, num2str(rdk_signal_onset));
            expDes.expMat{expDes.sjctNum}(t_trial,15) = rdk_signal_onset;
        end
        
        % Check touch screen
        [xCursor,yCursor] = GetMouse(scr.main);
        ellipse_correct_equation = (xCursor-correct_button_coords(1))^2/(const.button_out_rim_rad(1)^2) + ...
                                   (yCursor-correct_button_coords(2))^2/(const.button_out_rim_rad(2)^2);

        ellipse_incorrect_equation = (xCursor-incorrect_button_coords(1))^2/(const.button_out_rim_rad(1)^2) + ...
                                     (yCursor-incorrect_button_coords(2))^2/(const.button_out_rim_rad(2)^2);
        
        if ellipse_correct_equation <= 1
            if nbf <= const.signal_soa_nbf(rand2)+1
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -5; % response_val = too early
            else
                expDes.expMat{expDes.sjctNum}(t_trial,9) = 1; % response_val = correct response
            end
            touch_resp_onset = vbl;
            expDes.expMat{expDes.sjctNum}(t_trial,10) = touch_resp_onset - rdk_signal_onset;
            fprintf(const.log_fid,'touch_resp_onset %s trial %i at %s\n', sjct, t_trial, num2str(touch_resp_onset));
            expDes.expMat{expDes.sjctNum}(t_trial,16) = touch_resp_onset;
            break
            
        elseif ellipse_incorrect_equation <= 1
            if nbf <= const.signal_soa_nbf(rand2)+1
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -5; % response_val = too early
            else
                expDes.expMat{expDes.sjctNum}(t_trial,9) = 0; % response_val = incorrect response
            end
            touch_resp_onset = vbl;
            expDes.expMat{expDes.sjctNum}(t_trial,10) = touch_resp_onset - rdk_signal_onset;
            fprintf(const.log_fid,'touch_resp_onset %s trial %i at %s\n', sjct, t_trial, num2str(touch_resp_onset)); 
            expDes.expMat{expDes.sjctNum}(t_trial,16) = touch_resp_onset;
            break
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
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -7; % response val  
                expDes.expMat{expDes.sjctNum}(t_trial,10) = NaN; % reaction_time
                reward_resp_iti = 0;
                offset = vbl;
                fprintf(const.log_fid,'offset %s trial %i at %s\n', sjct, t_trial, num2str(offset));
                expDes.expMat{expDes.sjctNum}(t_trial,18) = offset;
                duration_ = offset - onset;
                fprintf(const.log_fid,'duration %s trial %i at %s\n', sjct, t_trial, num2str(duration_));
                expDes.expMat{expDes.sjctNum}(t_trial,2) = duration_;
                fprintf(const.log_fid,'quit_program at %s\n', num2str(offset));
                break
            end
        end
        
        % Make video
        if const.mkVideo
            vid_num = vid_num + 1;
            image_vid = Screen('GetImage', scr.main);
            imwrite(image_vid,sprintf('%s_frame_%i.png',const.movie_image_file,vid_num))
            writeVideo(const.vid_obj,image_vid);
        end
                
        if nbf >= size(rdk.posi,2)+const.resp_timeout_nbf
           if xCursor ~= 0 || yCursor ~= 0
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -4; % response_val = unprecise response
            else
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -6; % response_val = no response
            end
            expDes.expMat{expDes.sjctNum}(t_trial,10) = NaN;
            reward_resp_iti = 0;
            offset = vbl;
            fprintf(const.log_fid,'resp_timeout at %s\n', num2str(offset));
            fprintf(const.log_fid,'offset %s trial %i at %s\n', sjct, t_trial, num2str(offset));
            expDes.expMat{expDes.sjctNum}(t_trial,18) = offset;
            duration_ = offset - onset;
            fprintf(const.log_fid,'duration %s trial %i at %s\n', sjct, t_trial, num2str(duration_));
            expDes.expMat{expDes.sjctNum}(t_trial,2) = duration_;
        end
    end
end

% Reward and inter trial interval
% -------------------------------
if reward_resp_iti
    reward2 = 0;
    for nbf = 1:const.reward2_nbf
        Screen('FillRect',scr.main,const.gray);
        
        vbl = Screen('Flip',scr.main);
        if nbf == 1
            reward_resp_iti_onset = vbl;
            fprintf(const.log_fid,'reward_resp_iti_onset %s trial %i at %s\n', sjct, t_trial, num2str(reward_resp_iti_onset));
            expDes.expMat{expDes.sjctNum}(t_trial,17) = reward_resp_iti_onset;
        end
        if nbf == const.reward2_nbf
            offset = vbl;
            fprintf(const.log_fid,'offset %s trial %i at %s\n', sjct, t_trial, num2str(offset));
            expDes.expMat{expDes.sjctNum}(t_trial,18) = offset;
            duration_ = offset - onset;
            fprintf(const.log_fid,'duration %s trial %i at %s\n', sjct, t_trial, num2str(duration_));
            expDes.expMat{expDes.sjctNum}(t_trial,2) = duration_;
        end
                
        % Send reward
        if const.chair
            if ~reward2 && expDes.expMat{expDes.sjctNum}(t_trial,9) == 1
                send_reward(mc.RW, const.reward2_rev);reward2=1;
            end
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
                expDes.expMat{expDes.sjctNum}(t_trial,9) = -7; % response_val
                expDes.expMat{expDes.sjctNum}(t_trial,10) = NaN; % reaction_time
                offset = vbl;
                fprintf(const.log_fid,'offset %s trial %i at %s\n', sjct, t_trial, num2str(offset));
                expDes.expMat{expDes.sjctNum}(t_trial,18) = offset;
                duration_ = offset - onset;
                fprintf(const.log_fid,'duration %s trial %i at %s\n', sjct, t_trial, num2str(duration_));
                expDes.expMat{expDes.sjctNum}(t_trial,2) = duration_;
                fprintf(const.log_fid,'quit_program at %s\n', num2str(offset));
                break
            end
        end
        
        % Make video
        if const.mkVideo
            vid_num = vid_num + 1;
            image_vid = Screen('GetImage', scr.main);
            imwrite(image_vid,sprintf('%s_frame_%i.png',const.movie_image_file,vid_num));
            writeVideo(const.vid_obj,image_vid);
        end
    end
end

% Blank screen if incorrect trial
if expDes.expMat{expDes.sjctNum}(t_trial,9) ~= 1 || expDes.expMat{expDes.sjctNum}(t_trial,9) ~= 0
    Screen('FillRect',scr.main,const.gray);
    Screen('Flip',scr.main);
end

if const.checkTrial && const.expStart == 0
    switch expDes.expMat{expDes.sjctNum}(t_trial,9)
        case 1;  resp_txt = 'correct touch and response';
        case 0;  resp_txt = 'correct touch and incorrect response';
        case -1; resp_txt = 'no touch or no release without movement';
        case -2; resp_txt = 'unprecise touch';
        case -3; resp_txt = 'correct touch but no release';
        case -4; resp_txt = 'unprecise response';
        case -5; resp_txt = 'too_early_response';
        case -6; resp_txt = 'no_response';
        case -7; resp_txt = 'quit program';
    end
    fprintf(1,'\n\tResponse               :   %s\n',resp_txt);
    fprintf(1,'\n\tRT                     :   %1.2f seconds\n',expDes.expMat{expDes.sjctNum}(t_trial,10));
end
end