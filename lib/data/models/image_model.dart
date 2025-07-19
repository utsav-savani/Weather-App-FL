import 'package:assessmentfounder/domain/entities/image.dart';

class ImageModel extends ImageEntity {
  ImageModel({required super.url});

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      ImageModel(url: json["url"] ?? '');

  Map<String, dynamic> toJson() => {"url": url};
}
