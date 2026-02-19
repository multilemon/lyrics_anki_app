enum LearningMode {
  japanese,
  english,
  korean;

  bool get isReverse => this != LearningMode.japanese;
}
