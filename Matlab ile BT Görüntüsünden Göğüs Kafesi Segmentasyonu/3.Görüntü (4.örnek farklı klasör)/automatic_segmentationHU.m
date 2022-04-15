%% SEGMENTASYON
%Dosyadan görüntülerin okunmasý
clear;
clc;

for i=718:821
    
    dosya=strcat(  '1.3.12.2.1107.5.1.4.95454.30000015090806153912500047',num2str(i),'.dcm');
    img=dicomread(dosya);
     %Görüntünün Altýnda istenmeyen kýsmýn Silinmesi
    treshold=graythresh(img);
    I=im2bw(img,treshold);
    Mask=bwareaopen(I, 10000); 
    % Dicom görüntü bilgileri alma
    info = dicominfo(dosya); 
    % HU deðerleri hesaplayarak yeni görüntüyü oluþturma.
    img = double(img)*info.RescaleSlope + info.RescaleIntercept; 
    WC =150; %Alt limit deðeri
    WW =200;% Üst Limit deðeri
     %Verileri yeniden ölçeklendirmesi
    imgScaled = (double(img)-(WC-0.5))/((WW-0.5));
    %Görüntü yoðunluðu deðerini ve renk haritasýný ayarlar.
    imd = imadjust(imgScaled);
    % kemik deðerleri 1 olduðu için 0.99 üsstünü almasýný saðlýyoruz.
    thresh=0.95; 
    Rib=im2bw(imd,thresh); 
    %Görüntünün Geniþletilmesi
    SE = strel('square',2);
    BWsdil = imdilate(Rib,SE);
    %Görüntüdeki Boþluklarýn Doldurulmasý
    BWdfill = imfill(BWsdil,'holes');
    %Görüntüdeki beyaz noktalarý silme
    BW=bwareaopen(BWdfill, 100);
    New_img=BW.*Mask;
    figure(1),imshow(New_img)
end


