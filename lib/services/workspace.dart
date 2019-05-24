import 'package:needoff/api/gql.dart' as gql;

createWorkspace(String name, String desciption, List members) {
  String membersStr = '[${members.map((m) => '"$m"').toList().join(',')}]';
  print(membersStr);
  var res = gql.rawMutation('''
mutation CreateWS {
  createWorkspace(name: "$name", description: "$desciption", members: $membersStr) {
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