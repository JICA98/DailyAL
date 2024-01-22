export 'package:dal_api/dal_local_api.dart';
export 'package:dal_api/handlers/environemt.dart';
import 'package:shelf/shelf.dart';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'handlers/handler_core.dart';

class DalLocalApi {
  DalLocalApi._();
  static final i = DalLocalApi._();
  Future<void> runApp() async {
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(HandlerCore().handleRequest);

    final server = await shelf_io.serve(handler, '0.0.0.0', 8080);

    print('Serving at http://${server.address.host}:${server.port}');
  }
}
