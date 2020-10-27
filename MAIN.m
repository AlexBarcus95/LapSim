%% MAIN.m  --  LapSim

clear;
clc;

%% Set Collocation Parameters

sDist = 300;
problem.options.method = 'trapezoid';
% problem.options.method = 'hermiteSimpson';

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

%% Initialise Track Definition

td.sLap = linspace(0,sDist,gridSize);

curv = zeros(1,gridSize);
curv(ceil(length(curv)*0.3)) = 0.02;
curv(ceil(length(curv)*0.8)) = 0.1;

td.curv = curv;

%% Initialise Car Parameters

vd.aero.density = 1.3;
vd.aero.A = 1.5;
vd.aero.Cd = 1;
vd.tyres.Rl = 0.5;
vd.chassis.m = 100;

%% Set up function handles for the dynamics, objective, and constraints

problem.func.stateDynamics = @(s,x,u)( Controller.fnDynamics(x,u,vd) );
problem.func.objective = @(s,x,u)( Controller.fnObjective(x) );
problem.func.constraints = @(s,x,u)( Controller.fnConstraints(s,x,vd,td) );

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

f = figure(1); clf;

s = soln.grid.time;
z = soln.grid.state;
v = z(1,:);
u = soln.grid.control;
T = u(1,:);

f.Name = num2str(soln.info.objVal);
subplot(2,1,1);
plot(s,v,'LineWidth',3);
hold on
plot(s,v,'ob');
% plot(s,zeros(1,length(s)) + mean(v), 'or')
xlabel('distance (m)');
ylabel('velocity (m/s)');
xlim([s(1), s(end)]);
ylim([0, 100*round(max(v)/100,1)]);
title(['Velocity profile || ', num2str(soln.info.objVal), 's']);

subplot(2,1,2);
plot(s,T,'LineWidth',2);
hold on
plot(s,T,'ob');
plot(s,zeros(1,length(s)), '--b')
xlabel('distance (m)');
ylabel('torque (Nm)');
xlim([s(1), s(end)]);
ylim([problem.bounds.control.low, problem.bounds.control.upp]);
title(['Torque profile || ', num2str(soln.info.nlpTime), 's']);
