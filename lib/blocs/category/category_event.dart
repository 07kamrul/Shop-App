part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String? userId;

  const LoadCategories({this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddCategory extends CategoryEvent {
  final Map<String, dynamic> category;

  const AddCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final Map<String, dynamic> category;

  const UpdateCategory({required this.category});

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;

  const DeleteCategory({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}
