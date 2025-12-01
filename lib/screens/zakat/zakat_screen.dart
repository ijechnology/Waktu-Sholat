import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/zakat_provider.dart';
import '../../services/notification_service.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({Key? key}) : super(key: key);

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _hartaController = TextEditingController();
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  int _currentPage = 0;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _hartaController.addListener(_formatCurrency);
  }

  void _formatCurrency() {
    String text = _hartaController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return;
    double value = double.parse(text);
    String newText = _formatter.format(value);
    if (_hartaController.text != newText) {
      _hartaController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _hartaController.dispose();
    super.dispose();
  }

  // --- (Logika Navigasi Wizard tidak berubah) ---
  void _nextPage(BuildContext context) {
    final zakatProvider = context.read<ZakatProvider>();
    if (_currentPage == 0) {
      if(_hartaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total harta tidak boleh kosong.'), backgroundColor: Colors.redAccent)
        );
        return;
      }
      zakatProvider.setHartaAndCalculate(_hartaController.text);
    } 
    else if (_currentPage == 1) {
      if (!zakatProvider.wajibZakat) {
        _resetWizard();
        return;
      }
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
  void _resetWizard() {
    context.read<ZakatProvider>().resetWizard();
    _hartaController.clear();
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color secondaryTextColor = const Color(0xFF6B7280);
    final Color cardColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text('Asisten Zakat Mal',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Indikator Langkah (Dots)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: _currentPage == index ? 12.0 : 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage >= index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), 
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildStep1(textColor, secondaryTextColor, cardColor),
                _buildStep2(context, textColor, secondaryTextColor, cardColor),
                _buildStep3(context, textColor, secondaryTextColor, cardColor),
              ],
            ),
          ),
          
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  // --- WIDGET UNTUK LANGKAH 1 (DIPERBARUI) ---
  Widget _buildStep1(Color textColor, Color secondaryTextColor, Color cardColor) {
    // 1. Gunakan LayoutBuilder untuk mendapatkan tinggi layar
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            // 2. Buat kontainer seukuran tinggi layar
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            // 3. Gunakan Column dengan MainAxisAlignment.center
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // <-- KUNCI PERBAIKAN
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Langkah 1: Harta Anda',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan total harta (tabungan, emas, saham, dll) yang telah dimiliki selama 1 tahun penuh.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: secondaryTextColor, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _hartaController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: textColor, fontSize: 28, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Rp 0',
                      fillColor: Colors.white,
                      focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder?.copyWith(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                      enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // --- WIDGET UNTUK LANGKAH 2 (DIPERBARUI) ---
  Widget _buildStep2(BuildContext context, Color textColor, Color secondaryTextColor, Color cardColor) {
    final zakatProvider = context.watch<ZakatProvider>(); 
    
    bool wajib = zakatProvider.wajibZakat;
    IconData icon = wajib ? Icons.check_circle : Icons.cancel;
    Color bgColor = wajib ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) : Theme.of(context).colorScheme.error.withOpacity(0.1);
    Color iconColor = wajib ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error;
    Color titleColor = wajib ? Theme.of(context).colorScheme.secondary : Colors.red.shade900;
    String title = wajib ? 'Anda Wajib Zakat' : 'Anda Belum Wajib Zakat';

    // 1. Gunakan LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            // 2. Buat kontainer seukuran tinggi layar
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            // 3. Gunakan Column dengan MainAxisAlignment.center
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // <-- KUNCI PERBAIKAN
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 60),
                ),
                const SizedBox(height: 16),
                Text(
                  'Langkah 2: Cek Nishab',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nishab 85gr Emas ≈ ${zakatProvider.formatRupiah(zakatProvider.nishab)}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: secondaryTextColor, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                              color: titleColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Harta Anda: ${zakatProvider.formatRupiah(zakatProvider.totalHarta)}',
                          style: GoogleFonts.inter(color: textColor, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // --- WIDGET UNTUK LANGKAH 3 (DIPERBARUI) ---
  Widget _buildStep3(BuildContext context, Color textColor, Color secondaryTextColor, Color cardColor) {
    final zakatProvider = context.watch<ZakatProvider>();

    // 1. Gunakan LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            // 2. Buat kontainer seukuran tinggi layar
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            // 3. Gunakan Column dengan MainAxisAlignment.center
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // <-- KUNCI PERBAIKAN
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calculate_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Langkah 3: Total Zakat',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Berikut adalah total zakat (2.5%) yang harus Anda keluarkan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: secondaryTextColor, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 30),

                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5)
                        )
                      ]
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Zakat Mal (2.5%):',
                          style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.8), fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          zakatProvider.getFormattedZakatInCurrency(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: zakatProvider.selectedCurrency,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: GoogleFonts.inter(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
                      icon: zakatProvider.isLoading
                          ? Container(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                      onChanged: (String? newValue) {
                        if (newValue != null && !zakatProvider.isLoading) {
                          zakatProvider.setCurrency(newValue);
                        }
                      },
                      items: <String>['IDR', 'USD', 'MYR', 'KRW', 'JPY']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // --- WIDGET TOMBOL NAVIGASI (Logika tidak berubah) ---
  Widget _buildNavigationButtons(BuildContext context) {
    // ... (kode _buildNavigationButtons tidak berubah)
    final zakatProvider = context.watch<ZakatProvider>(); 

    String nextButtonText = 'Lanjut';
    if (_currentPage == 1) {
      nextButtonText = zakatProvider.wajibZakat ? 'Lanjut ke Hasil' : 'Hitung Ulang';
    } else if (_currentPage == 2) {
      nextButtonText = 'Selesai';
    }
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: _currentPage > 0,
            maintainSize: true, 
            maintainAnimation: true, 
            maintainState: true,
            child: TextButton(
              onPressed: _previousPage,
              child: Text(
                'Kembali',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == 2) {
                final provider = context.read<ZakatProvider>();
                if (provider.wajibZakat) {
                  String formattedAmount = provider.getFormattedZakatInCurrency(); 
                  _notificationService.showZakatCalculationNotification(formattedAmount);
                }
                _resetWizard();
              } else {
                _nextPage(context);
              }
            },
            child: Text(nextButtonText),
          ),
        ],
      ),
    );
  }
}