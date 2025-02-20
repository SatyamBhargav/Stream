import 'package:equatable/equatable.dart';
import 'package:videostream/features/category/domain/entities/category_entity.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

final class CategoryInitial extends CategoryState {}

final class CategoryLoading extends CategoryState {}

final class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

final class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
