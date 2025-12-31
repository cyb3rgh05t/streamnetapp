# StreamNet TV - Icons & Splash Screen Setup

## 📦 Benötigte PNG-Dateien

Du musst die SVG-Dateien in PNG konvertieren und hier ablegen:

| Datei                     | Größe     | Format                  | SVG-Vorlage               |
| ------------------------- | --------- | ----------------------- | ------------------------- |
| `app_icon.png`            | 1024x1024 | PNG (mit Hintergrund)   | `app_icon_large.svg`      |
| `app_icon_foreground.png` | 1024x1024 | PNG (transparent)       | `app_icon_foreground.svg` |
| `app_icon_monochrome.png` | 1024x1024 | PNG (weiß, transparent) | `app_icon_monochrome.svg` |
| `tv_banner.png`           | 640x360   | PNG                     | `tv_banner.svg`           |
| `splash_logo.png`         | 512x512   | PNG (transparent)       | `splash_logo.svg`         |
| `splash_branding.png`     | 400x80    | PNG (transparent)       | `splash_branding.svg`     |

---

## 🔄 SVG zu PNG konvertieren

### Option 1: Online Tools (empfohlen)

- [CloudConvert](https://cloudconvert.com/svg-to-png)
- [SVGtoPNG](https://svgtopng.com/)

### Option 2: Inkscape

```bash
inkscape app_icon_large.svg -o app_icon.png -w 1024 -h 1024
inkscape app_icon_foreground.svg -o app_icon_foreground.png -w 1024 -h 1024
inkscape app_icon_monochrome.svg -o app_icon_monochrome.png -w 1024 -h 1024
inkscape tv_banner.svg -o tv_banner.png -w 640 -h 360
inkscape splash_logo.svg -o splash_logo.png -w 512 -h 512
inkscape splash_branding.svg -o splash_branding.png -w 400 -h 80
```

---

## 🚀 Icons generieren

Nach dem Erstellen der PNGs:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 📺 Android TV Banner

Der Banner muss manuell in diese Ordner kopiert werden:

```
android/app/src/main/res/mipmap-mdpi/ic_banner.png    (160x90)
android/app/src/main/res/mipmap-hdpi/ic_banner.png    (240x135)
android/app/src/main/res/mipmap-xhdpi/ic_banner.png   (320x180)
android/app/src/main/res/mipmap-xxhdpi/ic_banner.png  (480x270)
android/app/src/main/res/mipmap-xxxhdpi/ic_banner.png (640x360)
```

---

## 🎨 StreamNet TV Farben

| Farbe      | Hex       | Verwendung  |
| ---------- | --------- | ----------- |
| Gold       | `#e5a00d` | Akzentfarbe |
| Background | `#121212` | Hintergrund |
| Surface    | `#1e1e1e` | Karten      |

---

## ✅ Checkliste

- [ ] `app_icon.png` erstellt
- [ ] `app_icon_foreground.png` erstellt
- [ ] `app_icon_monochrome.png` erstellt
- [ ] `tv_banner.png` erstellt
- [ ] `splash_logo.png` erstellt
- [ ] `splash_branding.png` erstellt
- [ ] `dart run flutter_launcher_icons` ausgeführt
- [ ] `dart run flutter_native_splash:create` ausgeführt
- [ ] Banner in mipmap-Ordner kopiert
