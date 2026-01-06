import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ModernEventCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int daysCount;
  final double percentage; // Value between 0.0 and 1.0
  final Color color;
  final IconData icon;
  final bool isDarkMode;

  const ModernEventCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.daysCount,
    required this.percentage,
    required this.color,
    required this.icon,
    this.isDarkMode = false, // Toggle this based on your app state
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Define Dynamic Colors
    final bgColor = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final titleColor = isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final subColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    
    // 2. Define Shadow (Soft for Light, None/Subtle for Dark)
    final shadow = isDarkMode 
        ? BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        : BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [shadow],
      ),
      child: Row(
        children: [
          // --- Circular Progress ---
          CircularPercentIndicator(
            radius: 42.0,
            lineWidth: 8.0,
            percent: percentage,
            circularStrokeCap: CircularStrokeCap.round,
            // Center Content
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$daysCount",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: titleColor,
                  ),
                ),
                Text(
                  "days",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: subColor,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
            backgroundColor: isDarkMode ? Colors.white10 : const Color(0xFFF1F5F9),
            progressColor: color,
            animation: true,
            animationDuration: 1000,
          ),
          
          const SizedBox(width: 20),
          
          // --- Text & Icon Info ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon Container (Squircle)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15), 
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: titleColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Status Text
                Text(
                  subtitle, 
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: color, // Matches the brand color
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // --- Action Button (Reset) ---
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: subColor.withOpacity(0.5)),
            onPressed: () {
                // Add reset logic here
            },
          ),
        ],
      ),
    );
  }
}