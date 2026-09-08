/*
 * AI-Provenance:
 *   model: Claude Opus 5
 *   harness: Cursor
 *   edited-by: Claude Fable 5.1 (Claude Code)
 */
import 'package:advanced_forms_docs_islands/support/example_log.dart';
import 'package:flutter/material.dart';

/// The part of an island that has nothing to do with the browser.
///
/// Kept free of `package:web` on purpose: `test/examples_test.dart` runs on the
/// Dart VM and puts every docs example through the same constraints the real
/// island imposes.
///
/// Deliberately **not** a [Scaffold]. An auto-height island is laid out with
/// unbounded vertical constraints so the framework's computed height can size
/// the host `<div>`, and [Scaffold] takes `constraints.biggest`. [MaterialApp]
/// itself is fine under unbounded height: its [Navigator] pushes an opaque
/// [ModalRoute], whose overlay entry sets `canSizeOverlay`, so the overlay
/// sizes itself to the route instead of to the constraints.
///
/// The background stays transparent — the docs page draws the frame around the
/// island, so the island only draws its content.
class IslandFrame extends StatefulWidget {
  const IslandFrame({
    super.key,
    required this.brightness,
    this.exampleId,
    this.builder,
  });

  final Brightness brightness;

  /// The id requested by the host page, kept for the missing-example message.
  final String? exampleId;

  /// Builds the example. Null when the requested id is not in this bundle,
  /// which means the docs and the bundle were built from different revisions.
  final WidgetBuilder? builder;

  @override
  State<IslandFrame> createState() => _IslandFrameState();
}

class _IslandFrameState extends State<IslandFrame> {
  final _log = ExampleLog();

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: islandTheme(widget.brightness),
      home: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ExampleLogScope(
            log: _log,
            // A Builder so the example resolves Theme, MediaQuery and
            // Localizations from inside MaterialApp rather than from the
            // context that constructed it.
            child: Builder(
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.builder?.call(context) ??
                      _MissingExample(exampleId: widget.exampleId),
                  ExampleLogView(log: _log),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The LeanCode design system, as a Material theme.
///
/// The same tokens the docs page paints with: near-black surfaces, one lime
/// accent, rounded filled inputs. In the light variant the accent becomes a
/// fill with dark ink on it — a lime *text* would not be legible on paper.
ThemeData islandTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  const accent = Color(0xFFEDFF2F);
  const accentInk = Color(0xFF0B0C00);
  final ink = dark ? const Color(0xFFF4F4F1) : const Color(0xFF0B0B0D);
  final ink2 = dark ? const Color(0xFFB7B7B3) : const Color(0xFF4B4B52);
  const muted = Color(0xFF7D7D84);
  final surface = dark ? const Color(0xFF101013) : Colors.white;
  final surface2 = dark ? const Color(0xFF16161B) : const Color(0xFFEFEFE9);
  final border = dark ? const Color(0xFF33333E) : const Color(0xFFCFCFC7);
  final borderSoft = dark ? const Color(0xFF23232B) : const Color(0xFFE2E2DC);
  final danger = dark ? const Color(0xFFFF5D5D) : const Color(0xFFD93636);
  final ok = dark ? const Color(0xFF58E08A) : const Color(0xFF1F9D55);

  final primary = dark ? accent : const Color(0xFF0B0B0D);
  final onPrimary = dark ? accentInk : accent;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: accent.withValues(alpha: dark ? 0.16 : 0.45),
    onPrimaryContainer: ink,
    secondary: accent,
    onSecondary: accentInk,
    secondaryContainer: surface2,
    onSecondaryContainer: ink,
    tertiary: ok,
    onTertiary: accentInk,
    error: danger,
    onError: dark ? accentInk : Colors.white,
    errorContainer: danger.withValues(alpha: dark ? 0.16 : 0.12),
    onErrorContainer: danger,
    surface: surface,
    onSurface: ink,
    surfaceContainerHighest: surface2,
    surfaceContainerHigh: surface2,
    surfaceContainer: surface2,
    onSurfaceVariant: ink2,
    outline: border,
    outlineVariant: borderSoft,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: ink,
    onInverseSurface: surface,
    inversePrimary: dark ? const Color(0xFF0B0B0D) : accent,
  );

  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    visualDensity: VisualDensity.compact,
    scaffoldBackgroundColor: surface,
    canvasColor: surface,
    dividerColor: borderSoft,
    hintColor: muted,
    splashFactory: InkSparkle.splashFactory,
    textTheme: Typography.material2021(
      colorScheme: scheme,
    ).black.apply(bodyColor: ink, displayColor: ink),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: muted),
      labelStyle: TextStyle(color: ink2),
      floatingLabelStyle: TextStyle(color: primary),
      helperStyle: const TextStyle(color: muted),
      errorStyle: TextStyle(color: danger),
      prefixIconColor: muted,
      suffixIconColor: muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: danger, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: surface2,
        disabledForegroundColor: muted,
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: onPrimary,
        disabledBackgroundColor: surface2,
        disabledForegroundColor: muted,
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ink2,
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: ink2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? onPrimary : muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primary : surface2,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primary : border,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primary
            : Colors.transparent,
      ),
      checkColor: WidgetStatePropertyAll(onPrimary),
      side: BorderSide(color: border, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? primary : border,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface2,
      selectedColor: accent.withValues(alpha: dark ? 0.18 : 0.6),
      checkmarkColor: dark ? accent : accentInk,
      side: BorderSide(color: border),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(color: ink, fontWeight: FontWeight.w500),
      secondaryLabelStyle: TextStyle(color: ink),
      showCheckmark: true,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: surface2,
        foregroundColor: ink2,
        selectedBackgroundColor: primary,
        selectedForegroundColor: onPrimary,
        side: BorderSide(color: border),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.zero,
      iconColor: ink2,
      textColor: ink,
      shape: rounded,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(surface),
        shape: WidgetStatePropertyAll(rounded),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      shape: rounded,
      textStyle: TextStyle(color: ink),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: dark ? accent : primary,
      linearTrackColor: surface2,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: TextStyle(color: surface),
      shape: rounded,
      behavior: SnackBarBehavior.floating,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(color: surface, fontSize: 12),
    ),
    cardTheme: CardThemeData(
      color: surface2,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderSoft),
      ),
    ),
  );
}

class _MissingExample extends StatelessWidget {
  const _MissingExample({required this.exampleId});

  final String? exampleId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        exampleId == null
            ? 'This island was attached without an example id.'
            : 'Example "$exampleId" is not in this bundle. Re-run '
                  '`npm run examples:build`.',
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}
