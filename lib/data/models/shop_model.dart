import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String id;
  final String name;
  final int bgColor;
  final int nameColor;
  final List<String> categoryIds;

  const Shop({
    required this.id,
    required this.name,
    required this.bgColor,
    required this.nameColor,
    required this.categoryIds,
  });

  @override
  List<Object?> get props => [
    id, 
    name, 
    bgColor, 
    nameColor, 
    categoryIds];
}
