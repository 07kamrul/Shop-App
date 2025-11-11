import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/category_service.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  void _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoriesLoadInProgress());
    try {
      final categories = await CategoryService.getCategories();
      emit(CategoriesLoadSuccess(categories: categories));
    } catch (e) {
      emit(CategoriesLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await CategoryService.createCategory(
        name: event.category['name'],
        parentCategoryId: event.category['parentCategoryId'],
        description: event.category['description'],
        profitMarginTarget: event.category['profitMarginTarget'],
      );

      // Reload categories after adding
      add(LoadCategories(userId: event.category['userId']));
    } catch (e) {
      emit(CategoryOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await CategoryService.updateCategory(
        id: event.category['id'],
        name: event.category['name'],
        parentCategoryId: event.category['parentCategoryId'],
        description: event.category['description'],
        profitMarginTarget: event.category['profitMarginTarget'],
      );

      // Reload categories after updating
      add(LoadCategories(userId: event.category['userId']));
    } catch (e) {
      emit(CategoryOperationFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await CategoryService.deleteCategory(event.categoryId);
      // Reload categories after deletion
      // You might need to pass userId here if you have it available
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryOperationFailure(error: e.toString()));
    }
  }
}
