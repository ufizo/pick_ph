function varargout = tempGuide(varargin)
% TEMPGUIDE MATLAB code for tempGuide.fig
%      TEMPGUIDE, by itself, creates a new TEMPGUIDE or raises the existing
%      singleton*.
%
%      H = TEMPGUIDE returns the handle to a new TEMPGUIDE or the handle to
%      the existing singleton*.
%
%      TEMPGUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEMPGUIDE.M with the given input arguments.
%
%      TEMPGUIDE('Property','Value',...) creates a new TEMPGUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tempGuide_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tempGuide_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tempGuide

% Last Modified by GUIDE v2.5 01-Jun-2013 23:29:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tempGuide_OpeningFcn, ...
                   'gui_OutputFcn',  @tempGuide_OutputFcn, ...
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


% --- Executes just before tempGuide is made visible.
function tempGuide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tempGuide (see VARARGIN)
w = 600; h = 500; 
set(handles.figure1,'Resize','off','Units','pixels', 'Position',[200 200 w h]);
set(handles.uipanel1,'Parent',handles.figure1,'Units','pixels', 'Position',[0 0 w-20 h]);
set(handles.slider1,'Parent',handles.figure1,'Style','slider', 'Enable','off','Units','pixels', 'Position',[w-20 0 20 h],'Min',0-eps, 'Max',0, 'Value',0, ...
    'Callback',{@onSlide,handles.uipanel1});
hListener = addlistener(handles.slider1,'Value','PostSet',@(s,e) onSlide(handles.uipanel1));

%# add and plot to axes one-by-one
hAx = zeros(7,1);
clr = lines(7);
for i=1:7
    hAx(i) = addAxis(handles);
    plot(hAx(i), cumsum(rand(100,1)-0.5), 'LineWidth',2, 'Color',clr(i,:))
    title(hAx(i), sprintf('plot %d',i))
    %pause(1)   %# slow down so that we can see the updates
end
% Choose default command line output for tempGuide
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tempGuide wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = tempGuide_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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
        hAx = axes('Parent',handles.uipanel1, ...
            'Units','normalized', 'Position',[0.13 0.11 0.775 0.815]);
        set(hAx, 'Units','pixels');

    else
        %# get height of figure
        p = get(handles.figure1, 'Position');
        h = p(4);

        %# increase panel height, and shift it to show new space
        p = get(handles.uipanel1, 'Position');
        set(handles.uipanel1, 'Position',[p(1) p(2)-h p(3) p(4)+h])

        %# compute position of new axis: append on top (y-shifted)
        p = get(ax, 'Position');
        if iscell(p), p = cell2mat(p); end
        p = [p(1,1) max(p(:,2))+h p(1,3) p(1,4)];

        %# create the new axis
        hAx = axes('Parent',handles.uipanel1, ...
            'Units','pixels', 'Position',p);

        %# adjust slider, and call its callback function
        mx = get(handles.slider1, 'Max');
        set(handles.slider1, 'Max',mx+h, 'Min',0, 'Enable','on')
        set(handles.slider1, 'Value',mx+h)       %# scroll to new space
        hgfeval(get(handles.slider1,'Callback'), handles.slider1, []);
    end

    %# force GUI update
    drawnow


function onSlide(slider1,ev,uipanel1)
    %# slider value
    offset = get(slider1,'Value');

    %# update panel position
    p = get(uipanel1, 'Position');  %# panel current position
    set(uipanel1, 'Position',[p(1) -offset p(3) p(4)])


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
