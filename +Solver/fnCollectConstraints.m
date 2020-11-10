function [c, ceq] = fnCollectConstraints(x,u,defects,constraints)

ceq_dyn = reshape(defects,numel(defects),1);

%% Compute the constraints defined by the constraint function
if isempty(constraints)
    c_path = [];
    ceq_path = [];
else
    [c_pathRaw, ceq_pathRaw] = constraints(x,u);
    c_path = reshape(c_pathRaw,numel(c_pathRaw),1);
    ceq_path = reshape(ceq_pathRaw,numel(ceq_pathRaw),1);
end

%% Combine the constraints and defects
c = c_path;
ceq = [ceq_dyn; ceq_path];

end