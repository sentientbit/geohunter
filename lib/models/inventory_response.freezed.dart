// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InventoryResponse _$InventoryResponseFromJson(Map<String, dynamic> json) {
  return _InventoryResponse.fromJson(json);
}

/// @nodoc
mixin _$InventoryResponse {
  @JsonKey(name: 'items', fromJson: _parseItems)
  List<Item> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'materials', fromJson: _parseMaterials)
  List<Materialmodel> get materials => throw _privateConstructorUsedError;
  @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
  List<Blueprint> get blueprints => throw _privateConstructorUsedError;

  /// Create a copy of InventoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryResponseCopyWith<InventoryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryResponseCopyWith<$Res> {
  factory $InventoryResponseCopyWith(
          InventoryResponse value, $Res Function(InventoryResponse) then) =
      _$InventoryResponseCopyWithImpl<$Res, InventoryResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'items', fromJson: _parseItems) List<Item> items,
      @JsonKey(name: 'materials', fromJson: _parseMaterials)
      List<Materialmodel> materials,
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      List<Blueprint> blueprints});
}

/// @nodoc
class _$InventoryResponseCopyWithImpl<$Res, $Val extends InventoryResponse>
    implements $InventoryResponseCopyWith<$Res> {
  _$InventoryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? materials = null,
    Object? blueprints = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Item>,
      materials: null == materials
          ? _value.materials
          : materials // ignore: cast_nullable_to_non_nullable
              as List<Materialmodel>,
      blueprints: null == blueprints
          ? _value.blueprints
          : blueprints // ignore: cast_nullable_to_non_nullable
              as List<Blueprint>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryResponseImplCopyWith<$Res>
    implements $InventoryResponseCopyWith<$Res> {
  factory _$$InventoryResponseImplCopyWith(_$InventoryResponseImpl value,
          $Res Function(_$InventoryResponseImpl) then) =
      __$$InventoryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'items', fromJson: _parseItems) List<Item> items,
      @JsonKey(name: 'materials', fromJson: _parseMaterials)
      List<Materialmodel> materials,
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      List<Blueprint> blueprints});
}

/// @nodoc
class __$$InventoryResponseImplCopyWithImpl<$Res>
    extends _$InventoryResponseCopyWithImpl<$Res, _$InventoryResponseImpl>
    implements _$$InventoryResponseImplCopyWith<$Res> {
  __$$InventoryResponseImplCopyWithImpl(_$InventoryResponseImpl _value,
      $Res Function(_$InventoryResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? materials = null,
    Object? blueprints = null,
  }) {
    return _then(_$InventoryResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Item>,
      materials: null == materials
          ? _value._materials
          : materials // ignore: cast_nullable_to_non_nullable
              as List<Materialmodel>,
      blueprints: null == blueprints
          ? _value._blueprints
          : blueprints // ignore: cast_nullable_to_non_nullable
              as List<Blueprint>,
    ));
  }
}

/// @nodoc
@JsonSerializable(createToJson: false)
class _$InventoryResponseImpl extends _InventoryResponse {
  const _$InventoryResponseImpl(
      {@JsonKey(name: 'items', fromJson: _parseItems)
      final List<Item> items = const [],
      @JsonKey(name: 'materials', fromJson: _parseMaterials)
      final List<Materialmodel> materials = const [],
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      final List<Blueprint> blueprints = const []})
      : _items = items,
        _materials = materials,
        _blueprints = blueprints,
        super._();

  factory _$InventoryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryResponseImplFromJson(json);

  final List<Item> _items;
  @override
  @JsonKey(name: 'items', fromJson: _parseItems)
  List<Item> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<Materialmodel> _materials;
  @override
  @JsonKey(name: 'materials', fromJson: _parseMaterials)
  List<Materialmodel> get materials {
    if (_materials is EqualUnmodifiableListView) return _materials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_materials);
  }

  final List<Blueprint> _blueprints;
  @override
  @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
  List<Blueprint> get blueprints {
    if (_blueprints is EqualUnmodifiableListView) return _blueprints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blueprints);
  }

  @override
  String toString() {
    return 'InventoryResponse(items: $items, materials: $materials, blueprints: $blueprints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality()
                .equals(other._materials, _materials) &&
            const DeepCollectionEquality()
                .equals(other._blueprints, _blueprints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_materials),
      const DeepCollectionEquality().hash(_blueprints));

  /// Create a copy of InventoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryResponseImplCopyWith<_$InventoryResponseImpl> get copyWith =>
      __$$InventoryResponseImplCopyWithImpl<_$InventoryResponseImpl>(
          this, _$identity);
}

abstract class _InventoryResponse extends InventoryResponse {
  const factory _InventoryResponse(
      {@JsonKey(name: 'items', fromJson: _parseItems) final List<Item> items,
      @JsonKey(name: 'materials', fromJson: _parseMaterials)
      final List<Materialmodel> materials,
      @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
      final List<Blueprint> blueprints}) = _$InventoryResponseImpl;
  const _InventoryResponse._() : super._();

  factory _InventoryResponse.fromJson(Map<String, dynamic> json) =
      _$InventoryResponseImpl.fromJson;

  @override
  @JsonKey(name: 'items', fromJson: _parseItems)
  List<Item> get items;
  @override
  @JsonKey(name: 'materials', fromJson: _parseMaterials)
  List<Materialmodel> get materials;
  @override
  @JsonKey(name: 'blueprints', fromJson: _parseBlueprints)
  List<Blueprint> get blueprints;

  /// Create a copy of InventoryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryResponseImplCopyWith<_$InventoryResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
