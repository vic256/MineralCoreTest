import 'package:mineral/core/extras.dart';
import 'package:mineral/framework.dart';
import 'package:mineral/src/internal/services/debugger.dart';

class AlreadyExistException with Container, Console implements Exception {
  final String message;

  AlreadyExistException(this.message) {
    container.use<Debugger>()
      .debug(message);
  }

  @override
  String toString () => message;
}
