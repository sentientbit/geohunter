import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Central gate for one-shot sound effects.
///
/// Sounds and vibration are device-local preferences: the backend only
/// persists music + notification levels (CI3 settings_put ignores the rest),
/// so the toggle state lives in secure storage on this device.
///
/// Usage:
///   await Sfx.init();              // once, at app start
///   Sfx.play('sfx/anvil_1.mp3');   // no-op when sounds are off
///   Sfx.setEnabled(false);         // from the Settings screen
abstract class Sfx {
  static const _storage = FlutterSecureStorage();
  static const _key = 'sounds_enabled';

  /// Current state — defaults to ON until [init] loads the stored value.
  static bool enabled = true;

  /// Loads the persisted toggle. Call once before runApp.
  static Future<void> init() async {
    final stored = await _storage.read(key: _key);
    enabled = stored != '0';
  }

  /// Persists and applies the toggle.
  static Future<void> setEnabled(bool value) async {
    enabled = value;
    await _storage.write(key: _key, value: value ? '1' : '0');
  }

  /// Plays a one-shot effect, honouring the toggle.
  static void play(String file) {
    if (!enabled) return;
    FlameAudio.play(file);
  }
}
