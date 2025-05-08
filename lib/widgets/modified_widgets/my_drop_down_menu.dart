// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


typedef FilterCallback<T> = List<DropdownMenuEntry<T>> Function(List<DropdownMenuEntry<T>> entries, String filter);


typedef SearchCallback<T> = int? Function(List<DropdownMenuEntry<T>> entries, String query);


final Map<ShortcutActivator, Intent> _kMenuTraversalShortcuts = <ShortcutActivator, Intent> {
  LogicalKeySet(LogicalKeyboardKey.arrowUp): const _ArrowUpIntent(),
  LogicalKeySet(LogicalKeyboardKey.arrowDown): const _ArrowDownIntent(),
};

const double _kMinimumWidth = 112.0;

const double _kDefaultHorizontalPadding = 12.0;


class MyDropdownMenu<T> extends StatefulWidget {
  const MyDropdownMenu({
    super.key,
    this.enabled = true,
    this.width,
    this.menuHeight,
    this.leadingIcon,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.selectedTrailingIcon,
    this.enableFilter = false,
    this.enableSearch = true,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.inputDecorationTheme,
    this.menuStyle,
    this.controller,
    this.initialSelection,
    this.onSelected,
    this.focusNode,
    this.requestFocusOnTap,
    this.expandedInsets,
    this.filterCallback,
    this.searchCallback,
    required this.dropdownMenuEntries,
    this.inputFormatters,
  }) : assert(filterCallback == null || enableFilter);


  final bool enabled;

  final double? width;
  final double? menuHeight;
  final Widget? leadingIcon;

  final Widget? label;

  /// Text that suggests what sort of input the field accepts.
  ///
  /// Defaults to null;
  final String? hintText;

  /// Text that provides context about the [DropdownMenu]'s value, such
  /// as how the value will be used.
  ///
  /// If non-null, the text is displayed below the input field, in
  /// the same location as [errorText]. If a non-null [errorText] value is
  /// specified then the helper text is not shown.
  ///
  /// Defaults to null;
  ///
  /// See also:
  ///
  /// * [InputDecoration.helperText], which is the text that provides context about the [InputDecorator.child]'s value.
  final String? helperText;

  /// Text that appears below the input field and the border to show the error message.
  ///
  /// If non-null, the border's color animates to red and the [helperText] is not shown.
  ///
  /// Defaults to null;
  ///
  /// See also:
  ///
  /// * [InputDecoration.errorText], which is the text that appears below the [InputDecorator.child] and the border.
  final String? errorText;

  /// An optional icon at the end of the text field to indicate that the text
  /// field is pressed.
  ///
  /// Defaults to an [Icon] with [Icons.arrow_drop_up].
  final Widget? selectedTrailingIcon;

  /// Determine if the menu list can be filtered by the text input.
  ///
  /// Defaults to false.
  final bool enableFilter;

  /// Determine if the first item that matches the text input can be highlighted.
  ///
  /// Defaults to true as the search function could be commonly used.
  final bool enableSearch;

  /// The text style for the [TextField] of the [DropdownMenu];
  ///
  /// Defaults to the overall theme's [TextTheme.bodyLarge]
  /// if the dropdown menu theme's value is null.
  final TextStyle? textStyle;

  /// The text align for the [TextField] of the [DropdownMenu].
  ///
  /// Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// Defines the default appearance of [InputDecoration] to show around the text field.
  ///
  /// By default, shows a outlined text field.
  final InputDecorationTheme? inputDecorationTheme;

  /// The [MenuStyle] that defines the visual attributes of the menu.
  ///
  /// The default width of the menu is set to the width of the text field.
  final MenuStyle? menuStyle;

  /// Controls the text being edited or selected in the menu.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// The value used to for an initial selection.
  ///
  /// Defaults to null.
  final T? initialSelection;

  /// The callback is called when a selection is made.
  ///
  /// Defaults to null. If null, only the text field is updated.
  final ValueChanged<T?>? onSelected;

  final FocusNode? focusNode;

  final bool? requestFocusOnTap;

  /// Descriptions of the menu items in the [DropdownMenu].
  ///
  /// This is a required parameter. It is recommended that at least one [DropdownMenuEntry]
  /// is provided. If this is an empty list, the menu will be empty and only
  /// contain space for padding.
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;

  final EdgeInsets? expandedInsets;

  /// comparison. When this is not null, `enableFilter` must be set to true.
  final FilterCallback<T>? filterCallback;

  final SearchCallback<T>? searchCallback;

  final List<TextInputFormatter>? inputFormatters;

  @override
  State<MyDropdownMenu<T>> createState() => _MyDropdownMenuState<T>();
}

class _MyDropdownMenuState<T> extends State<MyDropdownMenu<T>> {
  final GlobalKey _anchorKey = GlobalKey();
  final GlobalKey _leadingKey = GlobalKey();
  late List<GlobalKey> buttonItemKeys;
  final MenuController _controller = MenuController();
  late bool _enableFilter;
  late List<DropdownMenuEntry<T>> filteredEntries;
  List<Widget>? _initialMenu;
  int? currentHighlight;
  double? leadingPadding;
  bool _menuHasEnabledItem = false;
  TextEditingController? _localTextEditingController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _localTextEditingController = widget.controller;
    } else {
      _localTextEditingController = TextEditingController();
    }
    _enableFilter = widget.enableFilter;
    filteredEntries = widget.dropdownMenuEntries;
    buttonItemKeys = List<GlobalKey>.generate(filteredEntries.length, (int index) => GlobalKey());
    _menuHasEnabledItem = filteredEntries.any((DropdownMenuEntry<T> entry) => entry.enabled);

    final int index = filteredEntries.indexWhere((DropdownMenuEntry<T> entry) => entry.value == widget.initialSelection);
    if (index != -1) {
      _localTextEditingController?.value = TextEditingValue(
        text: filteredEntries[index].label,
        selection: TextSelection.collapsed(offset: filteredEntries[index].label.length),
      );
    }
    refreshLeadingPadding();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _localTextEditingController?.dispose();
      _localTextEditingController = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(MyDropdownMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (widget.controller != null) {
        _localTextEditingController?.dispose();
      }
      _localTextEditingController = widget.controller ?? TextEditingController();
    }
    if (oldWidget.enableSearch != widget.enableSearch) {
      if (!widget.enableSearch) {
        currentHighlight = null;
      }
    }
    if (oldWidget.dropdownMenuEntries != widget.dropdownMenuEntries) {
      currentHighlight = null;
      filteredEntries = widget.dropdownMenuEntries;
      buttonItemKeys = List<GlobalKey>.generate(filteredEntries.length, (int index) => GlobalKey());
      _menuHasEnabledItem = filteredEntries.any((DropdownMenuEntry<T> entry) => entry.enabled);
    }
    if (oldWidget.leadingIcon != widget.leadingIcon) {
      refreshLeadingPadding();
    }
    if (oldWidget.initialSelection != widget.initialSelection) {
      final int index = filteredEntries.indexWhere((DropdownMenuEntry<T> entry) => entry.value == widget.initialSelection);
      if (index != -1) {
        _localTextEditingController?.value = TextEditingValue(
          text: filteredEntries[index].label,
          selection: TextSelection.collapsed(offset: filteredEntries[index].label.length),
        );
      }
    }
  }

  bool canRequestFocus() {
    return widget.focusNode?.canRequestFocus ?? widget.requestFocusOnTap
      ?? switch (Theme.of(context).platform) {
        TargetPlatform.iOS || TargetPlatform.android || TargetPlatform.fuchsia => false,
        TargetPlatform.macOS || TargetPlatform.linux || TargetPlatform.windows => true,
      };
  }

  void refreshLeadingPadding() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        leadingPadding = getWidth(_leadingKey);
      });
    }, debugLabel: 'DropdownMenu.refreshLeadingPadding');
  }

  void scrollToHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? highlightContext = buttonItemKeys[currentHighlight!].currentContext;
      if (highlightContext != null) {
        Scrollable.ensureVisible(highlightContext);
      }
    }, debugLabel: 'DropdownMenu.scrollToHighlight');
  }

  double? getWidth(GlobalKey key) {
    final BuildContext? context = key.currentContext;
    if (context != null) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      return box.hasSize ? box.size.width : null;
    }
    return null;
  }

  List<DropdownMenuEntry<T>> filter(List<DropdownMenuEntry<T>> entries, TextEditingController textEditingController) {
    final String filterText = textEditingController.text.toLowerCase();
    return entries
      .where((DropdownMenuEntry<T> entry) => entry.label.toLowerCase().contains(filterText))
      .toList();
  }

  int? search(List<DropdownMenuEntry<T>> entries, TextEditingController textEditingController) {
    final String searchText = textEditingController.value.text.toLowerCase();
    if (searchText.isEmpty) {
      return null;
    }
    if (currentHighlight != null && entries[currentHighlight!].label.toLowerCase().contains(searchText)) {
      return currentHighlight;
    }
    final int index = entries.indexWhere((DropdownMenuEntry<T> entry) => entry.label.toLowerCase().contains(searchText));

    return index != -1 ? index : null;
  }

  List<Widget> _buildButtons(
    List<DropdownMenuEntry<T>> filteredEntries,
    TextDirection textDirection, {
    int? focusedIndex,
    bool enableScrollToHighlight = true,
  }) {
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < filteredEntries.length; i++) {
      final DropdownMenuEntry<T> entry = filteredEntries[i];

      final double padding = entry.leadingIcon == null ? (leadingPadding ?? _kDefaultHorizontalPadding) : _kDefaultHorizontalPadding;
      final ButtonStyle defaultStyle = switch (textDirection) {
        TextDirection.rtl => MenuItemButton.styleFrom(padding: EdgeInsets.only(left: _kDefaultHorizontalPadding, right: padding)),
        TextDirection.ltr => MenuItemButton.styleFrom(padding: EdgeInsets.only(left: padding, right: _kDefaultHorizontalPadding)),
      };

      ButtonStyle effectiveStyle = entry.style ?? defaultStyle;
      final Color focusedBackgroundColor = effectiveStyle.foregroundColor?.resolve(<MaterialState>{MaterialState.focused})
        ?? Theme.of(context).colorScheme.onSurface;

      Widget label = entry.labelWidget ?? Text(entry.label);
      if (widget.width != null) {
        final double horizontalPadding = padding + _kDefaultHorizontalPadding;
        label = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.width! - horizontalPadding),
          child: label,
        );
      }

      effectiveStyle = entry.enabled && i == focusedIndex
        ? effectiveStyle.copyWith(
            backgroundColor: MaterialStatePropertyAll<Color>(focusedBackgroundColor.withOpacity(0.12))
          )
        : effectiveStyle;

      final Widget  menuItemButton = MenuItemButton(
        key: enableScrollToHighlight ? buttonItemKeys[i] : null,
        style: effectiveStyle,
        leadingIcon: entry.leadingIcon,
        trailingIcon: entry.trailingIcon,
        onPressed: entry.enabled && widget.enabled
          ? () {
              _localTextEditingController?.value = TextEditingValue(
                text: entry.label,
                selection: TextSelection.collapsed(offset: entry.label.length),
              );
              currentHighlight = widget.enableSearch ? i : null;
              widget.onSelected?.call(entry.value);
            }
          : null,
        requestFocusOnHover: false,
        child: label,
      );
      result.add(menuItemButton);
    }

    return result;
  }

  void handleUpKeyInvoke(_) {
    setState(() {
      if (!widget.enabled || !_menuHasEnabledItem || !_controller.isOpen) {
        return;
      }
      _enableFilter = false;
      currentHighlight ??= 0;
      currentHighlight = (currentHighlight! - 1) % filteredEntries.length;
      while (!filteredEntries[currentHighlight!].enabled) {
        currentHighlight = (currentHighlight! - 1) % filteredEntries.length;
      }
      final String currentLabel = filteredEntries[currentHighlight!].label;
      _localTextEditingController?.value = TextEditingValue(
        text: currentLabel,
        selection: TextSelection.collapsed(offset: currentLabel.length),
      );
    });
  }

  void handleDownKeyInvoke(_) {
    setState(() {
      if (!widget.enabled || !_menuHasEnabledItem || !_controller.isOpen) {
        return;
      }
      _enableFilter = false;
      currentHighlight ??= -1;
      currentHighlight = (currentHighlight! + 1) % filteredEntries.length;
      while (!filteredEntries[currentHighlight!].enabled) {
        currentHighlight = (currentHighlight! + 1) % filteredEntries.length;
      }
      final String currentLabel = filteredEntries[currentHighlight!].label;
      _localTextEditingController?.value = TextEditingValue(
        text: currentLabel,
        selection: TextSelection.collapsed(offset: currentLabel.length),
      );
    });
  }

  void handlePressed(MenuController controller) {
    if (controller.isOpen) {
      currentHighlight = null;
      controller.close();
    } else {  // close to open
      if (_localTextEditingController!.text.isNotEmpty) {
        _enableFilter = false;
      }
      controller.open();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    _initialMenu ??= _buildButtons(widget.dropdownMenuEntries, textDirection, enableScrollToHighlight: false);
    final DropdownMenuThemeData theme = DropdownMenuTheme.of(context);
    final DropdownMenuThemeData defaults = _DropdownMenuDefaultsM3(context);

    if (_enableFilter) {
      filteredEntries = widget.filterCallback?.call(filteredEntries, _localTextEditingController!.text)
        ?? filter(widget.dropdownMenuEntries, _localTextEditingController!);
    }

    if (widget.enableSearch) {
      if (widget.searchCallback != null) {
        currentHighlight = widget.searchCallback!.call(filteredEntries, _localTextEditingController!.text);
      } else {
        currentHighlight = search(filteredEntries, _localTextEditingController!);
      }
      if (currentHighlight != null) {
        scrollToHighlight();
      }
    }

    final List<Widget> menu = _buildButtons(filteredEntries, textDirection, focusedIndex: currentHighlight);

    final TextStyle? effectiveTextStyle = widget.textStyle ?? theme.textStyle ?? defaults.textStyle;

    MenuStyle? effectiveMenuStyle = widget.menuStyle ?? theme.menuStyle ?? defaults.menuStyle!;

    final double? anchorWidth = getWidth(_anchorKey);
    if (widget.width != null) {
      effectiveMenuStyle = effectiveMenuStyle.copyWith(minimumSize: MaterialStatePropertyAll<Size?>(Size(widget.width!, 0.0)));
    } else if (anchorWidth != null){
      effectiveMenuStyle = effectiveMenuStyle.copyWith(minimumSize: MaterialStatePropertyAll<Size?>(Size(anchorWidth, 0.0)));
    }

    if (widget.menuHeight != null) {
      effectiveMenuStyle = effectiveMenuStyle.copyWith(maximumSize: MaterialStatePropertyAll<Size>(Size(double.infinity, widget.menuHeight!)));
    }
    final InputDecorationTheme effectiveInputDecorationTheme = widget.inputDecorationTheme
      ?? theme.inputDecorationTheme
      ?? defaults.inputDecorationTheme!;

    final MouseCursor? effectiveMouseCursor = switch (widget.enabled) {
      true => canRequestFocus() ? SystemMouseCursors.text : SystemMouseCursors.click,
      false => null,
    };

    Widget menuAnchor = MenuAnchor(
      style: effectiveMenuStyle,
      controller: _controller,
      menuChildren: menu,
      crossAxisUnconstrained: false,
      builder: (BuildContext context, MenuController controller, Widget? child) {
        assert(_initialMenu != null);

        final Widget leadingButton = Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.leadingIcon ?? const SizedBox.shrink()
        );

        final Widget textField = TextField(
          key: _anchorKey,
          enabled: widget.enabled,
          mouseCursor: effectiveMouseCursor,
          focusNode: widget.focusNode,
          canRequestFocus: canRequestFocus(),
          enableInteractiveSelection: canRequestFocus(),
          textAlign: widget.textAlign,
          textAlignVertical: TextAlignVertical.center,
          style: effectiveTextStyle,
          controller: _localTextEditingController,
          onEditingComplete: () {
            if (currentHighlight != null) {
              final DropdownMenuEntry<T> entry = filteredEntries[currentHighlight!];
              if (entry.enabled) {
                _localTextEditingController?.value = TextEditingValue(
                  text: entry.label,
                  selection: TextSelection.collapsed(offset: entry.label.length),
                );
                widget.onSelected?.call(entry.value);
              }
            } else {
              widget.onSelected?.call(null);
            }
            if (!widget.enableSearch) {
              currentHighlight = null;
            }
            controller.close();
          },
          onTap: !widget.enabled ? null : () {
            handlePressed(controller);
          },
          onChanged: (String text) {
            controller.open();
            setState(() {
              filteredEntries = widget.dropdownMenuEntries;
              _enableFilter = widget.enableFilter;
            });
          },
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            label: widget.label,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.leadingIcon != null ? SizedBox(
              key: _leadingKey,
              child: widget.leadingIcon
            ) : null,
          ).applyDefaults(effectiveInputDecorationTheme)
        );

        if (widget.expandedInsets != null) {
          return textField;
        }

        return _DropdownMenuBody(
          width: widget.width,
          children: <Widget>[
            textField,
            ..._initialMenu!,
            leadingButton,
          ],
        );
      },
    );

    if (widget.expandedInsets case final EdgeInsets padding) {
      menuAnchor = Padding(
        padding: padding.copyWith(top: 0.0, bottom: 0.0),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: menuAnchor,
        ),
      );
    }

    return Shortcuts(
      shortcuts: _kMenuTraversalShortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ArrowUpIntent: CallbackAction<_ArrowUpIntent>(
            onInvoke: handleUpKeyInvoke,
          ),
          _ArrowDownIntent: CallbackAction<_ArrowDownIntent>(
            onInvoke: handleDownKeyInvoke,
          ),
        },
        child: menuAnchor,
      ),
    );
  }
}

class _ArrowUpIntent extends Intent {
  const _ArrowUpIntent();
}

class _ArrowDownIntent extends Intent {
  const _ArrowDownIntent();
}

class _DropdownMenuBody extends MultiChildRenderObjectWidget {
  const _DropdownMenuBody({
    super.children,
    this.width,
  });

  final double? width;

  @override
  _RenderDropdownMenuBody createRenderObject(BuildContext context) {
    return _RenderDropdownMenuBody(
      width: width,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderDropdownMenuBody renderObject) {
    renderObject.width = width;
  }
}

class _DropdownMenuBodyParentData extends ContainerBoxParentData<RenderBox> { }

class _RenderDropdownMenuBody extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _DropdownMenuBodyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _DropdownMenuBodyParentData> {

  _RenderDropdownMenuBody({
    double? width,
  }) : _width = width;

  double? get width => _width;
  double? _width;
  set width(double? value) {
    if (_width == value) {
      return;
    }
    _width = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _DropdownMenuBodyParentData) {
      child.parentData = _DropdownMenuBodyParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    double maxWidth = 0.0;
    double? maxHeight;
    RenderBox? child = firstChild;

    final double intrinsicWidth = width ?? getMaxIntrinsicWidth(constraints.maxHeight);
    final double widthConstraint = math.min(intrinsicWidth, constraints.maxWidth);
    final BoxConstraints innerConstraints = BoxConstraints(
      maxWidth: widthConstraint,
      maxHeight: getMaxIntrinsicHeight(widthConstraint),
    );
    while (child != null) {
      if (child == firstChild) {
        child.layout(innerConstraints, parentUsesSize: true);
        maxHeight ??= child.size.height;
        final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
        continue;
      }
      child.layout(innerConstraints, parentUsesSize: true);
      final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
      childParentData.offset = Offset.zero;
      maxWidth = math.max(maxWidth, child.size.width);
      maxHeight ??= child.size.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    assert(maxHeight != null);
    maxWidth = math.max(_kMinimumWidth, maxWidth);
    size = constraints.constrain(Size(width ?? maxWidth, maxHeight!));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = firstChild;
    if (child != null) {
      final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
      context.paintChild(child, offset + childParentData.offset);
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints constraints = this.constraints;
    double maxWidth = 0.0;
    double? maxHeight;
    RenderBox? child = firstChild;
    final double intrinsicWidth = width ?? getMaxIntrinsicWidth(constraints.maxHeight);
    final double widthConstraint = math.min(intrinsicWidth, constraints.maxWidth);
    final BoxConstraints innerConstraints = BoxConstraints(
      maxWidth: widthConstraint,
      maxHeight: getMaxIntrinsicHeight(widthConstraint),
    );

    while (child != null) {
      if (child == firstChild) {
        final Size childSize = child.getDryLayout(innerConstraints);
        maxHeight ??= childSize.height;
        final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
        continue;
      }
      final Size childSize = child.getDryLayout(innerConstraints);
      final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
      childParentData.offset = Offset.zero;
      maxWidth = math.max(maxWidth, childSize.width);
      maxHeight ??= childSize.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    assert(maxHeight != null);
    maxWidth = math.max(_kMinimumWidth, maxWidth);
    return constraints.constrain(Size(width ?? maxWidth, maxHeight!));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    RenderBox? child = firstChild;
    double width = 0;
    while (child != null) {
      if (child == firstChild) {
        final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
        child = childParentData.nextSibling;
        continue;
      }
      final double maxIntrinsicWidth = child.getMinIntrinsicWidth(height);
      if (child == lastChild) {
        width += maxIntrinsicWidth;
      }
      if (child == childBefore(lastChild!)) {
        width += maxIntrinsicWidth;
      }
      width = math.max(width, maxIntrinsicWidth);
      final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
      child = childParentData.nextSibling;
    }

    return math.max(width, _kMinimumWidth);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    RenderBox? child = firstChild;
    double width = 0;
    while (child != null) {
      if (child == firstChild) {
        final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
        child = childParentData.nextSibling;
        continue;
      }
      final double maxIntrinsicWidth = child.getMaxIntrinsicWidth(height);
      // Add the width of leading Icon.
      if (child == lastChild) {
        width += maxIntrinsicWidth;
      }
      // Add the width of trailing Icon.
      if (child == childBefore(lastChild!)) {
        width += maxIntrinsicWidth;
      }
      width = math.max(width, maxIntrinsicWidth);
      final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
      child = childParentData.nextSibling;
    }

    return math.max(width, _kMinimumWidth);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final RenderBox? child = firstChild;
    double width = 0;
    if (child != null) {
      width = math.max(width, child.getMinIntrinsicHeight(width));
    }
    return width;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final RenderBox? child = firstChild;
    double width = 0;
    if (child != null) {
      width = math.max(width, child.getMaxIntrinsicHeight(width));
    }
    return width;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    final RenderBox? child = firstChild;
    if (child != null) {
      final _DropdownMenuBodyParentData childParentData = child.parentData! as _DropdownMenuBodyParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }
}

// Hand coded defaults. These will be updated once we have tokens/spec.
class _DropdownMenuDefaultsM3 extends DropdownMenuThemeData {
  _DropdownMenuDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);

  @override
  TextStyle? get textStyle => _theme.textTheme.bodyLarge;

  @override
  MenuStyle get menuStyle {
    return const MenuStyle(
      minimumSize: MaterialStatePropertyAll<Size>(Size(_kMinimumWidth, 0.0)),
      maximumSize: MaterialStatePropertyAll<Size>(Size.infinite),
      visualDensity: VisualDensity.standard,
    );
  }

  @override
  InputDecorationTheme get inputDecorationTheme {
    return const InputDecorationTheme(border: OutlineInputBorder());
  }
}
