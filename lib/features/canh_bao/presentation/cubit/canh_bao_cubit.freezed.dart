// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'canh_bao_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CanhBaoState {

 TrangThaiTai get trangThai; List<CanhBaoDayDu> get danhSach; BoLocCanhBao get boLoc; int get soChuaXem; String? get loi;
/// Create a copy of CanhBaoState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanhBaoStateCopyWith<CanhBaoState> get copyWith => _$CanhBaoStateCopyWithImpl<CanhBaoState>(this as CanhBaoState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CanhBaoState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanhBaoState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _this.danhSach)&&(identical(other.boLoc, _this.boLoc) || other.boLoc == _this.boLoc)&&(identical(other.soChuaXem, _this.soChuaXem) || other.soChuaXem == _this.soChuaXem)&&(identical(other.loi, _this.loi) || other.loi == _this.loi));
}


@override
int get hashCode {
  final _this = this as CanhBaoState;
  return Object.hash(runtimeType,_this.trangThai,const DeepCollectionEquality().hash(_this.danhSach),_this.boLoc,_this.soChuaXem,_this.loi);
}

@override
String toString() {
  final _this = this as CanhBaoState;
  return 'CanhBaoState(trangThai: ${_this.trangThai}, danhSach: ${_this.danhSach}, boLoc: ${_this.boLoc}, soChuaXem: ${_this.soChuaXem}, loi: ${_this.loi})';
}


}

/// @nodoc
abstract mixin class $CanhBaoStateCopyWith<$Res>  {
  factory $CanhBaoStateCopyWith(CanhBaoState value, $Res Function(CanhBaoState) _then) = _$CanhBaoStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, List<CanhBaoDayDu> danhSach, BoLocCanhBao boLoc, int soChuaXem, String? loi
});




}
/// @nodoc
class _$CanhBaoStateCopyWithImpl<$Res>
    implements $CanhBaoStateCopyWith<$Res> {
  _$CanhBaoStateCopyWithImpl(this._self, this._then);

  final CanhBaoState _self;
  final $Res Function(CanhBaoState) _then;

/// Create a copy of CanhBaoState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? danhSach = null,Object? boLoc = null,Object? soChuaXem = null,Object? loi = freezed,}) {
  return _then(CanhBaoState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self.danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<CanhBaoDayDu>,boLoc: null == boLoc ? _self.boLoc : boLoc // ignore: cast_nullable_to_non_nullable
as BoLocCanhBao,soChuaXem: null == soChuaXem ? _self.soChuaXem : soChuaXem // ignore: cast_nullable_to_non_nullable
as int,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CanhBaoState].
extension CanhBaoStatePatterns on CanhBaoState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CanhBaoState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CanhBaoState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CanhBaoState value)  $default,){
final _that = this;
switch (_that) {
case _CanhBaoState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CanhBaoState value)?  $default,){
final _that = this;
switch (_that) {
case _CanhBaoState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<CanhBaoDayDu> danhSach,  BoLocCanhBao boLoc,  int soChuaXem,  String? loi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CanhBaoState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.boLoc,_that.soChuaXem,_that.loi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  List<CanhBaoDayDu> danhSach,  BoLocCanhBao boLoc,  int soChuaXem,  String? loi)  $default,) {final _that = this;
switch (_that) {
case _CanhBaoState():
return $default(_that.trangThai,_that.danhSach,_that.boLoc,_that.soChuaXem,_that.loi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  List<CanhBaoDayDu> danhSach,  BoLocCanhBao boLoc,  int soChuaXem,  String? loi)?  $default,) {final _that = this;
switch (_that) {
case _CanhBaoState() when $default != null:
return $default(_that.trangThai,_that.danhSach,_that.boLoc,_that.soChuaXem,_that.loi);case _:
  return null;

}
}

}

/// @nodoc


class _CanhBaoState implements CanhBaoState {
  const _CanhBaoState({this.trangThai = TrangThaiTai.dangTai,  List<CanhBaoDayDu> danhSach = const [], this.boLoc = BoLocCanhBao.tatCa, this.soChuaXem = 0, this.loi}): _danhSach = danhSach;
  

@override@JsonKey() final  TrangThaiTai trangThai;
 final  List<CanhBaoDayDu> _danhSach;
@override@JsonKey() List<CanhBaoDayDu> get danhSach {
  if (_danhSach is EqualUnmodifiableListView) return _danhSach;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_danhSach);
}

@override@JsonKey() final  BoLocCanhBao boLoc;
@override@JsonKey() final  int soChuaXem;
@override final  String? loi;

/// Create a copy of CanhBaoState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CanhBaoStateCopyWith<_CanhBaoState> get copyWith => __$CanhBaoStateCopyWithImpl<_CanhBaoState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CanhBaoState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&const DeepCollectionEquality().equals(other.danhSach, _danhSach)&&(identical(other.boLoc, boLoc) || other.boLoc == boLoc)&&(identical(other.soChuaXem, soChuaXem) || other.soChuaXem == soChuaXem)&&(identical(other.loi, loi) || other.loi == loi));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,const DeepCollectionEquality().hash(_danhSach),boLoc,soChuaXem,loi);
}

@override
String toString() {
    return 'CanhBaoState(trangThai: $trangThai, danhSach: $danhSach, boLoc: $boLoc, soChuaXem: $soChuaXem, loi: $loi)';
}


}

/// @nodoc
abstract mixin class _$CanhBaoStateCopyWith<$Res> implements $CanhBaoStateCopyWith<$Res> {
  factory _$CanhBaoStateCopyWith(_CanhBaoState value, $Res Function(_CanhBaoState) _then) = __$CanhBaoStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, List<CanhBaoDayDu> danhSach, BoLocCanhBao boLoc, int soChuaXem, String? loi
});




}
/// @nodoc
class __$CanhBaoStateCopyWithImpl<$Res>
    implements _$CanhBaoStateCopyWith<$Res> {
  __$CanhBaoStateCopyWithImpl(this._self, this._then);

  final _CanhBaoState _self;
  final $Res Function(_CanhBaoState) _then;

/// Create a copy of CanhBaoState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? danhSach = null,Object? boLoc = null,Object? soChuaXem = null,Object? loi = freezed,}) {
  return _then(_CanhBaoState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,danhSach: null == danhSach ? _self._danhSach : danhSach // ignore: cast_nullable_to_non_nullable
as List<CanhBaoDayDu>,boLoc: null == boLoc ? _self.boLoc : boLoc // ignore: cast_nullable_to_non_nullable
as BoLocCanhBao,soChuaXem: null == soChuaXem ? _self.soChuaXem : soChuaXem // ignore: cast_nullable_to_non_nullable
as int,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
