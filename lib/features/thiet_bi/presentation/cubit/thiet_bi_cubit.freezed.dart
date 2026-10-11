// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thiet_bi_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThietBiState {

 TrangThaiTai get trangThai; List<ThietBiTongHop> get danhSach; String get tuKhoa; TrangThaiThietBi? get trangThaiLoc; String? get loi;
/// Create a copy of ThietBiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThietBiStateCopyWith<ThietBiState> get copyWith => _$ThietBiStateCopyWithImpl<ThietBiState>(this as ThietBiState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ThietBiState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThietBiState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _this.danhSach)&&(identical(other.tuKhoa, _this.tuKhoa) || other.tuKhoa == _this.tuKhoa)&&(identical(other.trangThaiLoc, _this.trangThaiLoc) || other.trangThaiLoc == _this.trangThaiLoc)&&(identical(other.loi, _this.loi) || other.loi == _this.loi));
}


@override
int get hashCode {
  final _this = this as ThietBiState;
  return Object.hash(runtimeType,_this.trangThai,const DeepCollectionEquality().hash(_this.danhSach),_this.tuKhoa,_this.trangThaiLoc,_this.loi);
}

@override
String toString() {
  final _this = this as ThietBiState;
  return 'ThietBiState(trangThai: ${_this.trangThai}, danhSach: ${_this.danhSach}, tuKhoa: ${_this.tuKhoa}, trangThaiLoc: ${_this.trangThaiLoc}, loi: ${_this.loi})';
}


}

/// @nodoc
abstract mixin class $ThietBiStateCopyWith<$Res>  {
  factory $ThietBiStateCopyWith(ThietBiState value, $Res Function(ThietBiState) _then) = _$ThietBiStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, List<ThietBiTongHop> danhSach, String tuKhoa, TrangThaiThietBi? trangThaiLoc, String? loi
});




}
/// @nodoc
class _$ThietBiStateCopyWithImpl<$Res>
    implements $ThietBiStateCopyWith<$Res> {
  _$ThietBiStateCopyWithImpl(this._self, this._then);

  final ThietBiState _self;
  final $Res Function(ThietBiState) _then;

/// Create a copy of ThietBiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? danhSach = null,Object? tuKhoa = null,Object? trangThaiLoc = freezed,Object? loi = freezed,}) {
  return _then(ThietBiState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self.danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<ThietBiTongHop>,tuKhoa: null == tuKhoa ? _self.tuKhoa : tuKhoa // ignore: cast_nullable_to_non_nullable
as String,trangThaiLoc: freezed == trangThaiLoc ? _self.trangThaiLoc : trangThaiLoc // ignore: cast_nullable_to_non_nullable
as TrangThaiThietBi?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ThietBiState].
extension ThietBiStatePatterns on ThietBiState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThietBiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThietBiState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThietBiState value)  $default,){
final _that = this;
switch (_that) {
case _ThietBiState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThietBiState value)?  $default,){
final _that = this;
switch (_that) {
case _ThietBiState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<ThietBiTongHop> danhSach,  String tuKhoa,  TrangThaiThietBi? trangThaiLoc,  String? loi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThietBiState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.tuKhoa,_that.trangThaiLoc,_that.loi);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<ThietBiTongHop> danhSach,  String tuKhoa,  TrangThaiThietBi? trangThaiLoc,  String? loi)  $default,) {final _that = this;
switch (_that) {
case _ThietBiState():
return $default(_that.trangThai,_that.danhSach,_that.tuKhoa,_that.trangThaiLoc,_that.loi);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  List<ThietBiTongHop> danhSach,  String tuKhoa,  TrangThaiThietBi? trangThaiLoc,  String? loi)?  $default,) {final _that = this;
switch (_that) {
case _ThietBiState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.tuKhoa,_that.trangThaiLoc,_that.loi);case _:
  return null;

}
}

}

/// @nodoc


class _ThietBiState implements ThietBiState {
  const _ThietBiState({this.trangThai = TrangThaiTai.dangTai,  List<ThietBiTongHop> danhSach = const [], this.tuKhoa = '', this.trangThaiLoc, this.loi}): _danhSach = danhSach;
  

@override@JsonKey() final  TrangThaiTai trangThai;
 final  List<ThietBiTongHop> _danhSach;
@override@JsonKey() List<ThietBiTongHop> get danhSach {
  if (_danhSach is EqualUnmodifiableListView) return _danhSach;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_danhSach);
}

@override@JsonKey() final  String tuKhoa;
@override final  TrangThaiThietBi? trangThaiLoc;
@override final  String? loi;

/// Create a copy of ThietBiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThietBiStateCopyWith<_ThietBiState> get copyWith => __$ThietBiStateCopyWithImpl<_ThietBiState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThietBiState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _danhSach)&&(identical(other.tuKhoa, tuKhoa) || other.tuKhoa == tuKhoa)&&(identical(other.trangThaiLoc, trangThaiLoc) || other.trangThaiLoc == trangThaiLoc)&&(identical(other.loi, loi) || other.loi == loi));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,const DeepCollectionEquality().hash(_danhSach),tuKhoa,trangThaiLoc,loi);
}

@override
String toString() {
    return 'ThietBiState(trangThai: $trangThai, danhSach: $danhSach, tuKhoa: $tuKhoa, trangThaiLoc: $trangThaiLoc, loi: $loi)';
}


}

/// @nodoc
abstract mixin class _$ThietBiStateCopyWith<$Res> implements $ThietBiStateCopyWith<$Res> {
  factory _$ThietBiStateCopyWith(_ThietBiState value, $Res Function(_ThietBiState) _then) = __$ThietBiStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, List<ThietBiTongHop> danhSach, String tuKhoa, TrangThaiThietBi? trangThaiLoc, String? loi
});




}
/// @nodoc
class __$ThietBiStateCopyWithImpl<$Res>
    implements _$ThietBiStateCopyWith<$Res> {
  __$ThietBiStateCopyWithImpl(this._self, this._then);

  final _ThietBiState _self;
  final $Res Function(_ThietBiState) _then;

/// Create a copy of ThietBiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? danhSach = null,Object? tuKhoa = null,Object? trangThaiLoc = freezed,Object? loi = freezed,}) {
  return _then(_ThietBiState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self._danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<ThietBiTongHop>,tuKhoa: null == tuKhoa ? _self.tuKhoa : tuKhoa // ignore: cast_nullable_to_non_nullable
as String,trangThaiLoc: freezed == trangThaiLoc ? _self.trangThaiLoc : trangThaiLoc // ignore: cast_nullable_to_non_nullable
as TrangThaiThietBi?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
