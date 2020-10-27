function [c, ceq] = fnConstraints(~,z,vd,dsSystem)

td = dsSystem.td;

v = z(1,:);
v_p = vd.chassis.m*td.curv.*v.^2;

c = v_p - 100;
ceq = [];

end