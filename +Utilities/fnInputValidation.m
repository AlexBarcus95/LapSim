function problem = fnInputValidation(problem)
% problem = fnInputValidation(problem)
% 
% This function runs through the problem struct and sets any missing fields
% to the default value. If a mandatory field is missing, then it throws an
% error.
%

%%%% Check the function handles:

if ~isfield(problem.func,'stateDynamics')
    error('Field ''stateDynamics'' cannot be ommitted from ''problem.func'''); end
if ~isfield(problem.func,'objective')
    error('Field ''objective'' cannot be ommitted from ''problem.func'''); end
if ~isfield(problem.func,'constraints'), problem.func.constraints = []; end

%%%% Compute nState and nControl:

[nState, ~] = size(problem.guess.state);
[nControl, ~] = size(problem.guess.control);

%%%% Check the problem bounds:

if ~isfield(problem,'bounds')
    problem.bounds.state = [];
    problem.bounds.initialState = [];
    problem.bounds.finalState = [];
    problem.bounds.control = [];
else
    
    if ~isfield(problem.bounds,'state')
        problem.bounds.state = []; end
    problem.bounds.state = ...
        checkLowUpp(problem.bounds.state,nState,1,'state');
    
    if ~isfield(problem.bounds,'initialState')
        problem.bounds.initialState = []; end
    problem.bounds.initialState = ...
        checkLowUpp(problem.bounds.initialState,nState,1,'initialState');
    
    if ~isfield(problem.bounds,'finalState')
        problem.bounds.finalState = []; end
    problem.bounds.finalState = ...
        checkLowUpp(problem.bounds.finalState,nState,1,'finalState');
    
    if ~isfield(problem.bounds,'control')
        problem.bounds.control = []; end
    problem.bounds.control = ...
        checkLowUpp(problem.bounds.control,nControl,1,'control');
    
end

end

function input = checkLowUpp(input,nRow,nCol,name)
%
% This function checks that input has the following is true:
%   size(input.low) == [nRow, nCol]
%   size(input.upp) == [nRow, nCol]

if ~isfield(input,'low')
    input.low = -inf(nRow,nCol);
end

if ~isfield(input,'upp')
    input.upp = inf(nRow,nCol);
end

[lowRow, lowCol] = size(input.low);
if lowRow ~= nRow || lowCol ~= nCol
    error(['problem.bounds.' name ...
        '.low must have size = [' num2str(nRow) ', ' num2str(nCol) ']']);
end

[uppRow, uppCol] = size(input.upp);
if uppRow ~= nRow || uppCol ~= nCol
    error(['problem.bounds.' name ...
        '.upp must have size = [' num2str(nRow) ', ' num2str(nCol) ']']);
end

if sum(sum(input.upp-input.low < 0))
    error(...
        ['problem.bounds.' name '.upp must be >= problem.bounds.' name '.low!']);
end

end