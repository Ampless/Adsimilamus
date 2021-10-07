import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dsb_server/dsb_server.dart';
import 'package:dsbuntis/dsbuntis.dart';
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
          getContent: (endpoint, authid) async {
            if (endpoint == 'dsbtimetables') {
              final ttjson =
                  await Session(authid, endpoint: backend).getTimetableJson();
              print('GET: ${af(authid)} $endpoint');
              return json.encode(ttjson);
            }
          },
          customHeaders: {'Access-Control-Allow-Origin': '*'}),
      InternetAddress.anyIPv6,
      int.parse(args['port']));
}
