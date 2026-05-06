import '../../models/room_model.dart';

class DetailRuanganController {
  final RoomModel room;

  const DetailRuanganController({required this.room});

  String get title => room.name;
  String get description => room.description;
  int get capacity => room.capacity;
  List<String> get availableItems => room.availableItems;
  String get imagePath => room.imagePath;
}
