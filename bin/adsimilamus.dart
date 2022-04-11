import 'dart:io';

import 'package:args/args.dart';
import 'package:dsb_server/dsb_server.dart';
import 'package:dsb/dsb.dart';
import 'package:shelf/shelf_io.dart';

String af(String authid) => authid.replaceFirst(RegExp('-.+'), '…');

void main(List<String> arguments) {
  final args = (ArgParser()
        ..addOption('backend', abbr: 'b', defaultsTo: Session.defaultEndpoint)
        ..addOption('port', abbr: 'p', defaultsTo: '80'))
      .parse(arguments);
  final backend = args['backend'];
  serve(
      dsbHandler(
          generateAuthid: (user, pass, bundleid, appversion, osversion) async {
            final authid =
                (await Session.login(user, pass, endpoint: backend)).token;
            print(
                'AUTH: $user $bundleid $appversion $osversion → ${af(authid)}');
            return authid;
          },
          getContent: (path, authid) async {
            final json = Session(authid, endpoint: backend).getJsonString(path);
            print('GET: ${af(authid)} $path');
            return json;
          },
          customHeaders: {'Access-Control-Allow-Origin': '*'}),
      InternetAddress.anyIPv6,
      int.parse(args['port']));
}
