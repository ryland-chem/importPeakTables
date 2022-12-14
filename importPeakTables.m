% Ryland T. Giebelhaus (2022).
% www.ryland-giebelhaus.com

% this function is made to read in peak tables, select the class and
% integration and spit them out into a table so they can be explored further
% with chemometrics.

%INPUTS
    %sourceFolder: The folder containing all .csv files. Best if this is
        %given as the whole path from ':C\'
    %groupCol: column number containing the group or class
    %areaCol: column containing the area
%OUTPUTS
    %fileNames: Names of files and in order which they were digested
    %fullTable: The reconstructed peak table.

function [fileNames, fullTable]= importPeakTables(sourceFolder, groupCol, areaCol)

%add directory and the string
dbstop if error
fileName = dir(fullfile(sourceFolder,'*.csv'));  % Get the names of csv file in the source folder
fileNum = numel(fileName); %Gets the total number of files to be imported
fileNames = cell(fileNum,1);
            
for i1 = 1:fileNum
   
    cd(sourceFolder);
    
    disp(strcat('working on file number --- ', num2str(i1),' -out of ',num2str(fileNum)))

    % Gets the name of the file we are importing now
    fileNames{i1} = fileName(i1,1).name(1:end-4); 

    RawData = readtable(fileNames{i1});

    %put area and group into same table
    areaAndGroup = [RawData(:,groupCol), RawData(:,areaCol)];

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