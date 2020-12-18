%% MAIN.m  --  LapSim

clear;
clc;

%% Initialise the problem data structure

problem = Initialise.fnInitMethod('trapezoid');
problem = Initialise.fnInitSystem(problem);
problem = Initialise.fnInitTrack(problem, false);
problem = Initialise.fnInitVd(problem);
problem = Initialise.fnInitFunctionHandles(problem);
problem = Initialise.fnInitBounds(problem);

%% Get initial estimate

problem = PreProcess.fnGetInitialEstimate(problem, 'PreSim');

%% Set solver options and solve LapSim

problem.options.nlpOpt = optimset();
problem.options.nlpOpt.Display = 'iter';
problem.options.nlpOpt.MaxFunEvals = 1e6;
problem.options.nlpOpt.MaxIter = 3e3;
problem.options.nlpOpt.TolFun = 1e-7;
problem.options.nlpOpt.Algorithm = 'sqp';

soln = Solver.LTS(problem);

%% Plot solution

PostProcess.fnPlotOutput(soln, true);
PostProcess.fnPlotOutputSingle(soln);
