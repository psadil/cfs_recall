function responses = getSubjectInfo(varargin)

    % Calling Example
    % getSubjectInfo('subject', struct('title', 'Subject Number', 'type', 'textinput', 'validationFcn', @(x) (isnumeric(x) && ~isnan(x))), ...
    %                'group', struct('title' ,'Group', 'type', 'dropdown', 'values', {{'immediate','delay'}}), ...
    %                'session', struct('title', 'Session', 'type', 'dropdown', 'values', {{'1','2'}}));

    %% --- parse and validate input --- %%

    ip = inputParser;
    ip.KeepUnmatched = true; % can have an arbitrary number of fields so this is important
    addParamValue(ip,'title', 'Input Subject Info', @ischar); %#ok<*NVREPL> dont warn about addParamValue
    parse(ip,varargin{:});
    fields = validateInputStruct(ip.Unmatched);
    %% --- Initialize the blank GUI window --- %%

    %some constants to use
    dims =  get(0, 'ScreenSize');
    offset= 0;
    width = 250;
    margin = 10;
    padding = 5;
    button_size = 30;
    title_size = 20;
    text_size = 30;
    check_size = 20;
    types = struct2cell(structfun(@(s) s.type, fields, 'UniformOutput', false));
    height = ((title_size+text_size)*sum(strcmp('textinput', types))) + ...
        ((title_size+text_size)*sum(strcmp('dropdown', types))) + ...
        (check_size*sum(strcmp('check', types))) +  button_size + (3*margin);
                 
    % create the figure
    fig = dialog('Name', ip.Results.title, 'Position', [(dims(3)/2) + width/2, (dims(4)/2) + height/2, width, height], ... 
                 'ToolBar','None','MenuBar','none', 'NumberTitle','off','Visible','off');

    % Add objects to the gui iteratively
    names = fieldnames(fields);
    for i = 1:length(names)
        % props.callback specifies the function that gets called whenever the user
        % interacts with the input GUI. The first element of the cell array is
        % a handle to the callback function and addtional elements contain
        % variables which will be passed to the function.
        props.callback = {@interact, names{i}};
        props.FontSize = 11;
        props.Tag = names{i};
        
        % If a field is a drop down or text input field, first give it a title by
        % using its 'title' property to create a text uicontrol object
        if any(ismember(fields.(names{i}).type, {'textinput','dropdown'}))
            props.Horiz ='left';
            props.Background = 'w';
            props.Position = [margin, height - offset - padding - title_size - text_size, width-2*margin, text_size];
            uicontrol(fig, 'Style', 'text', 'String', fields.(names{i}).title, ...
                'Horiz', 'left', 'Tag', [ names{i} '_title'], ...
                'Position', [margin, height - offset - margin - title_size, width-2*margin, title_size]);
        end

        % Next, fill in their values and set appearace properties
        % if the initial values pass validation, set their userdata values
        % to true
        if strcmp(types{i}, 'textinput')
            fields.(names{i}).handle = uicontrol(fig, props, 'Style', 'edit', 'String', fields.(names{i}).values);
            isvalid = fields.(names{i}).validationFcn(fields.(names{i}).values);
        elseif strcmp(types{i}, 'dropdown')
            fields.(names{i}).handle = uicontrol(fig, props, 'Style', 'popupmenu', 'String', fields.(names{i}).values, 'Value', 1);
            isvalid = fields.(names{i}).validationFcn(getPopupString(fields.(names{i}).handle));
        else % The only alternative is checkbox   
            fields.(names{i}).handle = uicontrol(fig, props, 'Style', 'checkbox', 'String', fields.(names{i}).title, ...
                'Val', fields.(names{i}).values, 'Position',[margin, height - offset - margin - check_size, width-2*margin, check_size]);
            isvalid = fields.(names{i}).validationFcn(fields.(names{i}).values);
        end
        set(fields.(names{i}).handle, 'UserData', isvalid);
        offset = offset + (strcmp(types{i},'checkbox')*check_size) + (~strcmp(types{i},'checkbox')*text_size) + ...
            (~strcmp(types{i},'checkbox')*title_size);
    end

    % add cancel and run buttons
    run = uicontrol(fig, 'Style','pushbutton', 'String', 'Run', 'Tag', 'RunBtn', 'Callback', @(~,~)  uiresume(gcbf), ...
              'Pos', [(width/2)+padding height-(height-10) ((width-2*margin)/2)-margin, button_size], ...
              'Enable','off');
    uicontrol(fig, 'Style','pushbutton','String','Cancel','Tag','CancelBtn','Callback' , @(~,~) delete(gcbf) , ...
              'Pos', [margin height-(height-10) ((width-2*margin)/2)-padding, button_size])

    % Add the fields info to the userdata of the parent object
    % Storing it here is useful so we can easily look it up and update it as needed
    set(fig, 'UserData', fields);
    
    % See if we should enable the run button by checking each fields UserData
    % If all their values passed validation, then we enable it
    if validateAllFields(fields)
        set(run,'Enable','on');
    end
    set(fig,'Visible','on'); % Show the input dialog to the user
    uiwait(fig);    % Wait for input

    % Parse input
    if ishghandle(fig)
        responses = struct;
        allFields = extractInput(get(fig, 'UserData'));
        for i = 1:length(names)
            responses.(names{i}) = allFields.(names{i}).input;
        end
        delete(fig);
    else
        responses = [];
    end
    
end

function allFields = extractInput(allFields)
    names = fieldnames(allFields);
    for i = 1:length(names)
        if strcmp('textinput',allFields.(names{i}).type)
            allFields.(names{i}).input = get(allFields.(names{i}).handle, 'String');
        elseif strcmp('dropdown',allFields.(names{i}).type)
            allFields.(names{i}).input = getPopupString(allFields.(names{i}).handle);
        else
            allFields.(names{i}).input = get(allFields.(names{i}).handle,'Value');
        end
    end
end

function allValid = validateAllFields(allFields)
    handles = structfun(@(s) s.handle, allFields, 'UniformOutput', false);
    status = structfun(@(s) get(s, 'UserData'), handles, 'UniformOutput', false);
    allValid = all(structfun(@(s) s == 1, status));
end

function interact(objectHandle, ~, currentField)
% the ~ is a placeholders for eventData
    
    % Extract the updates from all the fields, and update the global userdata
    parent = get(objectHandle,'Parent');
    allFields = extractInput(get(parent, 'UserData'));
    set(parent, 'UserData', allFields)    
    if ismember(allFields.(currentField).type, {'textinput','dropdown'})
        titleHandle = findobj('Tag',[currentField '_title']);
    else
        titleHandle = objectHandle;
    end    

    [valid, message] = allFields.(currentField).validationFcn(allFields.(currentField).input, allFields);
    if ~ valid
       set(allFields.(currentField).handle ,'UserData',struct('validInput', false));
       set(findobj('Tag','RunBtn'),'Enable','off')              
       set(titleHandle,'String', message);
       set(titleHandle,'Background','r');
    else
       set(allFields.(currentField).handle, 'UserData', true);
       set(titleHandle,'String',allFields.(currentField).title);
       set(titleHandle,'Background',[.94 .94 .94]);
       if validateAllFields(allFields)
           set(findobj('Tag','RunBtn'),'Enable','on');
       end
    end
end

function str = getPopupString(objectHandle)
    %# getCurrentPopupString returns the currently selected string in the popupmenu with handle objectHandle
    if ~ishandle(objectHandle) || ~strcmp(get(objectHandle,'Style'),'popupmenu')
        error('getCurrentPopupString needs a handle to a popupmenu as input')
    end

    %# get the string the readable way
    list = get(objectHandle,'String');
    val = get(objectHandle,'Value');
    if iscell(list)
        str = list{val};
    else
        str = list(val,:);
    end
end

function guiFields = validateInputStruct(guiFields)

validProperties = {'type','values','title', 'validationFcn'};
errorGeneric = '\nFeild ''%s'' is missing a value for the required property ''%s''.\n';

    for i = fieldnames(guiFields)'
        
        current = i{1};
        currentFieldProperties = fieldnames(guiFields.(current));

        % Make sure there are no unknown properties specified
        difference = strcat('"', setdiff(currentFieldProperties, validProperties), '"');
        assert(all(ismember(currentFieldProperties, validProperties)), ...
            strjoin({'Field "%s" contains unrecognized properties:', difference{:}}, ' '), ...
            current) %#ok<CCAT>

        % Make sure a valid type of ui object is specified for all fields.
        assert( (isfield(guiFields.(current),'type') && ismember(guiFields.(current).type, {'textinput','dropdown','check'}) ), ...
            [errorGeneric '''type'' must be ''textinput'', ''dropdown'', or ''check'' for each field.'], ...
            current, 'type')

        % Make sure there are no unknown properties specified
        assert( isfield(guiFields.(current),'title') && ischar(guiFields.(current).title), ...
               [errorGeneric '''title'' must be specified with a charater string for each field.'], ...
               current, 'title')                
        
        % What we do with value depends on the ui object type
        % If its a dropdown, value has to be given by the caller
        if strcmp('dropdown', guiFields.(current).type)
            assert(isfield(guiFields.(current),'values') && ~isempty(guiFields.(current).values(1)), ...
                [errorGeneric 'Fields with ''type'' set to ''dropdown'' must use the property ''values'' to populate the menu options.'], ...
                   current, 'values');
        % If its a checkbox and value is given, it has to be zero or 1
        elseif strcmp('check', guiFields.(current).type) && isfield(guiFields.(current), 'values')
            assert(is.member(guiFields.(current), {0,1}), ...
                [errorGeneric 'Fields with ''type'' set to ''check'' can only set ''values'' to 0 (unselected) or 1 (selected).'], ...
                current, 'values');
        %  If its a checkbox with no value given, use zero
        elseif strcmp('check', guiFields.(current).type) && ~isfield(guiFields.(current), 'values')
            guiFields.(current).values = [];
        %  If its a text input box with no value given, use an empty string         
        elseif strcmp('textinput', guiFields.(current).type) && ~isfield(guiFields.(current), 'values')
            guiFields.(current).values = 0;            
        end

        % if no validation function is given, use a dummy function that
        % is always true. If you don't care, we don't care!
        if ~isfield(guiFields.(current),'validationFcn')
            guiFields.(current).validationFcn = @dummyFunction;
        end
    end
end

function [valid, msg] =  dummyFunction(varargin)
    valid = true;
    msg = 'You should never see this?';
end
