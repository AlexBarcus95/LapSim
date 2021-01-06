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
v_pre = v;

ds = (td.sLap(end) - td.sLap(1)) / (length(td.sLap) - 1);
idxForceBrake = NaN;
i = 1;
while i < length(v_pre)
    if v_pre(i+1) < v(i) || ~isnan(idxForceBrake)
        T_guess(i) = Tlow;
    end
    dv = dynFun(v(i),T_guess(i));
    dv_pre = (v_pre(i+1) - v(i))/ds;
    
    if abs(dv) < abs(dv_pre) || ~isnan(idxForceBrake)
        v(i+1) = dv*ds + v(i);
        idxForceBrake = NaN;
    else
        dv_loop = zeros(size(td.sLap));
        T_loop  = Tlow:1:Tupp;
        for k = 1:length(T_loop)
            dv_loop(k) = dynFun(v(i),T_loop(k));
        end
        [~,idk] = min(abs(dv_loop - dv_pre));
        T_guess(i) = T_loop(idk);
        v(i+1) = v_pre(i+1);
    end
    
    if v(i+1) > v_pre(i+1)
        idxForceBrake = i - 1;
        i = idxForceBrake - 1;
    end
    i = i + 1;
end

v_guess = v;
a_guess = a_model(Fy_model == Fy_max).*(abs(td.curv/max(abs(td.curv))));

problem.guess.state   	= problem.dsSystem.PreSim.scale.*v_guess;
problem.guess.control   = [problem.dsSystem.PreSim.scale.*T_guess;
                           problem.dsSystem.PreSim.scale.*a_guess];

end