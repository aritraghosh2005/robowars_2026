// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MatchEditorState {

 bool get isLoading; String? get errorMessage; List<Match> get matches; Match? get selectedMatch; bool get isSaving;
/// Create a copy of MatchEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchEditorStateCopyWith<MatchEditorState> get copyWith => _$MatchEditorStateCopyWithImpl<MatchEditorState>(this as MatchEditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MatchEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchEditorState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&const DeepCollectionEquality().equals(other.matches, _this.matches)&&(identical(other.selectedMatch, _this.selectedMatch) || other.selectedMatch == _this.selectedMatch)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving));
}


@override
int get hashCode {
  final _this = this as MatchEditorState;
  return Object.hash(runtimeType,_this.isLoading,_this.errorMessage,const DeepCollectionEquality().hash(_this.matches),_this.selectedMatch,_this.isSaving);
}

@override
String toString() {
  final _this = this as MatchEditorState;
  return 'MatchEditorState(isLoading: ${_this.isLoading}, errorMessage: ${_this.errorMessage}, matches: ${_this.matches}, selectedMatch: ${_this.selectedMatch}, isSaving: ${_this.isSaving})';
}


}

/// @nodoc
abstract mixin class $MatchEditorStateCopyWith<$Res>  {
  factory $MatchEditorStateCopyWith(MatchEditorState value, $Res Function(MatchEditorState) _then) = _$MatchEditorStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? errorMessage, List<Match> matches, Match? selectedMatch, bool isSaving
});




}
/// @nodoc
class _$MatchEditorStateCopyWithImpl<$Res>
    implements $MatchEditorStateCopyWith<$Res> {
  _$MatchEditorStateCopyWithImpl(this._self, this._then);

  final MatchEditorState _self;
  final $Res Function(MatchEditorState) _then;

/// Create a copy of MatchEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? matches = null,Object? selectedMatch = freezed,Object? isSaving = null,}) {
  return _then(MatchEditorState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as List<Match>,selectedMatch: freezed == selectedMatch ? _self.selectedMatch : selectedMatch // ignore: cast_nullable_to_non_nullable
as Match?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchEditorState].
extension MatchEditorStatePatterns on MatchEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchEditorState value)  $default,){
final _that = this;
switch (_that) {
case _MatchEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _MatchEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  List<Match> matches,  Match? selectedMatch,  bool isSaving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchEditorState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.matches,_that.selectedMatch,_that.isSaving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  List<Match> matches,  Match? selectedMatch,  bool isSaving)  $default,) {final _that = this;
switch (_that) {
case _MatchEditorState():
return $default(_that.isLoading,_that.errorMessage,_that.matches,_that.selectedMatch,_that.isSaving);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? errorMessage,  List<Match> matches,  Match? selectedMatch,  bool isSaving)?  $default,) {final _that = this;
switch (_that) {
case _MatchEditorState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.matches,_that.selectedMatch,_that.isSaving);case _:
  return null;

}
}

}

/// @nodoc


class _MatchEditorState implements MatchEditorState {
  const _MatchEditorState({this.isLoading = false, this.errorMessage,  List<Match> matches = const [], this.selectedMatch, this.isSaving = false}): _matches = matches;
  

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
 final  List<Match> _matches;
@override@JsonKey() List<Match> get matches {
  if (_matches is EqualUnmodifiableListView) return _matches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matches);
}

@override final  Match? selectedMatch;
@override@JsonKey() final  bool isSaving;

/// Create a copy of MatchEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchEditorStateCopyWith<_MatchEditorState> get copyWith => __$MatchEditorStateCopyWithImpl<_MatchEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchEditorState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.matches, _matches)&&(identical(other.selectedMatch, selectedMatch) || other.selectedMatch == selectedMatch)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,errorMessage,const DeepCollectionEquality().hash(_matches),selectedMatch,isSaving);
}

@override
String toString() {
    return 'MatchEditorState(isLoading: $isLoading, errorMessage: $errorMessage, matches: $matches, selectedMatch: $selectedMatch, isSaving: $isSaving)';
}


}

/// @nodoc
abstract mixin class _$MatchEditorStateCopyWith<$Res> implements $MatchEditorStateCopyWith<$Res> {
  factory _$MatchEditorStateCopyWith(_MatchEditorState value, $Res Function(_MatchEditorState) _then) = __$MatchEditorStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? errorMessage, List<Match> matches, Match? selectedMatch, bool isSaving
});




}
/// @nodoc
class __$MatchEditorStateCopyWithImpl<$Res>
    implements _$MatchEditorStateCopyWith<$Res> {
  __$MatchEditorStateCopyWithImpl(this._self, this._then);

  final _MatchEditorState _self;
  final $Res Function(_MatchEditorState) _then;

/// Create a copy of MatchEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? matches = null,Object? selectedMatch = freezed,Object? isSaving = null,}) {
  return _then(_MatchEditorState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,matches: null == matches ? _self._matches : matches // ignore: cast_nullable_to_non_nullable
as List<Match>,selectedMatch: freezed == selectedMatch ? _self.selectedMatch : selectedMatch // ignore: cast_nullable_to_non_nullable
as Match?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
