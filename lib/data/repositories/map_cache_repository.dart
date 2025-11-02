import 'dart:io';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MapCacheRepository {
  FileCacheStore? _cacheStore;
  String? _cacheDirectoryPath;
  bool _isInitialised = false;

  Future<void> initialize() async {
    if (_isInitialised) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _cacheDirectoryPath = path.join(directory.path, 'map_cache');
      final cacheDirectory = Directory(_cacheDirectoryPath!);

      if (!await cacheDirectory.exists()) {
        await cacheDirectory.create(recursive: true);
      }

      _cacheStore = FileCacheStore(_cacheDirectoryPath!);

      _isInitialised = true;
    } catch (e) {
      throw Exception('Failed to initialize map cache: $e');
    }
  }

  FileCacheStore get cacheStore {
    if (!_isInitialised || _cacheStore == null) {
      throw Exception('cacheStore(): Cache store not initialized. Call initialize() first.');
    }
    return _cacheStore!;
  }

  bool get isInitialized => _isInitialised;

  Future<void> clearCache() async {
    if (!_isInitialised || _cacheDirectoryPath == null) {
      throw Exception('clearCache(): Cache store not initialized. Call initialize() first.');
    }

    try {
      final cacheDirectory = Directory(_cacheDirectoryPath!);
      if (await cacheDirectory.exists()) {
        await for (final entity in cacheDirectory.list()) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  void dispose() {
    _isInitialised = false;
  }
}
