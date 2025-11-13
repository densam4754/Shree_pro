part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingCompleting extends OnboardingState {}

class OnboardingPagesLoaded extends OnboardingState {
  final List<OnboardingEntity> pages;
  final int currentPage;

  const OnboardingPagesLoaded(this.pages, {this.currentPage = 0});

  @override
  List<Object> get props => [pages, currentPage];
}

class OnboardingCompleted extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object> get props => [message];
}

