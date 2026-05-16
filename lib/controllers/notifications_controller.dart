import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsController extends ChangeNotifier {
  static NotificationsController? _instance;
  static NotificationsController get instance {
    _instance ??= NotificationsController._internal();
    return _instance!;
  }

  NotificationsController._internal() {
    _loadFromStorage();
  }

  final List<NotificationModel> _items = [];
  Timer? _repeatTimer;

  List<NotificationModel> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((n) => !n.read).length;

  Future<void> _loadFromStorage() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('local_notifications') ?? '[]';
    final list = jsonDecode(raw) as List<dynamic>;
    _items.clear();
    _items.addAll(list
        .map((m) => NotificationModel.fromMap(Map<String, dynamic>.from(m))));
    notifyListeners();
  }

  Future<void> saveToStorage() async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toMap()).toList());
    await sp.setString('local_notifications', raw);
  }

  Future<void> addNotification(NotificationModel n,
      {bool showSystem = true}) async {
    _items.insert(0, n);
    await saveToStorage();
    notifyListeners();

    if (showSystem) {
      await NotificationService().showNotification(n.hashCode, n.title, n.body);
    }
  }

  Future<void> markAllRead() async {
    for (var i in _items) i.read = true;
    await saveToStorage();
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _items[idx].read = true;
    await saveToStorage();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _items.clear();
    await saveToStorage();
    notifyListeners();
  }

  /// Start repeating local notifications every [minutes] minutes.
  Future<void> startRepeatingPendingReminder(
      {int minutes = 5, required String title, required String body}) async {
    stopRepeating();
    _repeatTimer = Timer.periodic(Duration(minutes: minutes), (_) async {
      final n = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          body: body,
          timestamp: DateTime.now());
      await addNotification(n, showSystem: true);
    });

    await NotificationService().scheduleBackgroundReminder(
      title: title,
      body: body,
      frequency: const Duration(minutes: 15),
    );
  }

  Future<void> stopRepeating() async {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    await NotificationService().cancelBackgroundReminder();
  }
}
