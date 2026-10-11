import 'package:flutter/material.dart';

/// 斜纹条带
///
/// 顶部圆角、底部直角的条带，通常叠在卡片上方作为独立顶盖。
/// 斜纹由 [stripeColorA]、[stripeColorB] 交替构成，右侧带一个小号文字标签。
class StripeBandBanner extends StatelessWidget {
  final String label;
  final double? height;
  final Color? stripeColorA;
  final Color? stripeColorB;
  final Color? textColor;
  final double stripeWidth;
  final BorderRadius borderRadius;
  final double fontSize;
  final double? textHeight;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const StripeBandBanner({
    super.key,
    this.label = '',
    this.height,
    this.stripeColorA,
    this.stripeColorB,
    this.textColor,
    this.stripeWidth = 3,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(4)),
    this.fontSize = 7,
    this.textHeight,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsetsDirectional.only(end: 5),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final resolvedStripeA = stripeColorA ?? scheme.surfaceContainerLow;
    final resolvedStripeB = stripeColorB ?? scheme.secondaryContainer;
    // final resolvedText = textColor ?? scheme.onSecondaryContainer;
    final resolvedText = textColor ?? scheme.onSurfaceVariant;

    final double r = borderRadius.topLeft.x;
    final double? totalHeight = height == null ? null : height! + r;

    return Semantics(
      label: label,
      child: Padding(
        padding: margin,
        child: SizedBox(
          height: totalHeight,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _DiagonalStripePainter(
                    colorA: resolvedStripeA,
                    colorB: resolvedStripeB,
                    stripeWidth: stripeWidth,
                  ),
                ),
                if (label.isNotEmpty)
                  Padding(
                    padding: padding,
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: SizedBox(
                        height: textHeight,
                        child: FittedBox(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w800,
                              color: resolvedText,
                              letterSpacing: -0.2,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 绘制 45° 「/」方向的斜纹。
class _DiagonalStripePainter extends CustomPainter {
  final Color colorA;
  final Color colorB;
  final double stripeWidth;

  const _DiagonalStripePainter({
    required this.colorA,
    required this.colorB,
    required this.stripeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = colorA);

    final stripePaint = Paint()
      ..color = colorB
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double period = stripeWidth * 2;

    for (double x = -h; x < w + h; x += period) {
      final path = Path()
        ..moveTo(x, h)
        ..lineTo(x + stripeWidth, h)
        ..lineTo(x + stripeWidth + h, 0)
        ..lineTo(x + h, 0)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripePainter old) {
    return old.colorA != colorA ||
        old.colorB != colorB ||
        old.stripeWidth != stripeWidth;
  }
}
