import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/data/services/recipe_service.dart';
import 'package:app4_receitas/ui/recipes/recipes_viewmodel.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

Future<void> injectDependencies() async {
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  getIt.registerLazySingleton<RecipeService>(() => RecipeService());
  getIt.registerLazySingleton<RecipeRepository>(() => RecipeRepository());
  getIt.registerLazySingleton<RecipesViewModel>(() => RecipesViewModel());
}