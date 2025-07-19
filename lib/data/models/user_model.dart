import 'package:assessmentfounder/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String username,
    required String nick,
    required String avatar,
  }) : super(userName: username, nick: nick, avatar: avatar);

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    username: json["username"],
    nick: json["nick"],
    avatar: json["avatar"],
  );

  Map<String, dynamic> toJson() => {
    "username": userName,
    "nick": nick,
    "avatar": avatar,
  };
}
