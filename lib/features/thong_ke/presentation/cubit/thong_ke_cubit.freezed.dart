// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thong_ke_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThongKeState {

 TrangThaiTai get trangThai; ThongKeTongHop? get duLieu;/// Độ dài khoảng thống kê tính đến hôm nay: 7, 14 hoặc 30 ngày.
 int get soNgay; int? get maNguoiDung; List<NguoiDung> get nguoiDung; String? get loi;
/// Create a copy of ThongKeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThongKeStateCopyWith<ThongKeState> get copyWith => _$ThongKeStateCopyWithImpl<ThongKeState>(this as ThongKeState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ThongKeState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThongKeState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&(identical(other.duLieu, _this.duLieu) || other.duLieu == _this.duLieu)&&(identical(other.soNgay, _this.soNgay) || other.soNgay == _this.soNgay)&&(identical(other.maNguoiDung, _this.maNguoiDung) || other.maNguoiDung == _this.maNguoiDung)&&const DeepCollectionEquality().equals(other.nguoiDung, _this.nguoiDung)&&(identical(other.loi, _this.loi) || other.loi == _this.loi));
}


@override
int get hashCode {
  final _this = this as ThongKeState;
  return Object.hash(runtimeType,_this.trangThai,_this.duLieu,_this.soNgay,_this.maNguoiDung,const DeepCollectionEquality().hash(_this.nguoiDung),_this.loi);
}

@override
String toString() {
  final _this = this as ThongKeState;
  return 'ThongKeState(trangThai: ${_this.trangThai}, duLieu: ${_this.duLieu}, soNgay: ${_this.soNgay}, maNguoiDung: ${_this.maNguoiDung}, nguoiDung: ${_this.nguoiDung}, loi: ${_this.loi})';
}


}

/// @nodoc
abstract mixin class $ThongKeStateCopyWith<$Res>  {
  factory $ThongKeStateCopyWith(ThongKeState value, $Res Function(ThongKeState) _then) = _$ThongKeStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, ThongKeTongHop? duLieu, int soNgay, int? maNguoiDung, List<NguoiDung> nguoiDung, String? loi
});




}
/// @nodoc
class _$ThongKeStateCopyWithImpl<$Res>
    implements $ThongKeStateCopyWith<$Res> {
  _$ThongKeStateCopyWithImpl(this._self, this._then);

  final ThongKeState _self;
  final $Res Function(ThongKeState) _then;

/// Create a copy of ThongKeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? duLieu = freezed,Object? soNgay = null,Object? maNguoiDung = freezed,Object? nguoiDung = null,Object? loi = freezed,}) {
  return _then(ThongKeState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,duLieu: freezed == duLieu ? _self.duLieu : duLieu // ignore: cast_nullable_to_non_nullable
as ThongKeTongHop?,soNgay: null == soNgay ? _self.soNgay : soNgay // ignore: cast_nullable_to_non_nullable
as int,maNguoiDung: freezed == maNguoiDung ? _self.maNguoiDung : maNguoiDung // ignore: cast_nullable_to_non_nullable
as int?,nguoiDung: null == nguoiDung ? _self.nguoiDung : nguoiDung // ignore: cast_nullable_to_non_nullable
as List<NguoiDung>,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ThongKeState].
extension ThongKeStatePatterns on ThongKeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThongKeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThongKeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThongKeState value)  $default,){
final _that = this;
switch (_that) {
case _ThongKeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThongKeState value)?  $default,){
final _that = this;
switch (_that) {
case _ThongKeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  ThongKeTongHop? duLieu,  int soNgay,  int? maNguoiDung,  List<NguoiDung> nguoiDung,  String? loi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThongKeState() when $default != null:
return $default(_that.trangThai,_that.duLieu,_that.soNgay,_that.maNguoiDung,_that.nguoiDung,_that.loi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  ThongKeTongHop? duLieu,  int soNgay,  int? maNguoiDung,  List<NguoiDung> nguoiDung,  String? loi)  $default,) {final _that = this;
switch (_that) {
case _ThongKeState():
return $default(_that.trangThai,_that.duLieu,_that.soNgay,_that.maNguoiDung,_that.nguoiDung,_that.loi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  ThongKeTongHop? duLieu,  int soNgay,  int? maNguoiDung,  List<NguoiDung> nguoiDung,  String? loi)?  $default,) {final _that = this;
switch (_that) {
case _ThongKeState() when $default != null:
return $default(_that.trangThai,_that.duLieu,_that.soNgay,_that.maNguoiDung,_that.nguoiDung,_that.loi);case _:
  return null;

}
}

}

/// @nodoc


class _ThongKeState extends ThongKeState {
  const _ThongKeState({this.trangThai = TrangThaiTai.dangTai, this.duLieu, this.soNgay = 7, this.maNguoiDung,  List<NguoiDung> nguoiDung = const [], this.loi}): _nguoiDung = nguoiDung,super._();
  

@override@JsonKey() final  TrangThaiTai trangThai;
@override final  ThongKeTongHop? duLieu;
/// Độ dài khoảng thống kê tính đến hôm nay: 7, 14 hoặc 30 ngày.
@override@JsonKey() final  int soNgay;
@override final  int? maNguoiDung;
 final  List<NguoiDung> _nguoiDung;
@override@JsonKey() List<NguoiDung> get nguoiDung {
  if (_nguoiDung is EqualUnmodifiableListView) return _nguoiDung;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nguoiDung);
}

@override final  String? loi;

/// Create a copy of ThongKeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThongKeStateCopyWith<_ThongKeState> get copyWith => __$ThongKeStateCopyWithImpl<_ThongKeState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThongKeState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&(identical(other.duLieu, duLieu) || other.duLieu == duLieu)&&(identical(other.soNgay, soNgay) || other.soNgay == soNgay)&&(identical(other.maNguoiDung, maNguoiDung) || other.maNguoiDung == maNguoiDung)&&const DeepCollectionEquality().equals(other.nguoiDung, _nguoiDung)&&(identical(other.loi, loi) || other.loi == loi));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,duLieu,soNgay,maNguoiDung,const DeepCollectionEquality().hash(_nguoiDung),loi);
}

@override
String toString() {
    return 'ThongKeState(trangThai: $trangThai, duLieu: $duLieu, soNgay: $soNgay, maNguoiDung: $maNguoiDung, nguoiDung: $nguoiDung, loi: $loi)';
}


}

/// @nodoc
abstract mixin class _$ThongKeStateCopyWith<$Res> implements $ThongKeStateCopyWith<$Res> {
  factory _$ThongKeStateCopyWith(_ThongKeState value, $Res Function(_ThongKeState) _then) = __$ThongKeStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, ThongKeTongHop? duLieu, int soNgay, int? maNguoiDung, List<NguoiDung> nguoiDung, String? loi
});




}
/// @nodoc
class __$ThongKeStateCopyWithImpl<$Res>
    implements _$ThongKeStateCopyWith<$Res> {
  __$ThongKeStateCopyWithImpl(this._self, this._then);

  final _ThongKeState _self;
  final $Res Function(_ThongKeState) _then;

/// Create a copy of ThongKeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? duLieu = freezed,Object? soNgay = null,Object? maNguoiDung = freezed,Object? nguoiDung = null,Object? loi = freezed,}) {
  return _then(_ThongKeState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,duLieu: freezed == duLieu ? _self.duLieu : duLieu // ignore: cast_nullable_to_non_nullable
as ThongKeTongHop?,soNgay: null == soNgay ? _self.soNgay : soNgay // ignore: cast_nullable_to_non_nullable
as int,maNguoiDung: freezed == maNguoiDung ? _self.maNguoiDung : maNguoiDung // ignore: cast_nullable_to_non_nullable
as int?,nguoiDung: null == nguoiDung ? _self._nguoiDung : nguoiDung // ignore: cast_nullable_to_non_nullable
as List<NguoiDung>,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
