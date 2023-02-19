class UserData {
  static final UserData _userData = UserData._internal();

  UserData._internal();

  factory UserData() {
    return _userData;
  }

  String? _id;
  String? _email;
  String? _phone;
  String? _fullName;

  get id => _id;
  set id(id) => _id = id;

  get email => _email;
  set email(email) => _email = email;

  get phone => _phone;
  set phone(phone) => _phone = phone;

  get fullName => _fullName;
  set fullName(fullName) => _fullName = fullName;
}
