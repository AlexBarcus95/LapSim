function [c, ceq] = fnConstraints(~,x,vd,dsSystem)

td = dsSystem.td;

v = x(1,:);
v_p = vd.chassis.m*td.curv.*v.^2;

c = v_p - 100;
ceq = [];

end