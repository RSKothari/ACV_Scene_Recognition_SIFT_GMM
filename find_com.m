function [ com ] = find_com( mask )
mask=bwareaopen(mask,0);
stats=regionprops(mask,'Centroid','Area');
for i=1:length(stats)
    area_reg(i)=stats(i).Area;
end
[~,loc]=max(area_reg);
com=stats(loc).Centroid;
end

