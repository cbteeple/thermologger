function varargout = ThermoLogger_MAIN(varargin)
% THERMOLOGGER_MAIN MATLAB code for ThermoLogger_MAIN.fig
%      THERMOLOGGER_MAIN, by itself, creates a new THERMOLOGGER_MAIN or raises the existing
%      singleton*.
%
%      H = THERMOLOGGER_MAIN returns the handle to a new THERMOLOGGER_MAIN or the handle to
%      the existing singleton*.
%
%      THERMOLOGGER_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THERMOLOGGER_MAIN.M with the given input arguments.
%
%      THERMOLOGGER_MAIN('Property','Value',...) creates a new THERMOLOGGER_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ThermoLogger_MAIN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ThermoLogger_MAIN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ThermoLogger_MAIN

% Last Modified by GUIDE v2.5 10-Jan-2018 14:46:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ThermoLogger_MAIN_OpeningFcn, ...
                   'gui_OutputFcn',  @ThermoLogger_MAIN_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ThermoLogger_MAIN is made visible.
function ThermoLogger_MAIN_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ThermoLogger_MAIN (see VARARGIN)

% Choose default command line output for ThermoLogger_MAIN
handles.output = hObject;
handles.MainFile = mfilename;

%Switch the folder
    fullpath=mfilename('fullpath');
    idx=strfind(fullpath,'\');
    currPath=fullpath(1:idx(end))
    cd(currPath)
    

  ise = evalin( 'base', 'exist(''s_ThermoLogger'',''var'') == 1' );
    if ~ise %If the serial device has not been set up, run the 
        handles.closeFigure = true;
        
        assignin('base', 'handles', handles);
        SerialSetup; 
    else
             
        evalin('base','s_ThermoLogger');

        pause(1);

        handles.s=evalin('base','s_ThermoLogger');

            %Add all all of the subfolders of the App's folder to the MATLAB path.
                MyPath = pwd;
                addpath(genpath(MyPath), '-end');
        
        %Define the Thermologger's address
        handles.address=940; %Ours is address 940 for some reason 
                
     %Start the timer
        time_step = 1;
        handles.t_Collect = timer;
        handles.t_Collect.TimerFcn =...
            @(~, ~)DataCollectionFcn(hObject, eventdata, handles);
        handles.t_Collect.ExecutionMode = 'fixedRate';
        handles.t_Collect.Period = time_step;
        handles.t_Collect.BusyMode = 'drop';               
    
    
    
    %Set up the plot
        axes(handles.Graph0);
        hold on  
        handles.plot_h=plot([0],[0],'b');
        handles.plot_h.LineWidth=1.5;
        handles.plot_h.XData=[];
        handles.plot_h.YData=[];
        ylabel('Temperature (\circC)');
        xlabel('Time (sec)');
        set(gca,'FontSize',14);
        handles.currStep=1;
        handles.startSample=1;
    
    %Set up the Data
        timestamp = clock;
        handles.startTime = timestamp(6)+60*timestamp(5)+3600*timestamp(4);
        handles.T1=[];
        handles.T2=[];
        handles.sec=[];
    
    %Set up the Save File 
        if(~exist('data','dir'))
            mkdir('data');
        end
        
        dateStr=datestr(now,'yyyy_mm_dd---HH,MM,SS');
        filename = ['DATA---',dateStr,'.txt'];
        
        handles.dataFileDir=['data/',dateStr,'/'];
        mkdir(handles.dataFileDir);
        
        handles.dataFileID = fopen([handles.dataFileDir,filename],'a');
    end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ThermoLogger_MAIN wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ThermoLogger_MAIN_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if (isfield(handles,'closeFigure') && handles.closeFigure)
      figure1_CloseRequestFcn(hObject, eventdata, handles)
end



% --- Executes on button press in Start.
function Start_Callback(hObject, eventdata, handles)
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Start

start(handles.t_Collect);



% --- Executes on button press in Stop.
function Stop_Callback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Stop

stop(handles.t_Collect);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 evalin( 'base', 'clear(''s_ThermoLogger'')' );
 
 fclose('all');
 instrreset

% Hint: delete(hObject) closes the figure
delete(hObject);



function DataCollectionFcn(hObject, eventdata, handles)
%Collect data from the ThermoLogger
    %Get gui handles
        handles = guidata( hObject );
        i = handles.currStep;
        startSample=handles.startSample;

    %Get the data
        disp(['i=',num2str(handles.currStep),' ________________________']);
        
        [T1, T2,err] = HH506RA_ReadBuff(handles.s,handles.address);
        disp('Read the Buffer')
       disp(['err=',num2str(err)]);        
        %[T1, T2,err] = HH506RA_Read(handles.s);
        
        switch err
            case 1
                warning('ERROR 1: No data was recieved');
                return
            case 2
                warning('ERROR 2: An error occured on the TempLogger')
                return
            case 3
                warning('ERROR 3: No Data')
                return
        end
    
        handles.T1(i)=T1;
        handles.T2(i)=T2;
        
    %Get the time
        timestamp = clock;
        handles.sec(i)= timestamp(6)+60*timestamp(5)+3600*timestamp(4)...
                        -handles.startTime;
    
    %Plot everything
        handles.plot_h.XData=handles.sec(startSample:i);
        handles.plot_h.YData=handles.T1(startSample:i); %Only Plot T1
        drawnow
 
    %Save Stuff
         fprintf(handles.dataFileID,'%0.5f\t%0.3f\t%0.3f\n',...
             handles.sec(i),handles.T1(i),handles.T2(i));
 
    %Increment the counter
        i=i+1;
        handles.currStep=i;
        
 guidata(handles.figure1, handles);



function sampleTime_Callback(hObject, eventdata, handles)
% hObject    handle to sampleTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sampleTime as text
%        str2double(get(hObject,'String')) returns contents of sampleTime as a double

str=get(hObject,'String');
if isempty(str2num(str))
    sampletime = handles.t_Collect.Period;
    warndlg('Input must be numerical');
elseif str2num(str)<1
    sampletime = handles.t_Collect.Period;
    warndlg({'Input must be greater than 1.0 sec.';'This is an OLD piece of equipment'});
else
    
    sampletime=str2num(str);
    
end
%     d = 3; %// number of digits
% 
%     D = 10^(d-ceil(log10(sampletime)));
%     y = round(sampletime*D)/D;
    sampletime
    handles.t_Collect.Period=str2num(num2str(sampletime,'%0.2f'));
    set(hObject,'string',num2str(sampletime,'%0.2f'));
    
guidata(handles.output, handles);



% --- Executes during object creation, after setting all properties.
function sampleTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampleTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ClearButton
        handles.plot_h.XData=[];
        handles.plot_h.YData=[]; %Only Plot T1
handles.startSample = handles.currStep;
guidata(handles.output, handles);
