%z-score, L2 norm and max-min
holidayPath = 'G:\MATLAB\matlab\bin\data\holiday';
vladQueryPath = fullfile(holidayPath,'vlad_layout_query_500_100.mat');
vladTestPath = fullfile(holidayPath, 'vlad_layout_test_991_100.mat');
vladQuery = load(vladQueryPath);
vladQuery = vladQuery.vlad;
vladTest = load(vladTestPath);
vladTest = vladTest.vlad;
vlad = cat(2,vladQuery,vladTest);
PCADi = 1024;

vlad_before_p = cell2mat(vlad)';

%z-score
vlad_before_p = zscore(vlad_before_p);

%max-min
%for i=1:size(vlad_before_p,2)
%    vector = vlad_before_p(:,i);
%    vector = vector';
%    max_v = max(vector);
%    min_v = min(vector);
%    range = max_v-min_v;
%    vector = (vector-min_v)/range;
%    vlad_before_p(:,i) = vector';
%end

%L2 norm
for i=1:size(vlad_before_p,1)
		vector = vlad_before_p(i,:);
		vector = vector/norm(vector);
        vlad_before_p(i,:) = vector;
end
[~,vlad_after_p,hh] = pca(vlad_before_p);
%cumsum(hh)./sum(hh);
vlad_after_p = vlad_after_p';
vlad = mat2cell(vlad_after_p(1:PCADi,:), PCADi, [numel(vladQuery) numel(vladTest)]);
m = ones(numel(vladQuery), 1);
vladQuery = mat2cell(vlad{1}, PCADi, m);
m = ones(numel(vladTest), 1);
vladTest = mat2cell(vlad{2}, PCADi, m);
save(vladQueryPath, 'vladQuery') ;
save(vladTestPath, 'vladTest') ;