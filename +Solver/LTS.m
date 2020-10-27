function soln = LTS(problem)

%% Validate the input parameters and set the options

problem = Utilities.fnInputValidation(problem);   % Check inputs
problem = Utilities.fnGetDefaultOptions(problem); % Complete options struct

%% Set the specific parameters for trapezoid or HS integration and collocation
switch problem.options.method
    case 'trapezoid'
        nGrid = problem.options.trapezoid.nGrid;
        % Set quadrature weights for trapezoid integration
        problem.func.weights = ones(nGrid,1);
        problem.func.weights([1,end]) = 0.5;
        % Set the constraint function for calculation of trapezoidal defects
        problem.func.defectCst = @computeTrapezoidDefects;
        
    case 'hermiteSimpson'
        nGrid = 2*problem.options.hermiteSimpson.nSegment+1;
        % Set quadrature weights for HS integration
        problem.func.weights = (2/3)*ones(nGrid,1);
        problem.func.weights(2:2:end) = 4/3;
        problem.func.weights([1,end]) = 1/3;
        % Set the constraint function for calculation of HS defects
        problem.func.defectCst = @computeHSDefects;
        
    otherwise
        error('Invalid method.');
end

%% Solve the problem by direct collocation
soln = Solver.fnDirectCollocation(problem);
soln.problem = problem;

end

function defects = computeTrapezoidDefects(dt,x,f)
%
% This function computes the defects that are used to enforce the
% continuous dynamics of the system along the trajectory.
%

nTime = size(x,2);

idxLow = 1:(nTime-1);
idxUpp = 2:nTime;

xLow = x(:,idxLow);
xUpp = x(:,idxUpp);

fLow = f(:,idxLow);
fUpp = f(:,idxUpp);

% This is the key line:  (Trapazoid Rule)
defects = xUpp-xLow - 0.5*dt*(fLow+fUpp);

end

function defects = computeHSDefects(dt,x,f)
%
% This function computes the defects that are used to enforce the
% continuous dynamics of the system along the trajectory.
%

nTime = size(x,2);
nState = size(x,1);

iLow = 1:2:(nTime-1);
iMid = iLow + 1;
iUpp = iMid + 1;

xLow = x(:,iLow);
xMid = x(:,iMid);
xUpp = x(:,iUpp);

fLow = f(:,iLow);
fMid = f(:,iMid);
fUpp = f(:,iUpp);

% Mid-point constraint (Hermite)
defectMidpoint = xMid - (xUpp+xLow)/2 - dt*(fLow-fUpp)/4;

% Interval constraint (Simpson)
defectInterval = xUpp - xLow - dt*(fUpp + 4*fMid + fLow)/3;

% Pack up all defects: Arrnage for bandedness
defects = zeros(nState,nTime-1);
defects(:,iLow) = defectInterval;
defects(:,iMid) = defectMidpoint;

end