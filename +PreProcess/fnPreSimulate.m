function [problem] = fnPreSimulate(problem)

td = problem.dsSystem.td;
dynFun = problem.func.stateDynamics;

Tupp = problem.bounds.control.upp(1);
Tlow = problem.bounds.control.low(1);
T_guess = zeros(size(td.sLap)) + Tupp;

a_model     = -pi:0.0001:pi;
T_model     = zeros(size(a_model));
Fy_model    = problem.dsSystem.Models.Tyre.Run(0,[T_model;a_model],problem.dsSystem.vd);
Fy_max      = max(Fy_model);

v = sqrt(Fy_max./abs(td.curv.*problem.dsSystem.vd.chassis.m));
v(1) = mean([problem.bounds.initialState.low, problem.bounds.initialState.upp]);

ds = (td.sLap(end) - td.sLap(1)) / (length(td.sLap) - 1);
for i = 1:(length(v)-1)
    if v(i+1) < v(i)
        T_guess(i) = Tlow;
    end
    dv = dynFun(v(i),T_guess(i));
    dv_pre = (v(i+1) - v(i))/ds;
    
    if abs(dv) < abs(dv_pre)
        v(i+1) = dv*ds + v(i);
    else
        dv_loop = zeros(size(td.sLap));
        T_loop  = Tlow:1:Tupp;
        for k = 1:length(T_loop)
            dv_loop(k) = dynFun(v(i),T_loop(k));
        end
        [~,idk] = min(abs(dv_loop - dv_pre));
        T_guess(i) = T_loop(idk);
    end
end
v_guess = v;

% a_guess = zeros(size(td.sLap));
curv_mod = (abs(td.curv/max(abs(td.curv)))).^0.5;
a_guess = a_model(Fy_model == Fy_max).*curv_mod;

problem.guess.state   	= v_guess;
problem.guess.control   = [0.8.*T_guess;
                           a_guess];

end