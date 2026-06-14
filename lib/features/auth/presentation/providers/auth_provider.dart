import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';

class AuthState {
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({this.token, this.isLoading = false, this.error});

  AuthState copyWith({String? token, bool? isLoading, String? error}) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(token: ApiClient.isConfigured ? ApiClient.authToken : null));

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded['data'] as Map<String, dynamic>;
        final session = data['session'] as Map<String, dynamic>;
        final token = session['access_token'] as String;

        ApiClient.dynamicToken = token;
        state = AuthState(token: token);
        return true;
      } else {
        final err = decoded['error'] as Map<String, dynamic>?;
        final msg = err?['message'] as String? ?? 'Login failed';
        state = AuthState(error: msg);
        return false;
      }
    } catch (e) {
      state = AuthState(error: e.toString());
      return false;
    }
  }

  void logout() {
    ApiClient.dynamicToken = null;
    state = AuthState(token: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
