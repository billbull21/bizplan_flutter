import '../../domain/entities/ai_insight.dart';

abstract class AiInsightState {
  const AiInsightState();
}

class AiInsightInitial extends AiInsightState {
  const AiInsightInitial();
}

class AiInsightLoading extends AiInsightState {
  const AiInsightLoading();
}

class AiInsightSuccess extends AiInsightState {
  final AiInsight insight;
  const AiInsightSuccess(this.insight);
}

class AiInsightError extends AiInsightState {
  final String message;
  const AiInsightError(this.message);
}
