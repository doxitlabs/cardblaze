import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

// Matches, in order: $$display$$, \[display\], \(inline\), $inline$.
// For $inline$ the opening $ must not be followed by whitespace and the
// closing $ must not be preceded by whitespace or followed by a digit, so
// plain prices like "costs $5 and $10" are not treated as math.
final _mathPattern = RegExp(
  r'\$\$([\s\S]+?)\$\$'
  r'|\\\[([\s\S]+?)\\\]'
  r'|\\\(([\s\S]+?)\\\)'
  r'|(?<![\\$])\$(?!\s)((?:[^$\\\n]|\\.)+?)(?<!\s)\$(?!\d)',
);

class MathSegment {
  const MathSegment(this.text, {this.isMath = false, this.display = false});
  final String text;
  final bool isMath;
  final bool display;
}

bool containsMath(String text) => _mathPattern.hasMatch(text);

List<MathSegment> parseMathSegments(String text) {
  final segments = <MathSegment>[];
  var last = 0;
  for (final m in _mathPattern.allMatches(text)) {
    if (m.start > last) segments.add(MathSegment(text.substring(last, m.start)));
    final display = m.group(1) != null || m.group(2) != null;
    final tex = (m.group(1) ?? m.group(2) ?? m.group(3) ?? m.group(4))!.trim();
    segments.add(MathSegment(tex, isMath: true, display: display));
    last = m.end;
  }
  if (last < text.length) segments.add(MathSegment(text.substring(last)));
  return segments;
}

// Drop-in replacement for [Text] that renders LaTeX between $...$ / $$...$$
// (or \(...\) / \[...\]) as real formulas. Plain text without math is
// rendered as a normal [Text]; a formula that fails to parse falls back to
// its raw source so the card content is never lost.
class MathText extends StatelessWidget {
  const MathText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    if (!containsMath(text)) {
      return Text(text, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow);
    }

    final base = DefaultTextStyle.of(context).style.merge(style);
    final spans = <InlineSpan>[];
    for (final seg in parseMathSegments(text)) {
      if (!seg.isMath) {
        spans.add(TextSpan(text: seg.text));
        continue;
      }
      final formula = Math.tex(
        seg.text,
        mathStyle: seg.display ? MathStyle.display : MathStyle.text,
        textStyle: base,
        onErrorFallback: (_) => Text(seg.display ? '\$\$${seg.text}\$\$' : '\$${seg.text}\$', style: base),
      );
      if (seg.display && spans.isNotEmpty) spans.add(const TextSpan(text: '\n'));
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        // Scale down formulas wider than the available line instead of
        // overflowing the card.
        child: FittedBox(fit: BoxFit.scaleDown, child: formula),
      ));
      if (seg.display) spans.add(const TextSpan(text: '\n'));
    }
    if (spans.last case TextSpan(text: '\n')) spans.removeLast();

    return Text.rich(
      TextSpan(style: base, children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Live preview shown under a card text field — only visible once the text
// actually contains a formula.
class MathPreview extends StatelessWidget {
  const MathPreview({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (!containsMath(value.text)) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: MathText(value.text, style: theme.textTheme.bodyMedium),
        );
      },
    );
  }
}
