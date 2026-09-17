// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TeamEditorState {

 bool get isLoading; String? get errorMessage; List<Team> get teams; Team? get selectedTeam; bool get isSaving;
/// Create a copy of TeamEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamEditorStateCopyWith<TeamEditorState> get copyWith => _$TeamEditorStateCopyWithImpl<TeamEditorState>(this as TeamEditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TeamEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamEditorState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&const DeepCollectionEquality().equals(other.teams, _this.teams)&&(identical(other.selectedTeam, _this.selectedTeam) || other.selectedTeam == _this.selectedTeam)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving));
}


@override
int get hashCode {
  final _this = this as TeamEditorState;
  return Object.hash(runtimeType,_this.isLoading,_this.errorMessage,const DeepCollectionEquality().hash(_this.teams),_this.selectedTeam,_this.isSaving);
}

@override
String toString() {
  final _this = this as TeamEditorState;
  return 'TeamEditorState(isLoading: ${_this.isLoading}, errorMessage: ${_this.errorMessage}, teams: ${_this.teams}, selectedTeam: ${_this.selectedTeam}, isSaving: ${_this.isSaving})';
}


}

/// @nodoc
abstract mixin class $TeamEditorStateCopyWith<$Res>  {
  factory $TeamEditorStateCopyWith(TeamEditorState value, $Res Function(TeamEditorState) _then) = _$TeamEditorStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? errorMessage, List<Team> teams, Team? selectedTeam, bool isSaving
});




}
/// @nodoc
class _$TeamEditorStateCopyWithImpl<$Res>
    implements $TeamEditorStateCopyWith<$Res> {
  _$TeamEditorStateCopyWithImpl(this._self, this._then);

  final TeamEditorState _self;
  final $Res Function(TeamEditorState) _then;

/// Create a copy of TeamEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? teams = null,Object? selectedTeam = freezed,Object? isSaving = null,}) {
  return _then(TeamEditorState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as List<Team>,selectedTeam: freezed == selectedTeam ? _self.selectedTeam : selectedTeam // ignore: cast_nullable_to_non_nullable
as Team?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamEditorState].
extension TeamEditorStatePatterns on TeamEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamEditorState value)  $default,){
final _that = this;
switch (_that) {
case _TeamEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _TeamEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  List<Team> teams,  Team? selectedTeam,  bool isSaving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamEditorState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.teams,_that.selectedTeam,_that.isSaving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  List<Team> teams,  Team? selectedTeam,  bool isSaving)  $default,) {final _that = this;
switch (_that) {
case _TeamEditorState():
return $default(_that.isLoading,_that.errorMessage,_that.teams,_that.selectedTeam,_that.isSaving);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? errorMessage,  List<Team> teams,  Team? selectedTeam,  bool isSaving)?  $default,) {final _that = this;
switch (_that) {
case _TeamEditorState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.teams,_that.selectedTeam,_that.isSaving);case _:
  return null;

}
}

}

/// @nodoc


class _TeamEditorState implements TeamEditorState {
  const _TeamEditorState({this.isLoading = false, this.errorMessage,  List<Team> teams = const [], this.selectedTeam, this.isSaving = false}): _teams = teams;
  

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;
 final  List<Team> _teams;
@override@JsonKey() List<Team> get teams {
  if (_teams is EqualUnmodifiableListView) return _teams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teams);
}

@override final  Team? selectedTeam;
@override@JsonKey() final  bool isSaving;

/// Create a copy of TeamEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamEditorStateCopyWith<_TeamEditorState> get copyWith => __$TeamEditorStateCopyWithImpl<_TeamEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamEditorState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.teams, _teams)&&(identical(other.selectedTeam, selectedTeam) || other.selectedTeam == selectedTeam)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,errorMessage,const DeepCollectionEquality().hash(_teams),selectedTeam,isSaving);
}

@override
String toString() {
    return 'TeamEditorState(isLoading: $isLoading, errorMessage: $errorMessage, teams: $teams, selectedTeam: $selectedTeam, isSaving: $isSaving)';
}


}

/// @nodoc
abstract mixin class _$TeamEditorStateCopyWith<$Res> implements $TeamEditorStateCopyWith<$Res> {
  factory _$TeamEditorStateCopyWith(_TeamEditorState value, $Res Function(_TeamEditorState) _then) = __$TeamEditorStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? errorMessage, List<Team> teams, Team? selectedTeam, bool isSaving
});




}
/// @nodoc
class __$TeamEditorStateCopyWithImpl<$Res>
    implements _$TeamEditorStateCopyWith<$Res> {
  __$TeamEditorStateCopyWithImpl(this._self, this._then);

  final _TeamEditorState _self;
  final $Res Function(_TeamEditorState) _then;

/// Create a copy of TeamEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? teams = null,Object? selectedTeam = freezed,Object? isSaving = null,}) {
  return _then(_TeamEditorState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,teams: null == teams ? _self._teams : teams // ignore: cast_nullable_to_non_nullable
as List<Team>,selectedTeam: freezed == selectedTeam ? _self.selectedTeam : selectedTeam // ignore: cast_nullable_to_non_nullable
as Team?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
