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

% % Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 34);
% 
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
% 
% % Specify column names and types
opts.VariableNames = ["PeakId", "Mass", "Start", "Stop", "RT", "RI", "MDGC", "RT1tr", "RT2tr", "Area", "Height", "Width", "Area_Percent", "SampleFileName", "CompoundName", "Group", "Type", "Formula", "MF", "RMF", "Probability", "MW", "ExactMass", "CASNO", "NISTNO", "ID", "Library", "OtherDBS", "Contributor", "TenLargestPeaks", "Synonyms", "StructureDiagram", "LibraryRI", "SignalToNoiseRatio"];
opts.VariableTypes = ["double", "categorical", "double", "double", "double", "double", "categorical", "double", "double", "double", "double", "double", "double", "categorical", "categorical", "string", "double", "categorical", "double", "double", "double", "double", "double", "datetime", "double", "double", "categorical", "categorical", "categorical", "string", "string", "string", "double", "double"];

% % Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
% 
% % Specify variable properties
opts = setvaropts(opts, ["Group", "TenLargestPeaks", "Synonyms", "StructureDiagram"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Mass", "MDGC", "SampleFileName", "CompoundName", "Group", "Formula", "Library", "OtherDBS", "Contributor", "TenLargestPeaks", "Synonyms", "StructureDiagram"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "CASNO", "InputFormat", "yy-MM-dd");
            
for i1 = 1:fileNum
   
    cd(sourceFolder);
    
    disp(strcat('working on file number --- ', num2str(i1),' -out of ',num2str(fileNum)))

    % Gets the name of the file we are importing now
    fileNames{i1} = fileName(i1,1).name(1:end-4); 

    RawData = readtable(fileNames{i1}, opts);

    %put area and group into same table
    areaAndGroup = [RawData(:,groupCol), RawData(:,areaCol)];
    areaAndGroup.Properties.VariableNames = ["Group", 'Area'];

    if isa(areaAndGroup.Group, 'double') == 1

        areaAndGroup = table({'NoClass'}, [1], 'VariableNames',{'Group' 'Area'}); %#ok

    end

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
    bingroups = table(bingroups);
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

%drop the repetitive things at the beginning (first 50 chars)
fileNames = cellfun(@(fileNames) fileNames(50:end), fileNames, 'un', 0);

fullTable(ismember(fullTable.Group, 'NoClass'), :) = [];

end