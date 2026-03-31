import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignaturePad extends StatefulWidget {
  final String? initialSignature; // Base64 data URI
  final bool canWrite;

  const SignaturePad({super.key, this.initialSignature, this.canWrite = true});

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  ui.Image? _bgImage;

  @override
  void initState() {
    super.initState();
    if (widget.initialSignature != null && widget.initialSignature!.isNotEmpty) {
      _loadInitialSignature(widget.initialSignature!);
    }
  }

  Future<void> _loadInitialSignature(String dataUri) async {
    try {
      String base64Str = dataUri;
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      final bytes = base64Decode(base64Str);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() => _bgImage = frame.image);
      }
    } catch (_) {}
  }

  bool get isEmpty => _strokes.isEmpty && _bgImage == null;

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
      _bgImage = null;
    });
  }

  Future<String?> toBase64() async {
    if (isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(300, 150);

    // 흰색 배경
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // 기존 서명 이미지
    if (_bgImage != null) {
      canvas.drawImageRect(
        _bgImage!,
        Rect.fromLTWH(0, 0, _bgImage!.width.toDouble(), _bgImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
    }

    // 새 획
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final base64Str = base64Encode(byteData.buffer.asUint8List());
    return 'data:image/png;base64,$base64Str';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: GestureDetector(
        onPanStart: widget.canWrite ? (d) {
          setState(() {
            _currentStroke = [d.localPosition];
            _strokes.add(_currentStroke);
          });
        } : null,
        onPanUpdate: widget.canWrite ? (d) {
          setState(() {
            _currentStroke.add(d.localPosition);
          });
        } : null,
        child: CustomPaint(
          painter: _SignaturePainter(_strokes, _bgImage),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final ui.Image? bgImage;

  _SignaturePainter(this.strokes, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    if (bgImage != null) {
      canvas.drawImageRect(
        bgImage!,
        Rect.fromLTWH(0, 0, bgImage!.width.toDouble(), bgImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
    }

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter old) => true;
}
