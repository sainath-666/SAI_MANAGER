import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';

const _tokenKey = 'auth_token';

class AuthState {
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.token,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    if (savedToken != null && savedToken.isNotEmpty) {
      ApiClient.dynamicToken = savedToken;
      state = AuthState(token: savedToken, isInitialized: true);
    } else {
      state = const AuthState(isInitialized: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AuthState(isLoading: true, isInitialized: true);
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

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        ApiClient.dynamicToken = token;
        state = AuthState(token: token, isInitialized: true);
        return true;
      } else {
        final err = decoded['error'] as Map<String, dynamic>?;
        final msg = err?['message'] as String? ?? 'Login failed. Check your credentials.';
        state = AuthState(error: msg, isInitialized: true);
        return false;
      }
    } catch (e) {
      state = AuthState(
        error: 'Cannot reach server. Check your connection.',
        isInitialized: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    ApiClient.dynamicToken = null;
    state = const AuthState(isInitialized: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider.select((s) => s.isAuthenticated));
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return null;
  try {
    final data = await ApiClient().get('/users/me');
    return data['profile'] as Map<String, dynamic>?;
  } catch (_) {
    return null;
  }
});
