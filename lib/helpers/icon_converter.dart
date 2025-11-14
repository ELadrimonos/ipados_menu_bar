import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Helper class with constant methods to send [IconData] as image data to
/// *Swift*, using the data in a [UIImage].
class IconConverter {
  /// Converts an [IconData] into PNG bytes by drawing the glyph on a canvas.
  /// Produces a sharp result using an internal scale factor.
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

  /// Renders a widget representing an icon and converts it into PNG bytes.
  /// Useful when visual styling or layout beyond a simple glyph is needed.
  static Future<Uint8List?> iconWidgetToBytes(
    Widget widget, {
    double size = 24.0,
  }) async {
    try {
      if (size <= 0) {
        debugPrint('Invalid size: $size');
        return null;
      }

      final wrappedWidget = MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: widget),
          ),
        ),
      );

      return await _renderWidgetToBytes(wrappedWidget, Size(size, size));
    } catch (e) {
      debugPrint('Error converting icon widget to bytes: $e');
      return null;
    }
  }

  static Future<Uint8List?> _renderWidgetToBytes(
    Widget widget,
    Size size,
  ) async {
    try {
      final repaintBoundary = RenderRepaintBoundary();

      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());

      final renderView = RenderView(
        view: WidgetsBinding.instance.platformDispatcher.views.first,
        configuration: ViewConfiguration(
          logicalConstraints: BoxConstraints(
            minWidth: size.width,
            minHeight: size.height,
          ),
          devicePixelRatio: 3.0,
        ),
        child: RenderPositionedBox(
          alignment: Alignment.center,
          child: repaintBoundary,
        ),
      );

      pipelineOwner.rootNode = renderView;
      renderView.prepareInitialFrame();

      final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: widget,
      ).attachToRenderTree(buildOwner);

      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();

      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // Asegurar que las dimensiones son válidas antes de llamar toImage
      final int imageWidth = size.width.toInt();
      final int imageHeight = size.height.toInt();

      if (imageWidth <= 0 || imageHeight <= 0) {
        return null;
      }

      final image = await repaintBoundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e, stackTrace) {
      debugPrint('Error in _renderWidgetToBytes: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
