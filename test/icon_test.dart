// Tests adapted from https://github.com/fluttercommunity/font_awesome_flutter/blob/master/test/fa_icon_test.dart
// Copyright 2014 The Flutter Authors. All rights reserved.

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';

// 🌎 Project imports:
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  testWidgets('Can set opacity for an Icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: IconTheme(
          data: IconThemeData(color: Color(0xFF666666), opacity: 0.5),
          child: Icon(LucideIcons.bot),
        ),
      ),
    );
    final text = tester.widget<RichText>(find.byType(RichText));

    // Color opacity is stored in 8-bit alpha; 0.5 rounds to 128/255 (0.50196..),
    // so exact 0.5 equality is flaky across framework/color internals.
    expect(text.text.style!.color!.r, closeTo(0.4, 1e-6));
    expect(text.text.style!.color!.g, closeTo(0.4, 1e-6));
    expect(text.text.style!.color!.b, closeTo(0.4, 1e-6));
    expect(text.text.style!.color!.a, closeTo(128 / 255, 1e-6));
  });

  testWidgets('Icon sizing - no theme, default size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Icon(LucideIcons.bot)),
      ),
    );

    final renderObject = tester.renderObject<RenderBox>(find.byType(Icon));
    expect(renderObject.size, equals(const Size.square(24)));
  });

  testWidgets('Icon sizing - no theme, explicit size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Icon(LucideIcons.bot, size: 96)),
      ),
    );

    final renderObject = tester.renderObject<RenderBox>(find.byType(Icon));
    expect(renderObject.size, equals(const Size.square(96)));
  });

  testWidgets('Icon sizing - sized theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: IconTheme(
            data: IconThemeData(size: 36),
            child: Icon(LucideIcons.bot),
          ),
        ),
      ),
    );

    final renderObject = tester.renderObject<RenderBox>(find.byType(Icon));
    expect(renderObject.size, equals(const Size.square(36)));
  });

  testWidgets('Icon sizing - sized theme, explicit size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: IconTheme(
            data: IconThemeData(size: 36),
            child: Icon(LucideIcons.bot, size: 48),
          ),
        ),
      ),
    );

    final renderObject = tester.renderObject<RenderBox>(find.byType(Icon));
    expect(renderObject.size, equals(const Size.square(48)));
  });

  testWidgets('Icon sizing - sizeless theme, default size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: IconTheme(data: IconThemeData(), child: Icon(LucideIcons.bot)),
        ),
      ),
    );

    final renderObject = tester.renderObject<RenderBox>(find.byType(Icon));
    expect(renderObject.size, equals(const Size.square(24)));
  });

  testWidgets("Changing semantic label from null doesn't rebuild tree ", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Icon(LucideIcons.bot)),
      ),
    );

    final richText1 = tester.element<Element>(find.byType(RichText));

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Icon(LucideIcons.bot, semanticLabel: 'a label')),
      ),
    );

    final richText2 = tester.element<Element>(find.byType(RichText));

    // Compare a leaf Element in the Icon subtree before and after changing the
    // semanticLabel to make sure the subtree was not rebuilt.
    expect(richText2, same(richText1));
  });
}
