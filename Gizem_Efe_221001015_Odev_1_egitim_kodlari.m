% Klasör yollarını belirleme
datasetPath = 'C:\Users\Asus\Desktop\brain_dataset\brain_tumor_dataset';
yesFolderPath = fullfile(datasetPath, 'yes');
noFolderPath = fullfile(datasetPath, 'no');


% Yeni işlenmiş veriler için klasörler oluştur
processedPath = fullfile(datasetPath, 'processed1');
processedYesPath = fullfile(processedPath, 'yes');
processedNoPath = fullfile(processedPath, 'no');

% Klasörleri oluştur (eğer yoksa)
if ~exist(processedPath, 'dir')
    mkdir(processedPath);
    mkdir(processedYesPath);
    mkdir(processedNoPath);
end

% "Yes" klasöründeki görüntüleri işle
targetSize = [227, 227, 3];
% "Yes" klasöründeki görüntüleri işle
imageFiles = dir(fullfile(yesFolderPath, '*.jpg'));
imageFiles = [imageFiles; dir(fullfile(yesFolderPath, '*.jpeg'))];
imageFiles = [imageFiles; dir(fullfile(yesFolderPath, '*.png'))];

fprintf('İşleniyor: "yes" klasöründeki %d görüntü\n', length(imageFiles));

for i = 1:length(imageFiles)
    % Görüntüyü oku
    imagePath = fullfile(yesFolderPath, imageFiles(i).name);
    img = imread(imagePath);
    
    % RGB kontrolü ve dönüştürme
    if size(img, 3) ~= 3
        % Gri görüntüyü 3 kanallı RGB'ye dönüştür
        img = cat(3, img, img, img);
    end
    
    % Yeniden boyutlandır
    img = imresize(img, targetSize(1:2));
    
    % Kaydet
    [~, baseName, ~] = fileparts(imageFiles(i).name);
    imwrite(img, fullfile(processedYesPath, [baseName, '.png']));
    
    % İlerleme göster
    if mod(i, 10) == 0
        fprintf('  %d/%d görüntü işlendi\n', i, length(imageFiles));
    end
end
fprintf('Tamamlandı: %d görüntü işlendi ve %s klasörüne kaydedildi\n', length(imageFiles), processedYesPath);

% "No" klasöründeki görüntüleri işle
imageFiles = dir(fullfile(noFolderPath, '*.jpg'));
imageFiles = [imageFiles; dir(fullfile(noFolderPath, '*.jpeg'))];
imageFiles = [imageFiles; dir(fullfile(noFolderPath, '*.png'))];

fprintf('İşleniyor: "no" klasöründeki %d görüntü\n', length(imageFiles));


for i = 1:length(imageFiles)
    % Görüntüyü oku
    imagePath = fullfile(noFolderPath, imageFiles(i).name);
    img = imread(imagePath);
    
    % RGB kontrolü ve dönüştürme
    if size(img, 3) ~= 3
        % Gri görüntüyü 3 kanallı RGB'ye dönüştür
        img = cat(3, img, img, img);
    end
    
    % Yeniden boyutlandır
    img = imresize(img, targetSize(1:2));
    
    % Kaydet
    [~, baseName, ~] = fileparts(imageFiles(i).name);
    imwrite(img, fullfile(processedNoPath, [baseName, '.png']));
    
    % İlerleme göster
    if mod(i, 10) == 0
        fprintf('  %d/%d görüntü işlendi\n', i, length(imageFiles));
    end
end
fprintf('Tamamlandı: %d görüntü işlendi ve %s klasörüne kaydedildi\n', length(imageFiles), processedNoPath);

% İşlenmiş görüntüleri say
yesFiles = dir(fullfile(processedYesPath, '*.png'));
noFiles = dir(fullfile(processedNoPath, '*.png'));
fprintf('\nİşlenmiş görüntüler: Yes=%d, No=%d\n', length(yesFiles), length(noFiles));


% Veri çoğaltma (Data Augmentation) - "No" sınıfı için
if length(noFiles) < length(yesFiles)
    fprintf('\n"No" sınıfı için veri artırma uygulanıyor...\n');
    
    % İhtiyaç duyulan ek görüntü sayısı
    additionalImagesNeeded = length(yesFiles) - length(noFiles);
    
    % Veri artırma datastore'u oluştur - RandContrast parametresi kaldırıldı
    augmenter = imageDataAugmenter(...
        'RandRotation', [-20, 20], ...
        'RandXReflection', true, ...
        'RandYReflection', true, ...
        'RandXScale', [0.8, 1.2], ...
        'RandYScale', [0.8, 1.2], ...
        'RandXShear', [-10, 10], ...
        'RandYShear', [-10, 10]);
    
    % "No" sınıfındaki tüm görüntüler için döngü
    noImagesUsed = 0;
    augmentedImagesCreated = 0;
    
    while augmentedImagesCreated < additionalImagesNeeded
        noImagesUsed = mod(noImagesUsed, length(noFiles)) + 1;
        
        % Görüntüyü oku
        img = imread(fullfile(processedNoPath, noFiles(noImagesUsed).name));
        
        % Veri artırma uygula
        augmentedImg = augment(augmenter, img);
        
        % Yeni isimle kaydet
        [~, baseName, ~] = fileparts(noFiles(noImagesUsed).name);
        newName = sprintf('%s_aug_%d.png', baseName, augmentedImagesCreated+1);
        imwrite(augmentedImg, fullfile(processedNoPath, newName));
        
        augmentedImagesCreated = augmentedImagesCreated + 1;
        
        if mod(augmentedImagesCreated, 10) == 0
            fprintf('  %d/%d artırılmış görüntü oluşturuldu\n', augmentedImagesCreated, additionalImagesNeeded);
        end
    end
    
    fprintf('Veri artırma tamamlandı: %d yeni görüntü oluşturuldu\n', augmentedImagesCreated);
end


% Güncel görüntü sayılarını al
yesFiles = dir(fullfile(processedYesPath, '*.png'));
noFiles = dir(fullfile(processedNoPath, '*.png'));
fprintf('\nFinal görüntü sayıları: Yes=%d, No=%d\n', length(yesFiles), length(noFiles));

% Veri setini bölme işlemleri
folderArray = {processedYesPath, processedNoPath};
imds = imageDatastore(folderArray, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');
folderArray = {processedYesPath, processedNoPath};
imds = imageDatastore(folderArray, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');
% Veri karıştırma (verileri karıştırma)
imds = shuffle(imds);
% Veri setini bölümlere ayırma
numFiles = length(imds.Files);
trainRatio = 0.7;
valRatio = 0.15;
testRatio = 0.15;
% İndeksleri hesapla
trainIdx = 1:round(trainRatio * numFiles);
valIdx = (trainIdx(end) + 1):(trainIdx(end) + round(valRatio * numFiles));
testIdx = (valIdx(end) + 1):numFiles;

% Veri setlerini oluştur
trainImds = subset(imds, trainIdx);
valImds = subset(imds, valIdx);
testImds = subset(imds, testIdx);
% Veri seti bilgilerini göster
fprintf('\nVeri seti bölümleri:\n');
fprintf('  Eğitim seti: %d görüntü (%%%.1f)\n', numel(trainImds.Files), 100*numel(trainImds.Files)/numFiles);
fprintf('  Doğrulama seti: %d görüntü (%%%.1f)\n', numel(valImds.Files), 100*numel(valImds.Files)/numFiles);
fprintf('  Test seti: %d görüntü (%%%.1f)\n', numel(testImds.Files), 100*numel(testImds.Files)/numFiles);

% Veri setlerini kaydet
save(fullfile(datasetPath, 'processed_dataset.mat'), 'trainImds', 'valImds', 'testImds');
fprintf('\nVeri setleri kaydedildi: %s\n', fullfile(datasetPath, 'processed_dataset.mat'));


% Görselleştirme - her sınıftan birkaç örnek göster
figure;
perm = randperm(numel(trainImds.Files), min(9, numel(trainImds.Files)));
for i = 1:length(perm)
    subplot(3, 3, i);
    img = readimage(trainImds, perm(i));
    imshow(img);
    title(string(trainImds.Labels(perm(i))));
end
sgtitle('Eğitim Veri Setinden Örnekler');

disp('Veri hazırlama işlemi tamamlandı!');





