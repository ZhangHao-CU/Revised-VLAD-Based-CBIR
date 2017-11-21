% Load the query and test images
holidayPath = 'G:\MATLAB\matlab\bin\data\holiday';
fid = fopen(fullfile(holidayPath,'holidays_query_siftgeo_500.dat'));
holidayQueryFileNames=textscan(fid,'%s','delimiter','\n');
fclose(fid);
holidayQueryFileNames = holidayQueryFileNames{1,1};

fid = fopen(fullfile(holidayPath,'holidays_test_siftgeo_991.dat'));
holidayTestFileNames=textscan(fid,'%s','delimiter','\n');
fclose(fid);
holidayTestFileNames = holidayTestFileNames{1,1};

vladQueryPath = fullfile(holidayPath,'vlad_layout_query_500_100.mat');
vladTestPath = fullfile(holidayPath, 'vlad_layout_test_991_100.mat');
vladQuery = load(vladQueryPath);
vladQuery = vladQuery.vladQuery;
vladTest = load(vladTestPath);
vladTest = vladTest.vladTest;
%--------------------------------------------------------------------------
results = zeros(1,numel(holidayTestFileNames));
%sortIndex = zeros(numel(holidayTestFileNames),1,'uint32');
fid = fopen(fullfile(holidayPath,'vlad_layout_results_500_100.dat'),'w');
for i = 1:numel(holidayQueryFileNames)
    resultLine = [holidayQueryFileNames{i,1},' 0 ',holidayQueryFileNames{i,1}];
    for j = 1:numel(holidayTestFileNames)
        results(1,j) = norm(vladQuery{1,i}-vladTest{1,j});
    end
    [~,sortIndex] = sortrows(results');
    topIndex = sortIndex(1:9,:);
    for j = 1:numel(topIndex)
        resultLine = [resultLine, ' ', num2str(j), ' ', holidayTestFileNames{topIndex(j,1),1}];
    end
    %check if 
    groundTruth = find(strncmpi(holidayTestFileNames, holidayQueryFileNames{i,1}(1:4), 4));
    for j = 1:numel(groundTruth)
        [rank,~] = find(sortIndex == groundTruth(j,1));
        if rank > 9
            resultLine = [resultLine, ' ', num2str(rank), ' ', holidayTestFileNames{groundTruth(j,1),1}];
        end
    end
    
    
    fwrite(fid, resultLine,'char');
    fprintf(fid,'\n');
end
fclose(fid);