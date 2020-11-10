function [c, ceq] = fnConstraints(x,u,vd,dsSystem)

td = dsSystem.td;

v = x(1,:);
F_r = vd.chassis.m*td.curv.*v.^2;
Fy = dsSystem.Models.Tyre.Run(x,u,vd);

c = [];
ceq = F_r - Fy;

end