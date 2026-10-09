import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarjuman/features/player/domain/entities/subtitle_style.dart';

abstract interface class SettingsStore {
  SubtitleStyle readSubtitleStyle();
  Future<void> writeSubtitleStyle(SubtitleStyle style);
}

class SharedPrefsSettingsStore implements SettingsStore {
  SharedPrefsSettingsStore(this._prefs);
  final SharedPreferences _prefs;

  static const _size = 'subtitle.size';
  static const _color = 'subtitle.color';
  static const _bg = 'subtitle.background';
  static const _pos = 'subtitle.position';

  @override
  SubtitleStyle readSubtitleStyle() {
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final name = _prefs.getString(key);
      return values.asNameMap()[name] ?? fallback;
    }

    return SubtitleStyle(
      fontSize: _prefs.getDouble(_size) ?? 22,
      color: pick(
        SubtitleColorPreset.values,
        _color,
        SubtitleColorPreset.white,
      ),
      background: pick(SubtitleBackground.values, _bg, SubtitleBackground.box),
      position: pick(SubtitlePosition.values, _pos, SubtitlePosition.bottom),
    );
  }

  @override
  Future<void> writeSubtitleStyle(SubtitleStyle s) async {
    await _prefs.setDouble(_size, s.fontSize);
    await _prefs.setString(_color, s.color.name);
    await _prefs.setString(_bg, s.background.name);
    await _prefs.setString(_pos, s.position.name);
  }
}
