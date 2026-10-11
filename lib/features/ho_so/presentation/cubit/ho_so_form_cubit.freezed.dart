// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ho_so_form_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HoSoFormState {

 TrangThaiTai get trangThai;/// Hồ sơ đang sửa; `null` khi thêm mới.
 HoSoTongHop? get banDau; bool get dangLuu; String? get loi;/// Mã người dùng vừa lưu thành công.
 String? get maDaLuu;
/// Create a copy of HoSoFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoSoFormStateCopyWith<HoSoFormState> get copyWith => _$HoSoFormStateCopyWithImpl<HoSoFormState>(this as HoSoFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HoSoFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoSoFormState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&(identical(other.banDau, _this.banDau) || other.banDau == _this.banDau)&&(identical(other.dangLuu, _this.dangLuu) || other.dangLuu == _this.dangLuu)&&(identical(other.loi, _this.loi) || other.loi == _this.loi)&&(identical(other.maDaLuu, _this.maDaLuu) || other.maDaLuu == _this.maDaLuu));
}


@override
int get hashCode {
  final _this = this as HoSoFormState;
  return Object.hash(runtimeType,_this.trangThai,_this.banDau,_this.dangLuu,_this.loi,_this.maDaLuu);
}

@override
String toString() {
  final _this = this as HoSoFormState;
  return 'HoSoFormState(trangThai: ${_this.trangThai}, banDau: ${_this.banDau}, dangLuu: ${_this.dangLuu}, loi: ${_this.loi}, maDaLuu: ${_this.maDaLuu})';
}


}

/// @nodoc
abstract mixin class $HoSoFormStateCopyWith<$Res>  {
  factory $HoSoFormStateCopyWith(HoSoFormState value, $Res Function(HoSoFormState) _then) = _$HoSoFormStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, HoSoTongHop? banDau, bool dangLuu, String? loi, String? maDaLuu
});




}
/// @nodoc
class _$HoSoFormStateCopyWithImpl<$Res>
    implements $HoSoFormStateCopyWith<$Res> {
  _$HoSoFormStateCopyWithImpl(this._self, this._then);

  final HoSoFormState _self;
  final $Res Function(HoSoFormState) _then;

/// Create a copy of HoSoFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? banDau = freezed,Object? dangLuu = null,Object? loi = freezed,Object? maDaLuu = freezed,}) {
  return _then(HoSoFormState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,banDau: freezed == banDau ? _self.banDau : banDau // ignore: cast_nullable_to_non_nullable
as HoSoTongHop?,dangLuu: null == dangLuu ? _self.dangLuu : dangLuu // ignore: cast_nullable_to_non_nullable
as bool,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,maDaLuu: freezed == maDaLuu ? _self.maDaLuu : maDaLuu // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HoSoFormState].
extension HoSoFormStatePatterns on HoSoFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoSoFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoSoFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoSoFormState value)  $default,){
final _that = this;
switch (_that) {
case _HoSoFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoSoFormState value)?  $default,){
final _that = this;
switch (_that) {
case _HoSoFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  HoSoTongHop? banDau,  bool dangLuu,  String? loi,  String? maDaLuu)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoSoFormState() when $default != null:
return $default(_that.trangThai,_that.banDau,_that.dangLuu,_that.loi,_that.maDaLuu);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  HoSoTongHop? banDau,  bool dangLuu,  String? loi,  String? maDaLuu)  $default,) {final _that = this;
switch (_that) {
case _HoSoFormState():
return $default(_that.trangThai,_that.banDau,_that.dangLuu,_that.loi,_that.maDaLuu);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  HoSoTongHop? banDau,  bool dangLuu,  String? loi,  String? maDaLuu)?  $default,) {final _that = this;
switch (_that) {
case _HoSoFormState() when $default != null:
return $default(_that.trangThai,_that.banDau,_that.dangLuu,_that.loi,_that.maDaLuu);case _:
  return null;

}
}

}

/// @nodoc


class _HoSoFormState implements HoSoFormState {
  const _HoSoFormState({this.trangThai = TrangThaiTai.dangTai, this.banDau, this.dangLuu = false, this.loi, this.maDaLuu});
  

@override@JsonKey() final  TrangThaiTai trangThai;
/// Hồ sơ đang sửa; `null` khi thêm mới.
@override final  HoSoTongHop? banDau;
@override@JsonKey() final  bool dangLuu;
@override final  String? loi;
/// Mã người dùng vừa lưu thành công.
@override final  String? maDaLuu;

/// Create a copy of HoSoFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoSoFormStateCopyWith<_HoSoFormState> get copyWith => __$HoSoFormStateCopyWithImpl<_HoSoFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoSoFormState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&(identical(other.banDau, banDau) || other.banDau == banDau)&&(identical(other.dangLuu, dangLuu) || other.dangLuu == dangLuu)&&(identical(other.loi, loi) || other.loi == loi)&&(identical(other.maDaLuu, maDaLuu) || other.maDaLuu == maDaLuu));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,banDau,dangLuu,loi,maDaLuu);
}

@override
String toString() {
    return 'HoSoFormState(trangThai: $trangThai, banDau: $banDau, dangLuu: $dangLuu, loi: $loi, maDaLuu: $maDaLuu)';
}


}

/// @nodoc
abstract mixin class _$HoSoFormStateCopyWith<$Res> implements $HoSoFormStateCopyWith<$Res> {
  factory _$HoSoFormStateCopyWith(_HoSoFormState value, $Res Function(_HoSoFormState) _then) = __$HoSoFormStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, HoSoTongHop? banDau, bool dangLuu, String? loi, String? maDaLuu
});




}
/// @nodoc
class __$HoSoFormStateCopyWithImpl<$Res>
    implements _$HoSoFormStateCopyWith<$Res> {
  __$HoSoFormStateCopyWithImpl(this._self, this._then);

  final _HoSoFormState _self;
  final $Res Function(_HoSoFormState) _then;

/// Create a copy of HoSoFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? banDau = freezed,Object? dangLuu = null,Object? loi = freezed,Object? maDaLuu = freezed,}) {
  return _then(_HoSoFormState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,banDau: freezed == banDau ? _self.banDau : banDau // ignore: cast_nullable_to_non_nullable
as HoSoTongHop?,dangLuu: null == dangLuu ? _self.dangLuu : dangLuu // ignore: cast_nullable_to_non_nullable
as bool,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,maDaLuu: freezed == maDaLuu ? _self.maDaLuu : maDaLuu // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
