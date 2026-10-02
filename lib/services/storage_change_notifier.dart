import 'dart:async';

/// Lightweight singleton that broadcasts storage-mutation events.
///
/// Any service that writes to local storage calls [notify] after the write
/// completes.  UI screens (e.g. HomeContent) subscribe to [changes] and
/// automatically reload their data.
class StorageChangeNotifier {
  StorageChangeNotifier._();
  static final StorageChangeNotifier instance = StorageChangeNotifier._();

  final _controller = StreamController<StorageChangeEvent>.broadcast();

  /// A broadcast stream of change events.
  Stream<StorageChangeEvent> get changes => _controller.stream;

  /// Call after any local-storage mutation.
  void notify([StorageChangeType type = StorageChangeType.any]) {
    _controller.add(StorageChangeEvent(type));
  }
}

enum StorageChangeType { course, task, topic, any }

class StorageChangeEvent {
  final StorageChangeType type;
  final DateTime timestamp;

  StorageChangeEvent(this.type) : timestamp = DateTime.now();
}
