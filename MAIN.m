%% MAIN.m  --  LapSim

clear;
clc;

%% Initialise the problem data structure

problem = Initialise.fnInitMethod('trapezoid');
problem = Initialise.fnInitSystem(problem);
problem = Initialise.fnInitTrack(problem);
problem = Initialise.fnInitVd(problem);
problem = Initialise.fnInitFunctionHandles(problem);
problem = Initialise.fnInitBounds(problem);

%% Set initial guess

customGuess = load([cd, '/customGuess.mat']);

sLap_old = customGuess.soln.grid.sLap;
v_old = customGuess.soln.grid.state(1,:);
T_old = customGuess.soln.grid.control(1,:);
a_old = customGuess.soln.grid.control(2,:);

v_guess = interp1(sLap_old, v_old, problem.dsSystem.td.sLap);
T_guess = interp1(sLap_old, T_old, problem.dsSystem.td.sLap);
a_guess = interp1(sLap_old, a_old, problem.dsSystem.td.sLap);

problem.guess.state     = v_guess;
problem.guess.control   = [T_guess;
                           a_guess];

%% Set solver options and solve LapSim

problem.options.nlpOpt = optimset();
problem.options.nlpOpt.Display = 'iter';
problem.options.nlpOpt.MaxFunEvals = 1e6;
problem.options.nlpOpt.MaxIter = 3e3;
problem.options.nlpOpt.TolFun = 1e-7;
problem.options.nlpOpt.Algorithm = 'sqp';

soln = Solver.LTS(problem);

%% Plot solution

bOverlayGuess = true;
Utilities.fnPlotOutput(soln, bOverlayGuess);
