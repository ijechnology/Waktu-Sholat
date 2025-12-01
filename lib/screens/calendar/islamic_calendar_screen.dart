import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/calendar_provider.dart'; // Import provider baru
import 'package:intl/intl.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({Key? key}) : super(key: key);

  @override
  _IslamicCalendarScreenState createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late List<String> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Ambil data puasa untuk hari ini saat pertama kali buka
    // Kita pakai 'read' karena ini di initState
    _selectedEvents = context.read<CalendarProvider>().getEventsForDay(_selectedDay!);
  }

  // Fungsi untuk memuat list puasa
  List<String> _getEventsForDay(DateTime day) {
    // Kita pakai 'read' agar tidak memicu build ulang yang tidak perlu
    return context.read<CalendarProvider>().getEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    // Warna dari tema
    final Color primaryAccent = Theme.of(context).primaryColor; // Hijau Tua
    final Color secondaryAccent = Theme.of(context).colorScheme.secondary; // Hijau Sedang
    final Color cardColor = Theme.of(context).colorScheme.surface; // Pink Pucat
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender Ibadah',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // --- Kalender ---
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor, // Pink Pucat
              borderRadius: BorderRadius.circular(16)
            ),
            child: TableCalendar(
              locale: 'id_ID', // Bahasa Indonesia
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              
              eventLoader: _getEventsForDay, // Fungsi untuk penanda

              // --- Styling Kalender ---
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.inter(fontSize: 18.0, fontWeight: FontWeight.bold, color: textColor),
                leftChevronIcon: Icon(Icons.chevron_left, color: primaryAccent),
                rightChevronIcon: Icon(Icons.chevron_right, color: primaryAccent),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: primaryAccent.withOpacity(0.3), // Hijau transparan
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: primaryAccent, // Hijau Tua solid
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: GoogleFonts.inter(color: textColor),
                weekendTextStyle: GoogleFonts.inter(color: Colors.red[400]),
                // Penanda event (puasa/hari besar)
                markerDecoration: BoxDecoration(
                  color: secondaryAccent, // Hijau Sedang
                  shape: BoxShape.circle,
                ),
              ),
              // --- Akhir Styling ---

              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents = _getEventsForDay(selectedDay);
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 8.0),
          
          Text(
            'Info Ibadah ${DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDay!)}:',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8.0),

          // --- List Info Ibadah ---
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada info ibadah.',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      String event = _selectedEvents[index];
                      // Tentukan ikon berdasarkan nama event
                      IconData eventIcon = Icons.check_circle_outline;
                      if(event.contains('Puasa')) {
                        eventIcon = Icons.no_food; // Ikon puasa
                      } else if (event.contains('Hari Raya') || event.contains('Tahun Baru')) {
                        eventIcon = Icons.celebration; // Ikon hari besar
                      } else if (event.contains('Maulid') || event.contains('Isra')) {
                        eventIcon = Icons.mosque; // Ikon masjid
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: cardColor, // Pink Pucat
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: secondaryAccent.withOpacity(0.5))
                        ),
                        child: ListTile(
                          leading: Icon(eventIcon, color: secondaryAccent),
                          title: Text(
                            event,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: textColor),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}