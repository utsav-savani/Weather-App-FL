import 'package:assessmentfounder/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getPosts();
}
