part of 'category_bloc.dart';

@immutable
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoriesLoadInProgress extends CategoryState {}

class CategoriesLoadSuccess extends CategoryState {
  final List<dynamic> categories;

  const CategoriesLoadSuccess({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class CategoriesLoadFailure extends CategoryState {
  final String error;

  const CategoriesLoadFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class CategoryOperationInProgress extends CategoryState {}

class CategoryOperationSuccess extends CategoryState {}

class CategoryOperationFailure extends CategoryState {
  final String error;

  const CategoryOperationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}