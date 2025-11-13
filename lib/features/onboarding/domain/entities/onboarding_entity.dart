import 'package:equatable/equatable.dart';

class OnboardingEntity extends Equatable {
  final String title;
  final String description;
  final String imagePath;
  final String? iconPath;

  const OnboardingEntity({
    required this.title,
    required this.description,
    required this.imagePath,
    this.iconPath,
  });

  @override
  List<Object?> get props => [title, description, imagePath, iconPath];
}

