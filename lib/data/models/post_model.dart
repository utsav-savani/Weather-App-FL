import 'package:assessmentfounder/data/models/comment_model.dart';
import 'package:assessmentfounder/data/models/image_model.dart';
import 'package:assessmentfounder/data/models/user_model.dart';
import 'package:assessmentfounder/domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required UserModel sender,
    String? content,
    List<ImageModel> images = const [],
    List<CommentModel> comments = const [],
    String? error,
  }) : super(
         content: content,
         sender: sender,
         comments: comments,
         error: error,
         images: images,
       );

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel()
}
