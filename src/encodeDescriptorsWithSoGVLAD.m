% Load encoder(kdtree, words, and catwords)
FlickrPath = 'data\Flickr\Flickr_VD';
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
hehe = ones(1,100);
hehe = 5*hehe;

for i = 1:numel(holidayQueryFileNames)

[descrs,layout] = siftgeo_read(fullfile(holidayPath,holidayQueryFileNames{i,1}));
descrs = descrs';
layout = layout';
layout = layout(1:2,:);
%renormalize the size of images
im = imread(fullfile(holidayImagesPath, holidayQueryImageFileNames{i,1}));
[h, w] = size(im);
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
 
 %add the info of layout entropy
entropy = ones(2, 5*size(encoder.words,2));
entropy = mat2cell(entropy, [1,1], hehe);
%step 1
for j= 1: numel(words)
    if layout(1,j) < 0.2
        entropy{1, words(j)}(1,1) = entropy{1, words(j)}(1,1)+ 1;
    elseif layout(1,j) < 0.4
        entropy{1, words(j)}(1,2) = entropy{1, words(j)}(1,2)+ 1;
    elseif layout(1,j) < 0.6
        entropy{1, words(j)}(1,3) = entropy{1, words(j)}(1,3)+ 1;
    elseif layout(1,j) < 0.8
        entropy{1, words(j)}(1,4) = entropy{1, words(j)}(1,4)+ 1;
    else 
        entropy{1, words(j)}(1,5) = entropy{1, words(j)}(1,5)+ 1;
    end
    
    % y
    if layout(2,j) < 0.2
        entropy{2, words(j)}(1,1) = entropy{2, words(j)}(1,1)+ 1;
    elseif layout(2,j) < 0.4
        entropy{2, words(j)}(1,2) = entropy{2, words(j)}(1,2)+ 1;
    elseif layout(2,j) < 0.6
        entropy{2, words(j)}(1,3) = entropy{2, words(j)}(1,3)+ 1;
    elseif layout(2,j) < 0.8
        entropy{2, words(j)}(1,4) = entropy{2, words(j)}(1,4)+ 1;
    else 
        entropy{2, words(j)}(1,5) = entropy{2, words(j)}(1,5)+ 1;
    end
end
%step 2
for j= 1: size(encoder.words,2)
    tempsum = sum(entropy{1,j});
    for k= 1: 5
       entropy{1,j}(1,k) =  entropy{1,j}(1,k)/tempsum;
    end
    tempsum = sum(entropy{2,j});
    for k= 1: 5
       entropy{2,j}(1,k) =  entropy{2,j}(1,k)/tempsum;
    end
end
%step 3
layout_entropy = zeros(2, size(encoder.words,2));
for j= 1:size(encoder.words,2)
    for k=1: 5
      layout_entropy(1,j) = layout_entropy(1,j) - entropy{1,j}(1,k)*log(entropy{1,j}(1,k));
      layout_entropy(2,j) = layout_entropy(2,j) - entropy{2,j}(1,k)*log(entropy{2,j}(1,k));
    end
end
%extend with spatial layout
%-------------------------------------------------------------------------------------------    
%descrs = extendDescriptorsWithGeometry('xy', layout, descrs) ;
%-------------------------------------------------------------------------------------------
 z1 = vl_vlad(descrs, ...
                  encoder.words, ...
                  assign) ;%, ...
 %                 'SquareRoot', ...
 %                 'NormalizeComponents'
 %layout = mapminmax(layout(1:2,:)',0,100);
 %layout = layout';
 %encoder.catwords = mapminmax(encoder.catwords',0,100);
 %encoder.catwords = encoder.catwords';
 %z2 = vl_vlad(layout, single(encoder.catwords), assign) ; %, 'SquareRoot', 'NormalizeComponents'  
 z2 = layout_entropy(:);
 z = cat(1,z1,z2);%;
  

 vlad{i} = z;%/ max(sqrt(sum(z1.^2)), 1e-12) ;

 

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
[h, w] = size(im);
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
  %add the info of layout entropy
entropy = ones(2, 5*size(encoder.words,2));
entropy = mat2cell(entropy, [1,1], hehe);
%step 1
for j= 1: numel(words)
    if layout(1,j) < 0.2
        entropy{1, words(j)}(1,1) = entropy{1, words(j)}(1,1)+ 1;
    elseif layout(1,j) < 0.4
        entropy{1, words(j)}(1,2) = entropy{1, words(j)}(1,2)+ 1;
    elseif layout(1,j) < 0.6
        entropy{1, words(j)}(1,3) = entropy{1, words(j)}(1,3)+ 1;
    elseif layout(1,j) < 0.8
        entropy{1, words(j)}(1,4) = entropy{1, words(j)}(1,4)+ 1;
    else 
        entropy{1, words(j)}(1,5) = entropy{1, words(j)}(1,5)+ 1;
    end
    
    % y
    if layout(2,j) < 0.2
        entropy{2, words(j)}(1,1) = entropy{2, words(j)}(1,1)+ 1;
    elseif layout(2,j) < 0.4
        entropy{2, words(j)}(1,2) = entropy{2, words(j)}(1,2)+ 1;
    elseif layout(2,j) < 0.6
        entropy{2, words(j)}(1,3) = entropy{2, words(j)}(1,3)+ 1;
    elseif layout(2,j) < 0.8
        entropy{2, words(j)}(1,4) = entropy{2, words(j)}(1,4)+ 1;
    else 
        entropy{2, words(j)}(1,5) = entropy{2, words(j)}(1,5)+ 1;
    end
end
%step 2
for j= 1: size(encoder.words,2)
    tempsum = sum(entropy{1,j});
    for k= 1: 5
       entropy{1,j}(1,k) =  entropy{1,j}(1,k)/tempsum;
    end
    tempsum = sum(entropy{2,j});
    for k= 1: 5
       entropy{2,j}(1,k) =  entropy{2,j}(1,k)/tempsum;
    end
end
%step 3
layout_entropy = zeros(2, size(encoder.words,2));
for j= 1:size(encoder.words,2)
    for k=1: 5
      layout_entropy(1,j) = layout_entropy(1,j) - entropy{1,j}(1,k)*log(entropy{1,j}(1,k));
      layout_entropy(2,j) = layout_entropy(2,j) - entropy{2,j}(1,k)*log(entropy{2,j}(1,k));
    end
end
%extend with spatial layout
%-------------------------------------------------------------------------------------------    
%descrs = extendDescriptorsWithGeometry('xy', layout, descrs) ;
%-------------------------------------------------------------------------------------------
 z1 = vl_vlad(descrs, ...
                  encoder.words, ...
                  assign) ;%, ...
 %                 'SquareRoot', ...
 %                 'NormalizeComponents'
 %layout = mapminmax(layout(1:2,:)',0,100);
 %layout = layout';
 %encoder.catwords = mapminmax(encoder.catwords',0,100);
 %encoder.catwords = encoder.catwords';
 %layout = layout/100;
 %z2 = vl_vlad(layout, single(encoder.catwords), assign) ; %, 'SquareRoot', 'NormalizeComponents'    
 z2 = layout_entropy(:);
 z = cat(1,z1,z2);%;
 vlad{i} = z;%/ max(sqrt(sum(z1.^2)), 1e-12) ;
           

end
save(vladTestPath, 'vlad') ;