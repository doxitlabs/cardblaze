import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:cardblaze/widgets/math_text.dart';

void main() {
  test('parses inline and display math', () {
    final segs = parseMathSegments(r'Area is $\pi r^{2}$ and $$\frac{a}{b}$$ done');
    expect(segs.map((s) => s.isMath).toList(), [false, true, false, true, false]);
    expect(segs[1].text, r'\pi r^{2}');
    expect(segs[3].display, isTrue);
  });

  test('prices are not math', () {
    expect(containsMath(r'It costs $5 and $10 today'), isFalse);
    expect(containsMath('No math here'), isFalse);
    expect(containsMath(r'Water is $H_{2}O$'), isTrue);
    expect(containsMath(r'\(x+1\)'), isTrue);
  });

  testWidgets('MathText renders formulas via Math widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MathText(r'Solve $x^{2} = 4$ and $\broken{$')),
    ));
    expect(find.byType(Math), findsWidgets);
  });
}
