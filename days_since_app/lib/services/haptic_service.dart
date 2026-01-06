import 'package:vibration/vibration.dart';

/// Service for providing haptic feedback across the app.
/// Uses the vibration package directly for reliable haptic feedback.
class HapticService {
  static bool? _hasVibrator;
  static bool? _hasAmplitudeControl;

  /// Initialize the haptic service by checking device capabilities
  static Future<void> initialize() async {
    _hasVibrator = await Vibration.hasVibrator();
    _hasAmplitudeControl = await Vibration.hasAmplitudeControl();
  }

  /// Light impact feedback - for subtle interactions
  static Future<void> lightImpact() async {
    if (_hasVibrator != true) return;
    
    if (_hasAmplitudeControl == true) {
      await Vibration.vibrate(duration: 25, amplitude: 80);
    } else {
      await Vibration.vibrate(duration: 25);
    }
  }

  /// Medium impact feedback - for standard interactions
  static Future<void> mediumImpact() async {
    if (_hasVibrator != true) return;
    
    if (_hasAmplitudeControl == true) {
      await Vibration.vibrate(duration: 40, amplitude: 150);
    } else {
      await Vibration.vibrate(duration: 40);
    }
  }

  /// Heavy impact feedback - for important actions
  static Future<void> heavyImpact() async {
    if (_hasVibrator != true) return;
    
    if (_hasAmplitudeControl == true) {
      await Vibration.vibrate(duration: 60, amplitude: 255);
    } else {
      await Vibration.vibrate(duration: 60);
    }
  }

  /// Selection click feedback - for UI selections
  static Future<void> selectionClick() async {
    if (_hasVibrator != true) return;
    
    if (_hasAmplitudeControl == true) {
      await Vibration.vibrate(duration: 15, amplitude: 100);
    } else {
      await Vibration.vibrate(duration: 15);
    }
  }
}
