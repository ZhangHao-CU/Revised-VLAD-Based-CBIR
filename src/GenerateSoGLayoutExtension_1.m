FlickrPath = 'data\Flickr\Flickr_VC';
encoderPath = fullfile(FlickrPath,'encoder_100.mat');
catWordsPath = fullfile(FlickrPath,'encoder_100_catwords.mat');
holidayPath = 'G:\MATLAB\matlab\bin\data\holiday';
holidayImagesPath = 'G:\MATLAB\matlab\bin\data\holiday_images';
vladQueryPath = fullfile(holidayPath,'vlad_layout_query_500_100.mat');
vladTestPath = fullfile(holidayPath, 'vlad_layout_test_991_100.mat');
% Read the descriptors from holiday dataset
% Get the file names
fid = fopen(fullfile(holidayPath,'holidays_query_siftgeo_500.dat'));
holidayQueryFileNames=textscan(fid,'%s','delimiter','\n');
fclose(fid);
holidayQueryFileNames = holidayQueryFileNames{1,1};

fid = fopen(fullfile(holidayPath,'holidays_test_siftgeo_991.dat'));
holidayTestFileNames=textscan(fid,'%s','delimiter','\n');
fclose(fid);
holidayTestFileNames = holidayTestFileNames{1,1};
vlad = cell(1,numel(holidayQueryFileNames));
%get the images' file names
fid = fopen(fullfile(holidayImagesPath,'holidays_query_siftgeo_500.dat'));
holidayQueryImageFileNames=textscan(fid,'%s','delimiter','\n');
fclose(fid);
holidayQueryImageFileNames = holidayQueryImageFileNames{1,1};

fid = fopen(fullfile(holidayImagesPath,'holidays_test_siftgeo_991.dat'));
holidayTestImageFileNames=textscan(fid,'%s','delimiter','\n');
fclose(fid);
holidayTestImageFileNames = holidayTestImageFileNames{1,1};



encoder = struct;
encoder.words = fvecs_read('clust_flickr60_k100.fvecs');
encoder.words = encoder.words';
encoder.kdtree = vl_kdtreebuild(encoder.words, 'numTrees', 2) ;
holidayFileNames = cat(1, holidayQueryFileNames, holidayTestFileNames);
holidayImageFileNames = cat(1, holidayQueryImageFileNames, holidayTestImageFileNames);
descriptor = cell(1,numel(holidayFileNames));
spatial = cell(1,numel(holidayFileNames));
for i = 1: numel(holidayFileNames)
[descrs,layout] = siftgeo_read(fullfile(holidayPath,holidayFileNames{i,1}));
descrs = descrs';
layout = layout';
layout = layout(1:2,:);
%renormalize the size of images
im = imread(fullfile(holidayImagesPath, holidayImageFileNames{i,1}));
[h, w, ~] = size(im);
if h > w
    layout(1, :) = layout(1,:)/768;
    layout(2, :) = layout(2,:)/1024;
else
    layout(1, :) = layout(1,:)/1024;
    layout(2, :) = layout(2,:)/768;    
end
descriptor{1,i} = descrs;
spatial{1,i} = layout;
end
descriptor = cell2mat(descriptor);
spatial = cell2mat(spatial);
[assign,~] = vl_kdtreequery(encoder.kdtree, encoder.words, descriptor, 'MaxComparisons', 15) ;
encoder.catwords = calculateSingleGaussSpatialLayout(spatial, encoder.words, assign);
save(encoderPath, '-struct', 'encoder') ;
save(catWordsPath, '-struct', 'encoder','catwords') ;


