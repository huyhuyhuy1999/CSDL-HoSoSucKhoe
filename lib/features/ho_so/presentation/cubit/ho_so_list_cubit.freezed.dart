// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ho_so_list_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HoSoListState {

 TrangThaiTai get trangThai; List<HoSoTongHop> get danhSach; String get tuKhoa; GioiTinh? get gioiTinh; NhomTuoi? get nhomTuoi; String? get loi;
/// Create a copy of HoSoListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoSoListStateCopyWith<HoSoListState> get copyWith => _$HoSoListStateCopyWithImpl<HoSoListState>(this as HoSoListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HoSoListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoSoListState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _this.danhSach)&&(identical(other.tuKhoa, _this.tuKhoa) || other.tuKhoa == _this.tuKhoa)&&(identical(other.gioiTinh, _this.gioiTinh) || other.gioiTinh == _this.gioiTinh)&&(identical(other.nhomTuoi, _this.nhomTuoi) || other.nhomTuoi == _this.nhomTuoi)&&(identical(other.loi, _this.loi) || other.loi == _this.loi));
}


@override
int get hashCode {
  final _this = this as HoSoListState;
  return Object.hash(runtimeType,_this.trangThai,const DeepCollectionEquality().hash(_this.danhSach),_this.tuKhoa,_this.gioiTinh,_this.nhomTuoi,_this.loi);
}

@override
String toString() {
  final _this = this as HoSoListState;
  return 'HoSoListState(trangThai: ${_this.trangThai}, danhSach: ${_this.danhSach}, tuKhoa: ${_this.tuKhoa}, gioiTinh: ${_this.gioiTinh}, nhomTuoi: ${_this.nhomTuoi}, loi: ${_this.loi})';
}


}

/// @nodoc
abstract mixin class $HoSoListStateCopyWith<$Res>  {
  factory $HoSoListStateCopyWith(HoSoListState value, $Res Function(HoSoListState) _then) = _$HoSoListStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, List<HoSoTongHop> danhSach, String tuKhoa, GioiTinh? gioiTinh, NhomTuoi? nhomTuoi, String? loi
});




}
/// @nodoc
class _$HoSoListStateCopyWithImpl<$Res>
    implements $HoSoListStateCopyWith<$Res> {
  _$HoSoListStateCopyWithImpl(this._self, this._then);

  final HoSoListState _self;
  final $Res Function(HoSoListState) _then;

/// Create a copy of HoSoListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? danhSach = null,Object? tuKhoa = null,Object? gioiTinh = freezed,Object? nhomTuoi = freezed,Object? loi = freezed,}) {
  return _then(HoSoListState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self.danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<HoSoTongHop>,tuKhoa: null == tuKhoa ? _self.tuKhoa : tuKhoa // ignore: cast_nullable_to_non_nullable
as String,gioiTinh: freezed == gioiTinh ? _self.gioiTinh : gioiTinh // ignore: cast_nullable_to_non_nullable
as GioiTinh?,nhomTuoi: freezed == nhomTuoi ? _self.nhomTuoi : nhomTuoi // ignore: cast_nullable_to_non_nullable
as NhomTuoi?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HoSoListState].
extension HoSoListStatePatterns on HoSoListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HoSoListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HoSoListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HoSoListState value)  $default,){
final _that = this;
switch (_that) {
case _HoSoListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HoSoListState value)?  $default,){
final _that = this;
switch (_that) {
case _HoSoListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<HoSoTongHop> danhSach,  String tuKhoa,  GioiTinh? gioiTinh,  NhomTuoi? nhomTuoi,  String? loi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HoSoListState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.tuKhoa,_that.gioiTinh,_that.nhomTuoi,_that.loi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<HoSoTongHop> danhSach,  String tuKhoa,  GioiTinh? gioiTinh,  NhomTuoi? nhomTuoi,  String? loi)  $default,) {final _that = this;
switch (_that) {
case _HoSoListState():
return $default(_that.trangThai,_that.danhSach,_that.tuKhoa,_that.gioiTinh,_that.nhomTuoi,_that.loi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  List<HoSoTongHop> danhSach,  String tuKhoa,  GioiTinh? gioiTinh,  NhomTuoi? nhomTuoi,  String? loi)?  $default,) {final _that = this;
switch (_that) {
case _HoSoListState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.tuKhoa,_that.gioiTinh,_that.nhomTuoi,_that.loi);case _:
  return null;

}
}

}

/// @nodoc


class _HoSoListState extends HoSoListState {
  const _HoSoListState({this.trangThai = TrangThaiTai.dangTai,  List<HoSoTongHop> danhSach = const [], this.tuKhoa = '', this.gioiTinh, this.nhomTuoi, this.loi}): _danhSach = danhSach,super._();
  

@override@JsonKey() final  TrangThaiTai trangThai;
 final  List<HoSoTongHop> _danhSach;
@override@JsonKey() List<HoSoTongHop> get danhSach {
  if (_danhSach is EqualUnmodifiableListView) return _danhSach;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_danhSach);
}

@override@JsonKey() final  String tuKhoa;
@override final  GioiTinh? gioiTinh;
@override final  NhomTuoi? nhomTuoi;
@override final  String? loi;

/// Create a copy of HoSoListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HoSoListStateCopyWith<_HoSoListState> get copyWith => __$HoSoListStateCopyWithImpl<_HoSoListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HoSoListState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _danhSach)&&(identical(other.tuKhoa, tuKhoa) || other.tuKhoa == tuKhoa)&&(identical(other.gioiTinh, gioiTinh) || other.gioiTinh == gioiTinh)&&(identical(other.nhomTuoi, nhomTuoi) || other.nhomTuoi == nhomTuoi)&&(identical(other.loi, loi) || other.loi == loi));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,const DeepCollectionEquality().hash(_danhSach),tuKhoa,gioiTinh,nhomTuoi,loi);
}

@override
String toString() {
    return 'HoSoListState(trangThai: $trangThai, danhSach: $danhSach, tuKhoa: $tuKhoa, gioiTinh: $gioiTinh, nhomTuoi: $nhomTuoi, loi: $loi)';
}


}

/// @nodoc
abstract mixin class _$HoSoListStateCopyWith<$Res> implements $HoSoListStateCopyWith<$Res> {
  factory _$HoSoListStateCopyWith(_HoSoListState value, $Res Function(_HoSoListState) _then) = __$HoSoListStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, List<HoSoTongHop> danhSach, String tuKhoa, GioiTinh? gioiTinh, NhomTuoi? nhomTuoi, String? loi
});




}
/// @nodoc
class __$HoSoListStateCopyWithImpl<$Res>
    implements _$HoSoListStateCopyWith<$Res> {
  __$HoSoListStateCopyWithImpl(this._self, this._then);

  final _HoSoListState _self;
  final $Res Function(_HoSoListState) _then;

/// Create a copy of HoSoListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? danhSach = null,Object? tuKhoa = null,Object? gioiTinh = freezed,Object? nhomTuoi = freezed,Object? loi = freezed,}) {
  return _then(_HoSoListState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self._danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<HoSoTongHop>,tuKhoa: null == tuKhoa ? _self.tuKhoa : tuKhoa // ignore: cast_nullable_to_non_nullable
as String,gioiTinh: freezed == gioiTinh ? _self.gioiTinh : gioiTinh // ignore: cast_nullable_to_non_nullable
as GioiTinh?,nhomTuoi: freezed == nhomTuoi ? _self.nhomTuoi : nhomTuoi // ignore: cast_nullable_to_non_nullable
as NhomTuoi?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
