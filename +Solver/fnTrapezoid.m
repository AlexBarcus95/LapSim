function soln = fnTrapezoid(problem)
% soln = fnTrapezoid(problem)

nGrid = problem.options.trapezoid.nGrid;
fprintf('  -> Transcription via trapezoid method, nGrid = %d\n',nGrid);

%%%% Method-specific details to pass along to solver:

% Quadrature weights for trapezoid integration:
problem.func.weights = ones(nGrid,1);
problem.func.weights([1,end]) = 0.5;

% Trapazoid integration calculation of defects:
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

idxLow = 1:(nTime-1);
idxUpp = 2:nTime;

xLow = x(:,idxLow);
xUpp = x(:,idxUpp);

fLow = f(:,idxLow);
fUpp = f(:,idxUpp);

% This is the key line:  (Trapazoid Rule)
defects = xUpp-xLow - 0.5*dt*(fLow+fUpp);

end