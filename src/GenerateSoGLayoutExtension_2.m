%generate the catwords of Paris6K_16/64/256
FlickrPath = 'data\Flickr\Flickr_VD';
encoderPath = fullfile(FlickrPath,'encoder_200.mat');
catWordsPath = fullfile(FlickrPath,'encoder_200_catwords.mat');
encoder = struct;
encoder.words = load Paris6K_16 ;
%encoder.words = encoder.words';
encoder.kdtree = vl_kdtreebuild(encoder.words, 'numTrees', 2) ;
[descrs,layout] = siftgeo_read('flickr60K.siftgeo',10);
descrs = descrs';
layout = layout';
[assign,~] = vl_kdtreequery(encoder.kdtree, encoder.words, ...
                                         descrs, ...
                                         'MaxComparisons', 15) ;
encoder.catwords = calculateSingleGaussSpatialLayout(layout, encoder.words, assign);
%save(encoderPath, '-struct', 'encoder') ;
%save(catWordsPath, '-struct', 'encoder','catwords') ;


