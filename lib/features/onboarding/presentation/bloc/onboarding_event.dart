part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class LoadOnboardingPages extends OnboardingEvent {
  const LoadOnboardingPages();
}

class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

class PageChanged extends OnboardingEvent {
  final int pageIndex;

  const PageChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

