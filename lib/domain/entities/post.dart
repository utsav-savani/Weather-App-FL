import 'package:assessmentfounder/domain/entities/comment.dart';
import 'package:assessmentfounder/domain/entities/image.dart';
import 'package:assessmentfounder/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String? content;
  final List<ImageEntity> images;
  final User sender;
  final List<CommentEntity> comments;
  final String? error;

  const Post({
    this.content,
    this.images = const [],
    required this.sender,
    this.comments = const [],
    this.error,
  });

  bool get hasError => error != null;
  @override
  // TODO: implement props
  List<Object?> get props => [content, images, sender, comments, error];
}
