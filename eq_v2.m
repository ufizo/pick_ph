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

% Last Modified by GUIDE v2.5 14-Jun-2013 12:58:41

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

setappdata(handles.figure1,'uipos',getpixelposition(handles.uipanel1));
screen_size = get(0, 'ScreenSize');
%set(handles.figure1, 'Resize','off', 'Units','pixels', 'Position',[0 0 screen_size(3) screen_size(4) ]);
set(handles.uipanel1,'Parent',handles.figure1, 'Units','pixels');%, 'Position',[0 0 w-20 h]);
set(handles.slider1,'Parent',handles.figure1, 'Style','slider', 'Enable','off', 'Units','pixels', 'Min',0-eps, 'Max',0, 'Value',0);%'Position',[w-20 0 20 h],



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
folder_name = '/home/asingh336/work';
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%# add and plot to axes one-by-one


	dir_list1 = get(handles.listbox1,'String');
	dir_list2 = get(handles.listbox2,'String');



	ev = dir_list1(get(handles.listbox1,'value'));
	chn = dir_list2(get(handles.listbox2,'value'));
    ev = ev{1};% chn = chn{1};
    
ax = findobj(handles.uipanel1, 'type','axes');
for i = 1:length(ax)
    set(ax(i),'Visible','off');
    delete(ax(i))
end


set(handles.slider1, 'Max',1, 'Min',0, 'Enable','off');
set(handles.uipanel1, 'Position',getappdata(handles.figure1,'uipos'));


n = length(get(handles.listbox2,'Value'));

dat = cell(n,4);
for i=1:n
    %hAx(i) = addAxis(handles);
   
    
    
    path_data = fullfile(folder_name,ev,chn{i},'result.txt');
	fid = fopen(path_data,'rt');
	
	% Loop till the end of the header, and read some info
    R = cell(20,1); sr = cell(20,1);
    x = 0; j = 1;
	while (~strcmpi(x,'END_HEADER'))
   		x=fgetl(fid);
		[R{j}] = regexp(x,'Distance\sfrom\s\w+\s+:\s+(\d+\.\d+\skm)','tokens');
		[sr{j}] = regexp(x,'Sampling\srate:\s+(\d+\.\d+)','tokens');
		j = j + 1;
	end
    
    R  = R{~cellfun(@isempty,R)}{1};
	sr  = sr{~cellfun(@isempty,sr)}{1};
    
    sr = str2double(sr{1});
    
    dat{i,1} = R{1};
    
    
    fgetl(fid); fgetl(fid);	%Skip two lines
    
    A = fscanf (fid, '%g');
	fclose(fid);
	A = reshape(A,15,length(A)/15)';
    
    [m n] = size(A);
    acc = zeros(m,1);
    acc = A(:,15);
    dat{i,2} = acc;
    
    %path_data = fullfile(folder_name,ev,chn{i},'result_');
	%fid = fopen(path_data,'rt');
    %sr=fgetl(fid); sr = str2double(sr);
    %A = fscanf (fid, '%g');
	%fclose(fid);
    hAx(i) = addAxis(handles);
    t = 0:1/sr:(m-1)/sr;
    dat{i,3} = t;
    plot (hAx(i),t,acc);
    %legend(hAx(i),'string1');
    ylabel(hAx(i), sprintf('%s \n %s',dat{i,4},dat{i,1}),'FontSize',8 ,'FontWeight','bold');
    dat{i,4} = chn{i};
    
end

%dat = sortrows(dat,1);
for i = 1:n
 %   hAx(i) = addAxis(handles);
  %  plot (hAx(i),dat{i,3},dat{i,2});
   % ylabel(hAx(i), sprintf('%s \n %s',dat{i,4},dat{i,1}),'FontSize',8 ,'FontWeight','bold');
end


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


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %# slider value
   slidee(handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

function slidee(handles)
    offset = get(handles.slider1,'Value');

    %# update panel position
    p = get(handles.uipanel1, 'Position');  %# panel current position
    set(handles.uipanel1, 'Position',[p(1) -offset p(3) p(4)])
    
    
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function hAx = addAxis(handles)
    %# look for previous axes
    ax = findobj(handles.uipanel1, 'type','axes');

    if isempty(ax)
        %# create first axis
        p = get(handles.uipanel1, 'Position');
        h = p(4);
        hAx = axes('Parent',handles.uipanel1, ...
            'Units','normalized', 'Position',[0.08 0.05 0.9 .12]);
        set(hAx, 'Units','pixels');

    else
        %# get height of figure
        p = getpixelposition(handles.figure1);
        h = p(4);

        %# increase panel height, if it is full.
        p = get(ax, 'Position');
        if iscell(p), p = cell2mat(p); end
        
        %p = get(handles.uipanel1, 'Position');
        % set(handles.uipanel1, 'Position',[p(1) p(2)-.25 p(3) p(4)+.25]);

        %# compute position of new axis: append on top (y-shifted)
        
        p = [p(1,1) max(p(:,2))+h/8 p(1,3) p(1,4)];

        %# create the new axis
        hAx = axes('Parent',handles.uipanel1, ...
            'Units','pixels', 'Position',p);
        
        pui = getpixelposition(handles.uipanel1);
        h = pui(4);
        
        if max(p(:,2)) + p(1,4) > h
            pui = get(handles.uipanel1, 'Position');
            pui = [pui(1) pui(2) pui(3) pui(4) + (max(p(:,2)) + 1.3*p(1,4) - h)];
            set(handles.uipanel1, 'Position',pui);
        

            %# adjust slider, and call its callback function
            mx = get(handles.slider1, 'Max');
            set(handles.slider1, 'Max',mx+(max(p(:,2)) + 1.3*p(1,4) - h), 'Min',0, 'Enable','on')
            set(handles.slider1, 'Value',mx+(max(p(:,2)) + 1.3*p(1,4) - h))       %# scroll to new space
            slidee(handles);
        end
    end

    %# force GUI update
    drawnow


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
keyboard
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
