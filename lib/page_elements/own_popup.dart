import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

const double _kMenuHorizontalPadding = 16.0;

/// KeepKeyboardPopup version of [PopupMenuItem]. This is quite different from
/// [PopupMenuItem], this works more like a [ListTile].
///
/// you can't use [PopupMenuItem] with [WithKeepKeyboardPopupMenu]
/// because [PopupMenuItem] will pop the current route when tapped. Since
/// [WithKeepKeyboardPopupMenu] does not push a new route, this will cause the
/// page behind the popup menu be popped. Use [KeepKeyboardPopupMenuItem]
/// instead.
class KeepKeyboardPopupMenuItem extends StatelessWidget {
  final double height;
  final Widget? child;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const KeepKeyboardPopupMenuItem({
    Key? key,
    this.height = kMinInteractiveDimension,
    this.textStyle,
    this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    TextStyle style =
        textStyle ?? popupMenuTheme.textStyle ?? theme.textTheme.subtitle1!;

    if (onTap == null) style = style.copyWith(color: theme.disabledColor);

    Widget item = DefaultTextStyle(
      style: style,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        constraints: BoxConstraints(minHeight: height),
        padding:
        const EdgeInsets.symmetric(horizontal: _kMenuHorizontalPadding),
        child: child,
      ),
    );

    if (onTap == null) {
      final bool isDark = theme.brightness == Brightness.dark;
      item = IconTheme.merge(
        data: IconThemeData(opacity: isDark ? 0.5 : 0.38),
        child: item,
      );
    }

    return MergeSemantics(
      child: Semantics(
        enabled: onTap != null,
        button: true,
        child: InkWell(
          onTap: onTap,
          canRequestFocus: onTap != null,
          child: item,
        ),
      ),
    );
  }
}


const double kMenuScreenPadding = 8.0;

/// Used to calculate the position of the popup.
/// [menuSize]: size of the context menu, always smaller than [overlayRect.size]
/// [overlayRect]: rect of the screen excluding keyboard and status bar
/// [buttonRect]: rect of the button that triggered context menu
typedef CalculatePopupPosition = Offset Function(
    Size menuSize,
    Rect overlayRect,
    Rect buttonRect,
    );
typedef PopupMenuBackgroundBuilder = Widget Function(
    BuildContext context,
    Widget child,
    );

const double _kMenuWidthStep = 56.0;
const double _kMenuMaxWidth = 5.0 * _kMenuWidthStep;
const double _kMenuMinWidth = 2.0 * _kMenuWidthStep;

const double _kMenuVerticalPadding = 8.0;

/// Used to build the widget that is going to open the popup menu. This widget
/// can call [openPopup] to open the popup menu.
typedef ChildBuilder = Widget Function(
    BuildContext context,
    OpenPopupFn openPopup,
    );

/// Used to build the custom widget inside the popup menu. The widget can call
/// [openPopup] to open the popup menu. [WithKeepKeyboardPopupMenu] will then
/// wrap your widget in a [ListView].
typedef MenuBuilder = Widget Function(
    BuildContext context,
    ClosePopupFn closePopup,
    );

/// Used to build the item list inside the popup menu. Widgets can call
/// [openPopup] to open the popup menu. [WithKeepKeyboardPopupMenu] will then
/// wrap this list in a [ListView] with vertical padding of
/// [_kMenuVerticalPadding].
typedef MenuItemBuilder = List<KeepKeyboardPopupMenuItem> Function(
    BuildContext context,
    ClosePopupFn closePopup,
    );

/// Function type to open the popup menu, returns a future that resolves when
/// the opening animation stops.
typedef OpenPopupFn = Future<void> Function();

/// Function type to close the popup menu, returns a future that resolves when
/// the closing animation stops.
typedef ClosePopupFn = Future<void> Function();

enum PopupMenuState {
  CLOSED,
  OPENING,
  OPENED,
  CLOSING,
}

class PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  PopupMenuRouteLayout({
    required this.buttonRect,
    required this.overlayRect,
    required this.calculatePopupPosition,
  });

  /// Rect of the button that triggered this popup.
  final Rect buttonRect;

  /// Rect of the screen excluding keyboard and status bar.
  final Rect overlayRect;

  /// Function to calculate position of the popup.
  final CalculatePopupPosition calculatePopupPosition;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(
      overlayRect.size -
          const Offset(kMenuScreenPadding * 2, kMenuScreenPadding * 2) as Size,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return calculatePopupPosition(childSize, overlayRect, buttonRect);
  }

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => true;
}

class AnimatedPopupMenu extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFullyOpened;
  final Widget Function(BuildContext context, Widget child) backgroundBuilder;

  const AnimatedPopupMenu({
    Key? key,
    required this.child,
    required this.backgroundBuilder,
    this.onFullyOpened,
  }) : super(key: key);

  @override
  AnimatedPopupMenuState createState() => AnimatedPopupMenuState();
}

class AnimatedPopupMenuState extends State<AnimatedPopupMenu> with TickerProviderStateMixin {
  static const ENTER_DURATION = Duration(milliseconds: 220);
  static final CurveTween enterOpacityTween = CurveTween(
    curve: const Interval(0.0, 90 / 220, curve: Curves.linear),
  );
  static final CurveTween enterSizeTween = CurveTween(
    curve: Curves.easeOutCubic,
  );

  static const EXIT_DURATION = Duration(milliseconds: 260);
  static final CurveTween exitOpacityTween = CurveTween(
    curve: Curves.linear,
  );

  late final AnimationController _enterAnimationController;
  late final Animation<double> _enterAnimation;
  late final AnimationController _exitAnimationController;
  late final Animation<double> _exitAnimation;

  @override
  void initState() {
    _enterAnimationController = AnimationController(
      vsync: this,
      duration: ENTER_DURATION,
    );
    _enterAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_enterAnimationController);
    _enterAnimationController.forward().then((value) {
      if (widget.onFullyOpened != null) widget.onFullyOpened!();
    });

    _exitAnimationController = AnimationController(
      vsync: this,
      duration: EXIT_DURATION,
    );
    _exitAnimation =
        Tween(begin: 1.0, end: 0.0).animate(_exitAnimationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitAnimation,
      builder: (BuildContext context, child) {
        return Opacity(
          opacity: exitOpacityTween.evaluate(_exitAnimation),
          child: child!,
        );
      },
      child: AnimatedBuilder(
        animation: _enterAnimation,
        builder: (BuildContext context, _) {
          return Opacity(
            opacity: enterOpacityTween.evaluate(_enterAnimation),
            child: widget.backgroundBuilder(
              context,
              ScaleTransition(
                scale: _enterAnimation,
                child: widget.child
              )
            ),
          );
        },
      ),
    );
  }

  Future<void> showMenu() async {
    _enterAnimationController.stop();
    await _exitAnimationController.forward();
  }

  Future<void> hideMenu() async {
    _enterAnimationController.stop();
    await _exitAnimationController.forward();
  }

  @override
  void dispose() {
    _enterAnimationController.dispose();
    _exitAnimationController.dispose();
    super.dispose();
  }
}

/// Allow it's child (from [childBuilder]) to open a popup menu (from either
/// [menuBuilder] or [menuItemBuilder]) with customizable background
/// (though [backgroundBuilder]) at customizable position (though
/// [calculatePopupPosition]).
///
/// Unlike the popup menu created by [PopupMenuButton], which works by pushing
/// a new route to the navigator and causes the soft keyboard to hide, the popup
/// menu created by [WithKeepKeyboardPopupMenu] works by adding an entry to
/// [Overlay] and will keep the soft keyboard open.
///
/// Note that you can't use [PopupMenuItem] with [WithKeepKeyboardPopupMenu]
/// because [PopupMenuItem] will pop the current route when tapped. Since
/// [WithKeepKeyboardPopupMenu] does not push a new route, this will cause the
/// page behind the popup menu be popped. Use [KeepKeyboardPopupMenuItem]
/// instead.
class WithKeepKeyboardPopupMenu extends StatefulWidget {
  /// Build the widget inside the popup menu.
  final ChildBuilder childBuilder;

  /// Build the custom widget inside the popup menu. If passed value to
  /// [menuBuilder], [menuItemBuilder] must be null.
  final MenuBuilder? menuBuilder;

  /// Build the item list inside the popup menu.If passed value to
  /// [menuItemBuilder], [menuBuilder] must be null.
  final MenuItemBuilder? menuItemBuilder;

  /// Calculate the position of the popup, defaults to
  /// [_defaultCalculatePopupPosition]
  final CalculatePopupPosition calculatePopupPosition;

  /// Build the background of the popup menu, defaults to
  /// [_defaultBackgroundBuilder]
  final PopupMenuBackgroundBuilder backgroundBuilder;
  final void Function()? onCanceled;

  const WithKeepKeyboardPopupMenu({
    required this.childBuilder,
    this.menuBuilder,
    this.menuItemBuilder,
    this.calculatePopupPosition = _defaultCalculatePopupPosition,
    this.backgroundBuilder = _defaultBackgroundBuilder,
    Key? key, this.onCanceled,
  })  : assert((menuBuilder == null) != (menuItemBuilder == null),
  'You can only pass one of [menuBuilder] and [menuItemBuilder].'),
        super(key: key);

  @override
  WithKeepKeyboardPopupMenuState createState() =>
      WithKeepKeyboardPopupMenuState();
}

class WithKeepKeyboardPopupMenuState extends State<WithKeepKeyboardPopupMenu> {
  final GlobalKey _childKey = GlobalKey();
  final GlobalKey<AnimatedPopupMenuState> _menuKey = GlobalKey();
  OverlayEntry? _entry;
  PopupMenuState popupState = PopupMenuState.CLOSED;
  late final StreamSubscription<bool> _keyboardVisibilitySub;

  @override
  void initState() {
    super.initState();
    _keyboardVisibilitySub = KeyboardVisibilityController()
        .onChange
        .distinct()
        .listen((isKeyboardVisible) {
      if (!isKeyboardVisible) closePopupMenu();
    });
  }

  @override
  void dispose() {
    _keyboardVisibilitySub.cancel();
    closePopupMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Container mainView = Container(
      key: _childKey,
      child: widget.childBuilder(context, openPopupMenu),
    );
    if (kIsWeb || !Platform.isIOS) {
      return WillPopScope(
        onWillPop: () async {
          if (popupState == PopupMenuState.OPENED ||
              popupState == PopupMenuState.OPENING) {
            closePopupMenu();
            return false;
          } else {
            return true;
          }
        },
        child: mainView,
      );
    } else {
      return mainView;
    }
  }

  Rect? _getChildRect() {
    final context = _childKey.currentContext;
    if (context == null) return null;
    final childRenderBox = context.findRenderObject() as RenderBox;
    final childSize = childRenderBox.size;
    final childPos = childRenderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      childPos.dx,
      childPos.dy,
      childSize.width,
      childSize.height,
    );
  }

  Rect _getOverlayRect(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding.copyWith(
      bottom: max(mediaQuery.viewInsets.bottom, mediaQuery.padding.bottom),
    );

    return Rect.fromLTWH(
      padding.left,
      padding.top,
      mediaQuery.size.width - padding.horizontal,
      mediaQuery.size.height - padding.vertical,
    );
  }

  Widget _buildPopupBody() {
    if (widget.menuBuilder != null) {
      return widget.menuBuilder!(context, closePopupMenu);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: _kMenuVerticalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.menuItemBuilder!(context, closePopupMenu),
        ),
      );
    }
  }

  /// Only has effect when popup is fully closed.
  Future<void> openPopupMenu() async {
    if (popupState == PopupMenuState.CLOSED) {
      final childRect = _getChildRect();
      if (childRect == null) return;

      popupState = PopupMenuState.OPENING;

      final openMenuCompleter = Completer<void>();
      _entry = OverlayEntry(builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: closePopupMenu,
              ),
            ),
            CustomSingleChildLayout(
              delegate: PopupMenuRouteLayout(
                buttonRect: childRect,
                overlayRect: _getOverlayRect(context),
                calculatePopupPosition: widget.calculatePopupPosition,
              ),
              child: AnimatedPopupMenu(
                key: _menuKey,
                backgroundBuilder: widget.backgroundBuilder,
                onFullyOpened: () {
                  openMenuCompleter.complete();
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: _kMenuMinWidth,
                    maxWidth: _kMenuMaxWidth,
                  ),
                  child: SingleChildScrollView(
                    child: IntrinsicWidth(
                      stepWidth: _kMenuWidthStep,
                      child: _buildPopupBody(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      });

      final overlay = Overlay.of(context)!;
      overlay.insert(_entry!);

      await openMenuCompleter.future;
      popupState = PopupMenuState.OPENED;
    }
  }

  /// Only has effect when popup is fully opened or opening.
  Future<void> closePopupMenu() async {
    if (popupState == PopupMenuState.OPENED ||
        popupState == PopupMenuState.OPENING) {
      popupState = PopupMenuState.CLOSING;
      await _menuKey.currentState!.hideMenu();
      _entry!.remove();
      popupState = PopupMenuState.CLOSED;
      widget.onCanceled?.call();
    }
  }
}

Widget _defaultBackgroundBuilder(BuildContext context, Widget child) {
  return Material(
    elevation: 8,
    child: child,
  );
}

Offset _defaultCalculatePopupPosition(
    Size menuSize, Rect overlayRect, Rect buttonRect) {
  double y = buttonRect.top;

  double x;
  if (buttonRect.left - overlayRect.left >
      overlayRect.right - buttonRect.right) {
    // If button is closer to the right edge, grow to the left.
    x = buttonRect.right - menuSize.width;
  } else {
    x = buttonRect.left;
  }

  // Avoid going outside an area defined as the rectangle 8.0 pixels from the
  // edge of the screen in every direction.
  if (x < kMenuScreenPadding + overlayRect.left) {
    x = kMenuScreenPadding + overlayRect.left;
  } else if (x + menuSize.width > overlayRect.right - kMenuScreenPadding) {
    x = overlayRect.right - menuSize.width - kMenuScreenPadding;
  }
  if (y < kMenuScreenPadding + overlayRect.top) {
    y = kMenuScreenPadding + overlayRect.top;
  } else if (y + menuSize.height > overlayRect.bottom - kMenuScreenPadding) {
    y = overlayRect.bottom - menuSize.height - kMenuScreenPadding;
  }
  return Offset(x, y);
}
