import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class UniversalPrinterScreen extends StatefulWidget {
  final Widget content;
  final String title;
  final Future<void> Function(String note)? onPrint;
  final Future<void> Function(String note)? onPdf;
  final Future<void> Function(String note)? onExcel;
  final Future<void> Function(String note)? onEmail;

  const UniversalPrinterScreen({
    super.key,
    required this.content,
    required this.title,
    this.onPrint,
    this.onPdf,
    this.onExcel,
    this.onEmail,
  });

  @override
  State<UniversalPrinterScreen> createState() => _UniversalPrinterScreenState();
}

class _UniversalPrinterScreenState extends State<UniversalPrinterScreen> {
  // Mock states for toolbar interactions
  bool _isLandscape = false;
  bool _isFullScreen = false;
  bool _isActionInProgress = false;
  late TransformationController _transformationController;
  String _note = '';

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(Future<void> Function(String note)? action) async {
    if (_isActionInProgress || action == null) return;

    setState(() => _isActionInProgress = true);
    try {
      await action(_note);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('İşlem hatası: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  void _showAddNoteDialog() {
    final noteController = TextEditingController(text: _note);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Ekle'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Notunuzu buraya girin...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _note = noteController.text);
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      final matrix = _transformationController.value;
      // Simple zoom in center: logic can be complex, simplifying to just scaling current matrix
      // or creating new matrix with increased scale.
      // For simplicity, let's just scale by 10%
      matrix.scale(1.1);
      _transformationController.value = matrix;
    });
  }

  void _zoomOut() {
    setState(() {
      final matrix = _transformationController.value;
      matrix.scale(0.9);
      _transformationController.value = matrix;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Darker background for contrast
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(widget.title),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 1,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      floatingActionButton: _isFullScreen
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _isFullScreen = false),
              icon: const Icon(Icons.fullscreen_exit),
              label: const Text('Tam Ekran Çık'),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
            )
          : null,
      body: Column(
        children: [
          // Toolbar
          if (!_isFullScreen)
            Container(
              height: 60,
              color: Colors.white,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;

                  // Shared list of action buttons for right side
                  final List<Widget> rightActions = [
                    _buildToolbarButton(
                      Icons.email_outlined,
                      'E-posta',
                      () => _handleAction(widget.onEmail),
                    ),
                    _buildToolbarButton(
                      Icons.picture_as_pdf_outlined,
                      'PDF',
                      () => _handleAction(widget.onPdf),
                    ),
                    _buildToolbarButton(
                      Icons.table_chart_outlined,
                      'Excel',
                      () => _handleAction(widget.onExcel),
                    ),
                    const SizedBox(width: 8),
                    if (_isActionInProgress)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _handleAction(widget.onPrint),
                        icon: const Icon(Icons.print, size: 18),
                        label: const Text('Yazdır'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                        ),
                      ),
                  ];

                  // Shared list of tool buttons for left side
                  final List<Widget> leftTools = [
                    _buildToolbarButton(
                      Icons.note_add_outlined,
                      'Not Ekle',
                      _showAddNoteDialog,
                    ),
                    _buildToolbarButton(
                      Icons.fullscreen,
                      'Tam Ekran',
                      () => setState(() => _isFullScreen = true),
                    ),
                    _buildToolbarButton(Icons.zoom_in, 'Büyüt', _zoomIn),
                    _buildToolbarButton(Icons.zoom_out, 'Küçült', _zoomOut),
                    const VerticalDivider(indent: 12, endIndent: 12),
                    _buildToolbarButton(
                      _isLandscape
                          ? Icons.stay_current_landscape
                          : Icons.stay_current_portrait,
                      'Yön',
                      () {
                        setState(() => _isLandscape = !_isLandscape);
                      },
                    ),
                  ];

                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ...leftTools,
                          const SizedBox(width: 20), // Spacer replacement
                          ...rightActions,
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ...leftTools,
                          const Spacer(),
                          ...rightActions,
                        ],
                      ),
                    );
                  }
                },
              ),
            ),

          // Preview Area
          Expanded(
            child: InteractiveViewer(
              minScale: 0.1,
              maxScale: 4.0,
              constrained:
                  false, // Allow content to be larger than the viewport
              boundaryMargin: const EdgeInsets.all(
                100,
              ), // Allow scrolling past content
              transformationController: _transformationController,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                    // A4 Ratio: 1 : 1.414
                    width: _isLandscape
                        ? 842
                        : 595, // Approx A4 width in pixels
                    height: _isLandscape ? 595 : 842, // Approx A4 height
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: widget.content),
                        if (_note.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.yellow[100],
                              border: Border.all(color: Colors.yellow[700]!),
                            ),
                            child: Text(
                              'Not: $_note',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.grey[700]),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
