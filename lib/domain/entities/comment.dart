import 'package:assessmentfounder/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String content;
  final User sender;

  CommentEntity({required this.content, required this.sender});

  @override
  // TODO: implement props
  List<Object?> get props => [content, sender];
}
