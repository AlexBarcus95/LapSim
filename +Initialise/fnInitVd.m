function [vd] = fnInitVd(dsSystem)

vd = struct();
for i = 1:length(dsSystem.csModels)
    sModel = dsSystem.csModels{i};
    vd = dsSystem.Models.(sModel).Initialise(vd, dsSystem);
end

end