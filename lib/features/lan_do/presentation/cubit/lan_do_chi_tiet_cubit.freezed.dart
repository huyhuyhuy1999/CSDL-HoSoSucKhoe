// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lan_do_chi_tiet_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LanDoChiTietState {

 TrangThaiTai get trangThai; LanDoDayDu? get lanDo; List<CanhBaoDayDu> get canhBao; String? get loi; bool get daXoa;
/// Create a copy of LanDoChiTietState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LanDoChiTietStateCopyWith<LanDoChiTietState> get copyWith => _$LanDoChiTietStateCopyWithImpl<LanDoChiTietState>(this as LanDoChiTietState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LanDoChiTietState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanDoChiTietState&&(identical(other.trangThai, _this.trangThai) || other.trangThai == _this.trangThai)&&(identical(other.lanDo, _this.lanDo) || other.lanDo == _this.lanDo)&&const DeepCollectionEquality().equals(other.canhBao, _this.canhBao)&&(identical(other.loi, _this.loi) || other.loi == _this.loi)&&(identical(other.daXoa, _this.daXoa) || other.daXoa == _this.daXoa));
}


@override
int get hashCode {
  final _this = this as LanDoChiTietState;
  return Object.hash(runtimeType,_this.trangThai,_this.lanDo,const DeepCollectionEquality().hash(_this.canhBao),_this.loi,_this.daXoa);
}

@override
String toString() {
  final _this = this as LanDoChiTietState;
  return 'LanDoChiTietState(trangThai: ${_this.trangThai}, lanDo: ${_this.lanDo}, canhBao: ${_this.canhBao}, loi: ${_this.loi}, daXoa: ${_this.daXoa})';
}


}

/// @nodoc
abstract mixin class $LanDoChiTietStateCopyWith<$Res>  {
  factory $LanDoChiTietStateCopyWith(LanDoChiTietState value, $Res Function(LanDoChiTietState) _then) = _$LanDoChiTietStateCopyWithImpl;
@useResult
$Res call({
 TrangThaiTai trangThai, LanDoDayDu? lanDo, List<CanhBaoDayDu> canhBao, String? loi, bool daXoa
});




}
/// @nodoc
class _$LanDoChiTietStateCopyWithImpl<$Res>
    implements $LanDoChiTietStateCopyWith<$Res> {
  _$LanDoChiTietStateCopyWithImpl(this._self, this._then);

  final LanDoChiTietState _self;
  final $Res Function(LanDoChiTietState) _then;

/// Create a copy of LanDoChiTietState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trangThai = null,Object? lanDo = freezed,Object? canhBao = null,Object? loi = freezed,Object? daXoa = null,}) {
  return _then(LanDoChiTietState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,lanDo: freezed == lanDo ? _self.lanDo : lanDo // ignore: cast_nullable_to_non_nullable
as LanDoDayDu?,canhBao: null == canhBao ? _self.canhBao : canhBao // ignore: cast_nullable_to_non_nullable
as List<CanhBaoDayDu>,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,daXoa: null == daXoa ? _self.daXoa : daXoa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LanDoChiTietState].
extension LanDoChiTietStatePatterns on LanDoChiTietState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LanDoChiTietState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LanDoChiTietState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LanDoChiTietState value)  $default,){
final _that = this;
switch (_that) {
case _LanDoChiTietState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LanDoChiTietState value)?  $default,){
final _that = this;
switch (_that) {
case _LanDoChiTietState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  LanDoDayDu? lanDo,  List<CanhBaoDayDu> canhBao,  String? loi,  bool daXoa)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LanDoChiTietState() when $default != null:
return $default(_that.trangThai,_that.lanDo,_that.canhBao,_that.loi,_that.daXoa);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TrangThaiTai trangThai,  LanDoDayDu? lanDo,  List<CanhBaoDayDu> canhBao,  String? loi,  bool daXoa)  $default,) {final _that = this;
switch (_that) {
case _LanDoChiTietState():
return $default(_that.trangThai,_that.lanDo,_that.canhBao,_that.loi,_that.daXoa);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TrangThaiTai trangThai,  LanDoDayDu? lanDo,  List<CanhBaoDayDu> canhBao,  String? loi,  bool daXoa)?  $default,) {final _that = this;
switch (_that) {
case _LanDoChiTietState() when $default != null:
return $default(_that.trangThai,_that.lanDo,_that.canhBao,_that.loi,_that.daXoa);case _:
  return null;

}
}

}

/// @nodoc


class _LanDoChiTietState implements LanDoChiTietState {
  const _LanDoChiTietState({this.trangThai = TrangThaiTai.dangTai, this.lanDo,  List<CanhBaoDayDu> canhBao = const [], this.loi, this.daXoa = false}): _canhBao = canhBao;
  

@override@JsonKey() final  TrangThaiTai trangThai;
@override final  LanDoDayDu? lanDo;
 final  List<CanhBaoDayDu> _canhBao;
@override@JsonKey() List<CanhBaoDayDu> get canhBao {
  if (_canhBao is EqualUnmodifiableListView) return _canhBao;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_canhBao);
}

@override final  String? loi;
@override@JsonKey() final  bool daXoa;

/// Create a copy of LanDoChiTietState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LanDoChiTietStateCopyWith<_LanDoChiTietState> get copyWith => __$LanDoChiTietStateCopyWithImpl<_LanDoChiTietState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LanDoChiTietState&&(identical(other.trangThai, trangThai) || other.trangThai == trangThai)&&(identical(other.lanDo, lanDo) || other.lanDo == lanDo)&&const DeepCollectionEquality().equals(other.canhBao, _canhBao)&&(identical(other.loi, loi) || other.loi == loi)&&(identical(other.daXoa, daXoa) || other.daXoa == daXoa));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trangThai,lanDo,const DeepCollectionEquality().hash(_canhBao),loi,daXoa);
}

@override
String toString() {
    return 'LanDoChiTietState(trangThai: $trangThai, lanDo: $lanDo, canhBao: $canhBao, loi: $loi, daXoa: $daXoa)';
}


}

/// @nodoc
abstract mixin class _$LanDoChiTietStateCopyWith<$Res> implements $LanDoChiTietStateCopyWith<$Res> {
  factory _$LanDoChiTietStateCopyWith(_LanDoChiTietState value, $Res Function(_LanDoChiTietState) _then) = __$LanDoChiTietStateCopyWithImpl;
@override @useResult
$Res call({
 TrangThaiTai trangThai, LanDoDayDu? lanDo, List<CanhBaoDayDu> canhBao, String? loi, bool daXoa
});




}
/// @nodoc
class __$LanDoChiTietStateCopyWithImpl<$Res>
    implements _$LanDoChiTietStateCopyWith<$Res> {
  __$LanDoChiTietStateCopyWithImpl(this._self, this._then);

  final _LanDoChiTietState _self;
  final $Res Function(_LanDoChiTietState) _then;

/// Create a copy of LanDoChiTietState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trangThai = null,Object? lanDo = freezed,Object? canhBao = null,Object? loi = freezed,Object? daXoa = null,}) {
  return _then(_LanDoChiTietState(
trangThai: null == trangThai ? _self.trangThai : trangThai // ignore: cast_nullable_to_non_nullable
as TrangThaiTai,lanDo: freezed == lanDo ? _self.lanDo : lanDo // ignore: cast_nullable_to_non_nullable
as LanDoDayDu?,canhBao: null == canhBao ? _self._canhBao : canhBao // ignore: cast_nullable_to_non_nullable
as List<CanhBaoDayDu>,loi: freezed == loi ? _self.loi : loi // ignore: cast_nullable_to_non_nullable
as String?,daXoa: null == daXoa ? _self.daXoa : daXoa // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
