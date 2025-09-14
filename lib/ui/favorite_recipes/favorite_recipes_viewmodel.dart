import 'package:app4_receitas/data/models/recipe.dart';
import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:get/get.dart';

class FavoriteRecipesViewModel extends GetxController {
  final _repository = getIt<RecipeRepository>();

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
      // TODO: Get the current user dynamically
      var userId = '0d9a3214-76ff-4779-a12e-6938d0a0231c';
      _favoriteRecipes.value = await _repository.getFavoriteRecipes(userId);
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
