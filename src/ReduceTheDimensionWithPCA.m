holidayPath = 'G:\MATLAB\matlab\bin\data\holiday';
vladQueryPath = fullfile(holidayPath,'vlad_layout_query_500_100.mat');
vladTestPath = fullfile(holidayPath, 'vlad_layout_test_991_100.mat');
vladQuery = load(vladQueryPath);
vladQuery = vladQuery.vlad;
vladTest = load(vladTestPath);
vladTest = vladTest.vlad;
vlad = cat(2,vladQuery,vladTest);
PCADi = 32;


vlad_before_p = cell2mat(vlad)';

%z-score
%vlad_before_p = zscore(vlad_before_p);

%L2 norm
%for i=1:size(vlad_before_p,1)
%		vector = vlad_before_p(i,:);
%		vector = vector/norm(vector);
%        vlad_before_p(i,:) = vector;
%end

[~,vlad_after_p,hh] = pca(vlad_before_p);
%cumsum(hh)./sum(hh);
vlad_after_p = vlad_after_p';4
vlad = mat2cell(vlad_after_p(1:PCADi,:), PCADi, [numel(vladQuery) numel(vladTest)]);
m = ones(numel(vladQuery), 1);
vladQuery = mat2cell(vlad{1}, PCADi, m);
m = ones(numel(vladTest), 1);
vladTest = mat2cell(vlad{2}, PCADi, m);
save(vladQueryPath, 'vladQuery') ;
save(vladTestPath, 'vladTest') ;