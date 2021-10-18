function [T1, T2, err] = HH506RA_ReadBuff(portObject, address)
%HH506RA_READBUFF Reads Temperature data from a HH506RA Digital
%Thermometer. This is meant to be used in conjuction with the 
%HH506RA_Init function.
%
% [T1, T2, err] = HH506RA_ReadBuff(portObject, address)
%
% INPUTS:
%     portObject - An open serial port object for your Thermologger 
%     address    - the Thermologger's address
%
% OUTPUTS:
%     T1  - Temperature on Thermocouple 1, 
%     T2  - Temperature on Thermocouple 2,
%     err - Error code
%         err=0 - No error
%         err=1 - No data was recieved even though serial data was sent
%         err=2 - There was an error on the HH506RA
%         err=3 - No serial data was recieved at all
%
%     ***Temperatures are in the units you specified on the thermometer
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
%    This script was informed by a script by Brian Keats
%    https://www.mathworks.com/matlabcentral/fileexchange/11739-omega-hh506ra-read
%
%    Written by Clark Teeple, Harvard University, Jan. 14, 2018


readCmd = ['#',num2str(address),'N'];
fprintf(portObject,readCmd);
buff = getSerialBuffer(portObject)



if length(buff)<1
    err=3;
    T1 = 'Error';
    T2 = 'Error';
   return 
end

data=buff{1};

for i=1:length(buff)
    if ~isempty(buff{i})
        data=buff{i};
        break
    end
end

if isempty(data)
    err=1;
    T1 = 'Error';
    T2 = 'Error';
elseif contains(data,'Err')
    err=2;
    T1 = 'Error';
    T2 = 'Error';
else
    err=0;
    
    T1 = sscanf(data(2:5),'%x')/10;
    if data(1) == '-'
        T1 = -1*T1;
    end
    
    T2 = sscanf(data(8:11),'%x')/10;
    if data(7) == '-'
        T1 = -1*T1;
    end

end