import 'package:assessmentfounder/data/models/user_model.dart';
import 'package:assessmentfounder/domain/entities/comment.dart';

class CommentModel extends CommentEntity {
  CommentModel({required super.content, required UserModel super.sender});

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    sender: UserModel.fromJson(json["sender"] as Map<String, dynamic>),
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "content": content,
    "sender": (sender as UserModel).toJson(),
  };
}
