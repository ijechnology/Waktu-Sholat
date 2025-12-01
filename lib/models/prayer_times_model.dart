// lib/models/prayer_times_model.dart

class PrayerTimes {
  final String fajr;
  final String sunrise; // <-- DITAMBAHKAN KEMBALI
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.fajr,
    required this.sunrise, // <-- DITAMBAHKAN KEMBALI
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  // Factory 'fromJson' yang "kuat" (robust)
  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    // Pengecekan 'as String?'
    // Jika data dari API null, kita ganti jadi 'Error'
    return PrayerTimes(
      fajr: (json['Fajr'] as String?) ?? 'Error',
      sunrise: (json['Sunrise'] as String?) ?? 'Error', // <-- DITAMBAHKAN KEMBALI
      dhuhr: (json['Dhuhr'] as String?) ?? 'Error',
      asr: (json['Asr'] as String?) ?? 'Error',
      maghrib: (json['Maghrib'] as String?) ?? 'Error',
      isha: (json['Isha'] as String?) ?? 'Error',
    );
  }

  // Helper untuk mengubah data menjadi Map (berguna untuk notifikasi)
  Map<String, String> toMap() {
    return {
      'Subuh': fajr,
      'Dzuhur': dhuhr,
      'Ashar': asr,
      'Maghrib': maghrib,
      'Isya': isha,
    };
  }
}