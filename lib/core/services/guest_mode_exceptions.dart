/// Exception thrown when guest mode limits are exceeded
class GuestModeLimitException implements Exception {
  final String message;
  final int currentCount;
  final int maxLimit;
  final String resourceType;

  GuestModeLimitException({
    required this.message,
    required this.currentCount,
    required this.maxLimit,
    required this.resourceType,
  });

  @override
  String toString() => message;
}

/// Exception for semester limit
class SemesterLimitException extends GuestModeLimitException {
  SemesterLimitException({
    required int currentCount,
    required int maxLimit,
  }) : super(
          message: 'Guest mode limit reached: You can only create up to $maxLimit semesters. Please sign in to create more.',
          currentCount: currentCount,
          maxLimit: maxLimit,
          resourceType: 'semester',
        );
}

/// Exception for goal limit
class GoalLimitException extends GuestModeLimitException {
  GoalLimitException({
    required int currentCount,
    required int maxLimit,
  }) : super(
          message: 'Guest mode limit reached: You can only create up to $maxLimit goals. Please sign in to create more.',
          currentCount: currentCount,
          maxLimit: maxLimit,
          resourceType: 'goal',
        );
}

/// Exception for course limit
class CourseLimitException extends GuestModeLimitException {
  CourseLimitException({
    required int currentCount,
    required int maxLimit,
  }) : super(
          message: 'Guest mode limit reached: You can only create up to $maxLimit courses. Please sign in to create more.',
          currentCount: currentCount,
          maxLimit: maxLimit,
          resourceType: 'course',
        );
}

// Made with Bob
