function [result] = GF(img,para1,para2)

GDimg=PCA_img(img,1);
% GDimg =kpca(img,1000,1, 'Gaussian',20);%'Gaussian'
for i=1:size(img,3)
% result(:,:,i)= bilateralFilter(img(:,:,i),GDimg);
result(:,:,i)= guidedfilter(GDimg,img(:,:,i),para1,para2);%1,0.1^8
% result(:,:,i)= IC(img(:,:,i),3,0.1,3,GDimg); 
end
end