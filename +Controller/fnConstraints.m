function [c, ceq] = fnConstraints(~,z,vd,td)

v = z(1,:);
v_p = vd.chassis.m*td.curv.*v.^2;

c = v_p - 100;
ceq = [];

end