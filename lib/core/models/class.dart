class Class {
  final String id;
  final String name;

  Class({required this.id, required this.name});
  const Class.empty() : id = '', name = '';
  const Class.init({required this.id, required this.name});
}
