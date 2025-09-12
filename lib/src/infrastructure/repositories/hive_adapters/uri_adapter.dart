import 'package:hive_ce/hive.dart';

class UriAdapter extends TypeAdapter<Uri> {
  @override
  final int typeId = 2;

  @override
  Uri read(BinaryReader reader) {
    final s = reader.readString();
    return Uri.parse(s);
  }

  @override
  void write(BinaryWriter writer, Uri obj) {
    writer.writeString(obj.toString());
  }
}
