abstract class Failure {
  final String errorMsg;

  Failure({this.errorMsg = ""});
}

class ServerFailure extends Failure {
  ServerFailure({super.errorMsg = "Server Error"});
}

class NetworkFailure extends Failure {
  NetworkFailure({super.errorMsg = "Network Error"});
}
