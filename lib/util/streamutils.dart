// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:collection';

import 'package:dailyanimelist/cache/book_marks.dart';
import 'package:dailyanimelist/cache/cachemanager.dart';
import 'package:dailyanimelist/cache/history_data.dart';
import 'package:dal_commons/dal_commons.dart';

enum StreamType {
  search_page,
  book_marks,
}

class StreamConfig<T> {
  final T data;
  final StreamController<T> streamController;
  StreamConfig({
    required this.data,
    required this.streamController,
  });
}

class StreamUtils {
  StreamUtils._();
  static StreamUtils i = StreamUtils._();
  Map<StreamType, StreamConfig>? _streamInternalMap;

  String key(StreamType type) => 'stream-utils-${type.name}-init-data';

  Future<T> _initData<T>(
    StreamType type,
    T Function(Map<String, dynamic>?) fromJson,
  ) async {
    return fromJson(
      await CacheManager.instance.getCachedContent(key(type)),
    );
  }

  void _setData(StreamType type) async {
    await CacheManager.instance
        .setCachedJson(key(type), _streamInternalMap?.tryAt(type)?.data);
  }

  Future<void> init() async {
    _streamInternalMap = HashMap<StreamType, StreamConfig>.from({
      StreamType.search_page: StreamConfig<HistoryData>(
        data: await _initData(StreamType.search_page, HistoryData.fromJson),
        streamController: StreamController<HistoryData>.broadcast(),
      ),
      StreamType.book_marks: StreamConfig<BookMarks>(
          data: await _initData(
              StreamType.book_marks, (json) => BookMarks.fromJson(json ?? {})),
          streamController: StreamController.broadcast()),
    });
  }

  T initalData<T>(StreamType type) {
    return _streamInternalMap?.tryAt(type)?.data;
  }

  Stream<T> getStream<T>(StreamType type) {
    return (_streamInternalMap?.tryAt(type)?.streamController.stream ??
        Stream<T>.empty()) as Stream<T>;
  }

  void addData<T>(StreamType type, T Function(T) onAdd) {
    final streamConfig = _streamInternalMap?.tryAt(type);
    final streamData = onAdd(streamConfig?.data);
    streamConfig?.streamController?.add(streamData);
    _setData(type);
  }

  void close() {
    _streamInternalMap?.values.forEach((sd) => sd?.streamController?.close());
  }
}

class StreamListener<T> {
  final T? _initialData;
  T? currentValue;
  final controller = StreamController<T>.broadcast();
  StreamListener([this._initialData]) {
    this.currentValue = this._initialData;
  }
  Stream<T> get stream {
    return controller.stream;
  }

  T? get initialData {
    return _initialData;
  }

  void update(T value) {
    currentValue = value;
    controller.add(value);
  }

  void dispose() {
    controller.close();
  }
}
