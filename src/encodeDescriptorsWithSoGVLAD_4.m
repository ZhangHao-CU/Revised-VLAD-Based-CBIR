% Load encoder(kdtree, words, and catwords)
FlickrPath = 'data\Flickr\Flickr_VC';
holidayPath = 'G:\MATLAB\matlab\bin\data\holiday';
holidayImagesPath = 'G:\MATLAB\matlab\bin\data\holiday_images';
encoderPath = fullfile(FlickrPath,'encoder_100.mat');
vladQueryPath = fullfile(holidayPath,'vlad_layout_query_500_100.mat');
vladTestPath = fullfile(holidayPath, 'vlad_layout_test_991_100.mat');
encoder = load(encoderPath) ;
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
%extend with spatial layout
%-------------------------------------------------------------------------------------------    
%encoder.words = extendDescriptorsWithGeometry('xy', encoder.catwords, encoder.words) ;
%-------------------------------------------------------------------------------------------
encoder.catwords(encoder.catwords > 0) = 0.5;
%encoder.words = cat(1, encoder.words,encoder.catwords);
for i = 1:numel(holidayQueryFileNames)

[descrs,layout] = siftgeo_read(fullfile(holidayPath,holidayQueryFileNames{i,1}));
descrs = descrs';
layout = layout';
layout = layout(1:2,:);
%renormalize the size of images
im = imread(fullfile(holidayImagesPath, holidayQueryImageFileNames{i,1}));
[h, w, ~] = size(im);
if h > w
    layout(1, :) = layout(1,:)/768;
    layout(2, :) = layout(2,:)/1024;
else
    layout(1, :) = layout(1,:)/1024;
    layout(2, :) = layout(2,:)/768;    
end

[words,distances] = vl_kdtreequery(encoder.kdtree, encoder.words, ...%encoder.words(1:end-2,:)
                                         descrs, ...
                                         'MaxComparisons', 15) ;
 assign = zeros(size(encoder.words,2), numel(words), 'single') ;
 assign(sub2ind(size(assign), double(words), 1:numel(words))) = 1 ;

%extend with spatial layout
%-------------------------------------------------------------------------------------------    
%descrs = extendDescriptorsWithGeometry('xy', layout, descrs) ;
%-------------------------------------------------------------------------------------------
 z1 = vl_vlad(cat(1,descrs,layout), cat(1,encoder.words,encoder.catwords), assign, 'SquareRoot', 'NormalizeComponents');%, ...
 %                 'SquareRoot', ...
 %                 'NormalizeComponents'
 %layout = mapminmax(layout(1:2,:)',0,100);
 %layout = layout';
 %encoder.catwords = mapminmax(encoder.catwords',0,100);
 %encoder.catwords = encoder.catwords';
 %z2 = vl_vlad(layout, single(encoder.catwords), assign); %, 'SquareRoot', 'NormalizeComponents'  
 %z1 = reshape(z1,128,100);
 %z2 = reshape(z2,2,100);
 %z = cat(1,z1,z2);
  

 vlad{i} = z1(:);%/ max(sqrt(sum(z1.^2)), 1e-12) ;

 

end  
save(vladQueryPath, 'vlad') ;
vlad = cell(1,numel(holidayTestFileNames));
for i = 1:numel(holidayTestFileNames)

[descrs,layout] = siftgeo_read(fullfile(holidayPath,holidayTestFileNames{i,1}));
descrs = descrs';
layout = layout';
layout = layout(1:2,:);
%renormalize the size of images
im = imread(fullfile(holidayImagesPath, holidayTestImageFileNames{i,1}));
[h, w, ~] = size(im);
if h > w
    layout(1, :) = layout(1,:)/768;
    layout(2, :) = layout(2,:)/1024;
else
    layout(1, :) = layout(1,:)/1024;
    layout(2, :) = layout(2,:)/768;    
end

[words,distances] = vl_kdtreequery(encoder.kdtree, encoder.words, ...%encoder.words(1:end-2,:)
                                         descrs, ...
                                         'MaxComparisons', 15) ;
 assign = zeros(size(encoder.words,2), numel(words), 'single') ;
 assign(sub2ind(size(assign), double(words), 1:numel(words))) = 1 ;

%extend with spatial layout
%-------------------------------------------------------------------------------------------    
%descrs = extendDescriptorsWithGeometry('xy', layout, descrs) ;
%-------------------------------------------------------------------------------------------
 z1 = vl_vlad(cat(1,descrs,layout), cat(1,encoder.words,encoder.catwords), assign, 'SquareRoot', 'NormalizeComponents');%, ...
 %                 'SquareRoot', ...
 %                 'NormalizeComponents'
 %layout = mapminmax(layout(1:2,:)',0,100);
 %layout = layout';
 %encoder.catwords = mapminmax(encoder.catwords',0,100);
 %encoder.catwords = encoder.catwords';
 %z2 = vl_vlad(layout, single(encoder.catwords), assign); %, 'SquareRoot', 'NormalizeComponents'  
 %z1 = reshape(z1,128,100);
 %z2 = reshape(z2,2,100);
 %z = cat(1,z1,z2);
  

 vlad{i} = z1(:);%/ max(sqrt(sum(z1.^2)), 1e-12) ;
           

end
save(vladTestPath, 'vlad') ;