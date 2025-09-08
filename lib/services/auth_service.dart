import 'package:pardarsh_application/model/user.dart';
import 'package:pardarsh_application/services/api_serivces.dart';
import 'package:pardarsh_application/utils/secure_storgae.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<UserModel> login(String email, String password) async {
    final data = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final token = data['token'];
    await SecureStorage.writeToken(token);

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> register(Map<String, dynamic> body) async {
    final data = await _api.post('/auth/register', body);
    final token = data['token'];
    await SecureStorage.writeToken(token);

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel?> getMe() async {
    final token = await SecureStorage.readToken();
    if (token == null) return null;

    final data = await _api.get('/auth/me', token: token);
    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
  }
}
