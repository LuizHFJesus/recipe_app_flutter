import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:dart_either/dart_either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = getIt<SupabaseClient>();

  User? get currentUser => _supabaseClient.auth.currentUser;

  Stream<AuthState> get authStateChange =>
      _supabaseClient.auth.onAuthStateChange;

  Future<Either<AppError, AuthResponse>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Invalid login credentials':
          return Left(
            AppError('Usuário não cadastro ou credenciais inválidas'),
          );
        case 'Email not confirmed':
          return Left(AppError('E-mail não confirmado'));
        default:
          return Left(AppError('Erro ao fazer login', e));
      }
    }
  }

  Future<Either<AppError, Map<String, dynamic>?>> fetchUserProfile(
    String userId,
  ) async {
    try {
      final profile = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return Right(profile);
    } catch (e) {
      return Left(AppError('Erro ao carregar profile'));
    }
  }

  Future<Either<AppError, AuthResponse>> signUp({
    required String email,
    required String password,
    required String username,
    required String avatarUrl,
  }) async {
    try {
      final existingUsername = await _supabaseClient
          .from('profiles')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (existingUsername != null) {
        return Left(AppError('Nome de usuário já existe'));
      }

      final result = await _insertUser(email: email, password: password);
      return result.fold(
        ifLeft: (left) => Left(left),
        ifRight: (right) async {
          await _supabaseClient.from('profiles').insert({
            'id': right.user!.id,
            'username': username,
            'avatar_url': avatarUrl,
          });
          return Right(right);
        },
      );
    } on PostgrestException catch (e) {
      switch (e.message) {
        case '23505':
          return Left(AppError('E-mail já cadastrado'));
        default:
          return Left(AppError('Erro ao cadastrar usuário', e));
      }
    } catch (e) {
      return Left(AppError('Erro inesperado ao cadastrar usuário', e));
    }
  }

  Future<Either<AppError, void>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return Right(null);
    } on AuthException catch (e) {
      return Left(AppError('Erro ao sair', e));
    } catch (e) {
      return Left(AppError('Erro inesperado ao sair', e));
    }
  }

  Future<Either<AppError, AuthResponse>> _insertUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Email not confirmed':
          return Left(
            AppError('E-mail não confirmado. Verifique sua caixa de entrada'),
          );
        case 'Email already registered':
          return Left(AppError('E-mail já cadastrado'));
        default:
          return Left(AppError('Erro ao cadastrar usuário', e));
      }
    }
  }
}
