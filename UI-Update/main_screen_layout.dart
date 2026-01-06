import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modern_event_card.dart'; // Import the file created above

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Change this boolean to test Dark Mode
    bool isDarkMode = false; 
    
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF2F5F9);
    final headerColor = isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: backgroundColor,
      
      // Modern FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF), // Modern Purple
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Custom Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Days Since",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: headerColor,
                        ),
                      ),
                      Text(
                        "Track your recurring events",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  // Minimal Settings Button
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                         if (!isDarkMode)
                           BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,4))
                      ]
                    ),
                    child: IconButton(
                      icon: Icon(Icons.settings_outlined, color: headerColor),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),

            // --- List of Cards ---
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(), // Modern iOS feel
                children: [
                  ModernEventCard(
                    title: "Water Filter",
                    subtitle: "1 day remaining",
                    daysCount: 0,
                    percentage: 0.1,
                    color: const Color(0xFF29B6F6), // Light Blue
                    icon: Icons.water_drop,
                    isDarkMode: isDarkMode,
                  ),
                  ModernEventCard(
                    title: "Haircut",
                    subtitle: "7 days remaining",
                    daysCount: 7,
                    percentage: 0.3,
                    color: const Color(0xFFA78BFA), // Pastel Purple
                    icon: Icons.content_cut,
                    isDarkMode: isDarkMode,
                  ),
                  ModernEventCard(
                    title: "Oil Change",
                    subtitle: "Overdue by 2 days",
                    daysCount: 32,
                    percentage: 1.0,
                    color: const Color(0xFFEF4444), // Red/Alert
                    icon: Icons.directions_car,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}