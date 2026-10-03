// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'canvas_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CanvasEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanvasEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent()';
}


}

/// @nodoc
class $CanvasEventCopyWith<$Res>  {
$CanvasEventCopyWith(CanvasEvent _, $Res Function(CanvasEvent) __);
}


/// Adds pattern-matching-related methods to [CanvasEvent].
extension CanvasEventPatterns on CanvasEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadElements value)?  loadElements,TResult Function( AddElement value)?  addElement,TResult Function( AddElements value)?  addElements,TResult Function( UpdateElement value)?  updateElement,TResult Function( UpdateElements value)?  updateElements,TResult Function( DeleteSelected value)?  deleteSelected,TResult Function( DeleteElements value)?  deleteElements,TResult Function( SelectElement value)?  selectElement,TResult Function( SelectElements value)?  selectElements,TResult Function( ClearSelection value)?  clearSelection,TResult Function( SetDraft value)?  setDraft,TResult Function( SetMarquee value)?  setMarquee,TResult Function( MoveSelected value)?  moveSelected,TResult Function( ResizeElement value)?  resizeElement,TResult Function( RotateSelected value)?  rotateSelected,TResult Function( GroupSelected value)?  groupSelected,TResult Function( UngroupSelected value)?  ungroupSelected,TResult Function( BringSelectedToFront value)?  bringSelectedToFront,TResult Function( SendSelectedToBack value)?  sendSelectedToBack,TResult Function( ToggleLockSelected value)?  toggleLockSelected,TResult Function( ToggleVisibilitySelected value)?  toggleVisibilitySelected,TResult Function( AlignSelected value)?  alignSelected,TResult Function( DistributeSelected value)?  distributeSelected,TResult Function( UpdateConnectedArrows value)?  updateConnectedArrows,TResult Function( SetSnapGuides value)?  setSnapGuides,TResult Function( Undo value)?  undo,TResult Function( Redo value)?  redo,TResult Function( ClearHistory value)?  clearHistory,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadElements() when loadElements != null:
return loadElements(_that);case AddElement() when addElement != null:
return addElement(_that);case AddElements() when addElements != null:
return addElements(_that);case UpdateElement() when updateElement != null:
return updateElement(_that);case UpdateElements() when updateElements != null:
return updateElements(_that);case DeleteSelected() when deleteSelected != null:
return deleteSelected(_that);case DeleteElements() when deleteElements != null:
return deleteElements(_that);case SelectElement() when selectElement != null:
return selectElement(_that);case SelectElements() when selectElements != null:
return selectElements(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case SetDraft() when setDraft != null:
return setDraft(_that);case SetMarquee() when setMarquee != null:
return setMarquee(_that);case MoveSelected() when moveSelected != null:
return moveSelected(_that);case ResizeElement() when resizeElement != null:
return resizeElement(_that);case RotateSelected() when rotateSelected != null:
return rotateSelected(_that);case GroupSelected() when groupSelected != null:
return groupSelected(_that);case UngroupSelected() when ungroupSelected != null:
return ungroupSelected(_that);case BringSelectedToFront() when bringSelectedToFront != null:
return bringSelectedToFront(_that);case SendSelectedToBack() when sendSelectedToBack != null:
return sendSelectedToBack(_that);case ToggleLockSelected() when toggleLockSelected != null:
return toggleLockSelected(_that);case ToggleVisibilitySelected() when toggleVisibilitySelected != null:
return toggleVisibilitySelected(_that);case AlignSelected() when alignSelected != null:
return alignSelected(_that);case DistributeSelected() when distributeSelected != null:
return distributeSelected(_that);case UpdateConnectedArrows() when updateConnectedArrows != null:
return updateConnectedArrows(_that);case SetSnapGuides() when setSnapGuides != null:
return setSnapGuides(_that);case Undo() when undo != null:
return undo(_that);case Redo() when redo != null:
return redo(_that);case ClearHistory() when clearHistory != null:
return clearHistory(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadElements value)  loadElements,required TResult Function( AddElement value)  addElement,required TResult Function( AddElements value)  addElements,required TResult Function( UpdateElement value)  updateElement,required TResult Function( UpdateElements value)  updateElements,required TResult Function( DeleteSelected value)  deleteSelected,required TResult Function( DeleteElements value)  deleteElements,required TResult Function( SelectElement value)  selectElement,required TResult Function( SelectElements value)  selectElements,required TResult Function( ClearSelection value)  clearSelection,required TResult Function( SetDraft value)  setDraft,required TResult Function( SetMarquee value)  setMarquee,required TResult Function( MoveSelected value)  moveSelected,required TResult Function( ResizeElement value)  resizeElement,required TResult Function( RotateSelected value)  rotateSelected,required TResult Function( GroupSelected value)  groupSelected,required TResult Function( UngroupSelected value)  ungroupSelected,required TResult Function( BringSelectedToFront value)  bringSelectedToFront,required TResult Function( SendSelectedToBack value)  sendSelectedToBack,required TResult Function( ToggleLockSelected value)  toggleLockSelected,required TResult Function( ToggleVisibilitySelected value)  toggleVisibilitySelected,required TResult Function( AlignSelected value)  alignSelected,required TResult Function( DistributeSelected value)  distributeSelected,required TResult Function( UpdateConnectedArrows value)  updateConnectedArrows,required TResult Function( SetSnapGuides value)  setSnapGuides,required TResult Function( Undo value)  undo,required TResult Function( Redo value)  redo,required TResult Function( ClearHistory value)  clearHistory,}){
final _that = this;
switch (_that) {
case LoadElements():
return loadElements(_that);case AddElement():
return addElement(_that);case AddElements():
return addElements(_that);case UpdateElement():
return updateElement(_that);case UpdateElements():
return updateElements(_that);case DeleteSelected():
return deleteSelected(_that);case DeleteElements():
return deleteElements(_that);case SelectElement():
return selectElement(_that);case SelectElements():
return selectElements(_that);case ClearSelection():
return clearSelection(_that);case SetDraft():
return setDraft(_that);case SetMarquee():
return setMarquee(_that);case MoveSelected():
return moveSelected(_that);case ResizeElement():
return resizeElement(_that);case RotateSelected():
return rotateSelected(_that);case GroupSelected():
return groupSelected(_that);case UngroupSelected():
return ungroupSelected(_that);case BringSelectedToFront():
return bringSelectedToFront(_that);case SendSelectedToBack():
return sendSelectedToBack(_that);case ToggleLockSelected():
return toggleLockSelected(_that);case ToggleVisibilitySelected():
return toggleVisibilitySelected(_that);case AlignSelected():
return alignSelected(_that);case DistributeSelected():
return distributeSelected(_that);case UpdateConnectedArrows():
return updateConnectedArrows(_that);case SetSnapGuides():
return setSnapGuides(_that);case Undo():
return undo(_that);case Redo():
return redo(_that);case ClearHistory():
return clearHistory(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadElements value)?  loadElements,TResult? Function( AddElement value)?  addElement,TResult? Function( AddElements value)?  addElements,TResult? Function( UpdateElement value)?  updateElement,TResult? Function( UpdateElements value)?  updateElements,TResult? Function( DeleteSelected value)?  deleteSelected,TResult? Function( DeleteElements value)?  deleteElements,TResult? Function( SelectElement value)?  selectElement,TResult? Function( SelectElements value)?  selectElements,TResult? Function( ClearSelection value)?  clearSelection,TResult? Function( SetDraft value)?  setDraft,TResult? Function( SetMarquee value)?  setMarquee,TResult? Function( MoveSelected value)?  moveSelected,TResult? Function( ResizeElement value)?  resizeElement,TResult? Function( RotateSelected value)?  rotateSelected,TResult? Function( GroupSelected value)?  groupSelected,TResult? Function( UngroupSelected value)?  ungroupSelected,TResult? Function( BringSelectedToFront value)?  bringSelectedToFront,TResult? Function( SendSelectedToBack value)?  sendSelectedToBack,TResult? Function( ToggleLockSelected value)?  toggleLockSelected,TResult? Function( ToggleVisibilitySelected value)?  toggleVisibilitySelected,TResult? Function( AlignSelected value)?  alignSelected,TResult? Function( DistributeSelected value)?  distributeSelected,TResult? Function( UpdateConnectedArrows value)?  updateConnectedArrows,TResult? Function( SetSnapGuides value)?  setSnapGuides,TResult? Function( Undo value)?  undo,TResult? Function( Redo value)?  redo,TResult? Function( ClearHistory value)?  clearHistory,}){
final _that = this;
switch (_that) {
case LoadElements() when loadElements != null:
return loadElements(_that);case AddElement() when addElement != null:
return addElement(_that);case AddElements() when addElements != null:
return addElements(_that);case UpdateElement() when updateElement != null:
return updateElement(_that);case UpdateElements() when updateElements != null:
return updateElements(_that);case DeleteSelected() when deleteSelected != null:
return deleteSelected(_that);case DeleteElements() when deleteElements != null:
return deleteElements(_that);case SelectElement() when selectElement != null:
return selectElement(_that);case SelectElements() when selectElements != null:
return selectElements(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case SetDraft() when setDraft != null:
return setDraft(_that);case SetMarquee() when setMarquee != null:
return setMarquee(_that);case MoveSelected() when moveSelected != null:
return moveSelected(_that);case ResizeElement() when resizeElement != null:
return resizeElement(_that);case RotateSelected() when rotateSelected != null:
return rotateSelected(_that);case GroupSelected() when groupSelected != null:
return groupSelected(_that);case UngroupSelected() when ungroupSelected != null:
return ungroupSelected(_that);case BringSelectedToFront() when bringSelectedToFront != null:
return bringSelectedToFront(_that);case SendSelectedToBack() when sendSelectedToBack != null:
return sendSelectedToBack(_that);case ToggleLockSelected() when toggleLockSelected != null:
return toggleLockSelected(_that);case ToggleVisibilitySelected() when toggleVisibilitySelected != null:
return toggleVisibilitySelected(_that);case AlignSelected() when alignSelected != null:
return alignSelected(_that);case DistributeSelected() when distributeSelected != null:
return distributeSelected(_that);case UpdateConnectedArrows() when updateConnectedArrows != null:
return updateConnectedArrows(_that);case SetSnapGuides() when setSnapGuides != null:
return setSnapGuides(_that);case Undo() when undo != null:
return undo(_that);case Redo() when redo != null:
return redo(_that);case ClearHistory() when clearHistory != null:
return clearHistory(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<BoardElement> elements)?  loadElements,TResult Function( BoardElement element)?  addElement,TResult Function( List<BoardElement> elements)?  addElements,TResult Function( BoardElement element)?  updateElement,TResult Function( List<BoardElement> elements)?  updateElements,TResult Function()?  deleteSelected,TResult Function( Set<String> ids)?  deleteElements,TResult Function( String id,  bool toggle)?  selectElement,TResult Function( Set<String> ids)?  selectElements,TResult Function()?  clearSelection,TResult Function( BoardElement? draft)?  setDraft,TResult Function( Rect? marquee)?  setMarquee,TResult Function( Offset delta)?  moveSelected,TResult Function( String id,  Rect newBounds)?  resizeElement,TResult Function( double deltaAngle)?  rotateSelected,TResult Function()?  groupSelected,TResult Function()?  ungroupSelected,TResult Function()?  bringSelectedToFront,TResult Function()?  sendSelectedToBack,TResult Function()?  toggleLockSelected,TResult Function()?  toggleVisibilitySelected,TResult Function( AlignDirection direction)?  alignSelected,TResult Function( DistributeDirection direction)?  distributeSelected,TResult Function()?  updateConnectedArrows,TResult Function( List<SnapGuide> guides)?  setSnapGuides,TResult Function()?  undo,TResult Function()?  redo,TResult Function()?  clearHistory,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadElements() when loadElements != null:
return loadElements(_that.elements);case AddElement() when addElement != null:
return addElement(_that.element);case AddElements() when addElements != null:
return addElements(_that.elements);case UpdateElement() when updateElement != null:
return updateElement(_that.element);case UpdateElements() when updateElements != null:
return updateElements(_that.elements);case DeleteSelected() when deleteSelected != null:
return deleteSelected();case DeleteElements() when deleteElements != null:
return deleteElements(_that.ids);case SelectElement() when selectElement != null:
return selectElement(_that.id,_that.toggle);case SelectElements() when selectElements != null:
return selectElements(_that.ids);case ClearSelection() when clearSelection != null:
return clearSelection();case SetDraft() when setDraft != null:
return setDraft(_that.draft);case SetMarquee() when setMarquee != null:
return setMarquee(_that.marquee);case MoveSelected() when moveSelected != null:
return moveSelected(_that.delta);case ResizeElement() when resizeElement != null:
return resizeElement(_that.id,_that.newBounds);case RotateSelected() when rotateSelected != null:
return rotateSelected(_that.deltaAngle);case GroupSelected() when groupSelected != null:
return groupSelected();case UngroupSelected() when ungroupSelected != null:
return ungroupSelected();case BringSelectedToFront() when bringSelectedToFront != null:
return bringSelectedToFront();case SendSelectedToBack() when sendSelectedToBack != null:
return sendSelectedToBack();case ToggleLockSelected() when toggleLockSelected != null:
return toggleLockSelected();case ToggleVisibilitySelected() when toggleVisibilitySelected != null:
return toggleVisibilitySelected();case AlignSelected() when alignSelected != null:
return alignSelected(_that.direction);case DistributeSelected() when distributeSelected != null:
return distributeSelected(_that.direction);case UpdateConnectedArrows() when updateConnectedArrows != null:
return updateConnectedArrows();case SetSnapGuides() when setSnapGuides != null:
return setSnapGuides(_that.guides);case Undo() when undo != null:
return undo();case Redo() when redo != null:
return redo();case ClearHistory() when clearHistory != null:
return clearHistory();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<BoardElement> elements)  loadElements,required TResult Function( BoardElement element)  addElement,required TResult Function( List<BoardElement> elements)  addElements,required TResult Function( BoardElement element)  updateElement,required TResult Function( List<BoardElement> elements)  updateElements,required TResult Function()  deleteSelected,required TResult Function( Set<String> ids)  deleteElements,required TResult Function( String id,  bool toggle)  selectElement,required TResult Function( Set<String> ids)  selectElements,required TResult Function()  clearSelection,required TResult Function( BoardElement? draft)  setDraft,required TResult Function( Rect? marquee)  setMarquee,required TResult Function( Offset delta)  moveSelected,required TResult Function( String id,  Rect newBounds)  resizeElement,required TResult Function( double deltaAngle)  rotateSelected,required TResult Function()  groupSelected,required TResult Function()  ungroupSelected,required TResult Function()  bringSelectedToFront,required TResult Function()  sendSelectedToBack,required TResult Function()  toggleLockSelected,required TResult Function()  toggleVisibilitySelected,required TResult Function( AlignDirection direction)  alignSelected,required TResult Function( DistributeDirection direction)  distributeSelected,required TResult Function()  updateConnectedArrows,required TResult Function( List<SnapGuide> guides)  setSnapGuides,required TResult Function()  undo,required TResult Function()  redo,required TResult Function()  clearHistory,}) {final _that = this;
switch (_that) {
case LoadElements():
return loadElements(_that.elements);case AddElement():
return addElement(_that.element);case AddElements():
return addElements(_that.elements);case UpdateElement():
return updateElement(_that.element);case UpdateElements():
return updateElements(_that.elements);case DeleteSelected():
return deleteSelected();case DeleteElements():
return deleteElements(_that.ids);case SelectElement():
return selectElement(_that.id,_that.toggle);case SelectElements():
return selectElements(_that.ids);case ClearSelection():
return clearSelection();case SetDraft():
return setDraft(_that.draft);case SetMarquee():
return setMarquee(_that.marquee);case MoveSelected():
return moveSelected(_that.delta);case ResizeElement():
return resizeElement(_that.id,_that.newBounds);case RotateSelected():
return rotateSelected(_that.deltaAngle);case GroupSelected():
return groupSelected();case UngroupSelected():
return ungroupSelected();case BringSelectedToFront():
return bringSelectedToFront();case SendSelectedToBack():
return sendSelectedToBack();case ToggleLockSelected():
return toggleLockSelected();case ToggleVisibilitySelected():
return toggleVisibilitySelected();case AlignSelected():
return alignSelected(_that.direction);case DistributeSelected():
return distributeSelected(_that.direction);case UpdateConnectedArrows():
return updateConnectedArrows();case SetSnapGuides():
return setSnapGuides(_that.guides);case Undo():
return undo();case Redo():
return redo();case ClearHistory():
return clearHistory();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<BoardElement> elements)?  loadElements,TResult? Function( BoardElement element)?  addElement,TResult? Function( List<BoardElement> elements)?  addElements,TResult? Function( BoardElement element)?  updateElement,TResult? Function( List<BoardElement> elements)?  updateElements,TResult? Function()?  deleteSelected,TResult? Function( Set<String> ids)?  deleteElements,TResult? Function( String id,  bool toggle)?  selectElement,TResult? Function( Set<String> ids)?  selectElements,TResult? Function()?  clearSelection,TResult? Function( BoardElement? draft)?  setDraft,TResult? Function( Rect? marquee)?  setMarquee,TResult? Function( Offset delta)?  moveSelected,TResult? Function( String id,  Rect newBounds)?  resizeElement,TResult? Function( double deltaAngle)?  rotateSelected,TResult? Function()?  groupSelected,TResult? Function()?  ungroupSelected,TResult? Function()?  bringSelectedToFront,TResult? Function()?  sendSelectedToBack,TResult? Function()?  toggleLockSelected,TResult? Function()?  toggleVisibilitySelected,TResult? Function( AlignDirection direction)?  alignSelected,TResult? Function( DistributeDirection direction)?  distributeSelected,TResult? Function()?  updateConnectedArrows,TResult? Function( List<SnapGuide> guides)?  setSnapGuides,TResult? Function()?  undo,TResult? Function()?  redo,TResult? Function()?  clearHistory,}) {final _that = this;
switch (_that) {
case LoadElements() when loadElements != null:
return loadElements(_that.elements);case AddElement() when addElement != null:
return addElement(_that.element);case AddElements() when addElements != null:
return addElements(_that.elements);case UpdateElement() when updateElement != null:
return updateElement(_that.element);case UpdateElements() when updateElements != null:
return updateElements(_that.elements);case DeleteSelected() when deleteSelected != null:
return deleteSelected();case DeleteElements() when deleteElements != null:
return deleteElements(_that.ids);case SelectElement() when selectElement != null:
return selectElement(_that.id,_that.toggle);case SelectElements() when selectElements != null:
return selectElements(_that.ids);case ClearSelection() when clearSelection != null:
return clearSelection();case SetDraft() when setDraft != null:
return setDraft(_that.draft);case SetMarquee() when setMarquee != null:
return setMarquee(_that.marquee);case MoveSelected() when moveSelected != null:
return moveSelected(_that.delta);case ResizeElement() when resizeElement != null:
return resizeElement(_that.id,_that.newBounds);case RotateSelected() when rotateSelected != null:
return rotateSelected(_that.deltaAngle);case GroupSelected() when groupSelected != null:
return groupSelected();case UngroupSelected() when ungroupSelected != null:
return ungroupSelected();case BringSelectedToFront() when bringSelectedToFront != null:
return bringSelectedToFront();case SendSelectedToBack() when sendSelectedToBack != null:
return sendSelectedToBack();case ToggleLockSelected() when toggleLockSelected != null:
return toggleLockSelected();case ToggleVisibilitySelected() when toggleVisibilitySelected != null:
return toggleVisibilitySelected();case AlignSelected() when alignSelected != null:
return alignSelected(_that.direction);case DistributeSelected() when distributeSelected != null:
return distributeSelected(_that.direction);case UpdateConnectedArrows() when updateConnectedArrows != null:
return updateConnectedArrows();case SetSnapGuides() when setSnapGuides != null:
return setSnapGuides(_that.guides);case Undo() when undo != null:
return undo();case Redo() when redo != null:
return redo();case ClearHistory() when clearHistory != null:
return clearHistory();case _:
  return null;

}
}

}

/// @nodoc


class LoadElements implements CanvasEvent {
  const LoadElements(this.elements);
  

 final  List<BoardElement> elements;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoadElementsCopyWith<LoadElements> get copyWith => _$LoadElementsCopyWithImpl<LoadElements>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadElements&&const DeepCollectionEquality().equals(other.elements, elements));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(elements));

@override
String toString() {
  return 'CanvasEvent.loadElements(elements: $elements)';
}


}

/// @nodoc
abstract mixin class $LoadElementsCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $LoadElementsCopyWith(LoadElements value, $Res Function(LoadElements) _then) = _$LoadElementsCopyWithImpl;
@useResult
$Res call({
 List<BoardElement> elements
});




}
/// @nodoc
class _$LoadElementsCopyWithImpl<$Res>
    implements $LoadElementsCopyWith<$Res> {
  _$LoadElementsCopyWithImpl(this._self, this._then);

  final LoadElements _self;
  final $Res Function(LoadElements) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? elements = null,}) {
  return _then(LoadElements(
null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,
  ));
}


}

/// @nodoc


class AddElement implements CanvasEvent {
  const AddElement(this.element);
  

 final  BoardElement element;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddElementCopyWith<AddElement> get copyWith => _$AddElementCopyWithImpl<AddElement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddElement&&(identical(other.element, element) || other.element == element));
}


@override
int get hashCode => Object.hash(runtimeType,element);

@override
String toString() {
  return 'CanvasEvent.addElement(element: $element)';
}


}

/// @nodoc
abstract mixin class $AddElementCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $AddElementCopyWith(AddElement value, $Res Function(AddElement) _then) = _$AddElementCopyWithImpl;
@useResult
$Res call({
 BoardElement element
});


$BoardElementCopyWith<$Res> get element;

}
/// @nodoc
class _$AddElementCopyWithImpl<$Res>
    implements $AddElementCopyWith<$Res> {
  _$AddElementCopyWithImpl(this._self, this._then);

  final AddElement _self;
  final $Res Function(AddElement) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? element = null,}) {
  return _then(AddElement(
null == element ? _self.element : element // ignore: cast_nullable_to_non_nullable
as BoardElement,
  ));
}

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardElementCopyWith<$Res> get element {
  
  return $BoardElementCopyWith<$Res>(_self.element, (value) {
    return _then(_self.copyWith(element: value));
  });
}
}

/// @nodoc


class AddElements implements CanvasEvent {
  const AddElements(this.elements);
  

 final  List<BoardElement> elements;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddElementsCopyWith<AddElements> get copyWith => _$AddElementsCopyWithImpl<AddElements>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddElements&&const DeepCollectionEquality().equals(other.elements, elements));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(elements));

@override
String toString() {
  return 'CanvasEvent.addElements(elements: $elements)';
}


}

/// @nodoc
abstract mixin class $AddElementsCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $AddElementsCopyWith(AddElements value, $Res Function(AddElements) _then) = _$AddElementsCopyWithImpl;
@useResult
$Res call({
 List<BoardElement> elements
});




}
/// @nodoc
class _$AddElementsCopyWithImpl<$Res>
    implements $AddElementsCopyWith<$Res> {
  _$AddElementsCopyWithImpl(this._self, this._then);

  final AddElements _self;
  final $Res Function(AddElements) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? elements = null,}) {
  return _then(AddElements(
null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,
  ));
}


}

/// @nodoc


class UpdateElement implements CanvasEvent {
  const UpdateElement(this.element);
  

 final  BoardElement element;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateElementCopyWith<UpdateElement> get copyWith => _$UpdateElementCopyWithImpl<UpdateElement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateElement&&(identical(other.element, element) || other.element == element));
}


@override
int get hashCode => Object.hash(runtimeType,element);

@override
String toString() {
  return 'CanvasEvent.updateElement(element: $element)';
}


}

/// @nodoc
abstract mixin class $UpdateElementCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $UpdateElementCopyWith(UpdateElement value, $Res Function(UpdateElement) _then) = _$UpdateElementCopyWithImpl;
@useResult
$Res call({
 BoardElement element
});


$BoardElementCopyWith<$Res> get element;

}
/// @nodoc
class _$UpdateElementCopyWithImpl<$Res>
    implements $UpdateElementCopyWith<$Res> {
  _$UpdateElementCopyWithImpl(this._self, this._then);

  final UpdateElement _self;
  final $Res Function(UpdateElement) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? element = null,}) {
  return _then(UpdateElement(
null == element ? _self.element : element // ignore: cast_nullable_to_non_nullable
as BoardElement,
  ));
}

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardElementCopyWith<$Res> get element {
  
  return $BoardElementCopyWith<$Res>(_self.element, (value) {
    return _then(_self.copyWith(element: value));
  });
}
}

/// @nodoc


class UpdateElements implements CanvasEvent {
  const UpdateElements(this.elements);
  

 final  List<BoardElement> elements;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateElementsCopyWith<UpdateElements> get copyWith => _$UpdateElementsCopyWithImpl<UpdateElements>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateElements&&const DeepCollectionEquality().equals(other.elements, elements));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(elements));

@override
String toString() {
  return 'CanvasEvent.updateElements(elements: $elements)';
}


}

/// @nodoc
abstract mixin class $UpdateElementsCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $UpdateElementsCopyWith(UpdateElements value, $Res Function(UpdateElements) _then) = _$UpdateElementsCopyWithImpl;
@useResult
$Res call({
 List<BoardElement> elements
});




}
/// @nodoc
class _$UpdateElementsCopyWithImpl<$Res>
    implements $UpdateElementsCopyWith<$Res> {
  _$UpdateElementsCopyWithImpl(this._self, this._then);

  final UpdateElements _self;
  final $Res Function(UpdateElements) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? elements = null,}) {
  return _then(UpdateElements(
null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<BoardElement>,
  ));
}


}

/// @nodoc


class DeleteSelected implements CanvasEvent {
  const DeleteSelected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteSelected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.deleteSelected()';
}


}




/// @nodoc


class DeleteElements implements CanvasEvent {
  const DeleteElements(this.ids);
  

 final  Set<String> ids;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteElementsCopyWith<DeleteElements> get copyWith => _$DeleteElementsCopyWithImpl<DeleteElements>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteElements&&const DeepCollectionEquality().equals(other.ids, ids));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ids));

@override
String toString() {
  return 'CanvasEvent.deleteElements(ids: $ids)';
}


}

/// @nodoc
abstract mixin class $DeleteElementsCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $DeleteElementsCopyWith(DeleteElements value, $Res Function(DeleteElements) _then) = _$DeleteElementsCopyWithImpl;
@useResult
$Res call({
 Set<String> ids
});




}
/// @nodoc
class _$DeleteElementsCopyWithImpl<$Res>
    implements $DeleteElementsCopyWith<$Res> {
  _$DeleteElementsCopyWithImpl(this._self, this._then);

  final DeleteElements _self;
  final $Res Function(DeleteElements) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ids = null,}) {
  return _then(DeleteElements(
null == ids ? _self.ids : ids // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc


class SelectElement implements CanvasEvent {
  const SelectElement(this.id, {this.toggle = false});
  

 final  String id;
@JsonKey() final  bool toggle;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectElementCopyWith<SelectElement> get copyWith => _$SelectElementCopyWithImpl<SelectElement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectElement&&(identical(other.id, id) || other.id == id)&&(identical(other.toggle, toggle) || other.toggle == toggle));
}


@override
int get hashCode => Object.hash(runtimeType,id,toggle);

@override
String toString() {
  return 'CanvasEvent.selectElement(id: $id, toggle: $toggle)';
}


}

/// @nodoc
abstract mixin class $SelectElementCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $SelectElementCopyWith(SelectElement value, $Res Function(SelectElement) _then) = _$SelectElementCopyWithImpl;
@useResult
$Res call({
 String id, bool toggle
});




}
/// @nodoc
class _$SelectElementCopyWithImpl<$Res>
    implements $SelectElementCopyWith<$Res> {
  _$SelectElementCopyWithImpl(this._self, this._then);

  final SelectElement _self;
  final $Res Function(SelectElement) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? toggle = null,}) {
  return _then(SelectElement(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,toggle: null == toggle ? _self.toggle : toggle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class SelectElements implements CanvasEvent {
  const SelectElements(this.ids);
  

 final  Set<String> ids;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectElementsCopyWith<SelectElements> get copyWith => _$SelectElementsCopyWithImpl<SelectElements>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectElements&&const DeepCollectionEquality().equals(other.ids, ids));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ids));

@override
String toString() {
  return 'CanvasEvent.selectElements(ids: $ids)';
}


}

/// @nodoc
abstract mixin class $SelectElementsCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $SelectElementsCopyWith(SelectElements value, $Res Function(SelectElements) _then) = _$SelectElementsCopyWithImpl;
@useResult
$Res call({
 Set<String> ids
});




}
/// @nodoc
class _$SelectElementsCopyWithImpl<$Res>
    implements $SelectElementsCopyWith<$Res> {
  _$SelectElementsCopyWithImpl(this._self, this._then);

  final SelectElements _self;
  final $Res Function(SelectElements) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ids = null,}) {
  return _then(SelectElements(
null == ids ? _self.ids : ids // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc


class ClearSelection implements CanvasEvent {
  const ClearSelection();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.clearSelection()';
}


}




/// @nodoc


class SetDraft implements CanvasEvent {
  const SetDraft(this.draft);
  

 final  BoardElement? draft;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetDraftCopyWith<SetDraft> get copyWith => _$SetDraftCopyWithImpl<SetDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetDraft&&(identical(other.draft, draft) || other.draft == draft));
}


@override
int get hashCode => Object.hash(runtimeType,draft);

@override
String toString() {
  return 'CanvasEvent.setDraft(draft: $draft)';
}


}

/// @nodoc
abstract mixin class $SetDraftCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $SetDraftCopyWith(SetDraft value, $Res Function(SetDraft) _then) = _$SetDraftCopyWithImpl;
@useResult
$Res call({
 BoardElement? draft
});


$BoardElementCopyWith<$Res>? get draft;

}
/// @nodoc
class _$SetDraftCopyWithImpl<$Res>
    implements $SetDraftCopyWith<$Res> {
  _$SetDraftCopyWithImpl(this._self, this._then);

  final SetDraft _self;
  final $Res Function(SetDraft) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? draft = freezed,}) {
  return _then(SetDraft(
freezed == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as BoardElement?,
  ));
}

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BoardElementCopyWith<$Res>? get draft {
    if (_self.draft == null) {
    return null;
  }

  return $BoardElementCopyWith<$Res>(_self.draft!, (value) {
    return _then(_self.copyWith(draft: value));
  });
}
}

/// @nodoc


class SetMarquee implements CanvasEvent {
  const SetMarquee(this.marquee);
  

 final  Rect? marquee;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetMarqueeCopyWith<SetMarquee> get copyWith => _$SetMarqueeCopyWithImpl<SetMarquee>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetMarquee&&(identical(other.marquee, marquee) || other.marquee == marquee));
}


@override
int get hashCode => Object.hash(runtimeType,marquee);

@override
String toString() {
  return 'CanvasEvent.setMarquee(marquee: $marquee)';
}


}

/// @nodoc
abstract mixin class $SetMarqueeCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $SetMarqueeCopyWith(SetMarquee value, $Res Function(SetMarquee) _then) = _$SetMarqueeCopyWithImpl;
@useResult
$Res call({
 Rect? marquee
});




}
/// @nodoc
class _$SetMarqueeCopyWithImpl<$Res>
    implements $SetMarqueeCopyWith<$Res> {
  _$SetMarqueeCopyWithImpl(this._self, this._then);

  final SetMarquee _self;
  final $Res Function(SetMarquee) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? marquee = freezed,}) {
  return _then(SetMarquee(
freezed == marquee ? _self.marquee : marquee // ignore: cast_nullable_to_non_nullable
as Rect?,
  ));
}


}

/// @nodoc


class MoveSelected implements CanvasEvent {
  const MoveSelected(this.delta);
  

 final  Offset delta;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveSelectedCopyWith<MoveSelected> get copyWith => _$MoveSelectedCopyWithImpl<MoveSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveSelected&&(identical(other.delta, delta) || other.delta == delta));
}


@override
int get hashCode => Object.hash(runtimeType,delta);

@override
String toString() {
  return 'CanvasEvent.moveSelected(delta: $delta)';
}


}

/// @nodoc
abstract mixin class $MoveSelectedCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $MoveSelectedCopyWith(MoveSelected value, $Res Function(MoveSelected) _then) = _$MoveSelectedCopyWithImpl;
@useResult
$Res call({
 Offset delta
});




}
/// @nodoc
class _$MoveSelectedCopyWithImpl<$Res>
    implements $MoveSelectedCopyWith<$Res> {
  _$MoveSelectedCopyWithImpl(this._self, this._then);

  final MoveSelected _self;
  final $Res Function(MoveSelected) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? delta = null,}) {
  return _then(MoveSelected(
null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as Offset,
  ));
}


}

/// @nodoc


class ResizeElement implements CanvasEvent {
  const ResizeElement(this.id, this.newBounds);
  

 final  String id;
 final  Rect newBounds;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResizeElementCopyWith<ResizeElement> get copyWith => _$ResizeElementCopyWithImpl<ResizeElement>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResizeElement&&(identical(other.id, id) || other.id == id)&&(identical(other.newBounds, newBounds) || other.newBounds == newBounds));
}


@override
int get hashCode => Object.hash(runtimeType,id,newBounds);

@override
String toString() {
  return 'CanvasEvent.resizeElement(id: $id, newBounds: $newBounds)';
}


}

/// @nodoc
abstract mixin class $ResizeElementCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $ResizeElementCopyWith(ResizeElement value, $Res Function(ResizeElement) _then) = _$ResizeElementCopyWithImpl;
@useResult
$Res call({
 String id, Rect newBounds
});




}
/// @nodoc
class _$ResizeElementCopyWithImpl<$Res>
    implements $ResizeElementCopyWith<$Res> {
  _$ResizeElementCopyWithImpl(this._self, this._then);

  final ResizeElement _self;
  final $Res Function(ResizeElement) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? newBounds = null,}) {
  return _then(ResizeElement(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,null == newBounds ? _self.newBounds : newBounds // ignore: cast_nullable_to_non_nullable
as Rect,
  ));
}


}

/// @nodoc


class RotateSelected implements CanvasEvent {
  const RotateSelected(this.deltaAngle);
  

 final  double deltaAngle;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RotateSelectedCopyWith<RotateSelected> get copyWith => _$RotateSelectedCopyWithImpl<RotateSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RotateSelected&&(identical(other.deltaAngle, deltaAngle) || other.deltaAngle == deltaAngle));
}


@override
int get hashCode => Object.hash(runtimeType,deltaAngle);

@override
String toString() {
  return 'CanvasEvent.rotateSelected(deltaAngle: $deltaAngle)';
}


}

/// @nodoc
abstract mixin class $RotateSelectedCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $RotateSelectedCopyWith(RotateSelected value, $Res Function(RotateSelected) _then) = _$RotateSelectedCopyWithImpl;
@useResult
$Res call({
 double deltaAngle
});




}
/// @nodoc
class _$RotateSelectedCopyWithImpl<$Res>
    implements $RotateSelectedCopyWith<$Res> {
  _$RotateSelectedCopyWithImpl(this._self, this._then);

  final RotateSelected _self;
  final $Res Function(RotateSelected) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? deltaAngle = null,}) {
  return _then(RotateSelected(
null == deltaAngle ? _self.deltaAngle : deltaAngle // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class GroupSelected implements CanvasEvent {
  const GroupSelected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupSelected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.groupSelected()';
}


}




/// @nodoc


class UngroupSelected implements CanvasEvent {
  const UngroupSelected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UngroupSelected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.ungroupSelected()';
}


}




/// @nodoc


class BringSelectedToFront implements CanvasEvent {
  const BringSelectedToFront();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BringSelectedToFront);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.bringSelectedToFront()';
}


}




/// @nodoc


class SendSelectedToBack implements CanvasEvent {
  const SendSelectedToBack();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendSelectedToBack);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.sendSelectedToBack()';
}


}




/// @nodoc


class ToggleLockSelected implements CanvasEvent {
  const ToggleLockSelected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleLockSelected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.toggleLockSelected()';
}


}




/// @nodoc


class ToggleVisibilitySelected implements CanvasEvent {
  const ToggleVisibilitySelected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToggleVisibilitySelected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.toggleVisibilitySelected()';
}


}




/// @nodoc


class AlignSelected implements CanvasEvent {
  const AlignSelected(this.direction);
  

 final  AlignDirection direction;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlignSelectedCopyWith<AlignSelected> get copyWith => _$AlignSelectedCopyWithImpl<AlignSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlignSelected&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,direction);

@override
String toString() {
  return 'CanvasEvent.alignSelected(direction: $direction)';
}


}

/// @nodoc
abstract mixin class $AlignSelectedCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $AlignSelectedCopyWith(AlignSelected value, $Res Function(AlignSelected) _then) = _$AlignSelectedCopyWithImpl;
@useResult
$Res call({
 AlignDirection direction
});




}
/// @nodoc
class _$AlignSelectedCopyWithImpl<$Res>
    implements $AlignSelectedCopyWith<$Res> {
  _$AlignSelectedCopyWithImpl(this._self, this._then);

  final AlignSelected _self;
  final $Res Function(AlignSelected) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? direction = null,}) {
  return _then(AlignSelected(
null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as AlignDirection,
  ));
}


}

/// @nodoc


class DistributeSelected implements CanvasEvent {
  const DistributeSelected(this.direction);
  

 final  DistributeDirection direction;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DistributeSelectedCopyWith<DistributeSelected> get copyWith => _$DistributeSelectedCopyWithImpl<DistributeSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DistributeSelected&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,direction);

@override
String toString() {
  return 'CanvasEvent.distributeSelected(direction: $direction)';
}


}

/// @nodoc
abstract mixin class $DistributeSelectedCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $DistributeSelectedCopyWith(DistributeSelected value, $Res Function(DistributeSelected) _then) = _$DistributeSelectedCopyWithImpl;
@useResult
$Res call({
 DistributeDirection direction
});




}
/// @nodoc
class _$DistributeSelectedCopyWithImpl<$Res>
    implements $DistributeSelectedCopyWith<$Res> {
  _$DistributeSelectedCopyWithImpl(this._self, this._then);

  final DistributeSelected _self;
  final $Res Function(DistributeSelected) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? direction = null,}) {
  return _then(DistributeSelected(
null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as DistributeDirection,
  ));
}


}

/// @nodoc


class UpdateConnectedArrows implements CanvasEvent {
  const UpdateConnectedArrows();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateConnectedArrows);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.updateConnectedArrows()';
}


}




/// @nodoc


class SetSnapGuides implements CanvasEvent {
  const SetSnapGuides(this.guides);
  

 final  List<SnapGuide> guides;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetSnapGuidesCopyWith<SetSnapGuides> get copyWith => _$SetSnapGuidesCopyWithImpl<SetSnapGuides>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetSnapGuides&&const DeepCollectionEquality().equals(other.guides, guides));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(guides));

@override
String toString() {
  return 'CanvasEvent.setSnapGuides(guides: $guides)';
}


}

/// @nodoc
abstract mixin class $SetSnapGuidesCopyWith<$Res> implements $CanvasEventCopyWith<$Res> {
  factory $SetSnapGuidesCopyWith(SetSnapGuides value, $Res Function(SetSnapGuides) _then) = _$SetSnapGuidesCopyWithImpl;
@useResult
$Res call({
 List<SnapGuide> guides
});




}
/// @nodoc
class _$SetSnapGuidesCopyWithImpl<$Res>
    implements $SetSnapGuidesCopyWith<$Res> {
  _$SetSnapGuidesCopyWithImpl(this._self, this._then);

  final SetSnapGuides _self;
  final $Res Function(SetSnapGuides) _then;

/// Create a copy of CanvasEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? guides = null,}) {
  return _then(SetSnapGuides(
null == guides ? _self.guides : guides // ignore: cast_nullable_to_non_nullable
as List<SnapGuide>,
  ));
}


}

/// @nodoc


class Undo implements CanvasEvent {
  const Undo();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Undo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.undo()';
}


}




/// @nodoc


class Redo implements CanvasEvent {
  const Redo();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Redo);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.redo()';
}


}




/// @nodoc


class ClearHistory implements CanvasEvent {
  const ClearHistory();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearHistory);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CanvasEvent.clearHistory()';
}


}




// dart format on
