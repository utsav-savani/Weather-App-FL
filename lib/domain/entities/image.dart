import 'package:equatable/equatable.dart';

class ImageEntity extends Equatable {
  final String url;

  const ImageEntity({required this.url});

  @override
  // TODO: implement props
  List<Object?> get props => [url];
}
