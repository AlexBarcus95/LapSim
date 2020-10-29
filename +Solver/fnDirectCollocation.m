function soln = fnDirectCollocation(problem)

%% To make code more readable

B       = problem.bounds;
F       = problem.func;
Opt     = problem.options;
sLap    = problem.dsSystem.td.sLap;
nGrid   = length(F.weights);

%%  Pack the initial guess

[zGuess, pack] = packDecVar(problem.guess.state, problem.guess.control);

%%  Pack the lower and upper bounds

xLow = [B.initialState.low, B.state.low*ones(1,nGrid-2), B.finalState.low];
uLow = B.control.low*ones(1,nGrid);
zLow = packDecVar(xLow,uLow);

xUpp = [B.initialState.upp, B.state.upp*ones(1,nGrid-2), B.finalState.upp];
uUpp = B.control.upp*ones(1,nGrid);
zUpp = packDecVar(xUpp,uUpp);

%% Set up the functions, bounds, and options for fmincon

P.objective = @(z)( myObjective(z, pack, F.objective, F.weights, sLap) );
P.nonlcon = @(z)( myConstraint(z, pack, F.stateDynamics, F.constraints, F.defectCst, sLap) );

P.x0 = zGuess;
P.lb = zLow;
P.ub = zUpp;
P.Aineq = []; P.bineq = []; % Unused
P.Aeq = []; P.beq = [];     % Unused
P.options = Opt.nlpOpt;
P.solver = 'fmincon';

%% Call fmincon to solve the non-linear program (NLP)
tic;
[zSoln, objVal, exitFlag, output] = fmincon(P);
nlpTime = toc;

%% Unpack the solution and store the results

[xSoln,uSoln] = unPackDecVar(zSoln,pack); % Unpack decision variables

soln.grid.sLap = sLap;
soln.grid.state = xSoln;
soln.grid.control = uSoln;

soln.info = output;
soln.info.nlpTime = nlpTime;
soln.info.exitFlag = exitFlag;
soln.info.objVal = objVal;

end

%% Utility Functions

function [z,pack] = packDecVar(x,u)

nGrid = size(x,2);
nState = size(x,1);
nControl = size(u,1);

xCol = reshape(x, nState*nGrid, 1);
uCol = reshape(u, nControl*nGrid, 1);

indz = reshape(1:numel(u)+numel(x),nState+nControl,nGrid);

% index of state and control variables in the decVar vector
xIdx = indz(1:nState,:);
uIdx = indz(nState+(1:nControl),:);

% decision variables are indexed so that the defects gradients appear as a banded matrix
z = zeros(numel(indz),1);
z(xIdx(:),1) = xCol;
z(uIdx(:),1) = uCol;

pack.nGrid = nGrid;
pack.nState = nState;
pack.nControl = nControl;
pack.xIdx = xIdx;
pack.uIdx = uIdx;

end

function [x,u] = unPackDecVar(z,pack)

nGrid = pack.nGrid;
nState = pack.nState;
nControl = pack.nControl;

x = z(pack.xIdx);
u = z(pack.uIdx);

% make sure x and u are returned as vectors, [nState,nTime] and [nControl,nTime]
x = reshape(x,nState,nGrid);
u = reshape(u,nControl,nGrid);

end

%% Objective function

function cost = myObjective(z,pack,objective,weights,sLap)
% This function returns the final weighted cost

[x,u] = unPackDecVar(z,pack);

ds = (sLap(end) - sLap(1)) / (pack.nGrid - 1);
integrand = objective(x,u);   % Calculate the integrand of the cost function
cost = ds*integrand*weights;  % Integration

end

%% Constraint Function

function [c, ceq] = myConstraint(z,pack,dynFun,constraints,defectCst,sLap)
% This function computes the defects along the path
% and then evaluates the user-defined constraint functions

[x,u] = unPackDecVar(z,pack);

% Calculate defects along the path
ds = (sLap(end) - sLap(1)) / (pack.nGrid - 1);
f = dynFun(x,u);
defects = defectCst(ds,x,f);

% Call user-defined constraints and combine with defects
[c, ceq] = Solver.fnCollectConstraints(x,u,defects,constraints);

end
