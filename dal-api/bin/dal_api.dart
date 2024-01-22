// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:dal_api/handlers/environemt.dart';
import 'package:dal_api/handlers/handler_core.dart';
import 'package:dal_commons/commons.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  if (Environment.i.isLambda) {
    Runtime()
      ..registerEvent<RequestPaylodEvent>(RequestPaylodEvent.fromJson)
      ..registerHandler<RequestPaylodEvent>(
          "hello.handler", HandlerCore().handleLambdaEvent)
      ..invoke();
  } else {
    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(HandlerCore().handleRequest);

    final server = await shelf_io.serve(handler, '0.0.0.0', 8080);

    print('Serving at http://${server.address.host}:${server.port}');
  }
}
