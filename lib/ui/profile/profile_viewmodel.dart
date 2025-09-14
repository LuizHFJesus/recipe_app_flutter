import 'package:app4_receitas/data/models/user_profile.dart';
import 'package:app4_receitas/data/repositories/auth_repository.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:get/get.dart';

class ProfileViewModel extends GetxController {
  final _repository = getIt<AuthRepository>();

  final _profile = Rxn<UserProfile>();
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  UserProfile? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  Future<void> getCurrentUser() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await _repository.currentUser;
    result.fold(
      ifLeft: (left) => _errorMessage.value = left.message,
      ifRight: (right) => _profile.value = right,
    );

    _isLoading.value = false;
  }

  Future<void> signOut() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    final result = await _repository.signOut();
    result.fold(
      ifLeft: (left) => _errorMessage.value = left.message,
      ifRight: (right) => null,
    );
    _isLoading.value = false;
  }
}