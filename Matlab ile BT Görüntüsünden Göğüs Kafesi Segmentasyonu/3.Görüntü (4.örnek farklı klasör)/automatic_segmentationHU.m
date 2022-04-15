%% SEGMENTASYON
%Dosyadan g�r�nt�lerin okunmas�
clear;
clc;

for i=718:821
    
    dosya=strcat(  '1.3.12.2.1107.5.1.4.95454.30000015090806153912500047',num2str(i),'.dcm');
    img=dicomread(dosya);
     %G�r�nt�n�n Alt�nda istenmeyen k�sm�n Silinmesi
    treshold=graythresh(img);
    I=im2bw(img,treshold);
    Mask=bwareaopen(I, 10000); 
    % Dicom g�r�nt� bilgileri alma
    info = dicominfo(dosya); 
    % HU de�erleri hesaplayarak yeni g�r�nt�y� olu�turma.
    img = double(img)*info.RescaleSlope + info.RescaleIntercept; 
    WC =150; %Alt limit de�eri
    WW =200;% �st Limit de�eri
     %Verileri yeniden �l�eklendirmesi
    imgScaled = (double(img)-(WC-0.5))/((WW-0.5));
    %G�r�nt� yo�unlu�u de�erini ve renk haritas�n� ayarlar.
    imd = imadjust(imgScaled);
    % kemik de�erleri 1 oldu�u i�in 0.99 �sst�n� almas�n� sa�l�yoruz.
    thresh=0.95; 
    Rib=im2bw(imd,thresh); 
    %G�r�nt�n�n Geni�letilmesi
    SE = strel('square',2);
    BWsdil = imdilate(Rib,SE);
    %G�r�nt�deki Bo�luklar�n Doldurulmas�
    BWdfill = imfill(BWsdil,'holes');
    %G�r�nt�deki beyaz noktalar� silme
    BW=bwareaopen(BWdfill, 100);
    New_img=BW.*Mask;
    figure(1),imshow(New_img)
end


