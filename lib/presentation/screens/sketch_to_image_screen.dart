import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart' show Path;
import 'package:path_provider/path_provider.dart';
import '../../core/services/image_generation_service.dart';
import '../widgets/liquid_card.dart';

class SketchToImageScreen extends StatefulWidget {
  const SketchToImageScreen({super.key});

  @override
  State<SketchToImageScreen> createState() => _SketchToImageScreenState();
}

class _SketchToImageScreenState extends State<SketchToImageScreen>
    with TickerProviderStateMixin {
  // Drawing state
  List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  Color _brushColor = Colors.white;
  double _brushSize = 4.0;
  bool _isErasing = false;
  
  // History
  List<List<List<Offset>>> _undoHistory = [];
  List<List<List<Offset>>> _redoHistory = [];
  
  // Controls animation
  late AnimationController _controlsController;
  late Animation<double> _controlsAnimation;
  
  // Generation state
  bool _isGenerating = false;
  final TextEditingController _promptController = TextEditingController();
  String? _generatedImagePath;
  
  // Services
  final ImageGenerationService _imageService = ImageGenerationService();
  
  @override
  void initState() {
    super.initState();
    _controlsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsController,
      curve: Curves.easeOutCubic,
    );
    _controlsController.forward();
    _imageService.init();
  }
  
  @override
  void dispose() {
    _controlsController.dispose();
    _promptController.dispose();
    super.dispose();
  }
  
  void _addPoint(Offset point) {
    setState(() {
      _currentStroke = [..._currentStroke, point];
    });
  }
  
  void _startStroke(Offset point) {
    _undoHistory.add(List.from(_strokes));
    _redoHistory.clear();
    setState(() {
      _currentStroke = [point];
    });
  }
  
  void _endStroke() {
    if (_currentStroke.isNotEmpty) {
      setState(() {
        _strokes = [..._strokes, _currentStroke];
        _currentStroke = [];
      });
    }
  }
  
  void _undo() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _redoHistory.add(List.from(_strokes));
        _strokes = _undoHistory.removeLast();
      });
    }
  }
  
  void _redo() {
    if (_redoHistory.isNotEmpty) {
      setState(() {
        _undoHistory.add(List.from(_strokes));
        _strokes = _redoHistory.removeLast();
      });
    }
  }
  
  void _clearCanvas() {
    _undoHistory.add(List.from(_strokes));
    _redoHistory.clear();
    setState(() {
      _strokes = [];
      _currentStroke = [];
      _generatedImagePath = null;
    });
  }
  
  Future<Uint8List> _exportSketch() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final size = MediaQuery.of(context).size;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1C1C1E),
    );
    
    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final paint = Paint()
        ..color = _brushColor
        ..strokeWidth = _brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
  
  void _generateImage() async {
    if (_strokes.isEmpty && _promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw something or add a description')),
      );
      return;
    }
    
    setState(() => _isGenerating = true);
    
    try {
      Uint8List? sketchBytes;
      if (_strokes.isNotEmpty) {
        sketchBytes = await _exportSketch();
      }
      
      // For demo, generate from prompt only since we don't have real API
      final result = await _imageService.generateFromPrompt(
        _promptController.text.isNotEmpty 
          ? _promptController.text 
          : 'Beautiful futuristic artwork',
      );
      
      if (result.success && result.imageBytes != null) {
        // Save generated image
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/generated_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(result.imageBytes!);
        
        setState(() {
          _generatedImagePath = file.path;
        });
      } else {
        // If API not configured, simulate generation for demo
        await Future.delayed(const Duration(seconds: 2));
        // Create a demo gradient image
        final img = await _createDemoImage();
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/generated_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(img);
        
        setState(() {
          _generatedImagePath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation error: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }
  
  Future<Uint8List> _createDemoImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    final size = MediaQuery.of(context).size;
    
    // Create gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF667EEA),
        const Color(0xFF764BA2),
        const Color(0xFFF093FB),
      ],
    );
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      ),
    );
    
    // Add some decorative circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.2 + i * 0.15),
          size.height * (0.3 + (i % 2) * 0.2),
        ),
        30 + i * 20.0,
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill,
      );
    }
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
  
  void _saveImage() async {
    if (_generatedImagePath == null) return;
    
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'nova_sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final newFile = File('${dir.path}/$fileName');
      
      await File(_generatedImagePath!).copy(newFile.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }
  
  void _shareImage() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Stack(
        children: [
          // Drawing Canvas
          GestureDetector(
            onPanStart: (d) => _startStroke(d.localPosition),
            onPanUpdate: (d) => _addPoint(d.localPosition),
            onPanEnd: (_) => _endStroke(),
            child: CustomPaint(
              painter: _SketchPainter(
                strokes: _strokes,
                currentStroke: _currentStroke,
                brushColor: _brushColor,
                brushSize: _brushSize,
                isErasing: _isErasing,
              ),
              size: Size.infinite,
            ),
          ),
          
          // Top bar with back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                _buildIconButton(
                  icon: Icons.auto_fix_high,
                  onTap: _generateImage,
                  isPrimary: true,
                ),
              ],
            ),
          ),
          
          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: FadeTransition(
              opacity: _controlsAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_controlsAnimation),
                child: _buildBottomControls(),
              ),
            ),
          ),
          
          // Loading overlay
          if (_isGenerating)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }
  
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return LiquidCard(
      borderRadius: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFFF093FB)],
                  )
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBottomControls() {
    return LiquidCard(
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Prompt input
            if (_generatedImagePath == null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _promptController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Describe what you want...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Drawing tools row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolButton(
                  icon: Icons.undo,
                  label: 'Undo',
                  onTap: _undo,
                  enabled: _undoHistory.isNotEmpty,
                ),
                _buildToolButton(
                  icon: Icons.redo,
                  label: 'Redo',
                  onTap: _redo,
                  enabled: _redoHistory.isNotEmpty,
                ),
                _buildToolButton(
                  icon: _isErasing ? Icons.check : Icons.auto_fix_high,
                  label: _isErasing ? 'Draw' : 'Erase',
                  onTap: () => setState(() => _isErasing = !_isErasing),
                  isActive: _isErasing,
                ),
                _buildColorPicker(),
                _buildBrushSlider(),
                _buildToolButton(
                  icon: Icons.delete_outline,
                  label: 'Clear',
                  onTap: _clearCanvas,
                  enabled: _strokes.isNotEmpty,
                ),
              ],
            ),
            
            // Result actions
            if (_generatedImagePath != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.save_alt,
                    label: 'Save',
                    onTap: _saveImage,
                  ),
                  _buildActionButton(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: _shareImage,
                  ),
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Regenerate',
                    onTap: _generateImage,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
            ? const Color(0xFF667EEA).withOpacity(0.3)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: enabled
                ? (isActive ? const Color(0xFF667EEA) : Colors.white)
                : Colors.white30,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white70 : Colors.white30,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorPicker() {
    final colors = [
      Colors.white,
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF667EEA),
      const Color(0xFFF093FB),
      const Color(0xFFFFD93D),
    ];
    
    return GestureDetector(
      onTap: () => _showColorPicker(colors),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _brushColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 2),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Color',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showColorPicker(List<Color> colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Color',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colors.map((color) => GestureDetector(
                onTap: () {
                  setState(() => _brushColor = color);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _brushColor == color
                        ? const Color(0xFF667EEA)
                        : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBrushSlider() {
    return GestureDetector(
      onTap: () => _showBrushSlider(),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              child: Center(
                child: Container(
                  width: _brushSize * 2,
                  height: _brushSize * 2,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Size',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showBrushSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Brush Size',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _brushSize,
                      min: 1,
                      max: 30,
                      activeColor: const Color(0xFF667EEA),
                      inactiveColor: Colors.white24,
                      onChanged: (v) => setState(() => _brushSize = v),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated rings
            SizedBox(
              width: 120,
              height: 120,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) => CustomPaint(
                  painter: _RingPainter(progress: value),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Creating magic...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color brushColor;
  final double brushSize;
  final bool isErasing;
  
  _SketchPainter({
    required this.strokes,
    required this.currentStroke,
    required this.brushColor,
    required this.brushSize,
    required this.isErasing,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1C1C1E),
    );
    
    // Grid pattern for sketch feel
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    
    const gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Draw strokes
    final paint = Paint()
      ..color = isErasing ? const Color(0xFF1C1C1E) : brushColor
      ..strokeWidth = isErasing ? brushSize * 3 : brushSize
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
    
    // Current stroke
    if (currentStroke.length >= 2) {
      final path = Path();
      path.moveTo(currentStroke.first.dx, currentStroke.first.dy);
      for (int i = 1; i < currentStroke.length; i++) {
        path.lineTo(currentStroke[i].dx, currentStroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _SketchPainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke ||
        brushColor != oldDelegate.brushColor ||
        brushSize != oldDelegate.brushSize ||
        isErasing != oldDelegate.isErasing;
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  
  _RingPainter({required this.progress});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = Color.lerp(
          const Color(0xFF667EEA),
          const Color(0xFFF093FB),
          i / 3,
        )!.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      final startAngle = progress * 3.14 * 2 + i * 1;
      final sweepAngle = 1.5;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - i * 15),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}