import 'package:app4_receitas/data/models/recipe.dart';
import 'package:app4_receitas/data/repositories/auth_repository.dart';
import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:get/get.dart';

class RecipeDetailViewModel extends GetxController {
  final _repository = getIt<RecipeRepository>();
  final _authRepository = getIt<AuthRepository>();

  final Rxn<Recipe> _recipe = Rxn<Recipe>();

  Recipe? get recipe => _recipe.value;

  final RxBool _isFavorite = false.obs;

  bool get isFavorite => _isFavorite.value;

  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  final RxString _errorMessage = ''.obs;

  String? get errorMessage => _errorMessage.value;

  Future<void> loadRecipe(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _recipe.value = await _repository.getRecipeById(id);
      var userId = '';
      final currentUserResult = await _authRepository.currentUser;
      currentUserResult.fold(
        ifLeft: (left) => _errorMessage.value = left.message,
        ifRight: (right) => userId = right.id,
      );
      _isFavorite.value = await isRecipeFavorite(id, userId);
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> isRecipeFavorite(String recipeId, String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final favoriteRecipes = await _repository.getFavoriteRecipes(userId);
      return favoriteRecipes.any((recipe) => recipe.id == recipeId);
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    var userId = '';
    final currentUserResult = await _authRepository.currentUser;
    currentUserResult.fold(
      ifLeft: (left) => _errorMessage.value = left.message,
      ifRight: (right) => userId = right.id,
    );

    final recipeId = recipe!.id;

    if (_isFavorite.value) {
      await removeFromFavorites(recipeId, userId);
    } else {
      await addToFavorites(recipeId, userId);
    }
  }

  Future<void> addToFavorites(String recipeId, String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      await _repository.insertFavoriteRecipe(recipeId, userId);
      _isFavorite.value = true;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> removeFromFavorites(String recipeId, String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      await _repository.deleteFavoriteRecipe(recipeId, userId);
      _isFavorite.value = false;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
