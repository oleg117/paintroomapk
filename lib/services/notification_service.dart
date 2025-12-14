import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Инициализация уведомлений
  Future<void> initialize() async {
    if (_initialized) return;

    // Инициализация timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Berlin')); // Европейское время

    // Настройки для Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Настройки инициализации
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    print('✅ Notification tapped: ${response.payload}');
    // Здесь можно открыть нужный экран приложения
  }

  // Запланировать ежедневные уведомления
  Future<void> scheduleDailyReminder({
    int hour = 10, // 10:00 утра по умолчанию
    int minute = 0,
  }) async {
    await initialize();

    // Проверяем, включены ли уведомления
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    
    if (!enabled) return;

    // Детали уведомления для Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_reminder',
      'Ежедневные напоминания',
      channelDescription: 'Напоминания о расчёте стоимости работ',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // Время первого уведомления (сегодня в указанное время или завтра)
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Если время уже прошло сегодня, планируем на завтра
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Массив мотивирующих сообщений
    final messages = [
      '🏗️ Пора рассчитать стоимость работ!',
      '📊 Не забудьте проверить цены на строительные работы',
      '💰 Время планировать бюджет строительства',
      '🔨 Готовы рассчитать стоимость ремонта?',
      '📐 Новый день - новый расчёт стоимости!',
      '🎯 Посчитайте стоимость работ сегодня',
      '⚡ Быстрый расчёт строительных работ ждёт вас!',
    ];

    // Планируем уведомление с повтором каждый день
    await _notifications.zonedSchedule(
      0, // ID уведомления
      'Paintroom - Калькулятор строительных работ',
      messages[DateTime.now().day % messages.length], // Разные сообщения каждый день
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Повторять каждый день
    );

    print('✅ Daily reminder scheduled at $hour:$minute');
  }

  // Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('✅ All notifications cancelled');
  }

  // Показать немедленное уведомление (для тестирования)
  Future<void> showInstantNotification() async {
    await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'instant_notification',
      'Мгновенные уведомления',
      channelDescription: 'Уведомления для тестирования',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1, // ID
      'Paintroom - Тестовое уведомление',
      '🏗️ Пора рассчитать стоимость работ!',
      notificationDetails,
    );

    print('✅ Instant notification shown');
  }

  // Включить/выключить уведомления
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      // Планируем уведомления
      await scheduleDailyReminder();
    } else {
      // Отменяем все уведомления
      await cancelAllNotifications();
    }
  }

  // Проверить, включены ли уведомления
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  // Установить время уведомлений
  Future<void> setNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', hour);
    await prefs.setInt('notification_minute', minute);

    // Перепланируем уведомление с новым временем
    await cancelAllNotifications();
    await scheduleDailyReminder(hour: hour, minute: minute);
  }

  // Получить время уведомлений
  Future<Map<String, int>> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt('notification_hour') ?? 10,
      'minute': prefs.getInt('notification_minute') ?? 0,
    };
  }
}
