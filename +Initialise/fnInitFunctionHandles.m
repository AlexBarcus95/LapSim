function [problem] = fnInitFunctionHandles(problem)

problem.func.stateDynamics = @(x,u)( Controller.fnDynamics(x,u,problem.dsSystem.vd) );
problem.func.objective = @(x,u)( Controller.fnObjective(x) );
problem.func.constraints = @(x,u)( Controller.fnConstraints(x,u,problem.dsSystem.vd,problem.dsSystem) );

end