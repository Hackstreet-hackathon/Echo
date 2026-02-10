import 'package:equatable/equatable.dart';

/// Accessibility settings for PWD users
class AccessibilitySettingsModel extends Equatable {
  const AccessibilitySettingsModel({
    this.largeTextMode = false,
    this.highContrastMode = false,
    this.screenReaderEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.voicePlaybackEnabled = true,
    this.textScaleFactor = 1.0,
  });

  final bool largeTextMode;
  final bool highContrastMode;
  final bool screenReaderEnabled;
  final bool hapticFeedbackEnabled;
  final bool voicePlaybackEnabled;
  final double textScaleFactor;

  factory AccessibilitySettingsModel.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettingsModel(
      largeTextMode: json['large_text_mode'] as bool? ?? false,
      highContrastMode: json['high_contrast_mode'] as bool? ?? false,
      screenReaderEnabled: json['screen_reader_enabled'] as bool? ?? true,
      hapticFeedbackEnabled: json['haptic_feedback_enabled'] as bool? ?? true,
      voicePlaybackEnabled: json['voice_playback_enabled'] as bool? ?? true,
      textScaleFactor: (json['text_scale_factor'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'large_text_mode': largeTextMode,
      'high_contrast_mode': highContrastMode,
      'screen_reader_enabled': screenReaderEnabled,
      'haptic_feedback_enabled': hapticFeedbackEnabled,
      'voice_playback_enabled': voicePlaybackEnabled,
      'text_scale_factor': textScaleFactor,
    };
  }

  AccessibilitySettingsModel copyWith({
    bool? largeTextMode,
    bool? highContrastMode,
    bool? screenReaderEnabled,
    bool? hapticFeedbackEnabled,
    bool? voicePlaybackEnabled,
    double? textScaleFactor,
  }) {
    return AccessibilitySettingsModel(
      largeTextMode: largeTextMode ?? this.largeTextMode,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      voicePlaybackEnabled: voicePlaybackEnabled ?? this.voicePlaybackEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  @override
  List<Object?> get props => [
        largeTextMode,
        highContrastMode,
        screenReaderEnabled,
        hapticFeedbackEnabled,
        voicePlaybackEnabled,
        textScaleFactor,
      ];
}
