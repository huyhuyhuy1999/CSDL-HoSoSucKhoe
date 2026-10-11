// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lan_do_form_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LanDoFormState {

 TrangThaiTai get trangThai; List<NguoiDung> get nguoiDung;/// Chỉ gồm thiết bị đang hoạt động.
 List<ThietBi> get thietBi; List<LoaiChiSo> get loaiChiSo; bool get dangLuu; String? get loi;/// Mã lần đo vừa lưu thành công.
 String? get maDaLuu;
/// Create a copy of LanDoFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LanDoFormStateCopyWith<LanDoFormState> get copyWith => _$LanDoFormStateCopyWithImpl<LanDoFormState>(this as LanDoFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LanDoFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanDoFormState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&const DeepCollectionEquality().equals(other.nguoiDung, _this.nguoiDung)&&const DeepCollectionEquality().equals(other.thietBi, _this.thietBi)&&const DeepCollectionEquality().equals(other.loaiChiSo, _this.loaiChiSo)&&(identical(other.dangLuu, _this.dangLuu) || other.dangLuu == _this.dangLuu)&&(identical(other.loi, _this.loi) || other.loi == _this.loi)&&(identical(other.maDaLuu, _this.maDaLuu) || other.maDaLuu == _this.maDaLuu));
}


@override
int get hashCode {
  final _this = this as LanDoFormState;
  return Object.hash(runtimeType,_this.trangThai,const DeepCollectionEquality().hash(_this.nguoiDung),const DeepCollectionEquality().hash(_this.thietBi),const DeepCollectionEquality().hash(_this.loaiChiSo),_this.dangLuu,_this.loi,_this.maDaLuu);
}

@override
String toString() {
  final _this = this as LanDoFormState;
  return 'LanDoFormState(trangThai: ${_this.trangThai}, nguoiDung: ${_this.nguoiDung}, thietBi: ${_this.thietBi}, loaiChiSo: ${_this.loaiChiSo}, dangLuu: ${_this.dangLuu}, loi: ${_this.loi}, maDaLuu: ${_this.maDaLuu})';
}


}

/// @nodoc
abstract mixin class $LanDoFormStateCopyWith<$Res>  {
  factory $LanDoFormStateCopyWith(LanDoFormState value, $Res Function(LanDoFormState) _then) = _$LanDoFormStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, List<NguoiDung> nguoiDung, List<ThietBi> thietBi, List<LoaiChiSo> loaiChiSo, bool dangLuu, String? loi, String? maDaLuu
});




}
/// @nodoc
class _$LanDoFormStateCopyWithImpl<$Res>
    implements $LanDoFormStateCopyWith<$Res> {
  _$LanDoFormStateCopyWithImpl(this._self, this._then);

  final LanDoFormState _self;
  final $Res Function(LanDoFormState) _then;

/// Create a copy of LanDoFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? nguoiDung = null,Object? thietBi = null,Object? loaiChiSo = null,Object? dangLuu = null,Object? loi = freezed,Object? maDaLuu = freezed,}) {
  return _then(LanDoFormState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,nguoiDung: null == nguoiDung ? _self.nguoiDung : nguoiDung // ignore: cast_nullable_to_non_nullable
as List<NguoiDung>,thietBi: null == thietBi ? _self.thietBi : thietBi // ignore: cast_nullable_to_non_nullable
as List<ThietBi>,loaiChiSo: null == loaiChiSo ? _self.loaiChiSo : loaiChiSo // ignore: cast_nullable_to_non_nullable
as List<LoaiChiSo>,dangLuu: null == dangLuu ? _self.dangLuu : dangLuu // ignore: cast_nullable_to_non_nullable
as bool,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,maDaLuu: freezed == maDaLuu ? _self.maDaLuu : maDaLuu // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LanDoFormState].
extension LanDoFormStatePatterns on LanDoFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LanDoFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LanDoFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LanDoFormState value)  $default,){
final _that = this;
switch (_that) {
case _LanDoFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LanDoFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LanDoFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<NguoiDung> nguoiDung,  List<ThietBi> thietBi,  List<LoaiChiSo> loaiChiSo,  bool dangLuu,  String? loi,  String? maDaLuu)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LanDoFormState() when $default != null:
return $default(_that.trangThai,_that.nguoiDung,_that.thietBi,_that.loaiChiSo,_that.dangLuu,_that.loi,_that.maDaLuu);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<NguoiDung> nguoiDung,  List<ThietBi> thietBi,  List<LoaiChiSo> loaiChiSo,  bool dangLuu,  String? loi,  String? maDaLuu)  $default,) {final _that = this;
switch (_that) {
case _LanDoFormState():
return $default(_that.trangThai,_that.nguoiDung,_that.thietBi,_that.loaiChiSo,_that.dangLuu,_that.loi,_that.maDaLuu);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  List<NguoiDung> nguoiDung,  List<ThietBi> thietBi,  List<LoaiChiSo> loaiChiSo,  bool dangLuu,  String? loi,  String? maDaLuu)?  $default,) {final _that = this;
switch (_that) {
case _LanDoFormState() when $default != null:
return $default(_that.trangThai,_that.nguoiDung,_that.thietBi,_that.loaiChiSo,_that.dangLuu,_that.loi,_that.maDaLuu);case _:
  return null;

}
}

}

/// @nodoc


class _LanDoFormState implements LanDoFormState {
  const _LanDoFormState({this.trangThai = TrangThaiTai.dangTai,  List<NguoiDung> nguoiDung = const [],  List<ThietBi> thietBi = const [],  List<LoaiChiSo> loaiChiSo = const [], this.dangLuu = false, this.loi, this.maDaLuu}): _nguoiDung = nguoiDung,_thietBi = thietBi,_loaiChiSo = loaiChiSo;
  

@override@JsonKey() final  TrangThaiTai trangThai;
 final  List<NguoiDung> _nguoiDung;
@override@JsonKey() List<NguoiDung> get nguoiDung {
  if (_nguoiDung is EqualUnmodifiableListView) return _nguoiDung;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nguoiDung);
}

/// Chỉ gồm thiết bị đang hoạt động.
 final  List<ThietBi> _thietBi;
/// Chỉ gồm thiết bị đang hoạt động.
@override@JsonKey() List<ThietBi> get thietBi {
  if (_thietBi is EqualUnmodifiableListView) return _thietBi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_thietBi);
}

 final  List<LoaiChiSo> _loaiChiSo;
@override@JsonKey() List<LoaiChiSo> get loaiChiSo {
  if (_loaiChiSo is EqualUnmodifiableListView) return _loaiChiSo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_loaiChiSo);
}

@override@JsonKey() final  bool dangLuu;
@override final  String? loi;
/// Mã lần đo vừa lưu thành công.
@override final  String? maDaLuu;

/// Create a copy of LanDoFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LanDoFormStateCopyWith<_LanDoFormState> get copyWith => __$LanDoFormStateCopyWithImpl<_LanDoFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LanDoFormState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&const DeepCollectionEquality().equals(other.nguoiDung, _nguoiDung)&&const DeepCollectionEquality().equals(other.thietBi, _thietBi)&&const DeepCollectionEquality().equals(other.loaiChiSo, _loaiChiSo)&&(identical(other.dangLuu, dangLuu) || other.dangLuu == dangLuu)&&(identical(other.loi, loi) || other.loi == loi)&&(identical(other.maDaLuu, maDaLuu) || other.maDaLuu == maDaLuu));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,const DeepCollectionEquality().hash(_nguoiDung),const DeepCollectionEquality().hash(_thietBi),const DeepCollectionEquality().hash(_loaiChiSo),dangLuu,loi,maDaLuu);
}

@override
String toString() {
    return 'LanDoFormState(trangThai: $trangThai, nguoiDung: $nguoiDung, thietBi: $thietBi, loaiChiSo: $loaiChiSo, dangLuu: $dangLuu, loi: $loi, maDaLuu: $maDaLuu)';
}


}

/// @nodoc
abstract mixin class _$LanDoFormStateCopyWith<$Res> implements $LanDoFormStateCopyWith<$Res> {
  factory _$LanDoFormStateCopyWith(_LanDoFormState value, $Res Function(_LanDoFormState) _then) = __$LanDoFormStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, List<NguoiDung> nguoiDung, List<ThietBi> thietBi, List<LoaiChiSo> loaiChiSo, bool dangLuu, String? loi, String? maDaLuu
});




}
/// @nodoc
class __$LanDoFormStateCopyWithImpl<$Res>
    implements _$LanDoFormStateCopyWith<$Res> {
  __$LanDoFormStateCopyWithImpl(this._self, this._then);

  final _LanDoFormState _self;
  final $Res Function(_LanDoFormState) _then;

/// Create a copy of LanDoFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? nguoiDung = null,Object? thietBi = null,Object? loaiChiSo = null,Object? dangLuu = null,Object? loi = freezed,Object? maDaLuu = freezed,}) {
  return _then(_LanDoFormState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,nguoiDung: null == nguoiDung ? _self._nguoiDung : nguoiDung // ignore: cast_nullable_to_non_nullable
as List<NguoiDung>,thietBi: null == thietBi ? _self._thietBi : thietBi // ignore: cast_nullable_to_non_nullable
as List<ThietBi>,loaiChiSo: null == loaiChiSo ? _self._loaiChiSo : loaiChiSo // ignore: cast_nullable_to_non_nullable
as List<LoaiChiSo>,dangLuu: null == dangLuu ? _self.dangLuu : dangLuu // ignore: cast_nullable_to_non_nullable
as bool,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,maDaLuu: freezed == maDaLuu ? _self.maDaLuu : maDaLuu // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
