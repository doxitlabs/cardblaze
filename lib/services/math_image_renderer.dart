import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cardblaze/widgets/math_text.dart';

class RenderedMath {
  const RenderedMath(this.png, this.width, this.height);
  final Uint8List png;
  // Logical size — 1 logical pixel is drawn as 1 PDF point.
  final double width;
  final double height;
}

// Renders a card text containing LaTeX offscreen, through the same MathText
// widget the app uses, so formulas in the exported PDF look exactly like on
// screen. The widget tree is never attached to the visible UI.
class MathImageRenderer {
  static const _pixelRatio = 3.0;

  static Future<RenderedMath> render(
    String text, {
    required double maxWidth,
    required TextStyle style,
  }) async {
    final boundary = RenderRepaintBoundary();
    final view = ui.PlatformDispatcher.instance.implicitView ??
        ui.PlatformDispatcher.instance.views.first;
    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(alignment: Alignment.topLeft, child: boundary),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(Size(maxWidth, 10000)),
        devicePixelRatio: 1,
      ),
    );

    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final root = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: style,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: MathText(text, style: style),
            ),
          ),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner
      ..buildScope(root)
      ..finalizeTree();
    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final size = boundary.size;
    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return RenderedMath(data!.buffer.asUint8List(), size.width, size.height);
  }
}
