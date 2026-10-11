// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tong_quan_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TongQuanState {

 TrangThaiTai get trangThai; TongQuan? get duLieu; String? get loi;
/// Create a copy of TongQuanState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TongQuanStateCopyWith<TongQuanState> get copyWith => _$TongQuanStateCopyWithImpl<TongQuanState>(this as TongQuanState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TongQuanState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TongQuanState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&(identical(other.duLieu, _this.duLieu) || other.duLieu == _this.duLieu)&&(identical(other.loi, _this.loi) || other.loi == _this.loi));
}


@override
int get hashCode {
  final _this = this as TongQuanState;
  return Object.hash(runtimeType,_this.trangThai,_this.duLieu,_this.loi);
}

@override
String toString() {
  final _this = this as TongQuanState;
  return 'TongQuanState(trangThai: ${_this.trangThai}, duLieu: ${_this.duLieu}, loi: ${_this.loi})';
}


}

/// @nodoc
abstract mixin class $TongQuanStateCopyWith<$Res>  {
  factory $TongQuanStateCopyWith(TongQuanState value, $Res Function(TongQuanState) _then) = _$TongQuanStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, TongQuan? duLieu, String? loi
});




}
/// @nodoc
class _$TongQuanStateCopyWithImpl<$Res>
    implements $TongQuanStateCopyWith<$Res> {
  _$TongQuanStateCopyWithImpl(this._self, this._then);

  final TongQuanState _self;
  final $Res Function(TongQuanState) _then;

/// Create a copy of TongQuanState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? duLieu = freezed,Object? loi = freezed,}) {
  return _then(TongQuanState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,duLieu: freezed == duLieu ? _self.duLieu : duLieu // ignore: cast_nullable_to_non_nullable
as TongQuan?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TongQuanState].
extension TongQuanStatePatterns on TongQuanState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TongQuanState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TongQuanState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TongQuanState value)  $default,){
final _that = this;
switch (_that) {
case _TongQuanState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TongQuanState value)?  $default,){
final _that = this;
switch (_that) {
case _TongQuanState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  TongQuan? duLieu,  String? loi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TongQuanState() when $default != null:
return $default(_that.trangThai,_that.duLieu,_that.loi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  TongQuan? duLieu,  String? loi)  $default,) {final _that = this;
switch (_that) {
case _TongQuanState():
return $default(_that.trangThai,_that.duLieu,_that.loi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  TongQuan? duLieu,  String? loi)?  $default,) {final _that = this;
switch (_that) {
case _TongQuanState() when $default != null:
return $default(_that.trangThai,_that.duLieu,_that.loi);case _:
  return null;

}
}

}

/// @nodoc


class _TongQuanState implements TongQuanState {
  const _TongQuanState({this.trangThai = TrangThaiTai.dangTai, this.duLieu, this.loi});
  

@override@JsonKey() final  TrangThaiTai trangThai;
@override final  TongQuan? duLieu;
@override final  String? loi;

/// Create a copy of TongQuanState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TongQuanStateCopyWith<_TongQuanState> get copyWith => __$TongQuanStateCopyWithImpl<_TongQuanState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TongQuanState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&(identical(other.duLieu, duLieu) || other.duLieu == duLieu)&&(identical(other.loi, loi) || other.loi == loi));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,duLieu,loi);
}

@override
String toString() {
    return 'TongQuanState(trangThai: $trangThai, duLieu: $duLieu, loi: $loi)';
}


}

/// @nodoc
abstract mixin class _$TongQuanStateCopyWith<$Res> implements $TongQuanStateCopyWith<$Res> {
  factory _$TongQuanStateCopyWith(_TongQuanState value, $Res Function(_TongQuanState) _then) = __$TongQuanStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, TongQuan? duLieu, String? loi
});




}
/// @nodoc
class __$TongQuanStateCopyWithImpl<$Res>
    implements _$TongQuanStateCopyWith<$Res> {
  __$TongQuanStateCopyWithImpl(this._self, this._then);

  final _TongQuanState _self;
  final $Res Function(_TongQuanState) _then;

/// Create a copy of TongQuanState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? duLieu = freezed,Object? loi = freezed,}) {
  return _then(_TongQuanState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,duLieu: freezed == duLieu ? _self.duLieu : duLieu // ignore: cast_nullable_to_non_nullable
as TongQuan?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
