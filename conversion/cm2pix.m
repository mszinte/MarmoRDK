function [pixX, pixY] = cm2pix(cm,scr)
% ----------------------------------------------------------------------
% [pixX, pixY] = cm2pix(cm,scr)
% ----------------------------------------------------------------------
% Goal of the function :
% Convert cm in pixel ( x and y )
% ----------------------------------------------------------------------
% Input(s) :
% cm    = size in cm                                   ex : cm = 10
% scr   = screen configurations : scr.scr_sizeX (pix)  ex : = 1024
%                                 scr.scr_sizeY (pix)  ex : = 768
%                                 scr.disp_sizeX (mm)  ex : = 400
%                                 scr.disp_sizeY (mm)  ex : = 300
% ----------------------------------------------------------------------
% Output(s):
% pixX  = size in pixel(X)                             ex : = 35
% pixY  = size in pixel(Y)                             ex : = 25.35
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last edit : 30 / 10 / 2008
% Project : All
% Version : 1.0
% ----------------------------------------------------------------------

pix_by_mmX = scr.scr_sizeX/scr.disp_sizeX;
pix_by_mmY = scr.scr_sizeY/scr.disp_sizeY;

pixX = cm.*10.*pix_by_mmX;
pixY = cm.*10.*pix_by_mmY;

end