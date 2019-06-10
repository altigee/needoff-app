import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/config.dart' show appConfig;
import 'package:needoff/api/storage.dart' as storage;

class GqlErrorNotifier extends ChangeNotifier {
  String type;
  GqlErrorNotifier(this.type) : super();
  notify(){
    notifyListeners();
  }
}

final invalidTokenNotifier = GqlErrorNotifier('invalid_token');

Future<GraphQLClient> getClient() async {
  String token = await storage.getToken();
  Link link = HttpLink(
      uri: appConfig.get('gqlUrl'),
      headers: {'Authorization': 'Bearer $token'}) as Link;
  return GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );
}

rawQuery(String query) async {
  var opts = QueryOptions(
    document: query,
  );
  try {
    QueryResult res = await (await getClient()).query(opts);
    if (res.hasErrors) {
      print('GQL >  Query res> has errors');
      _tryParseErrors(res.errors);
    }
    return res;
  } catch (e) {}
}

rawMutation(String mutation) async {
  try {
    QueryResult res =
        await (await getClient()).mutate(MutationOptions(document: mutation));
    if (res.hasErrors) {
      print('GQL > Mutation res > has errorr');
      _tryParseErrors(res.errors);
    }
    return res;
  } catch (e) {
    print(e);
  }
}

void _tryParseErrors(errors) {
  if (errors != null) {
    bool invalidTokenErrorFound = false;
    List.from(errors).forEach((err) {
      if (!invalidTokenErrorFound && (err as GraphQLError).message.contains('Invalid token')) {
        invalidTokenErrorFound = true;
        invalidTokenNotifier.notify();
      }
    });
  }
}