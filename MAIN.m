%% MAIN.m  --  LapSim

clear;
clc;

%% Set Collocation Parameters

sDist = 300;
problem.options.method = 'trapezoid';
% problem.options.method = 'hermiteSimpson';

switch problem.options.method
    case 'trapezoid'
        nPoints = 100; % TEMP
        problem.options.trapezoid.nGrid = nPoints;
        nGrid = nPoints;
    case 'hermiteSimpson'
        nPoints = 50; % TEMP
        problem.options.hermiteSimpson.nSegment = nPoints;
        nGrid = 2*nPoints + 1;
    otherwise
        error('Invalid method.');
end

%% Initialise Track, System and Car Parameters

td          = Initialise.fnInitTrack(sDist,nGrid);
dsSystem    = Initialise.fnInitSystem(td);
vd          = Initialise.fnInitVd(dsSystem);

problem.dsSystem    = dsSystem;
problem.dsSystem.vd = vd;

%% Set up function handles for the dynamics, objective, and constraints

problem.func.stateDynamics = @(x,u)( Controller.fnDynamics(x,u,vd) );
problem.func.objective = @(x,u)( Controller.fnObjective(x) );
problem.func.constraints = @(x,u)( Controller.fnConstraints(x,u,vd,dsSystem) );

%% Set up the bounds of the states and controls

problem.bounds.state.low = 0;
problem.bounds.state.upp = Inf;

problem.bounds.initialState.low = 20;
problem.bounds.initialState.upp = problem.bounds.initialState.low;

problem.bounds.finalState.low = 1;
problem.bounds.finalState.upp = Inf;

problem.bounds.control.low = [-500; -pi];
problem.bounds.control.upp = [200; pi];

%% Set initial guess

customGuess = load([cd, '/customGuess.mat']);

sLap_old = customGuess.soln.grid.sLap;
v_old = customGuess.soln.grid.state(1,:);
T_old = customGuess.soln.grid.control(1,:);
a_old = customGuess.soln.grid.control(2,:);

v_guess = interp1(sLap_old, v_old, problem.dsSystem.td.sLap).*0.95;
T_guess = interp1(sLap_old, T_old, problem.dsSystem.td.sLap);
a_guess = interp1(sLap_old, a_old, problem.dsSystem.td.sLap).*0.8;

problem.guess.state     = v_guess;
problem.guess.control   = [T_guess;
                           a_guess];

%% Set solver options and solve LapSim

problem.options.nlpOpt = optimset();
problem.options.nlpOpt.Display = 'iter';
problem.options.nlpOpt.MaxFunEvals = 1e6;
problem.options.nlpOpt.MaxIter = 2e3;
problem.options.nlpOpt.TolFun = 1e-7;

soln = Solver.LTS(problem);

%% Plot solution

bOverlayGuess = true;
Utilities.fnPlotOutput(soln, bOverlayGuess);
