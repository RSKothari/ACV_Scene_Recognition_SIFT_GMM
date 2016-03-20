clear all
close all
clc

load('Training_data.mat');
load('Testing.mat');

for i=1:length(training_op)
    scene=zeros(8,1);
%     mat=dec2binvec(training_op(i),3);
%     mat=fliplr(mat);
    loc=training_op(i);
    scene(loc,1)=1;
    op(:,i)=scene;
end
for i=1:length(testing_op)
    scene=zeros(8,1);
    loc=testing_op(i);
%     mat=dec2binvec(testing_op(i),3);
%     mat=fliplr(mat);
    scene(loc,1)=1;
    test(:,i)=scene;
end
testing_ip=testing_ip./repmat((sum(testing_ip)),9,1);
training_ip=training_ip./repmat((sum(training_ip)),9,1);
nnstart