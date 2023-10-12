function [vaDeg]= pix2vaDeg (pix,scr)
% ----------------------------------------------------------------------
% [vaDeg]= pix2vaDeg (pix,scr)
% ----------------------------------------------------------------------
% Goal of the function :
% Convert pixel in visual angle
% ----------------------------------------------------------------------
% Input(s) :
% pix   = size in pixel                                ex : = 1
% scr   = screen configurations : scr.scr_sizeX (pix)  ex : = 1024
%                                 scr.scr_sizeY (pix)  ex : = 768
%                                 scr.disp_sizeX (mm)  ex : = 400
%                                 scr.disp_sizeY (mm)  ex : = 300
%                                 scr.dist (cm)        ex : = 60
% ----------------------------------------------------------------------
% Output(s):
% vaDeg = size in visual angle (degree)                ex : = 35
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last edit : 30 / 10 / 2008
% Project : All
% Version : 1.0
% ----------------------------------------------------------------------

[cmX,cmY]=pix2cm(pix,scr);
[vaDeg] = cm2vaDeg([cmX,cmY],scr);

end
