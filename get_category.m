function [ loc ] = get_category( name )
scene_name={'coast' 'forest' 'highway' 'mountain' 'tallbuilding'};
loc=1;
while ~strcmp(name,cell2mat(scene_name(loc)))
    loc=loc+1;
end