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
% Last Modified by GUIDE v2.5 27-Jun-2013 15:25:18

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
function pick_ph_OpeningFcn(hObject, ~, handles, varargin)
    warning off
	% Default work directory when program is loaded
	%folder_name = '/home/ufizo/work';
	folder_name = '/home/';
	set(handles.work_dir,'string',folder_name);
	load_listBox(folder_name,handles);
	setappdata(handles.figure1, 'x', 0);    %Un Xoomed to start with
	setappdata(handles.figure1, 'auto', 0); %AutoPick disabled by default because it needs a lot of processing power.
    setappdata(handles.figure1, 'multi', 0);%MultiChannel mode off by default

	%Check if listBox is empty, and check for catalogue
	checkdata(handles);

	% Choose default command line output for pick_ph
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);
    
    % Setup slider and panel for multiChannel
    setappdata(handles.figure1,'uipos',getpixelposition(handles.uimulti));
    set(handles.uimulti,'Parent',handles.figure1, 'Units','pixels');%, 'Position',[0 0 w-20 h]);
    set(handles.slider3,'Parent',handles.figure1, 'Style','slider', 'Enable','off', 'Units','pixels', 'Min',0-eps, 'Max',0, 'Value',0);%'Position',[w-20 0 20 h],

	% UIWAIT makes pick_ph wait for user response (see UIRESUME)
	% uiwait(handles.figure1);


% --- Executes on button press to load the work directory, or the 
% directory which contains the data processed by icorrect
function pushbutton1_Callback(~, ~, handles)

	folder_name = uigetdir('/home/','Select your DATA dir');
	set(handles.work_dir,'string',folder_name);
	% populate the listbox, with these directories
	load_listBox(folder_name,handles);
	% Check if this directory has the data as output by icorrect
	checkdata(handles);


% --- Executes when a event directory is selected in the first listbox
% Reads the channels in the subdirectory, and loads them
function listbox1_Callback(~, ~, handles)

	dir_list = get(handles.listbox1,'String');
    ev_dir = dir_list(get(handles.listbox1,'value'));
	path1 = fullfile(get(handles.work_dir,'string'),ev_dir{1});
	load_listBox2(path1,handles);
	set(handles.text5,'Visible','on');
	set(handles.listbox2,'Visible','on');
	%update_plots(handles);


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
% Assumption: channel directory names start with CN, Is
% this always true? Maybe not. ///TO-DO///
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
function update_plots(handles)
	% Get the sampling rate: sr
	sr = getappdata(handles.figure1, 'sr');
	sr = str2double(sr{1});

	% Check the selected option for PLOT1
	switch feval(@(x) x{1}{x{2}},get(handles.popupmenu1,{'String','Value'}))
        	case 'Acceleration'
        		waveform = getappdata(handles.figure1, 'acc'); 
        	case 'Velocity'
        		waveform = getappdata(handles.figure1, 'vel'); 
        	case 'Displacement'
        		waveform = getappdata(handles.figure1, 'dis'); 
        	case 'Original'
        		waveform = getappdata(handles.figure1, 'ori'); 
        	case 'Deglitched'
        		waveform = getappdata(handles.figure1, 'degli'); 
        	case 'Detrended'
        		waveform = getappdata(handles.figure1, 'detre');
        	case 'Windowed'
        		waveform = getappdata(handles.figure1, 'windd');
        	case 'FFT->Re'
        		waveform = getappdata(handles.figure1, 'fftre');
        	case 'FFT->Im'
        		waveform = getappdata(handles.figure1, 'fftim');
        	case 'FFT->Abs'
        		waveform = getappdata(handles.figure1, 'fftabs');
        	case 'Filtered'
        		waveform = getappdata(handles.figure1, 'filtdd');
	end

	w2 = waveform;	% Another copy, which maybe be used in other plots, if the main one is filtered

	% Check for the selected filter,and apply it. Only for plot1
	% Butterworth bandpass, 4th order
	switch get(handles.uipanel6,'SelectedObject')
    	case handles.radiobutton9
        	%No Filter
         	waveform;
    	case handles.radiobutton10
        	%2-5
        	[b a] = butter(4,[4/sr 10/sr]);	
        	waveform = filtfilt(b,a,waveform); 
    	case handles.radiobutton11
        	%4-8
        	[b a] = butter(4,[8/sr 16/sr]);	
        	waveform = filtfilt(b,a,waveform);  
    	case handles.radiobutton12
        	%8-16
        	[b a] = butter(4,[16/sr 32/sr]);	
        	waveform = filtfilt(b,a,waveform); 
    	case handles.radiobutton14
        	%custom
        	f1 = str2double(get(handles.edit2,'String'));
        	f2 = str2double(get(handles.edit4,'String'));
        	[b a] = butter(4,[f1*2/sr f2*2/sr]);	
        	waveform = filtfilt(b,a,waveform); 
    	otherwise
        	% No filter
        	waveform; 
	end

	% Check the selected option for PLOT2
	switch feval(@(x) x{1}{x{2}},get(handles.popupmenu2,{'String','Value'}))
    	case 'Original'
        	y2 = getappdata(handles.figure1, 'ori'); 
    	case 'Absolute Sum'
        	y2 = cumsum(abs(waveform));
    	case 'Square Sum'
        	y2 = cumsum(waveform.*waveform);
    	case 'BandPassed'
        	[b a] = butter(4,[4/sr 13/sr]);	
        	y2 = filtfilt(b,a,w2);  
	end

	% Check the selected option for PLOT3
	switch feval(@(x) x{1}{x{2}},get(handles.popupmenu3,{'String','Value'}))
    	%% //TO-DO// Insert some more usable parameters here
	case '???'
        	y3=waveform.^2+3*(waveform-waveform).^2*sr.^2; 
	end


	% Handles to the theree axes
    	h1 = handles.axes1;
    	h2 = handles.axes4;
    	h3 = handles.axes5;
    
	% If xoomed. x=1 for zoom, x=0 for no zoom    
	x = getappdata(handles.figure1, 'x');
	if (~x)
    		t = 0:1/sr:(length(waveform)-1)/sr;
            
    		plot (h1,t,waveform);
    		plot (h2,t,y2);
    		plot (h3,t,y3);
   
    		load_picks(handles);


	elseif (x)
    		% Get info about zoom window
    		xoo = getappdata(handles.figure1, 'xoo');
    		t =xoo(1):1/sr:xoo(2);
    
    		% Resize the vectors
    		waveform = waveform(round(xoo(1)*sr):round(xoo(1)*sr) + length(t) - 1);
    		y2 = y2(round(xoo(1)*sr):round(xoo(1)*sr) + length(t) - 1);
    		y3 = y3(round(xoo(1)*sr):round(xoo(1)*sr) + length(t) - 1);
        
    		plot (h1,t,waveform);
    		plot (h2,t,y2);
    		plot (h3,t,y3);
    		%load_picks(handles);       %Plotting the picks can screwup the zoomed
                                	    %view if the picks are outside current view. 
	end

	load_Q(handles);

	% Suggest autoPicks if enabled.
	auto = getappdata(handles.figure1, 'auto');
	if (auto)
    		[x1,x2] = auto_pick (handles,sr,waveform);
    		axes(h1);
    		vline ([x1-10 x1 x2 x2+60],'r');
    		%axes(h3);
    		%vline ([x1-10 x1 x2 x2+60],'r');
    		setappdata(handles.figure1, 'auto', 0); % AutoPick disable for next plot unless called explicitely
	end



% --- Executes on selection of a channel.
% Read the result.txt file for the channel and update the figure with the 
% scanned into. 
function listbox2_Callback(~, ~, handles)

    % Check the state of multi channel mode
    mmode = getappdata(handles.figure1, 'multi');
    cat = getappdata(handles.figure1, 'cat');
    
    % Get the list of events, and the list of channels
	dir_list1 = get(handles.listbox1,'String');
	dir_list2 = get(handles.listbox2,'String');
    
    ev = dir_list1(get(handles.listbox1,'value'));
	chn = dir_list2(get(handles.listbox2,'value'));
    
    if (~mmode)
	
	x = 0; i = 1;
	
    % Path to the result.txt for the selected channel
    ev = ev{1}; chn = chn{1};		%% //TO-DO// Properly handle returned cells
	path_data = fullfile(get(handles.work_dir,'string'),ev,chn,'result.txt');
	fid = fopen(path_data,'rt');
	
	% Loop till the end of the header, and read some info
    ev_date = cell(20,1); depth  =  cell(20,1); M = cell(20,1); R = cell(20,1); sr = cell(20,1);
	while (~strcmpi(x,'END_HEADER'))
   		x=fgetl(fid);
		[ev_date{i}] = regexp(x,'Event\sdate:\s+(\d+\/\d+\/\d+)','tokens');
		[depth{i}] = regexp(x,'Hypocentral\sdepth\(km\):\s+(\d+\.\d+)','tokens');
		[M{i}] = regexp(x,'Magnitude:\s+(\d+\.\d+)','tokens');
		[R{i}] = regexp(x,'Distance\sfrom\s\w+\s+:\s+(\d+\.\d+\skm)','tokens');
		[sr{i}] = regexp(x,'Sampling\srate:\s+(\d+\.\d+)','tokens');
		i = i + 1;
	end

	% I don't like regex in matlab, this is how I would have done it in Perl
	% //TO-DO//
	% A better implementation may exist to select R, M, sr etc from the header.
	R  = R{~cellfun(@isempty,R)}{1};
	ev_date  = ev_date{~cellfun(@isempty,ev_date)}{1};
	depth  = depth{~cellfun(@isempty,depth)}{1};
	M  = M{~cellfun(@isempty,M)}{1};
	sr  = sr{~cellfun(@isempty,sr)}{1};
    
	% Update the panel with the information of this channel
	set(handles.text13,'String',path_data);
	set(handles.text14,'String',R);
	set(handles.text15,'String',M);
	set(handles.text16,'String',depth);
	set(handles.text17,'String',ev_date);
	set(handles.text21,'String',get(handles.listbox1,'value'));
	set(handles.text22,'String',get(handles.listbox2,'value'));
    
    % Save R in the catalogue for use in multichannel plot
    cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).R = R{1};
	setappdata(handles.figure1, 'cat', cat);
    
	% Set the application data with the sampling rate
	% Will be used while plotting
	setappdata(handles.figure1, 'sr', sr);

	fgetl(fid); fgetl(fid);	%Skip two lines

	% Load the entire data into A, and reshape into 15 column format.
	% This is the fastest implementation IMO. But in future, if the traces are super-long,
	% reading the file in parts would be a good idea, depending on the memory. 

	A = fscanf (fid, '%g');
	fclose(fid);
	A = reshape(A,15,length(A)/15)';

	% Read the acceleration, velocity, displacement and the original waveform column.
	ori = A(:,2);       setappdata(handles.figure1, 'ori', ori);
	acc = A(:,15);      setappdata(handles.figure1, 'acc', acc);
	dis = A(:,13);      setappdata(handles.figure1, 'dis', dis);
	vel = A(:,14);      setappdata(handles.figure1, 'vel', vel);
	degli = A(:,3);     setappdata(handles.figure1, 'degli', degli);
	detre = A(:,4);     setappdata(handles.figure1, 'detre', detre);
	windd = A(:,5);     setappdata(handles.figure1, 'windd', windd);
	fftre = A(:,6);     setappdata(handles.figure1, 'fftre', fftre);
	fftim = A(:,7);     setappdata(handles.figure1, 'fftim', fftim);
	fftabs = A(:,8);    setappdata(handles.figure1, 'fftabs', fftabs);
	filtdd = A(:,9);    setappdata(handles.figure1, 'filtdd', filtdd);

	% Plot it, and show the last modification time.
	update_plots(handles);
	show_timestamp(handles);

	% Unhide the panels
	set(handles.text7,'Visible','on');
	set(handles.listbox3,'Visible','on');
	set(handles.uipanel4,'Visible','on');
	set(handles.uipanel5,'Visible','on');
	set(handles.uipanel6,'Visible','on');
    
    else
        % MultiChannel mode on
        ev = ev{1};
        i_ch = get(handles.listbox2,'value');
        
        % Delete existing objects from uimulti
        ax = findobj(handles.uimulti, 'type','axes');
        for i = 1:length(ax)
            try
            set(ax(i),'Visible','off');
            delete(ax(i))
            end
        end
        
        set(handles.slider3, 'Max',1, 'Min',0, 'Enable','off');
        set(handles.uimulti, 'Position',getappdata(handles.figure1,'uipos'));
        
        % Read the channel data
        n = length(get(handles.listbox2,'Value'));
        dat = cell(n,4);
        
        
        % Loop over all the selected channels
        for i=1:n
            if (isfield(cat.data(get(handles.listbox1,'value')).chn(i_ch(i)), 'R'))
            if (iscell(cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).R))
                cat.data(get(handles.listbox1,'value')).chn(i).R = cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).R{1};
            end
            if (cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).R > 0)
                % We have the R value in catalogue. Will read result_ for
                % speed
                path_data = fullfile(get(handles.work_dir,'string'),ev,chn{i},'result_');
                fid = fopen(path_data,'rt');
                
                % Sampling rate is the first line in result_
                sr=fgetl(fid); sr = str2double(sr);
                A = fscanf (fid, '%g');
                fclose(fid);
            
                acc = A;
                m = length(A);
                t = 0:1/sr:(m-1)/sr;
                
                % dat is a cell, 
                % 1 => R in Km. 
                % 2 => acceleration time series. 
                % 3 => Time vector for plotting
                % 4 => Channel Name
                
                dat{i,1} = cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).R;
                dat{i,2} = acc;
                dat{i,4} = chn{i};
                dat{i,3} = t;
                
                sprintf('reading _')
            else
                % Catalogue does not have R value
                cols = getDat(handles,ev,chn{i},cat,i);
                dat{i,1} = cols{1,1};
                dat{i,2} = cols{1,2};
                dat{i,3} = cols{1,3};
                dat{i,4} = cols{1,4};
            end
            
            else
                % Catalogue does not have R value
                cols = getDat(handles,ev,chn{i},cat,i);
                dat{i,1} = cols{1,1};
                dat{i,2} = cols{1,2};
                dat{i,3} = cols{1,3};
                dat{i,4} = cols{1,4};
            end
            
            % Read max amps for relative amp plotting
            ymax(i) = max(abs(dat{i,2}));
        end
        
        if (get(handles.checkbox1,'value'))
            dat = sortrows(dat,1);
        end

        xmax = max(dat{i,3});
        ymax = max(ymax);
        i_ch = get(handles.listbox2,'value');
        
        for i = 1:n
    
            hAx(i) = addAxis(handles);
            plot (hAx(i),dat{i,3},dat{i,2});
            
            p1 = cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).p1;
    		p2 = cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).p2;
    		p3 = cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).p3;
    		p4 = cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).p4;
    		h1 = hAx(i);
    		axes(h1);
    		h = vline ([p1 p2 p3 p4]);
            
            xlim([0 xmax]);
            if (get(handles.checkbox2,'value'))
                ylim([-ymax ymax])
            end
            
            
            if (i > 1)
                set(hAx(i),'xtick',[])
                set(hAx(i),'xticklabel',[])
            end
    
            ylabel(hAx(i), sprintf('%s \n %s',dat{i,4},dat{i,1}),'FontSize',8 ,'FontWeight','bold');
        end
        
    end
    

    
function hAx = addAxis(handles)
    %# look for previous axes
    ax = findobj(handles.uimulti, 'type','axes');

    if isempty(ax)
        %# create first axis
        p = get(handles.uimulti, 'Position');
        h = p(4);
        hAx = axes('Parent',handles.uimulti, ...
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

        %# computgetDat(handles,ev,chn,cat,i)e position of new axis: append on top (y-shifted)
        
        p = [p(1,1) max(p(:,2))+h/8 p(1,3) p(1,4)];

        %# create the new axis
        hAx = axes('Parent',handles.uimulti, ...
            'Units','pixels', 'Position',p);
        
        
        pui = getpixelposition(handles.uimulti);
        h = pui(4);
        
        if max(p(:,2)) + p(1,4) > h
            pui = get(handles.uimulti, 'Position');
            pui = [pui(1) pui(2) pui(3) pui(4) + (max(p(:,2)) + 1.3*p(1,4) - h)];
            set(handles.uimulti, 'Position',pui);
        

            %# adjust slider, and call its callback function
            mx = get(handles.slider3, 'Max');
            set(handles.slider3, 'Max',mx+(max(p(:,2)) + 1.3*p(1,4) - h), 'Min',0, 'Enable','on')
            set(handles.slider3, 'Value',mx+(max(p(:,2)) + 1.3*p(1,4) - h))       %# scroll to new space
            slidee(handles);
        end
    end

    %# force GUI update
    drawnow
    
    
function slidee(handles)
    offset = get(handles.slider3,'Value');

    %# update panel position
    p = get(handles.uimulti, 'Position');  %# panel current position
    set(handles.uimulti, 'Position',[p(1) -offset p(3) p(4)])
    
% In multi channel mode, returns the cell containing data.     
function dat = getDat(handles,ev,chn,cat,i)

    % get indices of selected channels
    i_ch = get(handles.listbox2,'value');
    
    path_data = fullfile(get(handles.work_dir,'string'),ev,chn,'result.txt');
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
    cat.data(get(handles.listbox1,'value')).chn(i_ch(i)).R = R{1};
    R{1}
    i_ch(i)
	sr  = sr{~cellfun(@isempty,sr)}{1};
    
    sr = str2double(sr{1});
    
    dat{1,1} = R{1};
    
    
    fgetl(fid); fgetl(fid);	%Skip two lines
    
    A = fscanf (fid, '%g');
	fclose(fid);
	A = reshape(A,15,length(A)/15)';
    
    [m n2] = size(A);
    acc = zeros(m,1);
    acc = A(:,15);
    
    dat{1,2} = acc;
    dat{1,4} = chn;
    
    

    t = 0:1/sr:(m-1)/sr;
    dat{1,3} = t;
    
    
    %cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).R = R{1};
	setappdata(handles.figure1, 'cat', cat);
    
    data = cat.data;
    save (fullfile(get(handles.work_dir,'string'),'catalogue.mat'),'data');
    sprintf('reading txt')
        

% Check the state of catalogue file.
function checkdata(handles)

	n_evts = get(handles.n_events,'String');
	cat_path = fullfile(get(handles.work_dir,'string'),'catalogue.mat');
	if (str2double(n_evts) == 0)
    		set(handles.edit1,'String','There is no data in the current directory');
	elseif ((str2double(n_evts) > 0) && ~exist(cat_path, 'file'))
    		set(handles.edit1,'String','Catalogue does not exist, or is damaged. Please use the reset catalogue button to regenrate.');
    		set(handles.gencat,'Visible','on');
	elseif ((str2double(n_evts) > 0) && exist(cat_path, 'file'))
    		cat = load (fullfile(get(handles.work_dir,'string'),'catalogue.mat'));
    		setappdata(handles.figure1, 'cat', cat);
    		set(handles.edit1,'String','Catalogue loaded!');
	end
    
    


% --- Executes on button to generate catalogue
function gencat_Callback(~, ~, handles)

	set(handles.edit1,'String','Please wait... This might take a few minutes ...');
	set(handles.gencat,'Visible','off');
	pause (1)

	% Assumption: directory names for events start with dir_
	% Assumption: channel directory names start with CN

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
                data(i).chn(j).R = 0;
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
	if ((str2double(n_evts) > 0) && exist(cat_path, 'file'))
    		cat = getappdata(handles.figure1, 'cat');
    		p1 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p1;
    		p2 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p2;
    		p3 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p3;
    		p4 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p4;
    		h1 = handles.axes1;
    		axes(h1);
    		h = vline ([p1 p2 p3 p4]);
            setappdata(handles.figure1, 'picks', h);
	end


% If quality has been assigned to for the channel, select it on the listbox.
function load_Q(handles)

	n_evts = get(handles.n_events,'String');
	cat_path = fullfile(get(handles.work_dir,'string'),'catalogue.mat');

	% Read from the catalogue if it is loaded
	if ((str2double(n_evts) > 0) && exist(cat_path, 'file'))             
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
	% Draws a vertical line on the current axes at the location specified by 'x'.  
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
            		linetype='g';
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

	if ~isempty(label)
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
function pushbutton4_Callback(hObject, ~, handles)

	cat = getappdata(handles.figure1, 'cat');
	data = cat.data;
	save (fullfile(get(handles.work_dir,'string'),'catalogue.mat'),'data');
	set(handles.edit1,'String','Saved!');


% --- Executes to pick the phases with mouse.
function pushbutton5_Callback(~, ~, handles)

	p = ginput(4);
	cat = getappdata(handles.figure1, 'cat');
	cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p1 = p(1,1);
	cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p2 = p(2,1);
	cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p3 = p(3,1);
	cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p4 = p(4,1);
	cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
	setappdata(handles.figure1, 'cat', cat);
	update_plots(handles);


% --- Executes when the quality of the channel is changed
function listbox3_Callback(~, ~, handles)

	cat = getappdata(handles.figure1, 'cat');
	cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
	cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
	setappdata(handles.figure1, 'cat', cat);


% --- Executes when plot option radio button is changed.
function uipanel4_SelectionChangeFcn(~, ~, handles)

	% Radio button has changed, just update the plots
	update_plots(handles)


% Read the list modification date and time for the current channel
% Marks the change of either picks or quality.
function show_timestamp(handles)

	n_evts = get(handles.n_events,'String');
	cat_path = fullfile(get(handles.work_dir,'string'),'catalogue.mat');
	% Read from the catalogue if it is loaded
	if ((str2double(n_evts) > 0) && exist(cat_path, 'file'))             
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


% --- Executes on key press with focus on figure1 and none of its controls.
% KeyBoard shortcuts
function figure1_KeyPressFcn(hObject, eventdata, handles)
	hotkeys(hObject, eventdata, handles)


% The Keyboard shortcuts
function hotkeys(hObject, eventdata, handles)

	%% kind of easter egg?
	x = get(handles.figure1,'currentcharacter');
	if x == 'h'
    		set(handles.edit1,'String','Hello! need help? mail to: me@arpitsingh.in');
	end

	% Set Quality with num keys 1-7	
	q = {'1','2','3','4','5','6','7'};
	if (ismember(x,q))
    		if (str2double(x) >=1 && str2double(x) <= 7)
        		set(handles.listbox3,'value',str2double(x));
        		cat = getappdata(handles.figure1, 'cat');
        		cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
        		cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
        		setappdata(handles.figure1, 'cat', cat);
    		end
	end

	% X to Xoom (Zoom :) )
	% o to Zoom out
	if x == 'x'
    		xoo = ginput(2);
    		xoo = xoo(:,1);
    		setappdata(handles.figure1, 'x', 1);
    		setappdata(handles.figure1, 'xoo', xoo);
    		update_plots(handles);
	end

	if x == 'o'
    		setappdata(handles.figure1, 'x', 0);
    		update_plots(handles);
	end

	% P to pick phases
	if x == 'p'
    		pushbutton5_Callback(hObject, eventdata, handles);
    end
    
    % M to switch to multiChannel mode
	if x == 'm'
        mmode = getappdata(handles.figure1, 'multi');
        mmode = ~mmode;
        setappdata(handles.figure1, 'multi',mmode);
        
        if (mmode)
            % Hide the axes and buttons for picking
            set(handles.axes1,'Visible','off');
            cla(handles.axes1);
            set(handles.axes4,'Visible','off');
            cla(handles.axes4);
            set(handles.axes5,'Visible','off');
            cla(handles.axes5);
            try
                delete(getappdata(handles.figure1,'picks'));
            end
            set(handles.uipanel4,'Visible','off');
            set(handles.uipanel5,'Visible','off');
            set(handles.uipanel6,'Visible','off');
            set(handles.listbox3,'Visible','off');
            set(handles.text7,'Visible','off');
            set(handles.pushbutton4,'Visible','off');
            set(handles.pushbutton5,'Visible','off');
            set(handles.pushbutton6,'Visible','off');
            set(handles.pushbutton11,'Visible','off');
            set(handles.edit1,'String','MultiChannel Mode activated');
            
            % Set the listbox2 for multiselect
            set(handles.listbox2,'Max',20);
            dim = get(handles.listbox2,'Position');
            dim(2) = dim(2) - dim(4);
            dim(4) = 2*dim(4);
            set(handles.listbox2,'Position',dim);
            
            % Unhide uimulti
            set(handles.uimulti,'Visible','on');
            set(handles.slider3,'Visible','on');
            set(handles.checkbox1,'Visible','on');
            set(handles.checkbox2,'Visible','on');
        else
            % Only unhide the buttons, axes are turned on by callback on
            % listbox2
            set(handles.pushbutton4,'Visible','on');
            set(handles.pushbutton5,'Visible','on');
            set(handles.pushbutton6,'Visible','on');
            set(handles.pushbutton11,'Visible','on');
            set(handles.edit1,'String','MultiChannel Mode de-activated');
            set(handles.listbox2,'Value',1);
            set(handles.listbox2,'Max',1);
            dim = get(handles.listbox2,'Position');
            dim(4) = .5*dim(4);
            dim(2) = dim(2) + dim(4);
            set(handles.listbox2,'Position',dim);
            
            % Hide uimulti
            set(handles.uimulti,'Visible','off');
            set(handles.slider3,'Visible','off');
            set(handles.checkbox1,'Visible','off');
            set(handles.checkbox2,'Visible','off');
        end
           		
	end


	% For arrowKey controls
	%x=double(x);

	%Left arrow key (28) to go to previous channel
	%Right arrow key (29) to go to next channel	
	%if x == 29
	if x == 'd'
    		j = get(handles.listbox2,'value');
    		if (j < str2double(get(handles.n_chn,'String')))
        		list = get(handles.listbox2,'String');
			% It it is a trio of EW - NS- Z channels, copy the picks and Q to rest of the two
        		[~, b] = regexp(list{get(handles.listbox2,'value')},'(\S*?\.\.\S\S)E','match');
        		if (b)
            			[a b] = regexp(list{get(handles.listbox2,'value')},'(\S*?\.\.\S\S)\S','tokens','match');
            			if strcmp(strcat(a{1}{1},'N'),list{get(handles.listbox2,'value')+1}) && strcmp(strcat(a{1}{1},'Z'),list{get(handles.listbox2,'value')+2}) 
                			cat = getappdata(handles.figure1, 'cat');
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+1).Q =  get(handles.listbox3,'value');
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+2).Q =  get(handles.listbox3,'value');
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+1).p1 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p1;
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+1).p2 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p2;
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+1).p3 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p3;
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+1).p4 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p4;              
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+2).p1 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p1;
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+2).p2 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p2;
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+2).p3 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p3;
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')+2).p4 = cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).p4;  
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0);                 
                			setappdata(handles.figure1, 'cat', cat);
			
					if (j+2 < str2double(get(handles.n_chn,'String')))
                    				set(handles.listbox2,'value',j+3);
                			else
                    				set(handles.listbox2,'value',j+2);
                			end

                			listbox2_Callback(hObject, eventdata, handles);
            			else
                			cat = getappdata(handles.figure1, 'cat');
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
                			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
                			setappdata(handles.figure1, 'cat', cat);                
                			set(handles.listbox2,'value',j+1);
                			listbox2_Callback(hObject, eventdata, handles);
            			end
        		else

            			cat = getappdata(handles.figure1, 'cat');
            			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
            			cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
            			setappdata(handles.figure1, 'cat', cat);            
            			set(handles.listbox2,'value',j+1);
            			listbox2_Callback(hObject, eventdata, handles);
        		end
    		end

    		if (j == str2double(get(handles.n_chn,'String')))
        		cat = getappdata(handles.figure1, 'cat');
        		cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
        		cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
        		setappdata(handles.figure1, 'cat', cat);
        		set(handles.listbox1,'value',get(handles.listbox1,'value')+1);
        		listbox1_Callback(hObject, eventdata, handles);
        		set(handles.listbox2,'value',1);
        		listbox2_Callback(hObject, eventdata, handles);
    		end
	end



	%if x == 28
	if x == 'a'
    		j = get(handles.listbox2,'value');
    		if (j > 1)
        		set(handles.listbox2,'value',j-1);
        		cat = getappdata(handles.figure1, 'cat');
        		cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).Q =  get(handles.listbox3,'value');
        		cat.data(get(handles.listbox1,'value')).chn(get(handles.listbox2,'value')).modtime = datestr(clock, 0); 
        		setappdata(handles.figure1, 'cat', cat);
        		listbox2_Callback(hObject, eventdata, handles);
    		end
	end


	% Up & Down arrow to change fiters
	%if x == 30
	if x == 'w'
    
	switch get(handles.uipanel6,'SelectedObject')
    		case handles.radiobutton9
        		%No Filter
        		set(handles.uipanel6,'SelectedObject',handles.radiobutton14);
    		case handles.radiobutton10
        		%2-5
        		set(handles.uipanel6,'SelectedObject',handles.radiobutton9);
    		case handles.radiobutton11
        		%4-8
        		set(handles.uipanel6,'SelectedObject',handles.radiobutton10);
    		case handles.radiobutton12
        		%8-16
        		set(handles.uipanel6,'SelectedObject',handles.radiobutton11);
    		case handles.radiobutton14
        		%custom
        		set(handles.uipanel6,'SelectedObject',handles.radiobutton12);
    		otherwise
        		% No filter
        		set(handles.uipanel6,'SelectedObject',handles.radiobutton9);
    	end
    
	update_plots(handles);
    	end


	%if x == 31
	if x == 's'
    		switch get(handles.uipanel6,'SelectedObject')
    			case handles.radiobutton9
        			%No Filter
        			set(handles.uipanel6,'SelectedObject',handles.radiobutton10);
    			case handles.radiobutton10
        			%2-5
        			set(handles.uipanel6,'SelectedObject',handles.radiobutton11);
    			case handles.radiobutton11
        			%4-8
        			set(handles.uipanel6,'SelectedObject',handles.radiobutton12);
    			case handles.radiobutton12
        			%8-16
        			set(handles.uipanel6,'SelectedObject',handles.radiobutton14);
    			case handles.radiobutton14
        			%custom
        			set(handles.uipanel6,'SelectedObject',handles.radiobutton9);
    			otherwise
        			% No filter
        			set(handles.uipanel6,'SelectedObject',handles.radiobutton9);
    		end
    		update_plots(handles);
	end


% //TO-DO// - Unfinished.
% This function needs work, which I might never do.
% Leaving this here, for if someone ever wishes to catch on this.
function [x1,x2] = auto_pick (~,sr,wave)

	% BandPass
	[b a] = butter(4,[3/sr 15/sr]);	% 3Hz to 20Hz for P phase picking
	waveBP = filtfilt(b,a,wave);

	% Narrow Detection interval
	win = 40;
	varY = wave.^2;                 % Bad assumption, that S has the max amp
	[~, b1] = max(varY);
	detect = [1 round(b1*0.9)];

	win = 500;
	waveD = waveBP(detect(1):detect(2));
	kurtY1 = myKurtosis(waveD,win);
	[~, b2] = max(kurtY1);
	detect = [b2-100 b2+60];

	clear waveD;
	win = 40;
	waveD = wave(detect(1):detect(2));
	kurtY = myKurtosis(waveD,win);
	[a2 b2] = max(kurtY);

	threshH = a2;
	while (kurtY(b2)>1.5)
		b2 = b2-1;
	end

	b2 = b2 + detect(1) - 1;
	x1 = b2/sr;

	% Highcut
	[b a] = butter(4,.2);	
	waveHC = filtfilt(b,a,wave);

	% S wave
	detectS = [b2 round(b1*1.1)];
	waveDS = waveHC(detectS(1):detectS(2));
	aicD = aic(waveDS); aicD(1) = 0;
	[~, b3] = min(aicD);
	b3 = b3 + detectS(1) - 1;
	detectS = [b3-70 b3+10];
	waveDS = wave(detectS(1):detectS(2));
	aicD = aic(waveDS); aicD(1) = 0;
	[~, b3] = min(aicD);
	b3 = b3 + detectS(1) - 1;
	x2 = b3/sr;

function [ kurt ] = myKurtosis( x,M )
% Kurtosis calculated over the entire signal length
% x is the signal, M is the window length
% Bottle Neck! This is slow!

	N = length(x);
	for k = M:N
		clear xw;
		xw = x(k-M+1:k);
		kurt(k) = kurtosis(xw) -3;
	end

function [ val ] = aic(wave)
% Computes AIC funciton without the AR coefficients.
% Bottle Neck! This is slow!

	N = length(wave);
	for k = 1:N
   		val(k) = k*log(var(wave(1:k))) + (N-k-1)*log(var(wave(k+1:N)));
    	end




% Custom filter
function pushbutton7_Callback(~, ~, handles)

	f1 = str2double(get(handles.edit2,'String'));
	set(handles.edit2,'String',f1+.5);
	check_custom_filter(handles)
	update_plots(handles);

function pushbutton8_Callback(~, ~, handles)

	f1 = str2double(get(handles.edit2,'String'));
	set(handles.edit2,'String',f1-.5);
	check_custom_filter(handles)
	update_plots(handles);


function edit4_Callback(~, ~, handles)

	check_custom_filter(handles)
	update_plots(handles);


function pushbutton9_Callback(~, ~, handles)

	f1 = str2double(get(handles.edit4,'String'));
	set(handles.edit4,'String',f1+.5);
	check_custom_filter(handles)
	update_plots(handles);

function pushbutton10_Callback(~, ~, handles)

	f1 = str2double(get(handles.edit4,'String'));
	set(handles.edit4,'String',f1-.5);
	check_custom_filter(handles)
	update_plots(handles);

function check_custom_filter(handles)

	f1 = str2double(get(handles.edit2,'String'));
	f2 = str2double(get(handles.edit4,'String'));
	sr = getappdata(handles.figure1, 'sr');
	sr = str2double(sr{1});

	if ((f1 > 0 && f2 > 0) && (f1 < f2))
    		if (f2 >= sr/2)
        		set(handles.edit4,'String',sr/2 - .1);
    		end
	else
    		set(handles.edit2,'String',1);
    		set(handles.edit4,'String',5);
	end







%% Called to export the CSV tables
%% not tested many times, but works

function write_out (handles)
cat = getappdata(handles.figure1, 'cat');
load('known.mat');
clc
psacsv = fullfile(get(handles.work_dir,'string'),'psa.csv');
fascsv = fullfile(get(handles.work_dir,'string'),'fas.csv');
fw = fopen (psacsv,'w');
fw1 = fopen (fascsv,'w');

fprintf(fw,'Note: PSA and PGA are in cm/s^2 and PGV is in cm/s,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n');
fprintf(fw,'PSAs are calculated for 5 percent of critical damping,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n');
fprintf(fw,',,,,,,,,,,,,,,,,,,,,,,,Frequncy (Hz) at,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n');
fprintf(fw,',,Year,Month,Day,Hour,Min,Sec,eve-lat,eve-lon,Depth,Mag.,Repi (km),Sta.,Comp.,ivert,sta-lat,sta-lon,VS30,Site class,Source,Sampling Rate,Quality,0.1,0.12,0.16,0.2,0.26,0.32,0.41,0.51,0.63,0.78,1,1.25,1.56,2,2.49,3.1,3.98,4.96,6.36,7.92,10.17,12.65,15.74,20.22,25.15,31.3,38.95,50,PGA,PGV\n');

fprintf(fw1,'Note: PSA and PGA are in cm/s^2 and PGV is in cm/s,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n');
fprintf(fw1,'PSAs are calculated for 5 percent of critical damping,,,,,,,,,,,,,,,,{},,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n');
fprintf(fw1,',,,,,,,,,,,,,,,,,,,,,,,Frequncy (Hz) at,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n');
fprintf(fw1,',,Year,Month,Day,Hour,Min,Sec,eve-lat,eve-lon,Depth,Mag.,Repi (km),Sta.,Comp.,ivert,sta-lat,sta-lon,VS30,Site class,Source,Sampling Rate,Quality,0.1,0.12,0.16,0.2,0.26,0.32,0.41,0.51,0.63,0.78,1,1.25,1.56,2,2.49,3.1,3.98,4.96,6.36,7.92,10.17,12.65,15.74,20.22,25.15,31.3,38.95,50,PGA,PGV\n');

for i = 1:length(cat.data)
    if ~isempty(cat.data(i).chn)
        for j = 1:length(cat.data(i).chn)
            if (cat.data(i).chn(j).Q <= 4 && cat.data(i).chn(j).p1 > 0)
            path_data = fullfile(get(handles.work_dir,'string'),cat.data(i).chn(j).ev_name,cat.data(i).chn(j).ch_name,'result.txt');
            fid = fopen(path_data,'rt');
            R = cell(20); ev_date = cell(20); M = cell(20); depth = cell(20); sr = cell(20); ep_lat = cell(20); ep_lon = cell(20); st_lat = cell(20); st_lon = cell(20);
            x = 0; k = 1;
            while (~strcmpi(x,'END_HEADER'))
                x=fgetl(fid);
                [ev_date{k}] = regexp(x,'Beginning\sof\srecord:\s+(\d+/\d+/\d+)','tokens');
                [time{k}] = regexp(x,'Event\sorigon\stime:\s+(\d+:\d+:\d+)','tokens');
                [depth{k}] = regexp(x,'Hypocentral\sdepth\(km\):\s+(\d+\.\d+)','tokens');
                [M{k}] = regexp(x,'Magnitude:\s+(\d+\.\d+)','tokens');
                [R{k}] = regexp(x,'Distance\sfrom\s\w+\s+:\s+(\d+\.\d+)','tokens');
                [sr{k}] = regexp(x,'Sampling\srate:\s+(\d+\.\d+)','tokens');
                [ep_lat{k}] = regexp(x,'Epicenter\slatitude:\s+(-?\d+\.\d+)','tokens');
                [ep_lon{k}] = regexp(x,'Epicenter\slongitude:\s+(-?\d+\.\d+)','tokens');
                [st_lat{k}] = regexp(x,'Station\slatitude:\s+(-?\d+\.\d+)','tokens');
                [st_lon{k}] = regexp(x,'Station\slongitude:\s+(-?\d+\.\d+)','tokens');
                k = k + 1;
            end
            
            fgetl(fid); fgetl(fid);
            % Load the entire data into A, and reshape into 15 column format.
            A = fscanf (fid, '%g');
            fclose(fid);
            A = reshape(A,15,length(A)/15)';

            R = R{find(~cellfun(@isempty,R))}{1};
            ev_date = ev_date{find(~cellfun(@isempty,ev_date))}{1};
            time = time{find(~cellfun(@isempty,time))}{1};
            ep_lat = ep_lat{find(~cellfun(@isempty,ep_lat))}{1};
            ep_lon = ep_lon{find(~cellfun(@isempty,ep_lon))}{1};
            depth = depth{find(~cellfun(@isempty,depth))}{1};
            M = M{find(~cellfun(@isempty,M))}{1};
            sr = sr{find(~cellfun(@isempty,sr))}{1};
            st_lat = st_lat{find(~cellfun(@isempty,st_lat))}{1};
            st_lon = st_lon{find(~cellfun(@isempty,st_lon))}{1};
            
            station = strrep(cat.data(i).chn(j).ch_name, 'CN.', '');
            station = regexp(station,'\.\.','split');
            sta = station{1}; comp = station{2};
            date_data = regexp(ev_date,'/','split');
            date_data = date_data{1}; yy = date_data{1}; mm = date_data{2}; dd = date_data{3};
            time_data = regexp(time,':','split');
            time_data = time_data{1}; hr = time_data{1}; min = time_data{2}; sec = time_data{3};
            
            
            idx_c = strcmp(sta2,sta);
            idx = find(idx_c);
            
            if isempty(idx)
                vs30_1 = [];
                source_1 = '';
                class_1 = '';
            else
                vs30_1 = vs30(idx);
                source_1 = source{idx};
                class_1 = class{idx};
            end
            
            p1 = round (cat.data(i).chn(j).p1*str2double(sr{1}));
            p2 = round (cat.data(i).chn(j).p4*str2double(sr{1}));
            acc = A(:,15);
            
            fas = get_FAS(acc(p1:p2),str2double(sr{1}),handles);
            psa = get_PSA(acc(p1:p2),str2double(sr{1}),handles);
                        
            pga = max(abs(A(:,15)));
            pgv = max(abs(A(:,14)));
            
            fprintf(fw,',,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,,%s,%s,%d,%s,%s,%s,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.9f,%.9f',yy,mm,dd,hr,min,sec,ep_lat{1},ep_lon{1},depth{1},M{1},R{1},sta,comp,st_lat{1},st_lon{1},vs30_1,class_1,source_1,sr{1},cat.data(i).chn(j).Q,psa,pga,pgv);
            fprintf(fw,'\n');
            fprintf(fw1,',,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,,%s,%s,%d,%s,%s,%s,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.9f,%.9f',yy,mm,dd,hr,min,sec,ep_lat{1},ep_lon{1},depth{1},M{1},R{1},sta,comp,st_lat{1},st_lon{1},vs30_1,class_1,source_1,sr{1},cat.data(i).chn(j).Q,fas,pga,pgv);
            fprintf(fw1,'\n');
            
            fprintf('%d of %d events, %d of %d channel\n',i,length(cat.data),j,length(cat.data(i).chn));
            end
        end
    end
end

fclose(fw);
fclose(fw1);


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(~, ~, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
write_out(handles)

function [Apsa] = get_PSA(x,sr,handles)
fid1 = fopen(fullfile(get(handles.work_dir,'string'),'series'), 'w');
fprintf(fid1, '%f\n', sr);
for i = 1:length(x)
fprintf(fid1, '%d\n', x(i));
end
fclose(fid1);

fid = fopen(fullfile(get(handles.work_dir,'string'),'Beh1.ctl'), 'w');
fprintf(fid, '%d\n', 1);
fprintf(fid, '%s %d\n', fullfile(get(handles.work_dir,'string'),'series'),length(x));
fprintf(fid, 'psa.out\n0\n5.\n28\n  0.1\n  0.12\n  0.16\n  0.2\n  0.26\n  0.32\n  0.41\n  0.51\n  0.63\n  0.78\n  1\n  1.25\n  1.56\n  2\n  2.49\n  3.1\n  3.98\n  4.96\n  6.36\n  7.92\n  10.17\n  12.65\n  15.74\n  20.22\n  25.15\n  31.3\n  38.95\n  50\n');
fclose(fid);


cd(get(handles.work_dir,'string'));
system('./Beh1');

load psa.out;
%fpsa = psa(1,2:end); 
Apsa = psa(2,2:end);

function [Afas] = get_FAS(x,sr,handles)
Af = fft(x); 

Afas = zeros(28,1);
fqs = [0.1 0.12	0.16 0.2 0.26 0.32 0.41 0.51 0.63 0.78 1 1.25 1.56 2 2.49 3.1 3.98 4.96	6.36 7.92 10.17 12.65 15.74 20.22 25.15 31.3 38.95 50 57];
fn = floor(fqs * length(x)/sr);         % Index of x corresponding to the frequency fqs(i)
i = 1;

while (fn(i) <= length(x)/2 && i <= length(fqs))
    if (i == 1)
        f1 = 1; f2 = fn(i+1);
    else
        f1 = fn(i-1); f2 = fn(i+1);
    end
    
    if (fn(i) > 0 && f1 > 0 && f2 > 0 && f1 <= f2)
        Afas(i) = 10^(mean(log10(abs(Af(f1:f2)))))/sr; % Geometric mean
    end
i = i + 1;
end
 
% --- Executes on button press in Debug.
function Debug_Callback(hObject, eventdata, handles)
% Only used while developing this program, to access the 
% handles at the command prompt.
keyboard


% Enable hotkeys when focus is on this listbox
function listbox3_KeyPressFcn(hObject, eventdata, handles)

	hotkeys(hObject, eventdata, handles)


% Enable hotkeys when focus is on this listbox
function listbox2_KeyPressFcn(hObject, eventdata, handles)

	hotkeys(hObject, eventdata, handles)


% --- Executes when selected object is changed in uipanel6.
function uipanel6_SelectionChangeFcn(hObject, eventdata, handles)
	update_plots(handles)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)

	setappdata(handles.figure1, 'auto', 1);
	update_plots(handles);


function edit2_Callback(hObject, eventdata, handles)

	check_custom_filter(handles)
	update_plots(handles);


function popupmenu1_Callback(hObject, eventdata, handles)

	update_plots(handles);


function popupmenu2_Callback(hObject, eventdata, handles)

	update_plots(handles);




% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)

	update_plots(handles);


















%%
%% UNUSED OR LESS FREQUENTLY USED FUNCTIONS
%% You might want to let them be.
%%



% --- Outputs from this function are returned to the command line.
function varargout = pick_ph_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over work_dir.
function work_dir_ButtonDownFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu2_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
slidee(handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
listbox2_Callback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
listbox2_Callback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox2
