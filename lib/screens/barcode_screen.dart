import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/widgets/nav_bar.dart/bottom_bar.dart';
import 'package:life_auctor/widgets/barcode/scanner_overlay.dart';
import 'package:life_auctor/widgets/barcode/product_result_card.dart';
import 'package:life_auctor/services/barcode_service.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/providers/history_provider.dart';
import 'package:life_auctor/models/item.dart';

class BarcodeScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(int)? onNavigate;

  const BarcodeScreen({super.key, this.onBack, this.onNavigate});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final BarcodeService _barcodeService = BarcodeService();

  bool _isScanned = false;
  String? _scannedBarcode;
  bool _torchEnabled = false;
  bool _isLoading = false;
  Map<String, String>? _productData;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() {
          _isScanned = true;
          _scannedBarcode = code;
          _isLoading = true;
        });

        // Fetch product data from API
        final productData = await _barcodeService.getProductByBarcode(code);

        setState(() {
          _productData = productData;
          _isLoading = false;
        });

        // Add to history
        if (mounted) {
          final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
          await historyProvider.addBarcodeScanEvent(code, productData?['name']);
        }
      }
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanned = false;
      _scannedBarcode = null;
      _productData = null;
      _isLoading = false;
    });
  }

  Future<void> _addItemAutomatically() async {
    if (_productData == null || _scannedBarcode == null) return;

    final itemProvider = Provider.of<ItemProviderV3>(context, listen: false);
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    // Create new item from barcode data
    final newItem = Item.create(
      name: _productData!['name'] ?? 'Unknown Product',
      quantity: _productData!['quantity'] ?? '1',
      category: _productData!['category'] ?? 'Food',
      notes: 'Barcode: $_scannedBarcode',
    );

    // Add to provider
    await itemProvider.addItem(newItem);

    // Add to history
    await historyProvider.addItemAddedEvent(newItem.name, newItem.id);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newItem.name} added successfully'),
          backgroundColor: AppConstants.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Reset scanner
    _resetScanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A4A4A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _buildScanner(),
                  const ScannerOverlay(),
                  _buildScanningHistory(),
                  if (_isScanned) _buildProductCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: 1,
        onTap: (index) {
          widget.onBack?.call();
          widget.onNavigate?.call(index);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'Scan Barcode',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _controller.toggleTorch();
              setState(() => _torchEnabled = !_torchEnabled);
            },
            child: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled ? Colors.yellow : Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return ClipRRect(
      child: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
      ),
    );
  }

  Widget _buildScanningHistory() {
    return Positioned(
      left: 24,
      right: 24,
      bottom: _isScanned ? 200 : 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Scanning History',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    final state = _isLoading
        ? ProductResultState.loading
        : (_productData == null ? ProductResultState.notFound : ProductResultState.found);

    return ProductResultCard(
      state: state,
      barcode: _scannedBarcode,
      productData: _productData,
      onAddManually: () {
        _resetScanner();
        widget.onNavigate?.call(6); // Navigate to Add Item screen
      },
      onScanAgain: _resetScanner,
      onAddItem: _addItemAutomatically,
    );
  }
}
