// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'equipment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EquipmentResponse _$EquipmentResponseFromJson(Map<String, dynamic> json) {
  return _EquipmentResponse.fromJson(json);
}

/// @nodoc
mixin _$EquipmentResponse {
  @JsonKey(name: 'equipment', fromJson: _parseEquipment)
  List<EquippedItem> get equipment => throw _privateConstructorUsedError;

  /// Create a copy of EquipmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EquipmentResponseCopyWith<EquipmentResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EquipmentResponseCopyWith<$Res> {
  factory $EquipmentResponseCopyWith(
          EquipmentResponse value, $Res Function(EquipmentResponse) then) =
      _$EquipmentResponseCopyWithImpl<$Res, EquipmentResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'equipment', fromJson: _parseEquipment)
      List<EquippedItem> equipment});
}

/// @nodoc
class _$EquipmentResponseCopyWithImpl<$Res, $Val extends EquipmentResponse>
    implements $EquipmentResponseCopyWith<$Res> {
  _$EquipmentResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EquipmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? equipment = null,
  }) {
    return _then(_value.copyWith(
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<EquippedItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EquipmentResponseImplCopyWith<$Res>
    implements $EquipmentResponseCopyWith<$Res> {
  factory _$$EquipmentResponseImplCopyWith(_$EquipmentResponseImpl value,
          $Res Function(_$EquipmentResponseImpl) then) =
      __$$EquipmentResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'equipment', fromJson: _parseEquipment)
      List<EquippedItem> equipment});
}

/// @nodoc
class __$$EquipmentResponseImplCopyWithImpl<$Res>
    extends _$EquipmentResponseCopyWithImpl<$Res, _$EquipmentResponseImpl>
    implements _$$EquipmentResponseImplCopyWith<$Res> {
  __$$EquipmentResponseImplCopyWithImpl(_$EquipmentResponseImpl _value,
      $Res Function(_$EquipmentResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of EquipmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? equipment = null,
  }) {
    return _then(_$EquipmentResponseImpl(
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<EquippedItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$EquipmentResponseImpl extends _EquipmentResponse {
  const _$EquipmentResponseImpl(
      {@JsonKey(name: 'equipment', fromJson: _parseEquipment)
      final List<EquippedItem> equipment = const []})
      : _equipment = equipment,
        super._();

  factory _$EquipmentResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$EquipmentResponseImplFromJson(json);

  final List<EquippedItem> _equipment;
  @override
  @JsonKey(name: 'equipment', fromJson: _parseEquipment)
  List<EquippedItem> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  @override
  String toString() {
    return 'EquipmentResponse(equipment: $equipment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EquipmentResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_equipment));

  /// Create a copy of EquipmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EquipmentResponseImplCopyWith<_$EquipmentResponseImpl> get copyWith =>
      __$$EquipmentResponseImplCopyWithImpl<_$EquipmentResponseImpl>(
          this, _$identity);
}

abstract class _EquipmentResponse extends EquipmentResponse {
  const factory _EquipmentResponse(
      {@JsonKey(name: 'equipment', fromJson: _parseEquipment)
      final List<EquippedItem> equipment}) = _$EquipmentResponseImpl;
  const _EquipmentResponse._() : super._();

  factory _EquipmentResponse.fromJson(Map<String, dynamic> json) =
      _$EquipmentResponseImpl.fromJson;

  @override
  @JsonKey(name: 'equipment', fromJson: _parseEquipment)
  List<EquippedItem> get equipment;

  /// Create a copy of EquipmentResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EquipmentResponseImplCopyWith<_$EquipmentResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
