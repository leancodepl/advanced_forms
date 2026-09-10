import 'package:advanced_forms_landing/components/icons.dart';
import 'package:advanced_forms_landing/styles.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A responsive grid of [Card]s: as many 300px columns as fit.
class CardGrid extends StatelessComponent {
  const CardGrid(this.children, {this.className, super.key});

  final List<Component> children;

  /// A class of the caller's, for its own rules on this grid.
  final ClassName? className;

  static const _grid = ClassName('af-card-grid');

  @css
  static List<StyleRule> get styles => [
    css(_grid.selector).styles(
      display: .grid,
      gap: .all(1.rem),
      raw: {
        'grid-template-columns':
            'repeat(auto-fit, minmax(min(100%, 300px), 1fr))',
      },
    ),
    // A card may hold a wide code chip; let it shrink instead of stretching
    // the page.
    css('${_grid.selector} > *').styles(minWidth: .zero),
  ];

  @override
  Component build(BuildContext context) {
    return ul(classes: _classes(_grid, className), children);
  }
}

/// A bordered surface that lifts a little when hovered, with a heading and a
/// paragraph or two inside; a [CardGrid] item.
class Card extends StatelessComponent {
  const Card(this.children, {this.className, super.key});

  final List<Component> children;

  /// A class of the caller's, for its own rules on this card.
  final ClassName? className;

  static const _card = ClassName('af-card');

  @css
  static List<StyleRule> get styles => [
    css(_card.selector).styles(
      display: .flex,
      padding: .all(1.5.rem),
      border: hairline(borderColor),
      radius: const .circular(radius),
      transition: .combine([
        Transition('border-color', duration: 200.ms, curve: .ease),
        Transition('transform', duration: 200.ms, curve: .ease),
      ]),
      flexDirection: .column,
      backgroundColor: surfaceColor,
    ),
    css('${_card.selector}:hover').styles(
      transform: .translate(y: (-2).px),
      raw: {'border-color': border2Color.value},
    ),
    css('${_card.selector} h3').styles(
      margin: .only(top: .zero, right: .zero, bottom: 0.5.rem, left: .zero),
      fontSize: 1.15.rem,
      fontWeight: .w600,
    ),
    css(
      '${_card.selector} p',
    ).styles(margin: .zero, color: text2Color, fontSize: 0.95.rem),
  ];

  @override
  Component build(BuildContext context) {
    return li(classes: _classes(_card, className), children);
  }
}

/// The icon in a card's corner: a rounded accent tile.
class CardIcon extends StatelessComponent {
  const CardIcon(this.icon, {super.key});

  final Icon icon;

  static const _icon = ClassName('af-card-icon');

  @css
  static List<StyleRule> get styles => [
    css(_icon.selector).styles(
      display: .inlineGrid,
      width: 42.px,
      height: 42.px,
      margin: .only(bottom: 0.5.rem),
      radius: .circular(12.px),
      color: accentTextColor,
      backgroundColor: accentSoftColor,
      raw: {
        'place-items': 'center',
        'border': '1px solid ${colorMix(accentColor, 35, with_: borderColor)}',
      },
    ),
  ];

  @override
  Component build(BuildContext context) {
    return span(classes: _icon.name, [icon.build(size: 22)]);
  }
}

String _classes(ClassName own, ClassName? extra) =>
    (extra == null ? own : own + extra).name;
