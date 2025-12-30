% --- 1. ADIM: EĞİTİM (İki Özellikli Akıllı Öğrenme) ---
try
    resimler = {TA__jpg, KA_IT_jpg, MAKAS_jpg}; 
    etiketler = {'TAS', 'KAGIT', 'MAKAS'};
    egitim_verisi = zeros(3, 2); 

    for i = 1:3
        img = resimler{i};
        gri = rgb2gray(img);
        bw = imbinarize(gri, 'adaptive', 'Sensitivity', 0.5);
        bw = imcomplement(bw);
        bw = bwareafilt(bw, 1);
        st = regionprops(bw, 'Solidity', 'Extent');
        egitim_verisi(i, :) = [st.Solidity, st.Extent];
    end
    fprintf('Yapay zeka akıllı eğitim modunda hazır!\n');
catch
    error('İsim hatası! Lütfen Workspace değişkenlerini kontrol et.');
end

% --- 2. ADIM: CANLI VE KARARLI ANALİZ ---
try
    cam = webcam; 
    h_fig = figure('Name', 'Kararlı Yapay Zeka Analizi');
    
    % Hareket ortalama için hafıza (son 10 tahmini tutar)
    tahmin_hafizasi = categorical(repmat({'GEÇERSİZ'}, 1, 10)); 
    
    while ishandle(h_fig)
        kare = snapshot(cam);
        g = rgb2gray(kare);
        bw_y = imbinarize(g, 'adaptive', 'Sensitivity', 0.5);
        bw_y = imcomplement(bw_y);
        bw_y = bwareafilt(bw_y, 1);
        stat_y = regionprops(bw_y, 'Solidity', 'Extent');
        
        anlik_tahmin = 'GEÇERSİZ';
        if ~isempty(stat_y)
            anlik_veri = [stat_y.Solidity, stat_y.Extent];
            mesafeler = sqrt(sum((egitim_verisi - anlik_veri).^2, 2));
            [en_yakin_mesafe, index] = min(mesafeler);
            
            if en_yakin_mesafe < 0.20 % Biraz daha esnek mesafe
                anlik_tahmin = etiketler{index};
            end
        end
        
        % Hafızayı güncelle (en eskiyi at, yeni tahmini ekle)
        tahmin_hafizasi = [tahmin_hafizasi(2:end), categorical({anlik_tahmin})];
        
        % Mod (En çok tekrar eden tahmini seç)
        final_tahmin = char(mode(tahmin_hafizasi));
        
        % Renk Belirleme
        if strcmp(final_tahmin, 'GEÇERSİZ'), r = 'y'; else, r = 'g'; end
        
        imshow(kare); 
        title(['Kararlı Tahmin: ', final_tahmin], 'FontSize', 22, 'Color', r);
        drawnow;
    end
    clear cam;
catch; clear cam; end