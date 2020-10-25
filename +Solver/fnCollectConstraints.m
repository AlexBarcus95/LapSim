function [c, ceq] = fnCollectConstraints(t,x,u,defects, pathCst)
% [c, ceq] = fnCollectConstraints(t,x,u,defects, pathCst)

ceq_dyn = reshape(defects,numel(defects),1);

%%%% Compute the user-defined constraints:
if isempty(pathCst)
    c_path = [];
    ceq_path = [];
else
    [c_pathRaw, ceq_pathRaw] = pathCst(t,x,u);
    c_path = reshape(c_pathRaw,numel(c_pathRaw),1);
    ceq_path = reshape(ceq_pathRaw,numel(ceq_pathRaw),1);
end

%%%% Pack everything up:
c = c_path;
ceq = [ceq_dyn; ceq_path];

end