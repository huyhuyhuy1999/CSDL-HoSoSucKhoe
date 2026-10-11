// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lich_su_do_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LichSuDoState {

 TrangThaiTai get trangThai; List<LanDoDayDu> get danhSach;/// Danh sách người dùng cho bộ chọn "người được đo".
 List<NguoiDung> get nguoiDung; String? get maNguoiDung; KhoangThoiGian get khoang;/// Chỉ dùng khi [khoang] là [KhoangThoiGian.tuyChon].
 DateTime? get tuNgay; DateTime? get denNgay; NguonDuLieu? get nguon; String? get loi;
/// Create a copy of LichSuDoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LichSuDoStateCopyWith<LichSuDoState> get copyWith => _$LichSuDoStateCopyWithImpl<LichSuDoState>(this as LichSuDoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LichSuDoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LichSuDoState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _this.danhSach)&&const DeepCollectionEquality().equals(other.nguoiDung, _this.nguoiDung)&&(identical(other.maNguoiDung, _this.maNguoiDung) || other.maNguoiDung == _this.maNguoiDung)&&(identical(other.khoang, _this.khoang) || other.khoang == _this.khoang)&&(identical(other.tuNgay, _this.tuNgay) || other.tuNgay == _this.tuNgay)&&(identical(other.denNgay, _this.denNgay) || other.denNgay == _this.denNgay)&&(identical(other.nguon, _this.nguon) || other.nguon == _this.nguon)&&(identical(other.loi, _this.loi) || other.loi == _this.loi));
}


@override
int get hashCode {
  final _this = this as LichSuDoState;
  return Object.hash(runtimeType,_this.trangThai,const DeepCollectionEquality().hash(_this.danhSach),const DeepCollectionEquality().hash(_this.nguoiDung),_this.maNguoiDung,_this.khoang,_this.tuNgay,_this.denNgay,_this.nguon,_this.loi);
}

@override
String toString() {
  final _this = this as LichSuDoState;
  return 'LichSuDoState(trangThai: ${_this.trangThai}, danhSach: ${_this.danhSach}, nguoiDung: ${_this.nguoiDung}, maNguoiDung: ${_this.maNguoiDung}, khoang: ${_this.khoang}, tuNgay: ${_this.tuNgay}, denNgay: ${_this.denNgay}, nguon: ${_this.nguon}, loi: ${_this.loi})';
}


}

/// @nodoc
abstract mixin class $LichSuDoStateCopyWith<$Res>  {
  factory $LichSuDoStateCopyWith(LichSuDoState value, $Res Function(LichSuDoState) _then) = _$LichSuDoStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, List<LanDoDayDu> danhSach, List<NguoiDung> nguoiDung, String? maNguoiDung, KhoangThoiGian khoang, DateTime? tuNgay, DateTime? denNgay, NguonDuLieu? nguon, String? loi
});




}
/// @nodoc
class _$LichSuDoStateCopyWithImpl<$Res>
    implements $LichSuDoStateCopyWith<$Res> {
  _$LichSuDoStateCopyWithImpl(this._self, this._then);

  final LichSuDoState _self;
  final $Res Function(LichSuDoState) _then;

/// Create a copy of LichSuDoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? danhSach = null,Object? nguoiDung = null,Object? maNguoiDung = freezed,Object? khoang = null,Object? tuNgay = freezed,Object? denNgay = freezed,Object? nguon = freezed,Object? loi = freezed,}) {
  return _then(LichSuDoState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self.danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<LanDoDayDu>,nguoiDung: null == nguoiDung ? _self.nguoiDung : nguoiDung // ignore: cast_nullable_to_non_nullable
as List<NguoiDung>,maNguoiDung: freezed == maNguoiDung ? _self.maNguoiDung : maNguoiDung // ignore: cast_nullable_to_non_nullable
as String?,khoang: null == khoang ? _self.khoang : khoang // ignore: cast_nullable_to_non_nullable
as KhoangThoiGian,tuNgay: freezed == tuNgay ? _self.tuNgay : tuNgay // ignore: cast_nullable_to_non_nullable
as DateTime?,denNgay: freezed == denNgay ? _self.denNgay : denNgay // ignore: cast_nullable_to_non_nullable
as DateTime?,nguon: freezed == nguon ? _self.nguon : nguon // ignore: cast_nullable_to_non_nullable
as NguonDuLieu?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LichSuDoState].
extension LichSuDoStatePatterns on LichSuDoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LichSuDoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LichSuDoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LichSuDoState value)  $default,){
final _that = this;
switch (_that) {
case _LichSuDoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LichSuDoState value)?  $default,){
final _that = this;
switch (_that) {
case _LichSuDoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<LanDoDayDu> danhSach,  List<NguoiDung> nguoiDung,  String? maNguoiDung,  KhoangThoiGian khoang,  DateTime? tuNgay,  DateTime? denNgay,  NguonDuLieu? nguon,  String? loi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LichSuDoState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.nguoiDung,_that.maNguoiDung,_that.khoang,_that.tuNgay,_that.denNgay,_that.nguon,_that.loi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<LanDoDayDu> danhSach,  List<NguoiDung> nguoiDung,  String? maNguoiDung,  KhoangThoiGian khoang,  DateTime? tuNgay,  DateTime? denNgay,  NguonDuLieu? nguon,  String? loi)  $default,) {final _that = this;
switch (_that) {
case _LichSuDoState():
return $default(_that.trangThai,_that.danhSach,_that.nguoiDung,_that.maNguoiDung,_that.khoang,_that.tuNgay,_that.denNgay,_that.nguon,_that.loi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  List<LanDoDayDu> danhSach,  List<NguoiDung> nguoiDung,  String? maNguoiDung,  KhoangThoiGian khoang,  DateTime? tuNgay,  DateTime? denNgay,  NguonDuLieu? nguon,  String? loi)?  $default,) {final _that = this;
switch (_that) {
case _LichSuDoState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.nguoiDung,_that.maNguoiDung,_that.khoang,_that.tuNgay,_that.denNgay,_that.nguon,_that.loi);case _:
  return null;

}
}

}

/// @nodoc


class _LichSuDoState extends LichSuDoState {
  const _LichSuDoState({this.trangThai = TrangThaiTai.dangTai,  List<LanDoDayDu> danhSach = const [],  List<NguoiDung> nguoiDung = const [], this.maNguoiDung, this.khoang = KhoangThoiGian.bayNgay, this.tuNgay, this.denNgay, this.nguon, this.loi}): _danhSach = danhSach,_nguoiDung = nguoiDung,super._();
  

@override@JsonKey() final  TrangThaiTai trangThai;
 final  List<LanDoDayDu> _danhSach;
@override@JsonKey() List<LanDoDayDu> get danhSach {
  if (_danhSach is EqualUnmodifiableListView) return _danhSach;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_danhSach);
}

/// Danh sách người dùng cho bộ chọn "người được đo".
 final  List<NguoiDung> _nguoiDung;
/// Danh sách người dùng cho bộ chọn "người được đo".
@override@JsonKey() List<NguoiDung> get nguoiDung {
  if (_nguoiDung is EqualUnmodifiableListView) return _nguoiDung;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nguoiDung);
}

@override final  String? maNguoiDung;
@override@JsonKey() final  KhoangThoiGian khoang;
/// Chỉ dùng khi [khoang] là [KhoangThoiGian.tuyChon].
@override final  DateTime? tuNgay;
@override final  DateTime? denNgay;
@override final  NguonDuLieu? nguon;
@override final  String? loi;

/// Create a copy of LichSuDoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LichSuDoStateCopyWith<_LichSuDoState> get copyWith => __$LichSuDoStateCopyWithImpl<_LichSuDoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LichSuDoState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _danhSach)&&const DeepCollectionEquality().equals(other.nguoiDung, _nguoiDung)&&(identical(other.maNguoiDung, maNguoiDung) || other.maNguoiDung == maNguoiDung)&&(identical(other.khoang, khoang) || other.khoang == khoang)&&(identical(other.tuNgay, tuNgay) || other.tuNgay == tuNgay)&&(identical(other.denNgay, denNgay) || other.denNgay == denNgay)&&(identical(other.nguon, nguon) || other.nguon == nguon)&&(identical(other.loi, loi) || other.loi == loi));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,const DeepCollectionEquality().hash(_danhSach),const DeepCollectionEquality().hash(_nguoiDung),maNguoiDung,khoang,tuNgay,denNgay,nguon,loi);
}

@override
String toString() {
    return 'LichSuDoState(trangThai: $trangThai, danhSach: $danhSach, nguoiDung: $nguoiDung, maNguoiDung: $maNguoiDung, khoang: $khoang, tuNgay: $tuNgay, denNgay: $denNgay, nguon: $nguon, loi: $loi)';
}


}

/// @nodoc
abstract mixin class _$LichSuDoStateCopyWith<$Res> implements $LichSuDoStateCopyWith<$Res> {
  factory _$LichSuDoStateCopyWith(_LichSuDoState value, $Res Function(_LichSuDoState) _then) = __$LichSuDoStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, List<LanDoDayDu> danhSach, List<NguoiDung> nguoiDung, String? maNguoiDung, KhoangThoiGian khoang, DateTime? tuNgay, DateTime? denNgay, NguonDuLieu? nguon, String? loi
});




}
/// @nodoc
class __$LichSuDoStateCopyWithImpl<$Res>
    implements _$LichSuDoStateCopyWith<$Res> {
  __$LichSuDoStateCopyWithImpl(this._self, this._then);

  final _LichSuDoState _self;
  final $Res Function(_LichSuDoState) _then;

/// Create a copy of LichSuDoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? danhSach = null,Object? nguoiDung = null,Object? maNguoiDung = freezed,Object? khoang = null,Object? tuNgay = freezed,Object? denNgay = freezed,Object? nguon = freezed,Object? loi = freezed,}) {
  return _then(_LichSuDoState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self._danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<LanDoDayDu>,nguoiDung: null == nguoiDung ? _self._nguoiDung : nguoiDung // ignore: cast_nullable_to_non_nullable
as List<NguoiDung>,maNguoiDung: freezed == maNguoiDung ? _self.maNguoiDung : maNguoiDung // ignore: cast_nullable_to_non_nullable
as String?,khoang: null == khoang ? _self.khoang : khoang // ignore: cast_nullable_to_non_nullable
as KhoangThoiGian,tuNgay: freezed == tuNgay ? _self.tuNgay : tuNgay // ignore: cast_nullable_to_non_nullable
as DateTime?,denNgay: freezed == denNgay ? _self.denNgay : denNgay // ignore: cast_nullable_to_non_nullable
as DateTime?,nguon: freezed == nguon ? _self.nguon : nguon // ignore: cast_nullable_to_non_nullable
as NguonDuLieu?,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
