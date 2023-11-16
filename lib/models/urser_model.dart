// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImage;
  final int feedCount;
  final List<String> followers;
  final List<String> following;
  final List<String> likes;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.feedCount,
    required this.followers,
    required this.following,
    required this.likes,
  });

  factory UserModel.init() {
    return UserModel(
      uid: '',
      name: '',
      email: '',
      profileImage: null,
      feedCount: 0,
      followers: [],
      following: [],
      likes: [],
    );
  }

//usermodle 이 가지고 있는 filed 변수로 가지고 있는 데이터들을 가지고 map 형태 데이터를 만들어 준다.
  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email': this.email,
      'profileImage': this.profileImage,
      'feedCount': this.feedCount,
      'followers': this.followers,
      'following': this.following,
      'likes': this.likes,
    };
  }

//map 형태 데이터를 인자값을 전달 받아 usermolde 객체를 만들어 준다.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profileImage: map['profileImage'],
      feedCount: map['feedCount'],
      followers: List<String>.from(map['followers']),
      following: List<String>.from(map['following']),
      likes: List<String>.from(map['likes']),
    );
  }
}
