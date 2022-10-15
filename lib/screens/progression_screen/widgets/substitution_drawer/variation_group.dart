part of 'substitution_drawer.dart';

// I copied this from stack overflow:
// https://stackoverflow.com/questions/48930372/flutter-collapsing-expansiontile-after-choosing-an-item,
// which:
// --- Copied and slightly modified version of the ExpansionTile.

const Duration _kExpand = Duration(milliseconds: 200);

class _VariationGroup extends StatefulWidget {
  const _VariationGroup({
    Key? key,
    required this.titleVariation,
    this.leading,
    this.backgroundColor,
    this.iconColor,
    this.color,
    this.borderRadius,
    this.onExpansionChanged,
    this.children = const [],
    this.trailing,
    this.showTrailing = true,
    this.initiallyExpanded = false,
    this.contentPadding = EdgeInsets.zero,
    required this.length,
  }) : super(key: key);

  final _Variation titleVariation;
  final Widget? leading;
  final ValueChanged<bool>? onExpansionChanged;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? color;
  final Widget? trailing;
  final bool showTrailing;
  final bool initiallyExpanded;
  final EdgeInsets contentPadding;
  final BorderRadius? borderRadius;
  final int length;

  @override
  _VariationGroupState createState() => _VariationGroupState();
}

class _VariationGroupState extends State<_VariationGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _easeOutAnimation;
  late final CurvedAnimation _easeInAnimation;
  late final ColorTween _headerColor;
  late final ColorTween _iconColor;
  late final ColorTween _backgroundColor;

  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _easeOutAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _easeInAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _headerColor = ColorTween();
    _iconColor = ColorTween();
    _backgroundColor = ColorTween();

    _isExpanded =
        PageStorage.of(context)?.readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> expand() async => _setExpanded(true);

  Future<void> collapse() async => _setExpanded(false);

  Future<void> toggle() async => _setExpanded(!_isExpanded);

  Future<void> _setExpanded(bool isExpanded) async {
    if (_isExpanded != isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
        PageStorage.of(context)?.writeState(context, _isExpanded);
      });
      if (_isExpanded) {
        await _controller.forward();
      } else {
        await _controller.reverse();
        //     .then((_) {
        //   setState(() {
        //     // Rebuild without widget.children.
        //   });
        // });
      }
      widget.onExpansionChanged?.call(_isExpanded);
    }
  }

  Widget _buildChildren(BuildContext context, Widget? child) => Material(
        color: widget.color,
        borderRadius: widget.borderRadius,
        child: InkWell(
          onTap: toggle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 0.2, thickness: 1.5),
              _Title(
                variation: widget.titleVariation,
                length: widget.length,
                expanded: _isExpanded,
                variationPadding: widget.contentPadding,
              ),
              ClipRect(
                child: Align(
                  heightFactor: _easeInAnimation.value,
                  child: Padding(
                    padding: widget.contentPadding,
                    child: Material(
                      color: Constants.libraryEntryColor,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(4.0),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2.0),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  _isExpanded
                      ? Icons.horizontal_rule_rounded
                      : Icons.more_horiz_rounded,
                  size: 16.0,
                ),
              ),
              const SizedBox(height: 2.0),
              const Divider(height: 2.0),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _headerColor
      ..begin = theme.colorScheme.primary
      ..end = theme.colorScheme.secondary;
    _iconColor
      ..begin = theme.unselectedWidgetColor
      ..end = theme.colorScheme.secondary;
    _backgroundColor.end = widget.backgroundColor;

    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    Key? key,
    required this.length,
    required this.variation,
    this.expanded = true,
    this.variationPadding = EdgeInsets.zero,
  }) : super(key: key);

  final int length;
  final bool expanded;
  final _Variation variation;
  final EdgeInsets variationPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: _Wrapper.horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextAndIcon(
                icon: Icons.filter_list_rounded,
                text: 'Variation${expanded ? '' : ' + ${length - 1}'}',
                style: const TextStyle(fontSize: 12.0),
                iconSize: 12.0,
              ),
              Icon(
                expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 15.0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: variationPadding,
          child: Material(
            color: Constants.libraryEntryColor,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(4.0),
              bottom: expanded ? Radius.zero : const Radius.circular(4.0),
            ),
            child: variation,
          ),
        ),
      ],
    );
  }
}
