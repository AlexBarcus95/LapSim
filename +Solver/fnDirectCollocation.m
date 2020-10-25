function soln = fnDirectCollocation(problem)
% soln = fnDirectCollocation(problem)

%To make code more readable
G   = problem.guess;
B   = problem.bounds;
F   = problem.func;
Opt = problem.options;

nGrid = length(F.weights);

% Interpolate the guess at the grid-points for transcription:
guess.tSpan = G.time([1,end]);
guess.time = linspace(guess.tSpan(1), guess.tSpan(2), nGrid);
guess.state = interp1(G.time', G.state', guess.time')';
guess.control = interp1(G.time', G.control', guess.time')';

[zGuess, pack] = packDecVar(guess.time, guess.state, guess.control);

% Unpack all bounds:
tLow = linspace(B.initialTime.low, B.finalTime.low, nGrid);
xLow = [B.initialState.low, B.state.low*ones(1,nGrid-2), B.finalState.low];
uLow = B.control.low*ones(1,nGrid);
zLow = packDecVar(tLow,xLow,uLow);

tUpp = linspace(B.initialTime.upp, B.finalTime.upp, nGrid);
xUpp = [B.initialState.upp, B.state.upp*ones(1,nGrid-2), B.finalState.upp];
uUpp = B.control.upp*ones(1,nGrid);
zUpp = packDecVar(tUpp,xUpp,uUpp);

%%%% Set up problem for fmincon:
P.objective = @(z)( myObjective(z, pack, F.objective, F.weights) );   %Numerical gradients

P.nonlcon = @(z)( myConstraint(z, pack, F.stateDynamics, F.pathCst, F.defectCst) ); %Numerical gradients

P.x0 = zGuess;
P.lb = zLow;
P.ub = zUpp;
P.Aineq = []; P.bineq = []; % Unused
P.Aeq = []; P.beq = [];     % Unused
P.options = Opt.nlpOpt;
P.solver = 'fmincon';

%%%% Call fmincon to solve the non-linear program (NLP)
tic;
[zSoln, objVal,exitFlag,output] = fmincon(P);
nlpTime = toc;

%%%% Store the results:

[tSoln,xSoln,uSoln] = unPackDecVar(zSoln,pack); % Unpack decision variables

soln.grid.time = tSoln;
soln.grid.state = xSoln;
soln.grid.control = uSoln;

soln.info = output;
soln.info.nlpTime = nlpTime;
soln.info.exitFlag = exitFlag;
soln.info.objVal = objVal;

soln.problem = problem;  % Return the fully detailed problem struct

end


%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%
%%%%                          SUB FUNCTIONS                            %%%%
%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%


function [z,pack] = packDecVar(t,x,u)

nTime = length(t);
nState = size(x,1);
nControl = size(u,1);

tSpan = [t(1); t(end)];
xCol = reshape(x, nState*nTime, 1);
uCol = reshape(u, nControl*nTime, 1);

indz = reshape(2+(1:numel(u)+numel(x)),nState+nControl,nTime);

% index of time, state, control variables in the decVar vector
tIdx = 1:2;
xIdx = indz(1:nState,:);
uIdx = indz(nState+(1:nControl),:);

% decision variables
% variables are indexed so that the defects gradients appear as a banded
% matrix
z = zeros(2+numel(indz),1);
z(tIdx(:),1) = tSpan;
z(xIdx(:),1) = xCol;
z(uIdx(:),1) = uCol;

pack.nTime = nTime;
pack.nState = nState;
pack.nControl = nControl;
pack.tIdx = tIdx;
pack.xIdx = xIdx;
pack.uIdx = uIdx;

end

%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%

function [t,x,u] = unPackDecVar(z,pack)

nTime = pack.nTime;
nState = pack.nState;
nControl = pack.nControl;

t = linspace(z(1),z(2),nTime);

x = z(pack.xIdx);
u = z(pack.uIdx);

% make sure x and u are returned as vectors, [nState,nTime] and
% [nControl,nTime]
x = reshape(x,nState,nTime);
u = reshape(u,nControl,nTime);

end

%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%

function cost = myObjective(z,pack,objective,weights)
% This function returns the final weighted cost

[t,x,u] = unPackDecVar(z,pack);

dt = (t(end)-t(1))/(pack.nTime-1);
integrand = objective(t,x,u);  %Calculate the integrand of the cost function
cost = dt*integrand*weights;  %Trapazoidal integration

end

%%%%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%%%%

function [c, ceq] = myConstraint(z,pack,dynFun, pathCst, defectCst)
% This function computes the defects along the trajectory
% and then evaluates the user-defined constraint functions.

[t,x,u] = unPackDecVar(z,pack);

%%%% Compute defects along the trajectory:
dt = (t(end)-t(1))/(length(t)-1);
f = dynFun(t,x,u);
defects = defectCst(dt,x,f);

%%%% Call user-defined constraints and pack up:
[c, ceq] = Solver.fnCollectConstraints(t,x,u,defects, pathCst);

end
