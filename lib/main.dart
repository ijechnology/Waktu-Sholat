import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_fonts/google_fonts.dart';

// Import semua provider
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/zakat_provider.dart';
// --- PERUBAHAN ---
import 'providers/calendar_provider.dart'; // Ganti dari TimezoneProvider
import 'providers/quran_provider.dart';   // Tambah QuranProvider
// --- AKHIR PERUBAHAN ---

// Import screen
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  tz.initializeTimeZones();
  await NotificationService().init();
  await initializeDateFormatting('id_ID', null);

  runApp(const PrayTimeApp());
}

class PrayTimeApp extends StatelessWidget {
  const PrayTimeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    // Tema "Soft Green & Peach" (Tidak berubah)
    final ThemeData theme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color(0xFF3A6F43),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3A6F43), 
        secondary: Color(0xFF59AC77), 
        background: Colors.white,
        surface: Color(0xFFFFD5D5), 
        error: Color(0xFFFDAAAA), 
        onPrimary: Colors.white, 
        onSurface: Color(0xFF1F2937), 
        onBackground: Color(0xFF1F2937),
      ),
      textTheme: GoogleFonts.interTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        bodyColor: const Color(0xFF1F2937),
        displayColor: const Color(0xFF1F2937),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
          fontSize: 20,
        ),
        shape: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF3A6F43),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A6F43),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0, 
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
        hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3A6F43), width: 2),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => ZakatProvider()),
        // --- PERUBAHAN ---
        ChangeNotifierProvider(create: (_) => CalendarProvider()), // Ganti TimezoneProvider
        ChangeNotifierProvider(create: (_) => QuranProvider()),   // Tambah QuranProvider
        // --- AKHIR PERUBAHAN ---
      ],
      child: MaterialApp(
        title: 'PrayTime',
        theme: theme, 
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}