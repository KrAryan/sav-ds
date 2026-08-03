// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:sav_catalog/foundations/foundations_use_cases.dart'
    as _sav_catalog_foundations_foundations_use_cases;
import 'package:sav_catalog/use_cases/sav_action_button_use_cases.dart'
    as _sav_catalog_use_cases_sav_action_button_use_cases;
import 'package:sav_catalog/use_cases/sav_button_use_cases.dart'
    as _sav_catalog_use_cases_sav_button_use_cases;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Components',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'SavActionButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Against SavButton',
            builder: _sav_catalog_use_cases_sav_action_button_use_cases
                .buildSavActionButtonComparison,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'All states',
            builder: _sav_catalog_use_cases_sav_action_button_use_cases
                .buildSavActionButtonMatrix,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _sav_catalog_use_cases_sav_action_button_use_cases
                .buildSavActionButtonPlayground,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Specs',
            builder: _sav_catalog_use_cases_sav_action_button_use_cases
                .buildSavActionButtonSpecs,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SavButton',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'All states',
            builder: _sav_catalog_use_cases_sav_button_use_cases
                .buildSavButtonMatrix,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'In a row',
            builder:
                _sav_catalog_use_cases_sav_button_use_cases.buildSavButtonRow,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Playground',
            builder: _sav_catalog_use_cases_sav_button_use_cases
                .buildSavButtonPlayground,
          ),
          _widgetbook.WidgetbookUseCase(
            name: 'Specs',
            builder:
                _sav_catalog_use_cases_sav_button_use_cases.buildSavButtonSpecs,
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookCategory(
    name: 'Foundations',
    children: [
      _widgetbook.WidgetbookComponent(
        name: 'SavColors',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Palette',
            builder: _sav_catalog_foundations_foundations_use_cases
                .buildColorPalette,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SavSquircle',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Corner smoothing',
            builder: _sav_catalog_foundations_foundations_use_cases
                .buildSquircleScale,
          ),
        ],
      ),
      _widgetbook.WidgetbookComponent(
        name: 'SavTypography',
        useCases: [
          _widgetbook.WidgetbookUseCase(
            name: 'Type scale',
            builder:
                _sav_catalog_foundations_foundations_use_cases.buildTypeScale,
          ),
        ],
      ),
    ],
  ),
];
