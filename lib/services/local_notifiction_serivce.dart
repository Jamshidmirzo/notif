import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzl;

class LocalNotifictionSerivce {
  static final _localNotifcation = FlutterLocalNotificationsPlugin();
  static bool notificationEnabled = false;

  static Future<void> requestPermission() async {
    if (Platform.isIOS || Platform.isMacOS) {
      notificationEnabled = await _localNotifcation
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
      await _localNotifcation
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final androidImplements =
          _localNotifcation.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? grantedNotficationsPermissions =
          await androidImplements?.requestNotificationsPermission();
      final bool? grantedScheduleNotficationsPermissions =
          await androidImplements?.requestExactAlarmsPermission();

      notificationEnabled = grantedNotficationsPermissions ?? false;
      notificationEnabled = grantedScheduleNotficationsPermissions ?? false;
    }
  }

  static Future<void> start() async {
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();

    tzl.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation(currentTimeZone),
    );
    const androidInit = AndroidInitializationSettings("image");
    final iosInit = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              'id_3',
              'Action 3',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ],
    );
    final notificationInit =
        InitializationSettings(android: androidInit, iOS: iosInit);
    await _localNotifcation.initialize(notificationInit);
  }

  static void showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      actions: [
        AndroidNotificationAction(
          'id_1',
          'Action1',
        ),
        AndroidNotificationAction(
          'id_2',
          'Action2',
        ),
        AndroidNotificationAction(
          'id_3',
          'Action3',
        ),
      ],
    );

    const iosDetails =
        DarwinNotificationDetails(categoryIdentifier: 'demoCategory');

    const notificationDetails = NotificationDetails(
      iOS: iosDetails,
      android: androidDetails,
    );
    await _localNotifcation.show(
        0,
        'Birinchi Notification',
        'Salom sizga\$100000 pul tushdi,Sms kodni ayting!',
        notificationDetails);
  }

  static void scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime taskDueTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      "GoodChannelId",
      "GoodChannelName",
      sound: RawResourceAndroidNotificationSound("slow_spring_board"),
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      sound: "slow_spring_board.aiff",
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Ensure the scheduled time is in the future
    final now = DateTime.now();
    final scheduledTime = tz.TZDateTime.from(taskDueTime, tz.local)
        .subtract(Duration(minutes: 5));
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      // If the scheduled time is in the past, adjust it to a future time
      // For example, you might want to schedule it for the next day at the same time
      final adjustedScheduledTime = scheduledTime.add(Duration(days: 1));
      await _localNotifcation.zonedSchedule(
        id,
        title,
        body,
        adjustedScheduledTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _localNotifcation.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    }
  }

  static void periodicallyShowNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      "GoodChannelId",
      "GoodChannelName",
      sound: RawResourceAndroidNotificationSound("slow_spring_board"),
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      sound: "slow_spring_board.aiff",
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifcation.periodicallyShowWithDuration(
      id,
      title,
      body,
      const Duration(seconds: 60),
      notificationDetails,
      payload: "Hello World",
    );
  }

  static Future<NotificationDetails> _groupedNotificationDetails() async {
    const List<String> lines = <String>[
      'Team 1 Play Badminton',
      'Team 1   Play Volleyball',
      'Team 1   Play Cricket',
      'Team 2 Play Badminton',
      'Team 2   Play Volleyball'
    ];
    const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '5 messages',
      summaryText: 'missed messages',
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'channel id',
      'channel name',
      sound: RawResourceAndroidNotificationSound("slow_spring_board"),
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      setAsGroupSummary: true,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      styleInformation: inboxStyleInformation,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(threadIdentifier: "thread2");

    final details = await _localNotifcation.getNotificationAppLaunchDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  static Future<void> showGroupedNotifications({
    required String title,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      "GoodChannelId",
      "GoodChannelName",
      sound: RawResourceAndroidNotificationSound("slow_spring_board"),
      importance: Importance.max,
    );
    const iosDetails = DarwinNotificationDetails(
      sound: "slow_spring_board.aiff",
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final groupedPlatformChannelSpecifics = await _groupedNotificationDetails();
    await _localNotifcation.show(
      0,
      "Team 1",
      "Play Badminton ",
      platformChannelSpecifics,
    );
    await _localNotifcation.show(
      1,
      "Team 1",
      "Play Volleyball",
      platformChannelSpecifics,
    );
    await _localNotifcation.show(
      3,
      "Team 1",
      "Play Cricket",
      platformChannelSpecifics,
    );
    await _localNotifcation.show(
      4,
      "Team 2",
      "Play Badminton",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await _localNotifcation.show(
      5,
      "Team 2",
      "Play Volleyball",
      Platform.isIOS
          ? groupedPlatformChannelSpecifics
          : platformChannelSpecifics,
    );
    await _localNotifcation.show(
      6,
      Platform.isIOS ? "Team 2" : "Attention",
      Platform.isIOS ? "Play Cricket" : "5 missed messages",
      groupedPlatformChannelSpecifics,
    );
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {
    print("on background tap");
  }
}
