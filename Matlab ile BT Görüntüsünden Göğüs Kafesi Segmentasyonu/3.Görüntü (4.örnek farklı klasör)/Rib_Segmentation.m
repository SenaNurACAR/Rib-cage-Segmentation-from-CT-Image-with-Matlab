%% SEGMENTASYON
%Dosyadan görüntülerin okunmasý
clear;
clc;
n=0;
image1=zeros(512,512,124);
Gray_img=zeros(512,512,124);
Ic_maske=ones(512,512,124);
%Görüntüden dosyalarýn okutulmasý
for i=718:821
    n=n+1;
    dosya=strcat(  '1.3.12.2.1107.5.1.4.95454.30000015090806153912500047',num2str(i),'.dcm');
    image1(:,:,n)=dicomread(dosya);
end
%Yarýçap Belirlenmesi
 r=130;
for i=1:103
    Gray_img=mat2gray(image1(:,:,i));
    treshold=graythresh(Gray_img);
    img=im2bw(Gray_img,treshold);
    %Görüntüden istenmeyen Kýsmýn atýlmasý
    Alt_silme=bwareaopen(img, 10000);
    %Gray Görüntü  ile alt kýsmý silinen kýsýmla gray görüntünün çarpýlmasý
    New_gray=Gray_img.*Alt_silme;
    %iç maske oluþturulmasý
    img_fill=imfill(img,4,'holes');
    L=img_fill-img; % maske elde etmek için akciðerlerin çýkarýlmasý
    L_fill=imfill(L,8,'holes');
    LungMask=bwareaopen(L_fill, 2000);
    se = strel ( 'disk',75);
    afterOpening = imclose (LungMask, se);
    maske=imcomplement(afterOpening);%Kullanýlacak maske
    Ic_maske(:,:,i)=maske; %maskeyi iç maske diye bir üç boyutlu görüntüde tutulmasý
    %Histogram Eþitleme Yapýlmasý
    hstq = histeq(New_gray);
    %Treshold Uygulanmasý
    thresh=0.98;
    Rib=im2bw(hstq,thresh);
    %iç maskede oluþan sorunu Çözme
    if i<60
        new_image=Rib.*maske;
    else if (60<=i)&& (i<98)
            maske=Ic_maske(:,:,25);
            new_image=Rib.*maske;
        else
            maske=Ic_maske(:,:,20);
            new_image=Rib.*maske;
        end
    end
    %Gürültüler için medyan filtre uygulanmasý
    Median=medfilt2(new_image, [3 3]);
    %ilk 10 görüntü için oluþturulacak yuvarlakk maske
    [M N]=size(Gray_img);
    %Görüntünün orta noktalarýnýn seçilmesi
    midpoint_x=M/2;
    midpoint_y=N/2;
    %Yuvarlak bir maske oluþturulmasý
    [x y]=meshgrid(-(midpoint_x-1):midpoint_x, -(midpoint_y-1):midpoint_y);
    z=sqrt(x.^2+ y.^2);
    daire=(z<r);
    % Ýlk 10 görüntüye uygulatma için koþul
    if i< 11
    Im=Median.*daire;
    else 
        Im=Median;
    end    
    %Görüntüyü onarmak için morfolojik iþlemler uygulanmasý
     SE = strel('square',2);
    BWsdil = imdilate(Im,SE); % görüntünün geniþletilmesi
    BWdfill = imfill(BWsdil,'holes'); % görüntüdeki boþluklarýn doldurulmasý
    BWnobord = imclearborder(BWdfill,4); % Küçük beyaz noktalarýn silinmesi
    
    Im=im2double(BWnobord);
  figure(1), imshow(Im)  ;   
end

