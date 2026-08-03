import 'package:flutter/material.dart';
import 'package:sav_design_system/sav_design_system.dart';

void main() => runApp(const ExampleApp());

/// Everything needed to consume the design system: install [SavTheme.light]
/// once, then use the components.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sav design system example',
    debugShowCheckedModeBanner: false,
    theme: SavTheme.light(),
    home: const CheckoutPage(),
  );
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _submitting = false;
  bool _agreed = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(SavSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: SavSpacing.xxl),
            Text('Confirm deposit', style: SavTypography.titleRegularText),
            const SizedBox(height: SavSpacing.sm),
            Text(
              'Move 250.00 into your Sav account.',
              style: SavTypography.bodyRegular.copyWith(
                color: SavColors.savPrimarySlate,
              ),
            ),
            const Spacer(),
            CheckboxListTile(
              value: _agreed,
              onChanged: (value) => setState(() => _agreed = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'I agree to the terms',
                style: SavTypography.bodyRegular,
              ),
            ),
            const SizedBox(height: SavSpacing.lg),

            // `isLoading` blocks taps on its own, so `onPressed` only has to
            // express whether the form is valid.
            SavButton.primary(
              label: 'Confirm',
              isLoading: _submitting,
              loadingSemanticLabel: 'Confirming your deposit',
              onPressed: _agreed ? _submit : null,
            ),
            const SizedBox(height: SavSpacing.md),
            SavButton.secondary(
              label: 'Cancel',
              onPressed: _submitting ? null : () {},
            ),
            const SizedBox(height: SavSpacing.xl),
          ],
        ),
      ),
    ),
  );
}
