function varargout = pick_ph(varargin)
% PICK_PH MATLAB code for pick_ph.fig
%      PICK_PH, by itself, creates a new PICK_PH or raises the existing
%      singleton*.
%
%      H = PICK_PH returns the handle to a new PICK_PH or the handle to
%      the existing singleton*.
%
%      PICK_PH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PICK_PH.M with the given input arguments.
%
%      PICK_PH('Property','Value',...) creates a new PICK_PH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pick_ph_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pick_ph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pick_ph

% Last Modified by GUIDE v2.5 28-May-2013 14:27:38

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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pick_ph (see VARARGIN)
folder_name = '/home/asingh336/work';
%folder_name = '/home/';
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
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir('/home/','Select your DATA dir');
set(handles.work_dir,'string',folder_name);
load_listBox(folder_name,handles);
checkdata(handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over work_dir.
function work_dir_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to work_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir_list = get(handles.listbox1,'String');
path1= strcat(get(handles.work_dir,'string'),'/',dir_list(get(handles.listbox1,'value')));
load_listBox2(path1{1},handles);
set(handles.text5,'Visible','on');
set(handles.listbox2,'Visible','on');
%update_plots(handles);
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

function update_plots(waveform,handles)
sr = waveform(1);
waveform = waveform(2:end);
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
% hObject    handle to Debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir_list1 = get(handles.listbox1,'String');
dir_list2 = get(handles.listbox2,'String');
path_data= strcat(get(handles.work_dir,'string'),'/',dir_list1(get(handles.listbox1,'value')),'/',dir_list2(get(handles.listbox2,'value')),'/result_');
waveform = load (path_data{1});
update_plots(waveform,handles);
set(handles.text7,'Visible','on');
set(handles.listbox3,'Visible','on');
% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkdata(handles)
handles.X = 20;
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
    
    


% --- Executes on button press in gencat.
function gencat_Callback(hObject, eventdata, handles)
% hObject    handle to gencat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit1,'String','Please wait... This might take a few minutes ...');
set(handles.gencat,'Visible','off');
pause (1)
evts = dir(fullfile(get(handles.work_dir,'string'),'dir_*'));
for i = 1:length(evts)
subdir = evts(i).name;
chns = dir(fullfile(get(handles.work_dir,'string'),subdir, 'CN*'));
for j = 1:length(chns)
    data(i).chn(j).ev_name = subdir;
    data(i).chn(j).ch_name = chns(j).name;
    data(i).chn(j).R = 0;
    data(i).chn(j).M = 0;
    data(i).chn(j).Q = 0;
    data(i).chn(j).p1 = 0;
    data(i).chn(j).p2 = 0;
    data(i).chn(j).p3 = 0;
    data(i).chn(j).p4 = 0;
end
end
save (fullfile(get(handles.work_dir,'string'),'catalogue.mat'),'data');
set(handles.edit1,'String','Done!');
pause (2)
checkdata(handles);



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


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cat = getappdata(handles.figure1, 'cat');
data = cat.data;
save (fullfile(get(handles.work_dir,'string'),'catalogue.mat'),'data');
set(handles.edit1,'String','Saved!');


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = ginput(4);
cat = getappdata(handles.figure1, 'cat');
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p1 = p(1);
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p2 = p(2);
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p3 = p(3);
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p4 = p(4);
setappdata(handles.figure1, 'cat', cat);
load_picks(handles);


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cat = getappdata(handles.figure1, 'cat');
cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
setappdata(handles.figure1, 'cat', cat);

% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
