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

  Future<int> getCacheSize() async {
    if (!_isInitialised || _cacheDirectoryPath == null) {
      throw Exception('getCacheSize(): Cache store not initialized. Call initialize() first.');
    }

    try {
      final cacheDirectory = Directory(_cacheDirectoryPath!);

      if (!await cacheDirectory.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in cacheDirectory.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      throw Exception('Failed to get cache size: $e');
    }
  }

  Future<String> getCacheSizeFormatted() async {
    final sizeInBytes = await getCacheSize();

    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }


  Future<int> getCachedTilesCount() async {
    if (!_isInitialised || _cacheDirectoryPath == null) {
      throw Exception('getCacheTilesCount(): Cache store not initialized. Call initialize() first.');
    }

    try {
      final cacheDirectory = Directory(_cacheDirectoryPath!);

      if (!await cacheDirectory.exists()) {
        return 0;
      }

      int fileCount = 0;
      await for (final entity in cacheDirectory.list(recursive: true)) {
        if (entity is File) {
          fileCount++;
        }
      }

      return fileCount;
    } catch (e) {
      throw Exception('Failed to get cached tiles count: $e');
    }
  }

  void dispose() {
    _isInitialised = false;
  }
}

