class Meat {
  Meat({
    required this.id,
    required this.name,
    required this.kind,
    required this.state,
  });

  Meat.fromMap(Map<String, dynamic> paramMap)
      : id = paramMap['id'] as int,
        kind = paramMap['kind'] as String,
        name = paramMap['name'] as String,
        state = paramMap['state'] as int;

  final int id;
  final String name;
  final String kind;
  final int state;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'name': name,
        'kind': kind,
        'state': state,
      };

  Map<String, dynamic> toMapExceptId() {
    final cloneMap = <String, dynamic>{...toMap()}..remove('id');
    return cloneMap;
  }
}
