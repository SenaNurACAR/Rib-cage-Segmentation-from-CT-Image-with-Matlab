%% SEGMENTASYON
%Dosyadan g�r�nt�lerin okunmas�
clear;
clc;
n=0;
image1=zeros(512,512,124);
Gray_img=zeros(512,512,124);
Ic_maske=ones(512,512,124);
%G�r�nt�den dosyalar�n okutulmas�
for i=718:821
    n=n+1;
    dosya=strcat(  '1.3.12.2.1107.5.1.4.95454.30000015090806153912500047',num2str(i),'.dcm');
    image1(:,:,n)=dicomread(dosya);
end
%Yar��ap Belirlenmesi
 r=130;
for i=1:103
    Gray_img=mat2gray(image1(:,:,i));
    treshold=graythresh(Gray_img);
    img=im2bw(Gray_img,treshold);
    %G�r�nt�den istenmeyen K�sm�n at�lmas�
    Alt_silme=bwareaopen(img, 10000);
    %Gray G�r�nt�  ile alt k�sm� silinen k�s�mla gray g�r�nt�n�n �arp�lmas�
    New_gray=Gray_img.*Alt_silme;
    %i� maske olu�turulmas�
    img_fill=imfill(img,4,'holes');
    L=img_fill-img; % maske elde etmek i�in akci�erlerin ��kar�lmas�
    L_fill=imfill(L,8,'holes');
    LungMask=bwareaopen(L_fill, 2000);
    se = strel ( 'disk',75);
    afterOpening = imclose (LungMask, se);
    maske=imcomplement(afterOpening);%Kullan�lacak maske
    Ic_maske(:,:,i)=maske; %maskeyi i� maske diye bir �� boyutlu g�r�nt�de tutulmas�
    %Histogram E�itleme Yap�lmas�
    hstq = histeq(New_gray);
    %Treshold Uygulanmas�
    thresh=0.98;
    Rib=im2bw(hstq,thresh);
    %i� maskede olu�an sorunu ��zme
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
    %G�r�lt�ler i�in medyan filtre uygulanmas�
    Median=medfilt2(new_image, [3 3]);
    %ilk 10 g�r�nt� i�in olu�turulacak yuvarlakk maske
    [M N]=size(Gray_img);
    %G�r�nt�n�n orta noktalar�n�n se�ilmesi
    midpoint_x=M/2;
    midpoint_y=N/2;
    %Yuvarlak bir maske olu�turulmas�
    [x y]=meshgrid(-(midpoint_x-1):midpoint_x, -(midpoint_y-1):midpoint_y);
    z=sqrt(x.^2+ y.^2);
    daire=(z<r);
    % �lk 10 g�r�nt�ye uygulatma i�in ko�ul
    if i< 11
    Im=Median.*daire;
    else 
        Im=Median;
    end    
    %G�r�nt�y� onarmak i�in morfolojik i�lemler uygulanmas�
     SE = strel('square',2);
    BWsdil = imdilate(Im,SE); % g�r�nt�n�n geni�letilmesi
    BWdfill = imfill(BWsdil,'holes'); % g�r�nt�deki bo�luklar�n doldurulmas�
    BWnobord = imclearborder(BWdfill,4); % K���k beyaz noktalar�n silinmesi
    
    Im=im2double(BWnobord);
  figure(1), imshow(Im)  ;   
end

