import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Helper class with constant methods to send [IconData] as image data to
/// *Swift*
class IconConverter {
  /// Converts an IconData to PNG bytes
  static Future<Uint8List?> iconToBytes(
    IconData iconData, {
    double size = 24.0,
    Color color = Colors.black,
  }) async {
    try {
      // The higher the scale, the better the quality; using a very high scale may
      // impact performance!
      final double scale = 3.0;
      final double scaledSize = size * scale;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      // Text using the icon data
      textPainter.text = TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: scaledSize,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: color,
          fontFeatures: [const FontFeature.enable('liga')], // Use ligatures :)
        ),
      );

      textPainter.layout();

      final double dx = (scaledSize - textPainter.width) / 2;
      final double dy = (scaledSize - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(dx, dy));

      final picture = recorder.endRecording();

      final img = await picture.toImage(scaledSize.toInt(), scaledSize.toInt());

      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error converting icon to bytes: $e');
      return null;
    }
  }

  /// Alternate version using Widgets with full context
  static Future<Uint8List?> iconWidgetToBytes(
    IconData iconData, {
    double size = 24.0,
    Color color = Colors.black,
  }) async {
    try {
      // Create a full widget with Directionality, will throw errors if not
      // using this parent widget
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Colors.transparent,
          child: Icon(iconData, size: size, color: color),
        ),
      );

      return await _renderWidgetToBytes(widget, Size(size, size));
    } catch (e) {
      debugPrint('Error converting icon widget to bytes: $e');
      return null;
    }
  }

  static Future<Uint8List?> _renderWidgetToBytes(
    Widget widget,
    Size size,
  ) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final PipelineOwner pipelineOwner = PipelineOwner(
      onNeedVisualUpdate: () {},
    );

    final BuildOwner buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () {},
    );

    final RenderView renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(devicePixelRatio: 3.0),
    );

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    // Create the widget tree
    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
          container: repaintBoundary,
          child: widget,
        ).attachToRenderTree(buildOwner);

    try {
      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();

      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      final ui.Image image = await repaintBoundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } finally {
      // Cleaning stuff...
      buildOwner.finalizeTree();
    }
  }
}
