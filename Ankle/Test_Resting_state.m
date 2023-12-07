% Ergometer_Baseline_MVC.m
%
% 23 Aug., 2023
%
% You can uncomment the coding to enter the name of the subject_ID and the preferred language...
%
% The Baseline will be firstly started and saved for the MVC measurement.
% Subject should relax and sit still while during the recording...
% Afterward, subject squeezes as hard as possible for at least two times for the MVC measurements.
%
% The Baseline and three MVC measurements will be saved in the current folder.
% The variables in the workspace will be saved and exported for the further usage.
%
% Paramenters:
%     Subject_ID :   "EEG"
%     lang (fr/eng): "eng"
%
% Triggers:
%     "0" : the onset of Baseline measurement.
%     "1" : the onset of MVC measurement.
%     "2" : the offset of MVC measurement.
%
% Default variables:
%     Baseline_duration         : 10s
%     MVC_duration              : 3s
%     Rest_duration             : 3mins (180s)
%     Ready_duration            : 5s
%     MVC_measurement_n         : 3 times
%
% OUTPUT:
%     SubjectID_Baseline.mat    : the recorded torque as the Baseline.
%     SubjectID_MVC_n.mat       : the recorded torque as the maximal voluntary contraction.
%     Variables.mat             : the screen setup variables, calculated Baseline and MVC values for the fatigue experiment.

clear, close all,  clc

%% Data aqusition with NI
DebugMode = 0; % If 1,(debug) small screen

%% Participant ID
Subject_ID='EEG'
Lang='eng';

%% Creat Parallel port
if ~DebugMode
    t = serialport('COM1', 9600) ;
    ioObj=io64;%create a parallel port handle
    status=io64(ioObj);%if this returns '0' the port driver is loaded & ready
    address=hex2dec('03F8') ;

    %fopen(t) ;
end

%% Experiment Set-up
PER = 0.7 ;                                                                 % Percentage of the inner screen to be used.

% other color
green   = [0 255 0];
red     = [255 0 0];
orange  = [255 100 0];
grey    = [200 200 200];

%% Screen set-up
sampleTime      = 1/60;                                                     % screen refresh rate at 60 Hz (always check!!)

Priority(2);                                                                % raise priority for stimulus presentation
screens=Screen('Screens');
screenid=max(screens);
white=WhiteIndex(screenid);                                                 % Find the color values which correspond to white and black: Usually
black=BlackIndex(screenid);                                                 % black is always 0 and white 255, but this rule is not true if one of
% the high precision framebuffer modes is enabled via the
% PsychImaging() commmand, so we query the true values via the
% functions WhiteIndex and BlackIndex
Screen('Preference', 'SkipSyncTests', 1);                                   % You can force Psychtoolbox to continue, despite the severe problems, by adding the command.

if DebugMode % Use this smaller screen for debugging
    [theWindow,screenRect] = Screen('OpenWindow',screenid, black,[500 100 1500 1000],[],2);
else
    [theWindow,screenRect] = Screen('OpenWindow',screenid, black,[],[],2);
    HideCursor;
end

oldTextSize=Screen('TextSize', theWindow, 55);                              % Costumize the textsize witht the monitor.

scrnWidth   = screenRect(3) - screenRect(1);
scrnHeight  = screenRect(4) - screenRect(2);

% Inner screen
frameWidth=(scrnHeight-PER *scrnHeight)/2; 
InScr=floor([screenRect(1:2)+frameWidth screenRect(3:4)-frameWidth]);
inScrnWidth  = InScr(3)-InScr(1);
inScrnHeight = InScr(4)-InScr(2);

cross_x= floor([(InScr(1)+ InScr(3))/2-inScrnWidth/20 , (InScr(2)+ InScr(4))/2-inScrnHeight/50, (InScr(1)+ InScr(3))/2+inScrnWidth/20 , (InScr(2)+ InScr(4))/2+inScrnHeight/50]);
cross_y= floor([(InScr(1)+ InScr(3))/2-inScrnWidth/50 , (InScr(2)+ InScr(4))/2-inScrnHeight/20, (InScr(1)+ InScr(3))/2+inScrnWidth/50 , (InScr(2)+ InScr(4))/2+inScrnHeight/20]);


%% RS

RS_duration=300;

switch Lang
    case 'eng'
        text1 = ['Please fix your eyes on the cross.']
        text2 = ['Resting state recording is done.']
    case 'fr'
        text1 = ['Préparez-vous à serrer votre main le plus fort possible pour ',num2str(trialTime),' secondes'];
end

if ~DebugMode  io64(ioObj,address,1); end

DrawFormattedText(theWindow, text1,'center','center',255);
Screen(theWindow,'Flip',[],0);
WaitSecs(3);

startTime = GetSecs;
while GetSecs < startTime + RS_duration;
        ClosePTB
        %RS_disp=[num2str(RS_duration-round(GetSecs-startTime)),'s'];
        %DrawFormattedText(theWindow,[RS_disp],'center','center', white,255);
        Screen('FillRect', theWindow, white,cross_x)
        Screen('FillRect', theWindow, white,cross_y)
        Screen(theWindow,'Flip',[],0);

 end ;

if ~DebugMode  io64(ioObj,address,2); end

DrawFormattedText(theWindow, text2,'center','center',255);
Screen(theWindow,'Flip',[],0);
WaitSecs(3);

%% End

%if ~DebugMode fclose(t); end

Screen('CloseAll');
