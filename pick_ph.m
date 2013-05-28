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

% Last Modified by GUIDE v2.5 28-May-2013 00:01:22

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
plot (h1,t,waveform);
plot (h3,t,char);
plot (h2,t,abs_sum);
plot (h2,t,sqr_sum,'Color','r');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
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
n_evts = get(handles.n_events,'String');
cat_path = strcat(get(handles.work_dir,'string'),'catalogue.dat');
if (str2num(n_evts) == 0)
    set(handles.edit1,'String','There is no data in the current directory');
elseif ((str2num(n_evts) > 0) && ~exist(cat_path, 'file'))
    set(handles.edit1,'String','Catalogue does not exist, or is damaged. Please use the reset catalogue button to regenrate.');
elseif ((str2num(n_evts) > 0) && exist(cat_path, 'file'))
    set(handles.edit1,'String','Catalogue loaded!');
end
    
    


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit1,'Please wait regenerating ...');

set(handles.edit1,'Done!');
checkdata(handles);
