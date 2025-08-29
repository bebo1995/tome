abstract class Jsonable {
  final String key;
  const Jsonable({required this.key});

  Map<String, String> toJson();
}