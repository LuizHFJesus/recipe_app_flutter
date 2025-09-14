import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/ui/recipe_detail/recipe_detail_viewmodel.dart';
import 'package:app4_receitas/ui/widgets/recipe_row_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeDetailView extends StatefulWidget {
  final String id;

  const RecipeDetailView({super.key, required this.id});

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  final viewModel = getIt<RecipeDetailViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.loadRecipe(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (viewModel.isLoading) {
        return Center(
          child: SizedBox(
            height: 96,
            width: 96,
            child: CircularProgressIndicator(strokeWidth: 12),
          ),
        );
      }

      if (viewModel.errorMessage! != '') {
        return Center(
          child: Container(
            padding: EdgeInsets.all(32),
            child: Column(
              spacing: 32,
              children: [
                Text(
                  'Erro: ${viewModel.errorMessage}',
                  style: TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.go('/');
                  },
                  child: Text('VOLTAR'),
                ),
              ],
            ),
          ),
        );
      }

      final recipe = viewModel.recipe!;

      return SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              recipe.image!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                  ? child
                  : Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
              errorBuilder: (context, child, stackTrace) => Container(
                height: 200,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.error),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  ListTile(
                    titleTextStyle: GoogleFonts.dancingScript(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                    title: Text(recipe.name, textAlign: TextAlign.center),
                    subtitleTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    subtitle: Text(
                      '${recipe.cuisine}',
                      textAlign: TextAlign.center,
                    ),
                  ),

                  RecipeRowDetails(recipe: recipe),

                  recipe.ingredients.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Ingredientes:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(recipe.ingredients.join('\n')),
                          ],
                        )
                      : Text('Nenhum ingrediente listado!'),

                  recipe.instructions.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Instruções:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(recipe.instructions.join('\n')),
                          ],
                        )
                      : Text('Nenhum instrução listada!'),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: Text('VOLTAR'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.toggleFavorite(),
                        child: Text(
                          viewModel.isFavorite ? 'DESFAVORITAR' : 'FAVORITAR',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
