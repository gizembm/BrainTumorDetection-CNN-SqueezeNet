function main
    clc;
    close all;

    global selectedImage;
    selectedImage = [];

    % Ana pencere
    fig = uifigure('Name', 'Beyin Tümörü Tespiti', 'Position', [100 100 600 400]);

    % Görüntü gösterim alanı
    global imgAxes;
    imgAxes = uiaxes(fig, 'Position', [25 110 250 250]);
    title(imgAxes, 'Görüntü');

    % Model seçim butonları
    global modelButtonGroup rb1 rb2;
    modelButtonGroup = uibuttongroup(fig, ...
        'Position', [300 280 260 80], ...
        'Title', 'Model Seçimi');

    rb1 = uiradiobutton(modelButtonGroup, ...
        'Text', 'trainedNetwork_8 (squeezenet)', ...
        'Position', [10 40 200 20]);

    rb2 = uiradiobutton(modelButtonGroup, ...
        'Text', 'trainedNetwork_2 (mycnn)', ...
        'Position', [10 10 200 20]);

    rb1.Value = true;

    % Görüntü yükleme butonu
    btnLoad = uibutton(fig, 'push', ...
        'Text', 'Görüntü Yükle', ...
        'Position', [300 230 120 30], ...
        'ButtonPushedFcn', @(btnLoad, event) loadImage());

    % Analiz butonu
    btnAnalyze = uibutton(fig, 'push', ...
        'Text', 'Analiz Et', ...
        'Position', [440 230 120 30], ...
        'ButtonPushedFcn', @(btnAnalyze, event) analyzeImage());

    % Sonuç etiketi
    global resultLabel;
    resultLabel = uilabel(fig, ...
        'Text', 'Sonuç: -', ...
        'FontSize', 16, ...
        'FontWeight', 'bold', ...
        'Position', [300 180 250 30]);

    % Bilgi etiketi
    global statusLabel;
    statusLabel = uilabel(fig, ...
        'Text', 'Hazır', ...
        'Position', [25 25 500 20]);
end

%% Görüntü Yükleme Fonksiyonu
function loadImage()
    global selectedImage imgAxes resultLabel statusLabel

    [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Tüm Görüntüler'}, 'Bir MR Görüntüsü Seçin');
    if isequal(file, 0)
        return;
    end

    imgPath = fullfile(path, file);
    img = imread(imgPath);
    selectedImage = img;

    imshow(img, 'Parent', imgAxes);
    title(imgAxes, 'Yüklenen Görüntü');

    resultLabel.Text = 'Sonuç: -';
    statusLabel.Text = ['Görüntü yüklendi: ' file];
end

%% Analiz Fonksiyonu
function analyzeImage()
    global selectedImage resultLabel modelButtonGroup rb1 imgAxes

    if isempty(selectedImage)
        errordlg('Lütfen önce bir MR görüntüsü seçin!', 'Görüntü Seçilmedi');
        return;
    end

    try
        resultLabel.Text = 'Analiz ediliyor...';
        drawnow;

        if modelButtonGroup.SelectedObject == rb1
            modelName = 'trainedNetwork_8';  % SqueezeNet
        else
            modelName = 'trainedNetwork_2';  % Kendi CNN'in
        end

        if ~evalin('base', ['exist(''' modelName ''', ''var'')'])
            errordlg([modelName ' modeli bulunamadı!'], 'Model Hatası');
            resultLabel.Text = 'Sonuç: Model bulunamadı';
            return;
        end

        net = evalin('base', modelName);
        netType = class(net);
        processedImg = prepareImageForNetwork(selectedImage);

        try
            if contains(netType, 'SeriesNetwork')
                lastLayer = net.Layers(end).Name;
                scores = activations(net, processedImg, lastLayer, 'OutputAs', 'rows');
            elseif contains(netType, 'DAGNetwork')
                lastLayer = net.OutputNames{1};
                scores = activations(net, processedImg, lastLayer, 'OutputAs', 'rows');
            else
                scores = predict(net, processedImg);
            end

            [~, idx] = max(scores);
            classes = net.Layers(end).Classes;
            prediction = string(classes(idx));
        catch
            errordlg('Model çıktısı alınamadı!', 'Model Hatası');
            return;
        end

        if strcmpi(prediction, 'yes')
            resultLabel.Text = 'Sonuç: TÜMÖRLÜ';
            resultLabel.FontColor = [0.8 0 0];
        elseif strcmpi(prediction, 'no')
            resultLabel.Text = 'Sonuç: TÜMÖRSÜZ';
            resultLabel.FontColor = [0 0.6 0];
        else
            resultLabel.Text = ['Sonuç: ' prediction];
            resultLabel.FontColor = [0 0 0];
        end

        title(imgAxes, ['Analiz Edildi - ' modelName]);

    catch e
        errordlg(['Analiz sırasında bir hata oluştu: ' e.message], 'Analiz Hatası');
        disp(['HATA: ' e.message]);
        disp(getReport(e));
    end
end

%% Görüntü Hazırlama Fonksiyonu
function processedImg = prepareImageForNetwork(img)
    targetSize = [227 227];

    img = double(img);

    if size(img, 3) == 1
        img = cat(3, img, img, img);
    elseif size(img, 3) > 3
        img = img(:, :, 1:3);
    end

    if any(isnan(img(:)))
        img(isnan(img)) = 0;
    end

    img = imresize(img, targetSize);
    processedImg = img;
end
