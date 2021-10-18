function [s] = HH506RA_Init(COM)
%HH506RA_INIT Sets up the serial object for a HH506RA Thermometer. This is
%meant to be used in conjuction with HH506RA_ReadBuff function.
% 
% [s] = HH506RA_Init(COM)
%
% INPUTS:
%     COM - a string with the name of the serial port you want to open
%
% OUTPUTS:
%     s - the serial object with the correct serial settings specified.
%         (baud rate, data bits, pairity, and stop bits)
%
% EXAMPLE:
%     COM='COM24';
%     address = 940; %Woodlab's Thermologger has this address
%
%     s = HH506RA_Init(COM);
%     fopen(s);
%
%     [T1, T2, err] = HH506RA_ReadBuff(s, address)
%     
%     if ~err
%         disp(['T1 = ',num2str(T1),', T2 = ',num2str(T2)]);
%     end
%
% _________________________________________________________________________
% CREDIT:
%    This script is based on a script by Brian Keats
%    https://www.mathworks.com/matlabcentral/fileexchange/11739-omega-hh506ra-read
%
%    Modified by Clark Teeple, Harvard University, Jan. 14, 2018

s = serial(COM);
s.BaudRate = 2400;
s.DataBits=7;
s.Parity = 'Even';
s.StopBits=1;


end

