import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../../domain/usecases/get_onboarding_pages_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingPagesUseCase getOnboardingPagesUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingBloc({
    required this.getOnboardingPagesUseCase,
    required this.completeOnboardingUseCase,
  }) : super(OnboardingInitial()) {
    on<LoadOnboardingPages>(_onLoadOnboardingPages);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<PageChanged>(_onPageChanged);
  }

  Future<void> _onLoadOnboardingPages(
    LoadOnboardingPages event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingLoading());

    final result = await getOnboardingPagesUseCase();

    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (pages) => emit(OnboardingPagesLoaded(pages, currentPage: 0)),
    );
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(OnboardingCompleting());

    final result = await completeOnboardingUseCase();

    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (_) => emit(OnboardingCompleted()),
    );
  }

  void _onPageChanged(
    PageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingPagesLoaded) {
      final currentState = state as OnboardingPagesLoaded;
      emit(OnboardingPagesLoaded(
        currentState.pages,
        currentPage: event.pageIndex,
      ));
    }
  }
}

