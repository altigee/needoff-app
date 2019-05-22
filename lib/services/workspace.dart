import 'package:needoff/api/gql.dart' as gql;

createWorkspace(String name, String desciption) {
  var res = gql.rawMutation('''
mutation CreateWS {
  createWorkspace(name: "$name", description: "$desciption") {
    ok,
    ws {
      id,
      name,
      description
    }
  }
}
  ''');

  return res;
}