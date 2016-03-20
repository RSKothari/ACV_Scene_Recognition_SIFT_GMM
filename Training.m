%% Name: Rakshit Kothari
% Title: ACV project, Scene Classification
% Method: Scene classification using GMM and fixed SIFT features
% File details: This is the M file for extracting SIFT features for each
% category. The output is stored in a file named Data.mat. Extraction can
% be resumed by directly running this file. To re-extract SIFT features,
% please run the M file named 'Reset_files.m'
%% Clearing MATlab state
clear all
close all
clc

%% Setup for VL feat library
rootDir = 'C:\Users\Rakshit\Documents\MATLAB\';
run([ rootDir 'VLFEATROOT\toolbox\vl_setup']);

%% Constants
load('Data.mat')
load('Training_data.mat')

choice=1;
trans_size=[64 64];
radius=8;
grid_k=5;
display(['Previous training was stopped at image no: ' num2str(n_trained)])
num=input('Please enter the image you want to start training from: ');
h=fspecial('gaussian',5,sqrt(2));

%% Algorithm
while choice~=0
    categories_counter=zeros(1,9);
    no_of_sift=zeros(1,9);
    current=cd('Images_Training');
    direc=dir('*.jpg');
    scene_name=direc(num).name;
    scene_name=scene_name(1:(find(scene_name=='_')-1));
    img=double(imread(direc(num).name));
    cd(current)

    [X, Y, ~]=size(img);

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

    reconstructed=zeros(X,Y);
    
    %Fetching mean values from each guassian from the model
    means=model.m;
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
    
    [x,y]=form_grid(X,Y,grid_k);
    x=x(:)';
    y=y(:)';
    fc=[x;y;radius*ones(1,length(x));zeros(1,length(x))];
    img_sift=single(rgb2gray(uint8(img)));
    [f,d]=vl_sift(img_sift,'frames',fc,'orientations');
    
    figure(4)
    imshow(uint8(img),[])
    h1 = vl_plotframe(f);
    h2 = vl_plotframe(f);
    set(h1,'color','k','linewidth',3);
    set(h2,'color','y','linewidth',2);
    
    for i=1:max(label)
        mask=reconstructed==i;
        trip=complete_belong(f,mask,0.9,radius);
        g=f(:,trip);
        sift_features=d(:,trip);
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
        
            ip=input('Please Enter the number for this label');
            categories_counter(ip)=categories_counter(ip)+1;
            no_of_sift(ip)=no_of_sift(ip)+length(g);
            if ismember(ip,categories)
                categories_sift_features(ip,1)={[cell2mat(categories_sift_features(ip,end)) sift_features]};
            else
                categories(end+1)=ip;
                categories_sift_features(ip,1)={sift_features};
            end
            clear g   
            clear sift_features
        end
    end
    choice=input('Do you wish to enter another image number?');
    if choice~=0
        choice=1;
        num=input('Please enter the image number');
        n_trained=n_trained+1;
        training_ip(:,n_trained)=categories_counter';
        training_op(1,n_trained)=get_category(scene_name);
        training_ip1(:,n_trained)=no_of_sift';
        save('Data.mat','categories','categories_sift_features','n_trained')
        save('Training_data.mat','training_ip','training_op','training_ip1')
    end
end

save('Data.mat','categories','categories_sift_features','n_trained')
save('Training_data.mat','training_ip','training_op','training_ip1')