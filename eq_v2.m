function varargout = eq_v2(varargin)
% EQ_V2 MATLAB code for eq_v2.fig
%      EQ_V2, by itself, creates a new EQ_V2 or raises the existing
%      singleton*.
%
%      H = EQ_V2 returns the handle to a new EQ_V2 or the handle to
%      the existing singleton*.
%
%      EQ_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EQ_V2.M with the given input arguments.
%
%      EQ_V2('Property','Value',...) creates a new EQ_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eq_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eq_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eq_v2

% Last Modified by GUIDE v2.5 12-Jun-2013 12:03:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eq_v2_OpeningFcn, ...
                   'gui_OutputFcn',  @eq_v2_OutputFcn, ...
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


% --- Executes just before eq_v2 is made visible.
function eq_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eq_v2 (see VARARGIN)

folder_name = '/home/asingh336/work';
load_listBox(folder_name,handles);

% Choose default command line output for eq_v2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eq_v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = eq_v2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
	%set(handles.n_events,'String',cellsize(1,1)) 

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
	%set(handles.n_chn,'String',cellsize(1,1)) ;
    
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
    work_dir = '/home/asingh336/work';
	dir_list = get(handles.listbox1,'String');
    ev_dir = dir_list(get(handles.listbox1,'value'));
	path1 = fullfile(work_dir,ev_dir{1});
	load_listBox2(path1,handles);


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

function updatePlots (handles)



% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 updatePlots (handles)
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
