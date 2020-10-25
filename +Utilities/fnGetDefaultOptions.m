function problem = fnGetDefaultOptions(problem)
% problem = fnGetDefaultOptions(problem)
%
% This function fills in any blank entries in the problem.options struct.

%%%% Top-level default options:
OPT.method = 'trapezoid';
OPT.verbose = 2;
OPT.defaultAccuracy = 'medium';

%%%% Basic setup

% ensure that options is not empty
if ~isfield(problem,'options')
    problem.options.method = OPT.method;
end
opt = problem.options;

if ~isfield(opt,'method')
    opt.method = OPT.method;
elseif isempty(opt.method)
    opt.method = OPT.method;
end
if ~isfield(opt,'verbose')
    opt.verbose = OPT.verbose;
elseif isempty(opt.verbose)
    opt.verbose = OPT.verbose;
end
if ~isfield(opt,'defaultAccuracy')
    opt.defaultAccuracy = OPT.defaultAccuracy;
elseif isempty(opt.defaultAccuracy)
    opt.defaultAccuracy = OPT.defaultAccuracy;
end

% Figure out basic problem size:
nState = size(problem.guess.state,1);
nControl = size(problem.guess.control,1);

% Loop over opt and fill in nlpOpt struct:
switch opt.verbose
    case 0
        NLP_display = 'notify';
    case 1
        NLP_display = 'final-detailed';
    case 2
        NLP_display = 'iter';
    case 3
        NLP_display = 'iter-detailed';
    otherwise
        error('Invalid value for options.verbose');
end
switch opt.defaultAccuracy
    case 'low'
        OPT.nlpOpt = optimset(...
            'Display',NLP_display,...
            'TolFun',1e-4,...
            'MaxIter',200,...
            'MaxFunEvals',1e4*(nState+nControl));
    case 'medium'
        OPT.nlpOpt = optimset(...
            'Display',NLP_display,...
            'TolFun',1e-6,...
            'MaxIter',400,...
            'MaxFunEvals',5e4*(nState+nControl));
    case 'high'
        OPT.nlpOpt = optimset(...
            'Display',NLP_display,...
            'TolFun',1e-8,...
            'MaxIter',800,...
            'MaxFunEvals',1e5*(nState+nControl));
    otherwise
        error('Invalid value for options.defaultAccuracy')
end
if isfield(opt,'nlpOpt')
    if isstruct(opt.nlpOpt) && ~isempty(opt.nlpOpt)
        names = fieldnames(opt.nlpOpt);
        for j=1:length(names)
            if ~isfield(OPT.nlpOpt,names{j})
                disp(['WARNING: options.nlpOpt.' names{j} ' is not a valid option']);
            else
                OPT.nlpOpt.(names{j}) = opt.nlpOpt.(names{j});
            end
        end
    end
end
opt.nlpOpt = OPT.nlpOpt;

% Fill in method-specific paramters:
OPT_method = opt.method;
switch OPT_method
    case 'trapezoid'
        OPT.trapezoid = defaults_trapezoid(opt.defaultAccuracy);
    case 'hermiteSimpson'
        OPT.hermiteSimpson = defaults_hermiteSimpson(opt.defaultAccuracy);
    otherwise
        error('Invalid value for options.method');
end
if isfield(opt,OPT_method)
    if isstruct(opt.(OPT_method)) && ~isempty(opt.(OPT_method))
        names = fieldnames(opt.(OPT_method));
        for j=1:length(names)
            if ~isfield(OPT.(OPT_method),names{j})
                disp(['WARNING: options.' OPT_method '.' names{j} ' is not a valid option']);
            else
                OPT.(OPT_method).(names{j}) = opt.(OPT_method).(names{j});
            end
        end
    end
end
opt.(OPT_method) = OPT.(OPT_method);

problem.options = opt;
end

function OPT_trapezoid = defaults_trapezoid(accuracy)

switch accuracy
    case 'low'
        OPT_trapezoid.nGrid = 12;
    case 'medium'
        OPT_trapezoid.nGrid = 30;
    case 'high'
        OPT_trapezoid.nGrid = 60;
    otherwise
        error('Invalid value for options.defaultAccuracy')
end

OPT_trapezoid.adaptiveDerivativeCheck = 'off';

end

function OPT_hermiteSimpson = defaults_hermiteSimpson(accuracy)

switch accuracy
    case 'low'
        OPT_hermiteSimpson.nSegment = 10;
    case 'medium'
        OPT_hermiteSimpson.nSegment = 20;
    case 'high'
        OPT_hermiteSimpson.nSegment = 40;
    otherwise
        error('Invalid value for options.defaultAccuracy')
end

OPT_hermiteSimpson.adaptiveDerivativeCheck = 'off';

end