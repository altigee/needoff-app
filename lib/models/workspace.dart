class Workspace {
  var _id;
  String _name;
  String _description;
  List _members;
  Workspace(this._name, {String description: '', int id, List members})
      : this._description = description,
        this._id = id,
        this._members = members;
  get id => _id;
  String get name => _name;
  String get description => _description;
  List get members => _members ?? [];
}