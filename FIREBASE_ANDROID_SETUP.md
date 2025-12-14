# 🔥 КРИТИЧНО: Настройка Firebase для Android APK

## 🚨 ПРОБЛЕМА: Google Sign In не работает в APK

Ошибка: **"Не удалось войти через Google"** в Android приложении

### 📋 Причина

Firebase Console не знает о вашем APK signing certificate (SHA-1 fingerprint).
Без этого Google Sign In не может работать на Android.

---

## ✅ РЕШЕНИЕ: Добавить SHA-1 fingerprint в Firebase Console

### Шаг 1: Ваш SHA-1 Fingerprint

```
48:57:26:1E:C6:20:D4:8B:B3:D7:C1:EA:13:87:DF:83:94:98:36:F2
```

**ВАЖНО:** Скопируйте это значение точно, включая двоеточия!

---

### Шаг 2: Откройте Firebase Console

1. Перейдите: **https://console.firebase.google.com/**
2. Выберите проект: **eu-paintroom-paintroom**

---

### Шаг 3: Добавьте SHA-1 в Android App

1. В Firebase Console перейдите:
   - **Project Overview** (⚙️ иконка шестерёнки справа от названия проекта)
   - **Project settings**

2. Прокрутите вниз до раздела **"Your apps"**

3. Найдите Android приложение:
   - **Package name:** `eu.paintroom.paintroom`
   - Нажмите на него

4. Прокрутите до раздела **"SHA certificate fingerprints"**

5. Нажмите кнопку **"Add fingerprint"**

6. Вставьте SHA-1:
   ```
   48:57:26:1E:C6:20:D4:8B:B3:D7:C1:EA:13:87:DF:83:94:98:36:F2
   ```

7. Нажмите **"Save"**

---

### Шаг 4: Скачайте обновлённый google-services.json

После добавления SHA-1:

1. В том же окне **Project settings** → **Your apps** → Android app
2. Найдите кнопку **"Download google-services.json"**
3. Скачайте новый файл
4. **ВАЖНО:** Замените старый файл в вашем проекте

---

### Шаг 5: Пересоберите APK с новым google-services.json

После обновления `google-services.json`:

1. Загрузите новый файл в проект (если скачали)
2. Пересоберите APK:
   ```bash
   cd /home/user/flutter_app
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

---

## 🎯 Альтернативное решение (БЕЗ доступа к Firebase Console)

Если у вас нет доступа к Firebase Console, используйте **Anonymous Authentication**:

### Включите Anonymous Auth в Firebase Console:

1. **Firebase Console** → **Authentication**
2. Вкладка **"Sign-in method"**
3. Найдите **"Anonymous"**
4. Нажмите **"Enable"**
5. Сохраните

Затем в коде используйте:
```dart
await FirebaseAuth.instance.signInAnonymously();
```

---

## 📱 Проверка после настройки

### После добавления SHA-1:

1. Установите новый APK на телефон
2. Откройте приложение
3. Перейдите на вкладку **"Profile"**
4. Нажмите **"Войти через Google"**
5. Выберите Google аккаунт
6. ✅ Должно работать!

---

## 🔍 Диагностика проблем

### Если всё ещё не работает:

1. **Проверьте Package Name:**
   - В Firebase Console должно быть: `eu.paintroom.paintroom`
   - В `build.gradle.kts` должно быть: `applicationId = "eu.paintroom.paintroom"`

2. **Проверьте SHA-1:**
   - Должен быть добавлен в Firebase Console
   - Скопирован без ошибок

3. **Проверьте google-services.json:**
   - Должен быть обновлён после добавления SHA-1
   - Должен находиться в `android/app/google-services.json`

4. **Очистите кэш и пересоберите:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

---

## 📊 Текущая конфигурация

### Firebase Project
- **Project ID:** `eu-paintroom-paintroom`
- **Project Number:** `516082565964`

### Android App
- **Package Name:** `eu.paintroom.paintroom`
- **App ID:** `1:516082565964:android:8a3c62e5877f1d8b6345e9`

### Signing
- **Keystore:** `android/release-key.jks`
- **Key Alias:** `release`
- **SHA-1:** `48:57:26:1E:C6:20:D4:8B:B3:D7:C1:EA:13:87:DF:83:94:98:36:F2`

---

## 🔗 Полезные ссылки

- **Firebase Console:** https://console.firebase.google.com/project/eu-paintroom-paintroom
- **Google Sign In for Android Documentation:** https://firebase.google.com/docs/auth/android/google-signin
- **SHA-1 Certificate Fingerprint Guide:** https://developers.google.com/android/guides/client-auth

---

## ⚠️ ВАЖНО!

**Без добавления SHA-1 fingerprint в Firebase Console, Google Sign In НЕ БУДЕТ РАБОТАТЬ в Android APK!**

Это обязательное требование безопасности Google.

---

**Обновлено:** 28 ноября 2025  
**SHA-1 Fingerprint:** `48:57:26:1E:C6:20:D4:8B:B3:D7:C1:EA:13:87:DF:83:94:98:36:F2`
