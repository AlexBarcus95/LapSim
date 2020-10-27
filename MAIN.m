%% MAIN.m  --  LapSim

clear;
clc;

%% Set Collocation Parameters

sDist = 300;
% problem.options.method = 'trapezoid';
problem.options.method = 'hermiteSimpson';

switch problem.options.method
    case 'trapezoid'
        nPoints = 50; % TEMP
        problem.options.trapezoid.nGrid = nPoints;
        gridSize = nPoints;
    case 'hermiteSimpson'
        nPoints = 25; % TEMP
        problem.options.hermiteSimpson.nSegment = nPoints;
        gridSize = 2*nPoints + 1;
    otherwise
        error('Invalid method.');
end

%% Initialise Track, System and Car Parameters

td          = Initialise.fnInitTrack(sDist,gridSize);
dsSystem    = Initialise.fnInitSystem(td);
vd          = Initialise.fnInitVd(dsSystem);

%% Set up function handles for the dynamics, objective, and constraints

problem.func.stateDynamics = @(s,x,u)( Controller.fnDynamics(x,u,vd) );
problem.func.objective = @(s,x,u)( Controller.fnObjective(x) );
problem.func.constraints = @(s,x,u)( Controller.fnConstraints(s,x,vd,dsSystem) );

%% Set up the bounds of the states and controls

problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = sDist;
problem.bounds.finalTime.upp = sDist;

problem.bounds.state.low = 0;
problem.bounds.state.upp = Inf;

problem.bounds.initialState.low = 10;
problem.bounds.initialState.upp = problem.bounds.initialState.low;

problem.bounds.finalState.low = 1;
problem.bounds.finalState.upp = Inf;

problem.bounds.control.low = -500;
problem.bounds.control.upp = 200;

%% Set initial guess

% problem.guess.time = linspace(0, sDist, gridSize);
% problem.guess.state = interp1(problem.guess.time', [1,40]', problem.guess.time')';
% problem.guess.control = interp1(problem.guess.time', [-100,200]', problem.guess.time')';

problem.guess.time = [0, sDist];
problem.guess.state = [1, 40];
problem.guess.control = [-100,200];  

%% Set solver options and solve LapSim

problem.options.nlpOpt = optimset(...
    'display','iter',...
    'MaxFunEval',1e6,...
    'tolFun',1e-7);
problem.options.nlpOpt.MaxIter = 1e4;

soln = Solver.LTS(problem);

%% Plot solution

Utilities.fnPlotOutput(soln);
