import 'package:flutter/material.dart';
import 'package:sav_design_system/sav_design_system.dart';

/// A scrollable page of written specification, used by the catalog's
/// Foundations and per-component Specs entries.
///
/// The catalog's job is not only to render components but to carry the
/// information a developer needs to use one correctly — sizes, states, and
/// accessibility notes that a screenshot cannot convey.
class SpecSheet extends StatelessWidget {
  /// Creates a spec sheet.
  const SpecSheet({
    required this.title,
    required this.children,
    this.subtitle,
    super.key,
  });

  /// Page heading.
  final String title;

  /// Optional supporting line under the heading.
  final String? subtitle;

  /// Page content, usually a list of [SpecSection]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scrollbar(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(SavSpacing.xxl),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: SavTypography.titleRegularText),
              if (subtitle case final subtitle?) ...<Widget>[
                const SizedBox(height: SavSpacing.sm),
                Text(
                  subtitle,
                  style: SavTypography.bodyRegular.copyWith(
                    color: SavColors.savPrimarySlate,
                  ),
                ),
              ],
              const SizedBox(height: SavSpacing.xl),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

/// A titled block within a [SpecSheet].
class SpecSection extends StatelessWidget {
  /// Creates a spec section.
  const SpecSection({required this.title, required this.child, super.key});

  /// Section heading.
  final String title;

  /// Section body.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SavSpacing.xxl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: SavTypography.headingRegular),
        const SizedBox(height: SavSpacing.md),
        child,
      ],
    ),
  );
}

/// A two-column table of `name -> value` rows.
class SpecTable extends StatelessWidget {
  /// Creates a spec table.
  const SpecTable({required this.rows, super.key});

  /// Rows to render, in order.
  final Map<String, String> rows;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: SavColors.savPrimaryLumen),
      borderRadius: BorderRadius.circular(SavSpacing.sm),
    ),
    child: Column(
      children: <Widget>[
        for (final (index, entry) in rows.entries.indexed)
          DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven
                  ? SavColors.savPrimaryWhite
                  : SavColors.savPrimaryLumen,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SavSpacing.lg,
                vertical: SavSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 220,
                    child: Text(entry.key, style: SavTypography.bodyBold),
                  ),
                  const SizedBox(width: SavSpacing.lg),
                  Expanded(
                    child: Text(entry.value, style: SavTypography.bodyRegular),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

/// A bulleted list of guidance points.
class SpecList extends StatelessWidget {
  /// Creates a spec list.
  const SpecList({required this.items, this.positive = true, super.key});

  /// The points to show.
  final List<String> items;

  /// Whether these are things to do (`true`) or avoid (`false`).
  final bool positive;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: SavSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                positive ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 18,
                color: positive
                    ? SavColors.lushCapital600
                    : SavColors.satinVault600,
              ),
              const SizedBox(width: SavSpacing.sm),
              Expanded(
                child: Text(item, style: SavTypography.bodyRegular),
              ),
            ],
          ),
        ),
    ],
  );
}
