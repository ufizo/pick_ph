function varargout = pick_ph(varargin)
% PICK_PH MATLAB code for pick_ph.fig
%
% A user interfacet to pick phases and assign quality to data
% output by icorrect.
% http://www.seismotoolbox.ca/icorrect.html
%
% Saves the data in a catalogue file, stored in the
% root of the work directory.
%
% Arpit Singh
% me@arpitsingh.in
%
% Last Modified by GUIDE v2.5 28-May-2013 23:00:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pick_ph_OpeningFcn, ...
                   'gui_OutputFcn',  @pick_ph_OutputFcn, ...
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


% --- Executes just before pick_ph is made visible.
function pick_ph_OpeningFcn(hObject, eventdata, handles, varargin)
% Default work directory when program is loaded
%folder_name = '/home/ufizo/work';
folder_name = '/home/';
set(handles.work_dir,'string',folder_name);
load_listBox(folder_name,handles);

%Check if listBox is empty, and check for catalogue
checkdata(handles);

% Choose default command line output for pick_ph
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pick_ph wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pick_ph_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press to load the work directory, or the 
% directory which contains the data processed by icorrect
function pushbutton1_Callback(hObject, eventdata, handles)
folder_name = uigetdir('/home/','Select your DATA dir');
set(handles.work_dir,'string',folder_name);
% populate the listbox, with these directories
load_listBox(folder_name,handles);
% Check if this directory has the data as output by icorrect
checkdata(handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over work_dir.
function work_dir_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes when a event directory is selected in the first listbox
% Reads the channels in the subdirectory, and loads them
function listbox1_Callback(hObject, eventdata, handles)

dir_list = get(handles.listbox1,'String');
path1= strcat(get(handles.work_dir,'string'),'/',dir_list(get(handles.listbox1,'value')));
load_listBox2(path1{1},handles);
set(handles.text5,'Visible','on');
set(handles.listbox2,'Visible','on');
%update_plots(handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% To populate the listbox with the list of events, present
% in the work directory.
% Assumption: directory names for events start with dir_
function load_listBox(dir_path,handles)
cd (dir_path)
dir_struct = dir('dir_*');
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.listbox1,'String',handles.file_names,'Value',1)
cellsize = size(handles.file_names);
set(handles.n_events,'String',cellsize(1,1)) 


% To populate the second listbox with the list of channels
% contained in the selected event directory
% Assumption: channel directory names start with CN, this may only
% be true for Canadian stations? I am not sure.
function load_listBox2(dir_path,handles)
cd (dir_path)
dir_struct = dir('CN*');
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.listbox2,'String',handles.file_names,'Value',1)
cellsize = size(handles.file_names);
set(handles.n_chn,'String',cellsize(1,1)) ;


% To the paint the axes with the plots. 
% Acceleration/Dispalcement/Velocity plot based on the radio button
function update_plots(handles)
sr = getappdata(handles.figure1, 'sr');
sr = str2num(sr{1});

switch get(handles.uipanel4,'SelectedObject')
    case handles.radiobutton8
        %Acceleration
        waveform = getappdata(handles.figure1, 'acc'); 
    case handles.radiobutton7
        %Velocity
        waveform = getappdata(handles.figure1, 'vel'); 
    case handles.radiobutton6
        %Displacement
        waveform = getappdata(handles.figure1, 'dis'); 
    case handles.radiobutton5
        %Original
        waveform = getappdata(handles.figure1, 'ori'); 
    otherwise
        waveform = getappdata(handles.figure1, 'acc'); 
end

t = 0:1/sr:(length(waveform)-1)/sr;
char=zeros(length(waveform),1);
num=1:length(waveform)-1;
char(num,1)=waveform(num).^2+3*(waveform(num+1)-waveform(num)).^2*sr.^2;
sqr_sum=cumsum(waveform.*waveform);
abs_sum=cumsum(abs(waveform));
sqr_sum=sqr_sum/sqr_sum(length(waveform));
abs_sum=abs_sum/abs_sum(length(waveform));

h1 = handles.axes1;
h2 = handles.axes4;
h3 = handles.axes5;
axes(h1);
plot (h1,t,waveform);
%vline ([150 200]);
plot (h3,t,char);
plot (h2,t,abs_sum);
plot (h2,t,sqr_sum,'Color','r');
load_picks(handles);
load_Q(handles);

% --- Executes on button press in Debug.
function Debug_Callback(hObject, eventdata, handles)
% Only used while developing this program, to access the 
% handles at the command prompt.
keyboard


% --- Executes on selection of a channel. 
function listbox2_Callback(hObject, eventdata, handles)
% Get the list of events, and the list of channels
dir_list1 = get(handles.listbox1,'String');
dir_list2 = get(handles.listbox2,'String');

%path_data= strcat(get(handles.work_dir,'string'),'/',dir_list1(get(handles.listbox1,'value')),'/',dir_list2(get(handles.listbox2,'value')),'/result_');
%waveform = load (path_data{1});
%update_plots(waveform,handles);

x = 0; i = 1;
% Path to the result.txt for the selected channel
path_data = fullfile(get(handles.work_dir,'string'),dir_list1(get(handles.listbox1,'value')),dir_list2(get(handles.listbox2,'value')),'result.txt');
fid = fopen(path_data{1},'rt');
R = {}; ev_date = {}; M = {}; depth = {}; sr = {};
% Loop till the end of the header, and read some info
while (~strcmpi(x,'END_HEADER'))
   x=fgetl(fid);
	[ev_date{i},m1] = regexp(x,'Event\sdate:\s+(\d+\/\d+\/\d+)','tokens','match');
	[depth{i},m2] = regexp(x,'Hypocentral\sdepth\(km\):\s+(\d+\.\d+)','tokens','match');
	[M{i},m3] = regexp(x,'Magnitude:\s+(\d+\.\d+)','tokens','match');
	[R{i},m4] = regexp(x,'Distance\sfrom\s\w+\s+:\s+(\d+\.\d+\skm)','tokens','match');
	[sr{i},m5] = regexp(x,'Sampling\srate:\s+(\d+\.\d+)','tokens','match');
	i = i + 1;
end

% I don't like regex in matlab, this is how I would have done it in Perl
% A better implementation may exist to select R, M, sr etc from the header.
R  = R{find(~cellfun(@isempty,R))}{1};
ev_date  = ev_date{find(~cellfun(@isempty,ev_date))}{1};
depth  = depth{find(~cellfun(@isempty,depth))}{1};
M  = M{find(~cellfun(@isempty,M))}{1};
sr  = sr{find(~cellfun(@isempty,sr))}{1};

% Update the panel with the information of this channel
set(handles.text13,'String',path_data{1});
set(handles.text14,'String',R);
set(handles.text15,'String',M);
set(handles.text16,'String',depth);
set(handles.text17,'String',ev_date);

% Set the application data with the sampling rate
setappdata(handles.figure1, 'sr', sr);

fgetl(fid); fgetl(fid);
% Load the entire data into A, and reshape into 15 column format.
% This is the fastest implementation. But in future, if the traces are super-long,
% reading the file in parts would be a good idea, depending on the memory. 
A = fscanf (fid, '%g');
A = reshape(A,15,length(A)/15)';

% Read the acceleration, velocity, displacement and the original waveform column.
acc = A(:,15);  setappdata(handles.figure1, 'acc', acc);
dis = A(:,13);  setappdata(handles.figure1, 'dis', dis);
vel = A(:,14);  setappdata(handles.figure1, 'vel', vel);
ori = A(:,2);   setappdata(handles.figure1, 'ori', ori);

% Plot it, and show the last modification time.
update_plots(handles);
show_timestamp(handles);

% Unhide the panels
set(handles.text7,'Visible','on');
set(handles.listbox3,'Visible','on');
set(handles.uipanel4,'Visible','on');
set(handles.uipanel5,'Visible','on');


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Check the state of catalogue file.
function checkdata(handles)
n_evts = get(handles.n_events,'String');
cat_path = fullfile(get(handles.work_dir,'string'),'catalogue.mat');
if (str2num(n_evts) == 0)
    set(handles.edit1,'String','There is no data in the current directory');
elseif ((str2num(n_evts) > 0) && ~exist(cat_path, 'file'))
    set(handles.edit1,'String','Catalogue does not exist, or is damaged. Please use the reset catalogue button to regenrate.');
    set(handles.gencat,'Visible','on');
elseif ((str2num(n_evts) > 0) && exist(cat_path, 'file'))
    cat = load (fullfile(get(handles.work_dir,'string'),'catalogue.mat'));
    setappdata(handles.figure1, 'cat', cat);
    set(handles.edit1,'String','Catalogue loaded!');
end
    
    


% --- Executes on button to generate catalogue
function gencat_Callback(hObject, eventdata, handles)

set(handles.edit1,'String','Please wait... This might take a few minutes ...');
set(handles.gencat,'Visible','off');
pause (1)
% Assumption: directory names for events start with dir_
% Assumption: channel directory names start with CN, this may only
% be true for Canadian stations? I am not sure.
evts = dir(fullfile(get(handles.work_dir,'string'),'dir_*'));
for i = 1:length(evts)
subdir = evts(i).name;
chns = dir(fullfile(get(handles.work_dir,'string'),subdir, 'CN*'));
for j = 1:length(chns)
    data(i).chn(j).ev_name = subdir;
    data(i).chn(j).ch_name = chns(j).name;
    data(i).chn(j).Q = 0;
    data(i).chn(j).p1 = 0;
    data(i).chn(j).p2 = 0;
    data(i).chn(j).p3 = 0;
    data(i).chn(j).p4 = 0;
    data(i).chn(j).modtime = 0;
end
end
save (fullfile(get(handles.work_dir,'string'),'catalogue.mat'),'data');
set(handles.edit1,'String','Done!');
pause (2)
checkdata(handles);


% If phase pics have been done for the channel, show it on the plot.
function load_picks(handles)
n_evts = get(handles.n_events,'String');
cat_path = fullfile(get(handles.work_dir,'string'),'catalogue.mat');
% Read from the catalogue if it is loaded
if ((str2num(n_evts) > 0) && exist(cat_path, 'file'))
    cat = getappdata(handles.figure1, 'cat');
    p1 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p1;
    p2 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p2;
    p3 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p3;
    p4 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p4;
    h1 = handles.axes1;
    axes(h1);
    vline ([p1 p2 p3 p4]);
end

% If quality has been assigned to for the channel, select it on the listbox.
function load_Q(handles)
n_evts = get(handles.n_events,'String');
cat_path = fullfile(get(handles.work_dir,'string'),'catalogue.mat');
% Read from the catalogue if it is loaded
if ((str2num(n_evts) > 0) && exist(cat_path, 'file'))             
    cat = getappdata(handles.figure1, 'cat');
    Q = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q;
    % Q = 0, means quality has not been assigned.
    if (Q ~= 0)
        set(handles.listbox3,'value',Q);
    end
end


function hhh=vline(x,in1,in2)
% function h=vline(x, linetype, label)
% 
% Draws a vertical line on the current axes at the location specified by 'x'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = vline(42,'g','The Answer')
%
% returns a handle to a green vertical line on the current axes at x=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% vline also supports vector inputs to draw multiple lines at once.  For example,
%
% vline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001
%
%   Modified to work with pick_ph @ UWO
%   by Arpit Singh
%   me@arpitsingh.in (27 May 2013)



if length(x)>1  % vector input
    for I=1:length(x)
        switch nargin
        case 1
            linetype='r:';
            label='';
        case 2
            if ~iscell(in1)
                in1={in1};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            label='';
        case 3
            if ~iscell(in1)
                in1={in1};
            end
            if ~iscell(in2)
                in2={in2};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            if I>length(in2)
                label=in2{end};
            else
                label=in2{I};
            end
        end
        h(I)=vline(x(I),linetype,label);
    end
else
    switch nargin
    case 1
        linetype='r:';
        label='';
    case 2
        linetype=in1;
        label='';
    case 3
        linetype=in1;
        label=in2;
    end

        
    g=ishold(gca);
    hold on

    y=get(gca,'ylim');
    h=plot([x x],y,linetype);
    if length(label)
        xx=get(gca,'xlim');
        xrange=xx(2)-xx(1);
        xunit=(x-xx(1))/xrange;
        if xunit<0.8
            text(x+0.01*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'))
        else
            text(x-.05*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'))
        end
    end     

    if g==0
    hold off
    end
    set(h,'tag','vline','handlevisibility','off')
end % else

if nargout
    hhh=h;
end


% --- Executes on save button press
function pushbutton4_Callback(hObject, eventdata, handles)
cat = getappdata(handles.figure1, 'cat');
data = cat.data;
save (fullfile(get(handles.work_dir,'string'),'catalogue.mat'),'data');
set(handles.edit1,'String','Saved!');


% --- Executes to pick the phases with mouse.
function pushbutton5_Callback(hObject, eventdata, handles)
p = ginput(4);
cat = getappdata(handles.figure1, 'cat');
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p1 = p(1);
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p2 = p(2);
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p3 = p(3);
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p4 = p(4);
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
setappdata(handles.figure1, 'cat', cat);
load_picks(handles);


% --- Executes when the quality of the channel is changed
function listbox3_Callback(hObject, eventdata, handles)
cat = getappdata(handles.figure1, 'cat');
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
setappdata(handles.figure1, 'cat', cat);

% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes when plot option radio button is changed.
function uipanel4_SelectionChangeFcn(hObject, eventdata, handles)
% Radio button has changed, just update the plots
update_plots(handles)

% Read the list modification date and time for the current channel
% Marks the change of either picks or quality.
function show_timestamp(handles)
n_evts = get(handles.n_events,'String');
cat_path = fullfile(get(handles.work_dir,'string'),'catalogue.mat');
% Read from the catalogue if it is loaded
if ((str2num(n_evts) > 0) && exist(cat_path, 'file'))             
    cat = getappdata(handles.figure1, 'cat');
    modtime = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime;
    % modtime = 0, means quality has not been assigned.
    if (modtime ~= 0)        
        set(handles.text19,'String',modtime);
        set(handles.text18,'Visible','on');
        set(handles.text19,'Visible','on');
    else
        set(handles.text18,'Visible','off');
        set(handles.text19,'Visible','off');
    end
end
