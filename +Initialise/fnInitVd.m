function [problem] = fnInitVd(problem)

vd = struct();
for i = 1:length(problem.dsSystem.csModels)
    sModel = problem.dsSystem.csModels{i};
    vd = problem.dsSystem.Models.(sModel).Initialise(vd, problem.dsSystem);
end

problem.dsSystem.vd = vd;

end