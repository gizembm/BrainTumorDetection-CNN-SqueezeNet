# CNN ve SqueezeNet ile Beyin Tümörü Sınıflandırması

Bu proje, beyin MR görüntülerini tümörlü ve tümörsüz olarak sınıflandırmak amacıyla geliştirilmiştir. Derin öğrenme tabanlı iki farklı model kullanılmıştır: önceden eğitilmiş **SqueezeNet** ağı ve özel olarak tasarlanmış **CNN mimarisi**. Ayrıca MATLAB ortamında çalışabilen kullanıcı dostu bir arayüz (GUI) geliştirilmiştir.

## 📁 Veri Seti

- Kaynak: [Kaggle - Brain MRI Images for Brain Tumor Detection](https://www.kaggle.com/datasets/navoneel/brain-mri-images-for-brain-tumor-detection)
- Sınıflar:
  - `yes`: Tümörlü görüntüler
  - `no`: Tümörsüz görüntüler
- Toplam Görüntü: 252 (154 tümörlü, 98 tümörsüz)

## 🧪 Ön İşleme

- Tüm görüntüler `227x227x3` boyutuna getirildi
- Gri tonlamalı görüntüler RGB'ye dönüştürüldü
- Dosya formatı `.png` olarak standardize edildi
- Veri çoğaltma (data augmentation) ile sınıf dengesi sağlandı:
  - Döndürme, yansıtma, ölçekleme, kaydırma
- Veri bölme oranları:
  - Eğitim: %70
  - Doğrulama: %15
  - Test: %15

## 🧠 Kullanılan Modeller

### 🔹 SqueezeNet (Önceden Eğitilmiş)

- Hafif mimariye sahip CNN modeli
- “Fire modülleri” ile optimize edilmiş
- **Adam** algoritması ile 30 epoch eğitimde **%91.30 doğruluk** sağladı

### 🔹 MyCNN (Özel Tasarım CNN)

- Conv + BatchNorm + ReLU + MaxPooling + Dropout katmanları içerir
- Softmax ile iki sınıflı çıkış üretir
- En iyi doğruluk değeri: **%86.96**

## ⚙️ Eğitim Parametreleri

| Parametre                | Değer             |
|--------------------------|-------------------|
| Optimizasyon Algoritmaları | Adam, SGDM        |
| Epoch (dönem) sayısı      | 15 / 30           |
| Mini-batch boyutu         | 16                |
| Öğrenme oranı             | 0.0001            |
| Aktivasyon (çıkış)        | Softmax           |

## 📊 Sonuçlar

- En iyi başarı: **%91.30** (SqueezeNet + Adam, 30 epoch)
- Tüm model varyasyonları için doğruluklar ve konfüzyon matrisleri analiz edildi
- Adam ve SGDM gibi farklı algoritmalar karşılaştırıldı

## 📈 Eğitim Grafikleri

Aşağıda farklı konfigürasyonlarla eğitilmiş modellerin doğruluk ve kayıp (loss) grafiklerini görebilirsiniz:

### 🔹 SqueezeNet + SDGM (15 Epoch)
![image](https://github.com/user-attachments/assets/c96ff21a-d889-4393-8b51-c91de3c6174c)

### 🔹 SqueezeNet + ADAM (15 Epoch)
![image](https://github.com/user-attachments/assets/748a1118-9095-4549-bee8-f9ce2d1b40de)


### 🔹 MyCNN + ADAM (30 Epoch)
![image](https://github.com/user-attachments/assets/255afd0c-2ff1-44ba-80fa-12f0ea27c8f2)


---

## 🧩 Konfüzyon Matrisleri

Modellerin test verileri üzerinde oluşturduğu konfüzyon matrisleri:

### 🔹 SqueezeNet + SDGM (15 Epoch)
![image](https://github.com/user-attachments/assets/febc3683-be3c-4466-8dee-f290e96eec90)

### 🔹 SqueezeNet + ADAM (15 Epoch)
![image](https://github.com/user-attachments/assets/a205561e-b0bf-4fea-b6b3-e94fe2fe9247)


### 🔹 MyCNN + ADAM (15 Epoch)
![image](https://github.com/user-attachments/assets/bdca0f32-69c3-44ea-ba2e-e627633ea30b)


## 🖥️ MATLAB GUI Arayüzü

- Kullanıcı:
  - Görüntü yükleyebilir
  - Model seçebilir (MyCNN veya SqueezeNet)
  - “Analiz Et” butonuna basarak sonucu alabilir
- Arayüzde sonuç metin olarak gösterilir

![image](https://github.com/user-attachments/assets/513af00f-6834-475b-8cca-05ed393b5084)

![image](https://github.com/user-attachments/assets/77f58c64-608c-40b9-bb64-c313741a6d66)

![image](https://github.com/user-attachments/assets/4f152469-724f-4acd-b7f2-635bbbe5c422)



