import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home/home_screen.dart';
import 'zakat/zakat_screen.dart';
import 'profile/profile_screen.dart';
// --- PERUBAHAN ---
import 'calendar/islamic_calendar_screen.dart'; // Ganti dari timezone
import 'quran/quran_list_screen.dart'; // Halaman Quran baru
// --- AKHIR PERUBAHAN ---

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // --- PERUBAHAN: Tambah 1 screen ---
  final List<Widget> _screens = [
    HomeScreen(),
    const ZakatScreen(),
    const QuranListScreen(), // Halaman Quran
    const IslamicCalendarScreen(), // Halaman Kalender
    const ProfileScreen(),
  ];
  // --- AKHIR PERUBAHAN ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN: Tambah 1 item ---
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calculate_outlined),
        activeIcon: Icon(Icons.calculate),
        label: 'Zakat',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book_outlined), // Ikon Quran
        activeIcon: Icon(Icons.book),
        label: 'Qur\'an',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined), // Ikon Kalender
        activeIcon: Icon(Icons.calendar_month),
        label: 'Kalender',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
    // --- AKHIR PERUBAHAN ---

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          
          type: BottomNavigationBarType.fixed, // Wajib agar 5 item muat
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor, 
          unselectedItemColor: const Color(0xFF6B7280), 
          elevation: 0, 
          selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),

          items: items, // Gunakan list items yang baru
        ),
      ),
    );
  }
}