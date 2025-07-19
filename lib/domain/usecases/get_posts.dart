import 'package:assessmentfounder/core/error/failures.dart';
import 'package:assessmentfounder/domain/repositories/post_repository.dart';
import 'package:dartz/dartz.dart';

import '../entities/post.dart';

class GetPost {
  final PostRepository repository;

  GetPost(this.repository);

  Future<Either<Failure, List<Post>>> call() async {
    return await repository.getPosts();
  }
}
