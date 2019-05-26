import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:needoff/api/gql.dart' as gql;

Future fetchProfile() async {
  QueryResult res = await gql.rawQuery('''
query MyProfile{
  profile{ 
    firstName,
    lastName,
    email,
    position,
    phone
  }
}
''');
  return res;
}
