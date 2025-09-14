import 'package:app4_receitas/data/models/recipe.dart';
import 'package:app4_receitas/data/repositories/auth_repository.dart';
import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:get/get.dart';

class FavoriteRecipesViewModel extends GetxController {
  final _repository = getIt<RecipeRepository>();
  final _authRepository = getIt<AuthRepository>();

  final RxList<Recipe> _favoriteRecipes = <Recipe>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Recipe> get recipes => _favoriteRecipes;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  Future<void> getFavoriteRecipes() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      var userId = '';
      final currentUserResult = await _authRepository.currentUser;
      currentUserResult.fold(
        ifLeft: (left) => _errorMessage.value = left.message,
        ifRight: (right) => userId = right.id,
      );

      _favoriteRecipes.value = await _repository.getFavoriteRecipes(userId);
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
