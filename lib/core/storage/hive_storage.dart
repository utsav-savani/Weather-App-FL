import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '/core/errors/exceptions.dart';

abstract class HiveStorage {
  Future<void> init();
  Future<void> put(String key, dynamic value);
  Future<dynamic> get(String key);
  Future<bool> has(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class HiveStorageImpl implements HiveStorage {
  static const String _boxName = 'weather_app_box';
  late Box _box;

  @override
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Hive storage: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> put(String key, dynamic value) async {
    try {
      if (value is Map || value is List) {
        // First serialize to JSON string to ensure consistency
        final jsonString = jsonEncode(value);
        await _box.put(key, jsonString);
      } else {
        await _box.put(key, value);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to save data: ${e.toString()}');
    }
  }

  @override
  Future<dynamic> get(String key) async {
    try {
      final value = _box.get(key);
      if (value == null) return null;

      if (value is String) {
        try {
          if ((value.startsWith('{') && value.endsWith('}')) ||
              (value.startsWith('[') && value.endsWith(']'))) {
            return jsonDecode(value);
          }
        } catch (_) {}
      }

      return value;
    } catch (e) {
      throw CacheException(message: 'Failed to get data: ${e.toString()}');
    }
  }

  @override
  Future<bool> has(String key) async {
    try {
      return _box.containsKey(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to check if key exists: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _box.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete data: ${e.toString()}');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear storage: ${e.toString()}');
    }
  }
}
