function [rdk] = compute_rdk(scr,const,stim)
% -------------------------------------------------------------------------
% [dots] = compute_rdk(const)
% -------------------------------------------------------------------------
% Goal of the function :
% Compute random dot kinematogram stimulus masks (patches of randomly
% moving dots), and signal item (patch with coherent motion).
% -------------------------------------------------------------------------
% Input(s) :
% scr : screen settings
% const : general settings
% -------------------------------------------------------------------------
% Output(s):
% rdk : all settings to draw rdks
% -------------------------------------------------------------------------
% Function created by Martin Szinte (martin.szinte@gmail.com)
% Last update : 15 / 05 / 2021
% Project :     MarmStim
% Version :     2.0
% -------------------------------------------------------------------------

% define matrix of distractor and test
dotSet.xyd              = [const.stim_coords,const.rdk_rad*2];          % x coord / y coord / diameter
dotSet.durBef           = stim.durBef_nbf;                              % before the signal
dotSet.durAft           = 0;                                            % after the signal
dotSet.dirS             = stim.theta_signal;
dotSet.kappaVal         = stim.kappa_signal;
const.frame_dur         = scr.frame_duration;
rdk                     = comp_randomDots1(const,dotSet);

end

function dots = comp_randomDots1(const,dotSet)
% ----------------------------------------------------------------------
% dots = comp_randomDots1(const,dotSet)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute details of random dot stimuli corresponding to the probe 
% signal. Made for only one signal inside noise.
% ----------------------------------------------------------------------
% Input(s) :
% const = constant of the experiment
% dotSet.dirSignal = direction of the signal
% dotSet.posAngle = angle of the centre of the patch to compute
% dotSet.durBef = duration of first motion phase
% dotSet.durAft = duration of second motion phase
% dotSet.kappaVal = kappa value of the von misses distribution of direction
% ----------------------------------------------------------------------
% Output(s):
% dots : struct containing all dots informations
% ----------------------------------------------------------------------
% Function created by Martin Szinte (martin.szinte@gmail.com)
% Last update : 03 / 02 / 2021
% Project :     MarmStim
% Version :     1.0
% ----------------------------------------------------------------------

% Create information for dots in first motion phase
dinf1 = genVonMisesLimLifeDotInfo(const,dotSet.xyd);
dinf1.dur = const.frame_dur*dotSet.durBef;
dinf1.nfr = dotSet.durBef;

% Create information for dots in second motion phase
dinf2 = genVonMisesLimLifeDotInfo(const,dotSet.xyd);
dinf2.dur = const.frame_dur*const.signal_nbf;
dinf2.nfr = const.signal_nbf;

% Change kappa for test patch (randomly chose above)
dinf2.kap = dotSet.kappaVal;   % kappa of 10 should be clearly visible
dinf2.the = dotSet.dirS;
dinf2.spd = const.dotSpeed_pix * const.sigDotSpeedMulti; 

% Create information for dots in second motion phase
dinf3 = genVonMisesLimLifeDotInfo(const,dotSet.xyd);
dinf3.dur = const.frame_dur*dotSet.durAft;
dinf3.nfr = dotSet.durAft;

% Generate integrated motion paths for dots (comprising all three phases)
dots1  = getVonMisesLimLifeDotData(const,dinf1);
dots2  = addVonMisesLimLifeDotData(const,dinf2,dots1);

if dotSet.durAft ~= 0
	dots(1) = addVonMisesLimLifeDotData(const,dinf3,dots2);
else
    dots(1) = dots2(1);
end
end

function dinf = genVonMisesLimLifeDotInfo(const,xyd)
% Version 1.0, Feb 2012 by Martin Rolfs
% Modified by Martin Szinte, 14 Jan 2014
%           - add dotSize
%           - add scr as input and use my own conversion in pix
%           - add const as input to be used in my codes
% NH :      - took out scr; (9.4.2019)
%           - changed deg to pix

dinf.xyd = xyd;                                     % center and diameter of patch [deg]
dinf.spd_pix = const.dotSpeed_pix;                  % speed [pix/dec]
dinf.the = const.theta_noise;                       % theta parameter of von Mises, main direction [degrees]
dinf.kap = const.kappa_noise;                       % kappa parameter of von Mises, spread of direction [0 = evenly distributed]
dinf.dur = 1;                                       % maxDotTime [sec]
dinf.col = repmat(const.white(1),1,3);           % white dots default [rgb]
dinf.siz = const.dotRadSize;                        % dot size [pix]
dinf.lif = [const.numMinLife const.numMeanLife];	% life time parameters (minimum and mean) [frames]

% define number of dots based on density per deg^2.
% This value is taken from Ball & Sekuler (1987, Experiments 3 to 6).
dinf.num = const.numDots;

% black and white dots only
dinf.col = repmat(round(rand(1,dinf.num)),3,1).*repmat(dinf.col,dinf.num,1)';

% we can make each dot have a different size by changing the siz matrix
dinf.siz = repmat(dinf.siz,1,dinf.num);
% % example of varying sizes: 
% dinf.siz = repmat(dinf.siz,1,dinf.num)+3*rand(1,dinf.num).*repmat(dinf.siz,1,dinf.num);
end

function dots = getVonMisesLimLifeDotData(const,dots)
% Version 1.0, Feb 2012 by Martin Rolfs
% Modified by Martin Szinte, 21 Jan 2016
%           - add scr as input and use my own conversion in pix
% NH :      - took out scr; (9.4.2019)
%           - changed deg to pix

% locate position of patch in screen coordinates
dots.cent = dots.xyd(1:2);
dots.diam = dots.xyd(3);

% define initial dot positions and reposition dots outside the aperture
dots.posi{1} = (rand(dots.num, 2)-0.5) * dots.diam; 
out = sqrt(dots.posi{1}(:,1).^2 + dots.posi{1}(:,2).^2) > dots.diam/2;
while sum(out)
    dots.posi{1}(out==1,:) = (rand(sum(out), 2)-0.5) * dots.diam;
    out = sqrt(dots.posi{1}(:,1).^2 + dots.posi{1}(:,2).^2) > dots.diam/2;
end

% draw directions from von Mises distribution
dots.dirs = circ_vmrnd(dots.the*pi/180,dots.kap,dots.num)/pi*180;

% define life times
dots.life{1} = ones(1,dots.num);

for f = 2 : round(dots.dur / const.frame_dur)
    % displacement per frame for each dot
    dxdy(:,1:2) = const.frame_dur * dots.spd_pix * [cos(pi*dots.dirs/180) -sin(pi*dots.dirs/180)];
    
    % update position of all dots
    dots.posi{f} = dots.posi{f-1} + dxdy;
    
    % wrap around if out of circular aperture
    wrap = sqrt(dots.posi{f}(:,1).^2 + dots.posi{f}(:,2).^2) > dots.diam/2;
    
    if sum(wrap) > 0
        % wraps it to a position on the opposite half of the circle
        wrapphi = pi*dots.dirs(wrap)/180 + pi/2 + rand(sum(wrap),1)*pi;
        wrapamp = dots.diam/2;
        
        [wrapx,wrapy] = pol2cart(wrapphi,wrapamp);
        dots.posi{f}(wrap==1,:) = [wrapx -wrapy];
    end
    
    % decide which dots end their life time and, thus, change position
    ranLife = dots.lif(1)+exprnd(dots.lif(2)-dots.lif(1),1,dots.num);   % life times drawn from exponential distribution
    newLife(dots.life{f-1}< ranLife) = false;
    newLife(dots.life{f-1}>=ranLife) = true;
    
    % update lifetime
    dots.life{f}( newLife)   = 1;
    dots.life{f}(~newLife)   = dots.life{f-1}(~newLife)+1;

    % replace dots that begin a new life
    dots.posi{f}(newLife,:) = (rand(sum(newLife), 2)-0.5) * dots.diam;
    
    % make sure they are all inside the aperture
    out = sqrt(dots.posi{f}(:,1).^2 + dots.posi{f}(:,2).^2) > dots.diam/2;
    while sum(out)
        dots.posi{f}(out==1,:) = (rand(sum(out), 2)-0.5) * dots.diam;
        out = sqrt(dots.posi{f}(:,1).^2 + dots.posi{f}(:,2).^2) > dots.diam/2;
    end
    
    % draw new direction for dots that begin a new life
    dots.dirs(newLife) = circ_vmrnd(dots.the*pi/180,dots.kap,sum(newLife))/pi*180;
end
end

function dots = addVonMisesLimLifeDotData(const,dots,dots0)
% Version 1.0, Feb 2012 by Martin Rolfs
% Modified by Martin Szinte, 21 Jan 2016
%           - add scr as input and use my own conversion in pix
% NH :      - took out scr; (9.4.2019)
%           - changed deg to pix

dots.cent = dots.xyd(1:2);
dots.diam = dots.xyd(3);

% change directions for each new phase
dots.dirs = circ_vmrnd(dots.the*pi/180,dots.kap,dots.num)/pi*180;

for f = 1 : round(dots.dur / const.frame_dur)
    % displacement per frame for each dot
    dxdy(:,1:2) = const.frame_dur * dots.spd_pix * [cos(pi*dots.dirs/180) -sin(pi*dots.dirs/180)];

    % update position of all dots
    if f == 1
        dots.posi{f} = dots0.posi{end} + dxdy;
    else
        dots.posi{f} = dots.posi{f-1} + dxdy;
    end
        
    % wrap around if out of circular aperture
    wrap = sqrt(dots.posi{f}(:,1).^2 + dots.posi{f}(:,2).^2) > dots.diam/2;
    
    if sum(wrap) > 0
        % wraps it to a position on the opposite half of the circle
        wrapphi = pi*dots.dirs(wrap)/180 + pi/2 + rand(sum(wrap),1)*pi;
        wrapamp = dots.diam/2;
        
        [wrapx,wrapy] = pol2cart(wrapphi,wrapamp);
        dots.posi{f}(wrap==1,:) = [wrapx -wrapy];
    end
    
    % decide which dots end their life time and, thus, change position
    ranLife = dots.lif(1)+exprnd(dots.lif(2)-dots.lif(1),1,dots.num);   % life times drawn from exponential distribution
    if f == 1
        newLife(dots0.life{end}< ranLife) = false;
        newLife(dots0.life{end}>=ranLife) = true;
        
        % update lifetime
        dots.life{f}( newLife)   = 1;
        dots.life{f}(~newLife)   = dots0.life{end}(~newLife)+1;
    else
        newLife(dots.life{f-1}< ranLife) = false;
        newLife(dots.life{f-1}>=ranLife) = true;
        
        % update lifetime
        dots.life{f}( newLife)   = 1;
        dots.life{f}(~newLife)   = dots.life{f-1}(~newLife)+1;
    end
    
    % replace dots that ended their lifetime
    dots.posi{f}(newLife,:) = (rand(sum(newLife), 2)-0.5) * dots.diam; 
     
    % make sure they are all inside the aperture
    out = sqrt(dots.posi{f}(:,1).^2 + dots.posi{f}(:,2).^2) > dots.diam/2;
    while sum(out)
        dots.posi{f}(out==1,:) = (rand(sum(out), 2)-0.5) * dots.diam;
        out = sqrt(dots.posi{f}(:,1).^2 + dots.posi{f}(:,2).^2) > dots.diam/2;
    end
    
    % draw new direction for dots that begin a new life
    dots.dirs(newLife) = circ_vmrnd(dots.the*pi/180,dots.kap,sum(newLife))/pi*180;
end

dots.posi = [dots0.posi dots.posi];
dots.life = [dots0.life dots.life];
end

function alpha = circ_vmrnd(theta, kappa, n)
% alpha = circ_vmrnd(theta, kappa, n)
%   Simulates n random angles from a von Mises distribution, with preferred 
%   direction thetahat and concentration parameter kappa.
%
%   Input:      [theta    preferred direction, default is 0]
%               [kappa    width, default is 1]
%               [n        number of samples, default is 10]
%
%   If n is a vector with two entries (e.g. [2 10]), the function creates
%   a matrix output with the respective dimensionality.
%
%   Output:     alpha     samples from von Mises distribution
%   References: Statistical analysis of circular data, Fisher, sec. 3.3.6, p. 49
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens and Marc J. Velasco, 2009
% velasco@ccs.fau.edu

% default parameter
if nargin < 3;  n = 10;end
if nargin < 2;  kappa = 1;end
if nargin < 1;  theta = 0;end

if numel(n) > 2; error('n must be a scalar or two-entry vector!')
elseif numel(n) == 2; m = n; n = n(1) * n(2);
end  

% if kappa is small, treat as uniform distribution
if kappa < 1e-6; alpha = 2*pi*rand(n,1);return;end

% other cases
a = 1 + sqrt((1+4*kappa.^2));
b = (a - sqrt(2*a))/(2*kappa);
r = (1 + b^2)/(2*b);

alpha = zeros(n,1);
for j = 1:n
  while true
      u = rand(3,1);
      z = cos(pi*u(1));
      f = (1+r*z)/(r+z);
      c = kappa*(r-f);
      if u(2) < c * (2-c) || ~(log(c)-log(u(2)) + 1 -c < 0)
         break
      end
  end
  alpha(j) = theta +  sign(u(3) - 0.5) * acos(f);
  alpha(j) = angle(exp(1i*alpha(j)));
end

if exist('m','var')
  alpha = reshape(alpha,m(1),m(2));
end
end