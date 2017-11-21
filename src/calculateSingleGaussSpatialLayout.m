function catwords = calculateSingleGaussSpatialLayout(frames, words, assign)

z = frames(1:2,:) ;
catwords = zeros(2,size(words , 2));
for i = 1:size(words , 2)
    c =z(:,assign == i);
    catwords(:,i) = sum(c,2)/size(c,2);
end