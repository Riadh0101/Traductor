import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../domain/entities/conversation_session.dart';
import '../../../../domain/entities/language.dart';
import '../../../../domain/entities/translation_message.dart';

enum TranslatorStatus {
  idle,
  listening,
  processing,
  translating,
  speaking,
  paused,
  error,
}

class TranslatorState {
  final Language language1;
  final Language language2;
  final TranslatorStatus status;
  final String activeMode; // auto_conversation, push_to_talk, manual_l1_to_l2, manual_l2_to_l1
  final String liveTranscript;
  final Language? detectedLiveLanguage;
  final List<TranslationMessage> messages;
  final ConversationSession? currentSession;
  final String? errorMessage;
  final Language? lastSpokenLanguage;
  final bool isSwappingLanguages;

  const TranslatorState({
    this.language1 = SupportedLanguages.arabic,
    this.language2 = SupportedLanguages.turkish,
    this.status = TranslatorStatus.idle,
    this.activeMode = AppConstants.modePushToTalk,
    this.liveTranscript = '',
    this.detectedLiveLanguage,
    this.messages = const [],
    this.currentSession,
    this.errorMessage,
    this.lastSpokenLanguage,
    this.isSwappingLanguages = false,
  });

  TranslatorState copyWith({
    Language? language1,
    Language? language2,
    TranslatorStatus? status,
    String? activeMode,
    String? liveTranscript,
    Language? detectedLiveLanguage,
    List<TranslationMessage>? messages,
    ConversationSession? currentSession,
    String? errorMessage,
    Language? lastSpokenLanguage,
    bool? isSwappingLanguages,
  }) {
    return TranslatorState(
      language1: language1 ?? this.language1,
      language2: language2 ?? this.language2,
      status: status ?? this.status,
      activeMode: activeMode ?? this.activeMode,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      detectedLiveLanguage: detectedLiveLanguage ?? this.detectedLiveLanguage,
      messages: messages ?? this.messages,
      currentSession: currentSession ?? this.currentSession,
      errorMessage: errorMessage,
      lastSpokenLanguage: lastSpokenLanguage ?? this.lastSpokenLanguage,
      isSwappingLanguages: isSwappingLanguages ?? this.isSwappingLanguages,
    );
  }
}
