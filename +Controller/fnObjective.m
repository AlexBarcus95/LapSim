function f = fnObjective(x)
% 
%  f = f(x,y) = integrand of the objective function
%

v = x(1,:);

% Minimise inverse of velocity
f = 1./v;

end