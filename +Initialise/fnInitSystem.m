function [problem] = fnInitSystem(problem)

dsSystem = struct;
% Set up the vehicle models
dsSystem.csModels 	= {'Aero';'Chassis';'Tyre'};
for i = 1:length(dsSystem.csModels)
    sModel = dsSystem.csModels{i};
    dsSystem.Models.(sModel) = Model.(sModel).(['Model_', sModel]);
end

problem.dsSystem = dsSystem;

end