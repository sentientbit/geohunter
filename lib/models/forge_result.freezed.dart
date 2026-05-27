// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forge_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ForgeItem _$ForgeItemFromJson(Map<String, dynamic> json) {
  return _ForgeItem.fromJson(json);
}

/// @nodoc
mixin _$ForgeItem {
  @JsonKey(name: 'nr', fromJson: _parseInt)
  int get nr => throw _privateConstructorUsedError;
  @JsonKey(name: 'img')
  String get img => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'rarity', fromJson: _parseInt)
  int get rarity => throw _privateConstructorUsedError;

  /// Create a copy of ForgeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForgeItemCopyWith<ForgeItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForgeItemCopyWith<$Res> {
  factory $ForgeItemCopyWith(ForgeItem value, $Res Function(ForgeItem) then) =
      _$ForgeItemCopyWithImpl<$Res, ForgeItem>;
  @useResult
  $Res call(
      {@JsonKey(name: 'nr', fromJson: _parseInt) int nr,
      @JsonKey(name: 'img') String img,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'rarity', fromJson: _parseInt) int rarity});
}

/// @nodoc
class _$ForgeItemCopyWithImpl<$Res, $Val extends ForgeItem>
    implements $ForgeItemCopyWith<$Res> {
  _$ForgeItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForgeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nr = null,
    Object? img = null,
    Object? name = null,
    Object? rarity = null,
  }) {
    return _then(_value.copyWith(
      nr: null == nr
          ? _value.nr
          : nr // ignore: cast_nullable_to_non_nullable
              as int,
      img: null == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      rarity: null == rarity
          ? _value.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ForgeItemImplCopyWith<$Res>
    implements $ForgeItemCopyWith<$Res> {
  factory _$$ForgeItemImplCopyWith(
          _$ForgeItemImpl value, $Res Function(_$ForgeItemImpl) then) =
      __$$ForgeItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'nr', fromJson: _parseInt) int nr,
      @JsonKey(name: 'img') String img,
      @JsonKey(name: 'name') String name,
      @JsonKey(name: 'rarity', fromJson: _parseInt) int rarity});
}

/// @nodoc
class __$$ForgeItemImplCopyWithImpl<$Res>
    extends _$ForgeItemCopyWithImpl<$Res, _$ForgeItemImpl>
    implements _$$ForgeItemImplCopyWith<$Res> {
  __$$ForgeItemImplCopyWithImpl(
      _$ForgeItemImpl _value, $Res Function(_$ForgeItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ForgeItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nr = null,
    Object? img = null,
    Object? name = null,
    Object? rarity = null,
  }) {
    return _then(_$ForgeItemImpl(
      nr: null == nr
          ? _value.nr
          : nr // ignore: cast_nullable_to_non_nullable
              as int,
      img: null == img
          ? _value.img
          : img // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      rarity: null == rarity
          ? _value.rarity
          : rarity // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$ForgeItemImpl implements _ForgeItem {
  const _$ForgeItemImpl(
      {@JsonKey(name: 'nr', fromJson: _parseInt) this.nr = 0,
      @JsonKey(name: 'img') this.img = '',
      @JsonKey(name: 'name') this.name = '',
      @JsonKey(name: 'rarity', fromJson: _parseInt) this.rarity = 0});

  factory _$ForgeItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ForgeItemImplFromJson(json);

  @override
  @JsonKey(name: 'nr', fromJson: _parseInt)
  final int nr;
  @override
  @JsonKey(name: 'img')
  final String img;
  @override
  @JsonKey(name: 'name')
  final String name;
  @override
  @JsonKey(name: 'rarity', fromJson: _parseInt)
  final int rarity;

  @override
  String toString() {
    return 'ForgeItem(nr: $nr, img: $img, name: $name, rarity: $rarity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgeItemImpl &&
            (identical(other.nr, nr) || other.nr == nr) &&
            (identical(other.img, img) || other.img == img) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.rarity, rarity) || other.rarity == rarity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, nr, img, name, rarity);

  /// Create a copy of ForgeItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgeItemImplCopyWith<_$ForgeItemImpl> get copyWith =>
      __$$ForgeItemImplCopyWithImpl<_$ForgeItemImpl>(this, _$identity);
}

abstract class _ForgeItem implements ForgeItem {
  const factory _ForgeItem(
          {@JsonKey(name: 'nr', fromJson: _parseInt) final int nr,
          @JsonKey(name: 'img') final String img,
          @JsonKey(name: 'name') final String name,
          @JsonKey(name: 'rarity', fromJson: _parseInt) final int rarity}) =
      _$ForgeItemImpl;

  factory _ForgeItem.fromJson(Map<String, dynamic> json) =
      _$ForgeItemImpl.fromJson;

  @override
  @JsonKey(name: 'nr', fromJson: _parseInt)
  int get nr;
  @override
  @JsonKey(name: 'img')
  String get img;
  @override
  @JsonKey(name: 'name')
  String get name;
  @override
  @JsonKey(name: 'rarity', fromJson: _parseInt)
  int get rarity;

  /// Create a copy of ForgeItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgeItemImplCopyWith<_$ForgeItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ForgeResult _$ForgeResultFromJson(Map<String, dynamic> json) {
  return _ForgeResult.fromJson(json);
}

/// @nodoc
mixin _$ForgeResult {
  @JsonKey(name: 'items', fromJson: _parseFirstItem)
  ForgeItem get item => throw _privateConstructorUsedError;

  /// Create a copy of ForgeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForgeResultCopyWith<ForgeResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForgeResultCopyWith<$Res> {
  factory $ForgeResultCopyWith(
          ForgeResult value, $Res Function(ForgeResult) then) =
      _$ForgeResultCopyWithImpl<$Res, ForgeResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'items', fromJson: _parseFirstItem) ForgeItem item});

  $ForgeItemCopyWith<$Res> get item;
}

/// @nodoc
class _$ForgeResultCopyWithImpl<$Res, $Val extends ForgeResult>
    implements $ForgeResultCopyWith<$Res> {
  _$ForgeResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForgeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
  }) {
    return _then(_value.copyWith(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as ForgeItem,
    ) as $Val);
  }

  /// Create a copy of ForgeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ForgeItemCopyWith<$Res> get item {
    return $ForgeItemCopyWith<$Res>(_value.item, (value) {
      return _then(_value.copyWith(item: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ForgeResultImplCopyWith<$Res>
    implements $ForgeResultCopyWith<$Res> {
  factory _$$ForgeResultImplCopyWith(
          _$ForgeResultImpl value, $Res Function(_$ForgeResultImpl) then) =
      __$$ForgeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'items', fromJson: _parseFirstItem) ForgeItem item});

  @override
  $ForgeItemCopyWith<$Res> get item;
}

/// @nodoc
class __$$ForgeResultImplCopyWithImpl<$Res>
    extends _$ForgeResultCopyWithImpl<$Res, _$ForgeResultImpl>
    implements _$$ForgeResultImplCopyWith<$Res> {
  __$$ForgeResultImplCopyWithImpl(
      _$ForgeResultImpl _value, $Res Function(_$ForgeResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ForgeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? item = null,
  }) {
    return _then(_$ForgeResultImpl(
      item: null == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as ForgeItem,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$ForgeResultImpl extends _ForgeResult {
  const _$ForgeResultImpl(
      {@JsonKey(name: 'items', fromJson: _parseFirstItem) required this.item})
      : super._();

  factory _$ForgeResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ForgeResultImplFromJson(json);

  @override
  @JsonKey(name: 'items', fromJson: _parseFirstItem)
  final ForgeItem item;

  @override
  String toString() {
    return 'ForgeResult(item: $item)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgeResultImpl &&
            (identical(other.item, item) || other.item == item));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, item);

  /// Create a copy of ForgeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgeResultImplCopyWith<_$ForgeResultImpl> get copyWith =>
      __$$ForgeResultImplCopyWithImpl<_$ForgeResultImpl>(this, _$identity);
}

abstract class _ForgeResult extends ForgeResult {
  const factory _ForgeResult(
      {@JsonKey(name: 'items', fromJson: _parseFirstItem)
      required final ForgeItem item}) = _$ForgeResultImpl;
  const _ForgeResult._() : super._();

  factory _ForgeResult.fromJson(Map<String, dynamic> json) =
      _$ForgeResultImpl.fromJson;

  @override
  @JsonKey(name: 'items', fromJson: _parseFirstItem)
  ForgeItem get item;

  /// Create a copy of ForgeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgeResultImplCopyWith<_$ForgeResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
