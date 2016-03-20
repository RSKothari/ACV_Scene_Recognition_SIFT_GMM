%% Name: Rakshit Kothari
% Title: ACV project, Scene Classification
% Method: Scene classification using GMM and fixed SIFT features
% File details: This is the M file for matching SIFT features for each
% category. The output is fed into a neural network, which estimates the scene.
% To re-extract SIFT features,please run the M file named 'Reset_files.m'
%%
clear all
close all
clc
%% Setup for VL feat library
run VLFEATROOT/toolbox/vl_setup
%% Constants
load('Data.mat')

label_names=struct('Names',{'Sky' 'Water' 'Greens' 'Trees' 'Sand/Snow' 'Rocks/Mountains' 'Highway/Roads' 'Bldgs' 'Unclassified'});

num=input('Please enter the image you want to classify');
h=fspecial('gaussian',5,sqrt(2));
trans_size=[64 64];
radius=8;
grid_k=5;
%% Algorithm
current=cd('Images_Training');
direc=dir('*.jpg');
img=double(imread(direc(num).name));
cd(current)

[X Y ~]=size(img);

img_ycbcr=rgb2ycbcr(img);
img_filtered=imfilter(img,h,'same');

img_ycbcr_trans=rgb2ycbcr(img_filtered);
img_ycbcr_trans=imresize(img_ycbcr_trans,trans_size);
a=img_ycbcr_trans(:,:,2); %Cb frame
trans_img(1,:)=a(:);
a=img_ycbcr_trans(:,:,3); %Cr frame
trans_img(2,:)=a(:);

tic
[label,model,~]=vbgm(trans_img,7);
figure(1)
spread(trans_img,label);
toc
r=reshape(label,trans_size);
figure(2)
imshow(r,[])
means=model.m;
reconstructed=zeros(X,Y);

for i=1:X
    for j=1:Y
        temp(1,1)=img_ycbcr(i,j,2);
        temp(2,1)=img_ycbcr(i,j,3);
        temp=repmat(temp,1,length(means));
        temp=abs(means-temp);
        temp=sum(temp,1);
        [~,loc]=min(temp);
        reconstructed(i,j)=loc;
        clear temp
    end
end

figure(3)
subplot(1,2,1)
imshow(reconstructed,[])
subplot(1,2,2)
imshow(uint8(img),[])

%% Extracting SIFT features
[x,y]=form_grid(X,Y,grid_k);
x=x(:)';
y=y(:)';
fc=[x;y;radius*ones(1,length(x));zeros(1,length(x))];
img_sift=single(rgb2gray(uint8(img)));
[f,d]=vl_sift(img_sift,'frames',fc,'orientations');
%% SIFT matching
for i=1:max(label)
    mask=reconstructed==i;
    
    [com]=find_com(mask);
    com_locs(i,:)=com;
    trip=complete_belong(f,mask,0.9,radius);
    g=f(:,trip);
    sift_vector=d(:,trip);
    if ~isempty(g)
        masked_img=img_sift.*mask; 
        figure(5)
        subplot(1,2,1)
        imshow(uint8(img),[])
        subplot(1,2,2)
        imshow(uint8(masked_img),[])
        h11 = vl_plotframe(g);
        h22 = vl_plotframe(g);
        set(h11,'color','k','linewidth',3);
        set(h22,'color','y','linewidth',2);
        drawnow
        count_matches=zeros(1,max(categories));
        for j=1:max(categories)
            database=cell2mat(categories_sift_features(j,1));
            if ~isempty(database)
                [matches,scores]=vl_ubcmatch(sift_vector,database,1.2);
                if ~isempty(matches)
                    matches=remove_repeated(matches);
                end
                count_matches(j)=length(matches)/length(g);
                count_matches_check(i,j)={count_matches(j)};
                count_scores(i,j)={scores};
            end
                
        end
    end
    if ~exist('count_matches','var') || isempty(count_matches)
        count_matches=[zeros(1,8) 1];
    end
    [~,loc]=max(count_matches);
    label_region(i)=loc;
%     pause(8)
end
figure(6)
imshow(uint8(img),[])
for i=1:max(label)
    x=com_locs(i,1);
    y=com_locs(i,2);
    text(x,y,label_names(label_region(i)).Names,'Color',[0 0 0],'EdgeColor',[0 0 0],'BackgroundColor',[1 1 1])
end
clear functions