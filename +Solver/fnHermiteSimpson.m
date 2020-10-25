function soln = fnHermiteSimpson(problem)
% soln = fnHermiteSimpson(problem)

% Each segment needs an additional data point in the middle, thus:
nGrid = 2*problem.options.hermiteSimpson.nSegment+1;
fprintf('  -> Transcription via Hermite-Simpson method, nSegment = %d\n',...
    problem.options.hermiteSimpson.nSegment);

%%%% Method-specific details to pass along to solver:

%Simpson quadrature for integration of the cost function:
problem.func.weights = (2/3)*ones(nGrid,1);
problem.func.weights(2:2:end) = 4/3;
problem.func.weights([1,end]) = 1/3;

% Hermite-Simpson calculation of defects:
problem.func.defectCst = @computeDefects;

%%%% The key line - solve the problem by direct collocation:
soln = Solver.fnDirectCollocation(problem);

end

function defects = computeDefects(dt,x,f)
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