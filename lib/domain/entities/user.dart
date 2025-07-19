import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String userName;
  final String nick;
  final String avatar;

  User({required this.userName, required this.nick, required this.avatar});

  @override
  // TODO: implement props
  List<Object?> get props => [userName, nick, avatar];
}
