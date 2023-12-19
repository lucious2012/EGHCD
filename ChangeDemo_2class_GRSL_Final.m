clc,clear
close all

[imagename1 imagepath1]=uigetfile('Datasets\*.jpg;*.bmp;*.png;*.tif;*.tiff;*.pgm;*.gif;*.mat','Please choose the first input image');

location1 = [imagepath1,imagename1];
load(location1)

[no_lines, no_rows, no_bands] = size(T1);
img1=T1;
img2=T2;
GroundT=matricetotwo(GT);

ffimg1=abs(img1-img2);
fimg1=Normalization(double(ffimg1));
fimg2=GF(fimg1,10,0.05);%GF
fimg=fimg2;
fimg=kpca(fimg,1000,3, 'Gaussian',1);
fimg = ToVector(fimg);
fimg = fimg';
fimg=double(fimg);
OA=[];AA=[];Kappa=[];CA=[];
load Farmland10
for i=1:10
indexes=XX(:,i);
train_SL = GroundT(:,indexes);%2*80
train_samples = fimg(:,train_SL(1,:))';%80*20
train_labels= train_SL(2,:)';%80*1
test_SL = GroundT;%2*10249
test_SL(:,indexes) = [];%2*10169
test_samples = fimg(:,test_SL(1,:))';%10169*20
test_labels = test_SL(2,:)';%10169*1
% Normalizing Training and original img 
[train_samples,M,m] = scale_func(train_samples);
[fimg3 ] = scale_func(fimg',M,m);
% Selecting the paramter for SVM
[Ccv Gcv cv cv_t]=cross_validation_svm(train_labels,train_samples);
% Training using a Gaussian RBF kernel
parameter=sprintf('-c %f -g %f -m 500 -t 2 -q',Ccv,Gcv);
model=svmtrain(train_labels,train_samples,parameter);
% Testing
Result = svmpredict(ones(no_lines*no_rows,1),fimg3,model); 
SVMresult = reshape(Result,no_lines,no_rows);
para1=7;
para2=0.1^3;
EPFresult = EPF(3,2,fimg3,SVMresult,para1,para2);
EPFresult =reshape(EPFresult,[no_rows*no_lines 1]);
EPFresulttest = EPFresult(test_SL(1,:),:);%62800*1
GroudTest = double(test_labels(:,1));%62800*1
[OA_i,AA_i,kappa_i,CA_i]=confusion(GroudTest,EPFresulttest);
Finalmap=reshape(EPFresult,[no_lines, no_rows]);
Finalmap=Normalization(Finalmap);

mm = Finalmap;
mm_gt = GT;
mm_gt = mm_gt-1;
mm((mm_gt==0)&(Finalmap~=0))= 2;
mm((mm_gt==1)&(Finalmap==0))= 3;
mm = mm +1;
cla_map = label2color(mm,'change');
imwrite(cla_map,'farmland_color.png')
figure,imshow(Finalmap,[]);
OA=[OA OA_i];
AA=[AA AA_i];
Kappa=[Kappa kappa_i];
CA=[CA CA_i];
end

OA_std=std(OA);OA1=mean(OA)';
AA_std=std(AA);AA1=mean(AA)';
K_std=std(Kappa);kappa1=mean(Kappa)';
CA_std=std(CA')';CA_mean=mean(CA,2);
% % ttime=time/w
OI=[OA1 OA_std;AA1 AA_std;kappa1 K_std]
