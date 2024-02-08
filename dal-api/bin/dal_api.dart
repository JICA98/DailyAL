import 'package:dal_api/handlers/handler_core.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(HandlerCore().handleRequest);

  final server = await shelf_io.serve(handler, '0.0.0.0', 8080);

  print('Serving at http://${server.address.host}:${server.port}');
}
