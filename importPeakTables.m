function [fileNames, areaAndGroup, fullTable]= importPeakTables(sourceFolder)

%add directory and the string
dbstop if error
fileName = dir(fullfile(sourceFolder,'*.csv'));  % Get the names of csv file in the source folder
fileNum = numel(fileName); %Gets the total number of files to be imported
fileNames = cell(fileNum,1);
            
for i1 = 1:fileNum
   
    cd(sourceFolder);
    
    disp(strcat('working on file number - -- ', num2str(i1),'-out of ',num2str(fileNum)))

    % Gets the name of the file we are importing now
    fileNames{i1} = fileName(i1,1).name(1:end-4); 

    RawData = readtable(fileNames{i1});

    %put area and group into same table
    areaAndGroup = [RawData(:,15), RawData(:,9)];

    %drop the rows without classes
    areaAndGroup(ismember(areaAndGroup.Group, ''), :) = [];

    %dropping duplicate rows
    [~, indx] = unique(areaAndGroup, 'rows');
    areaAndGroup = areaAndGroup(indx,:);

    %summing same groups
    binvalues = [];
    bingroups = [];
    [binvalues, bingroups] = groupsummary(areaAndGroup.Area, areaAndGroup.Group, @sum);
    binvalues = array2table(binvalues);
    areaAndGroup = [bingroups, binvalues];
    areaNumber = sprintf("area%d", i1);
    areaAndGroup.Properties.VariableNames = ["Group", areaNumber];

    if i1 == 1

        fullTable = areaAndGroup;

    else

        fullTable = outerjoin(fullTable, areaAndGroup, 'MergeKeys', true);

    end

    fullTable = fullTable;

end       



end