%% General experimenter launcher
%  =============================
% By :      Martin SZINTE
% Projet :  MarmoRDK
% With :    Guillaume MASSON & Guilhem IBOS

% Version description
% ===================

% Design : 

% - training :  1. go in marmoset chair
%               2. touch & release button press
%               3. release button press
%               4. correct response button press with short SOA + easy signal strenght
%               5. correct response button press with middle SOA + easy signal strenght
%               6. correct response button press with long SOA + easy signal strenght
%               7. correct response button press with long SOA + intermediate signal strenght
%               8. correct response button press with long SOA + hard signal strenght

% - main task:  random SOA and random signal strengh

% Trial timecourse :    . init_touch : a circle until monkey touch and release of button
%                       . reward_touch : reward given and prenseaton for 1 second of a fixation mark on stim center
%                       . rdk_resp : noise stimulus (random of rdk 75 to 500 ms between blocks)
%                       .            followed by signal stimulus (right or left ~800 ms coherent RDK at 5 possible level of orientation dispersion)
%                       .            shown toghether with two buttons shown until response with a timeout of 1 second 
%                       . reward_resp_iti : inter-trial interval with reward given for correct response 

% To do
% -----

% check saving of data
% code training with training level per animal
% think how to analyse data

% First settings
% --------------
Screen('CloseAll'); clear all;clear mex;clear functions; close all; home; AssertOpenGL; instrreset;

% General settings
% ----------------
const.expName           =   'MarmoRDK';     % experiment name
const.expStart          =   0;              % Start of a recording exp                  0 = NO  , 1 = YES
const.checkTrial        =   1;              % Print trial conditions (for debugging)    0 = NO  , 1 = YES
const.mkVideo           =   0;              % Make a video of a run                     0 = NO  , 1 = YES
const.genStim           =   0;              % Generate the stimuli                      0 = NO  , 1 = YES

% External controls
% -----------------
const.chair             =   0;              % Use of the NHP Smart System Interface     0 = NO  , 1 = YES
const.training          =   0;              % Training or main mode                     0 = Main, 1 = Training
const.training_step     =   0;              % Training steps                            (see above)

% Marmoset ID
% -----------
const.marmo_ID          =   {   '551_090635065187',...                                  % marmoset #1 old tag
                                '551_090635065204',...                                  % marmoset #2 old tag
                                '551_090635059034',...                                  % marmoset #3 old tag
                                '551_090635077713',...                                  % marmoset #4 old tag
                                '551_090635077718',...                                  % marmoset #1 new tag
                                '551_090635050081',...                                  % marmoset #2 new tag
                                '551_090635064683',...                                  % marmoset #3 new tag
                                '551_090635066231'};                                    % marmoset #4 new tag               
                            
% Path
% ----
dir                     =   (which('expLauncher'));
cd(dir(1:end-18));
addpath('config','main','conversion','trials','stim','rogue');

% Desired screen setting
% ----------------------
const.desiredFD         =   66;            % Desired refresh rate
const.desiredRes        =   [480,800];     % Desired resolution

% Subject configuration
% ---------------------
[const]                 =   sbjConfig(const);

% Main run
% --------
main(const);