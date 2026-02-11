# 💧 Bottle of Water

**Bottle of Water**, günlük su tüketimini takip etmenizi ve hidrasyon alışkanlığı kazanmanızı sağlayan, SwiftUI ile geliştirilmiş bir iOS su hatırlatıcı uygulamasıdır.

![Swift](https://img.shields.io/badge/Swift-5.0-orange?logo=swift)
![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-blue?logo=apple)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Özellikler

- **Zamana Göre Karşılama** — Günün saatine göre "Good Morning", "Good Afternoon", "Good Evening" veya "Good Night" mesajları ve buna uyumlu ikonlar.
- **Günlük Hidrasyon Önerileri** — Yılın gününe göre değişen, motive edici su içme ipuçları; her açılışta farklı bir öneri.
- **Sekmeli Arayüz** — **Home**, **Calendar**, **Limitize** ve **Statistics** sekmeleriyle düzenli ve akıcı gezinme.
- **Liquid Glass Tab Bar** — Cam efektli, animasyonlu "liquid" blob'larla modern alt navigasyon çubuğu.
- **Özenli Tasarım** — Mavi–turkuaz gradyan arka plan, yuvarlak tipografi ve sade bir görünüm.
- **Bildirim ve Ayarlar** — Header'da bildirim ve ayarlar için hazır buton alanları.

Uygulama, su içmeyi unutmamanız ve düzenli hidrasyon alışkanlığı edinmeniz için günlük kullanıma uygun, hafif ve kullanıcı dostu bir deneyim sunar.

---

## 🛠 Teknolojiler

- **SwiftUI** — Arayüz ve bileşenler
- **Combine** — Reaktif yapı (ihtiyaç halinde)
- **Xcode** — Geliştirme ortamı
- **iOS 17+** — Hedef platform

---

## 📁 Proje Yapısı

```
Bottle of Water/
├── Bottle of Water/
│   ├── Bottle_of_WaterApp.swift   # Uygulama giriş noktası
│   ├── ContentView.swift         # Ana içerik ve sekmeler (Home, Calendar, Limitize, Statistics)
│   ├── HeaderView.swift          # Karşılama, öneri metni, bildirim ve ayar butonları
│   ├── CustomTabBar.swift        # Liquid glass tab bar ve animasyonlar
│   └── Assets.xcassets/          # Görseller ve renkler
├── Helpers/
│   └── LaunchScreen.swift
└── Bottle of Water.xcodeproj
```

---

## 🚀 Kurulum

1. Repoyu klonlayın:
   ```bash
   git clone https://github.com/yigitbal5555/Bottle-of-Water.git
   cd Bottle-of-Water
   ```
2. `Bottle of Water.xcodeproj` dosyasını Xcode ile açın.
3. Hedef cihaz veya simülatör seçip **Run** (⌘R) ile derleyin ve çalıştırın.

---

## 📄 Lisans

Bu proje **MIT** lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

*Su içmeyi unutma — her yudum önemli. 💧*
