function [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% [expDes]=designConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define experimental design
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% expDes : struct containg experimental design
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 22 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

%% Experimental random variables
rng('default');rng('shuffle');

% Rand 1 : mvt direction (2 modalities)
% ====== 
expDes.oneR = [1;2];
expDes.txt_rand1 = {'0 deg','180 deg'};
% 01 = 0 deg (right)
% 02 = 180 deg (left)

% Rand 2 : signal soa (5 modalities)
% ======
expDes.twoR = [1:const.signal_soa_num]';
expDes.txt_rand2 = {'75 ms','136 ms','258 ms','379 ms','500 ms'};
% 01 =  ~75 msec
% 02 = ~136 msec
% 03 = ~258 msec
% 04 = ~379 msec
% 05 =  500 msec

% Rand 3 : signal coherence (5 modalities)
% ======
expDes.threeR = [1:const.kappa_levels]';
expDes.txt_rand3 = {'kappa = 0','kappa = 2.5','kappa = 5.0','kappa = 7.5','kappa = 10'};
% 01 = kappa: 0 (random)
% 02 = kappa: 2.5
% 03 = kappa: 5.0
% 04 = kappa: 7.5
% 05 = kappa: 10

% Rand 4 : stim sample (20 modalities)
% ======
expDes.fourR = [1:const.sample_num]';
expDes.txt_rand4 = { 'sample #01','sample #02','sample #03','sample #04','sample #05',...
                     'sample #06','sample #07','sample #08','sample #09','sample #10',...
                     'sample #11','sample #12','sample #13','sample #14','sample #15',...
                     'sample #16','sample #17','sample #18','sample #19','sample #20'};
% 01 = sample 1
% 02 = sample 2
% ...
% 20 = sample 20


% Experimental settings
% ---------------------
expDes.nb_rand = 4;
expDes.nb_trials = 10000;


% Experimental design decide before each trial

end