# 🔧 Исправление Google Authentication для Web

## 🚨 Проблема

При попытке войти через Google на Web-платформе появляется ошибка:
```
Не удалось войти через Google
```

## 🔍 Причина

Для работы Google Sign In на Web-платформе требуется:
1. ✅ OAuth Client ID для Web приложения
2. ⚠️ Авторизованные домены в Firebase Console
3. ⚠️ Правильная настройка redirect URI

## 📋 Текущая конфигурация

### Firebase Project
- **Project ID:** `eu-paintroom-paintroom`
- **Project Number:** `516082565964`

### OAuth Client IDs
- **Android:** `516082565964-b0cga31evlq0b41nseae1bdr4h982hk4.apps.googleusercontent.com`
- **Web:** `516082565964-b0cga31evlq0b41nseae1bdr4h982hk4.apps.googleusercontent.com`

### Current Web Domain
- **Sandbox URL:** `https://5060-ii603aqp2wsfigo4xqtrs-2e1b9533.sandbox.novita.ai`

## ✅ Решение

### Шаг 1: Добавить авторизованные домены в Firebase Console

1. Откройте **Firebase Console**: https://console.firebase.google.com/
2. Выберите проект: **eu-paintroom-paintroom**
3. Перейдите: **Authentication** → **Sign-in method** → **Google** → **Web SDK configuration**
4. В разделе **Authorized domains** добавьте:
   ```
   sandbox.novita.ai
   5060-ii603aqp2wsfigo4xqtrs-2e1b9533.sandbox.novita.ai
   localhost
   ```

### Шаг 2: Настроить OAuth 2.0 в Google Cloud Console

1. Откройте **Google Cloud Console**: https://console.cloud.google.com/
2. Выберите проект: **eu-paintroom-paintroom**
3. Перейдите: **APIs & Services** → **Credentials**
4. Найдите OAuth 2.0 Client ID для Web
5. В разделе **Authorized JavaScript origins** добавьте:
   ```
   https://5060-ii603aqp2wsfigo4xqtrs-2e1b9533.sandbox.novita.ai
   https://sandbox.novita.ai
   http://localhost:5060
   ```
6. В разделе **Authorized redirect URIs** добавьте:
   ```
   https://5060-ii603aqp2wsfigo4xqtrs-2e1b9533.sandbox.novita.ai/__/auth/handler
   https://eu-paintroom-paintroom.firebaseapp.com/__/auth/handler
   http://localhost:5060/__/auth/handler
   ```

### Шаг 3: Включить Google Sign In в Firebase

1. В **Firebase Console**
2. **Authentication** → **Sign-in method**
3. Включите **Google** провайдер
4. Сохраните изменения

## 🔄 Альтернативное решение (Временное)

Если у вас нет доступа к Firebase Console, можно использовать **"Продолжить без входа"**:

1. Нажмите кнопку **"Продолжить без входа"**
2. Приложение будет работать с локальными данными
3. Авторизация через Google будет доступна после настройки Firebase

## 📱 Для Android APK

Google Sign In для Android **уже настроен правильно** и будет работать в APK файле:
- ✅ SHA-1 отпечаток зарегистрирован
- ✅ Package name: `eu.paintroom.paintroom`
- ✅ OAuth Client ID для Android настроен

## 🧪 Проверка работы

После настройки Firebase Console:
1. Откройте приложение в браузере
2. Перейдите на вкладку **Profile**
3. Нажмите **"Войти через Google"**
4. Должно открыться окно выбора Google аккаунта
5. После выбора — успешная авторизация

## 📝 Примечания

- **Web-версия** требует настройки в Firebase Console
- **Android APK** работает без дополнительных настроек
- Ошибка "Не удалось войти через Google" на Web — это нормально для sandbox окружения
- Для production деплоя нужно добавить ваш домен в Authorized domains

## 🔗 Полезные ссылки

- Firebase Console: https://console.firebase.google.com/project/eu-paintroom-paintroom
- Google Cloud Console: https://console.cloud.google.com/
- Firebase Auth Documentation: https://firebase.google.com/docs/auth/web/google-signin

---

**Обновлено:** 28 ноября 2025
