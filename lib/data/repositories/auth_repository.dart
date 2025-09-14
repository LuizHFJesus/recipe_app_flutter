import 'package:app4_receitas/data/models/user_profile.dart';
import 'package:app4_receitas/data/services/auth_service.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:dart_either/dart_either.dart';
import 'package:get/get.dart';

class AuthRepository extends GetxController {
  final _service = getIt<AuthService>();

  Future<Either<AppError, UserProfile>> get currentUser async {
    final user = _service.currentUser;
    final profile = await _service.fetchUserProfile(user!.id);
    return profile.fold(
      ifLeft: (left) => Left(left),
      ifRight: (right) {
        return Right(UserProfile.fromSupabase(user.toJson(), right!));
      },
    );
  }

  Future<Either<AppError, UserProfile>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _service.signInWithPassword(
      email: email,
      password: password,
    );

    return response.fold(
      ifLeft: (left) => Left(left),
      ifRight: (right) async {
        final user = right.user!;
        final profileResult = await _service.fetchUserProfile(user.id);
        return profileResult.fold(
          ifLeft: (left) => Left(left),
          ifRight: (right) {
            return Right(UserProfile.fromSupabase(user.toJson(), right!));
          },
        );
      },
    );
  }
}
