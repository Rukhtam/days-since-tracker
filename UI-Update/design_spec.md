# Days Since App - Modern Redesign Specification

## 1. Design Philosophy
 The goal is to move away from the "Stock Material 2" look (stark white, hard black borders) to a **Modern Minimalist** aesthetic. This involves:
*   **Soft UI:** Replacing borders with soft shadows and spacing.
*   **Squircle Shapes:** Using high border-radii (20px+) for a friendlier feel.
*   **Typography:** Using geometric sans-serif fonts (Poppins or Outfit).
*   **Visual Hierarchy:** Using color primarily for status indication, keeping the rest neutral.

---

## 2. Color Palettes

### Theme A: "Soft Minimal" (Light Mode)
*Best for daytime readability and a clean, airy feel.*

| Element | Color | Hex Code | Note |
| :--- | :--- | :--- | :--- |
| **Background** | Off-White / Blue-Grey | `#F2F5F9` | Never use pure white for backgrounds. |
| **Cards** | Pure White | `#FFFFFF` | Pop against the off-white bg. |
| **Primary Text** | Slate Dark | `#1E293B` | Softer than pure black. |
| **Secondary Text** | Cool Grey | `#64748B` | For subtitles/labels. |
| **Shadows** | Soft Grey | `#000000` (5-10% Opacity) | High blur radius. |

### Theme B: "Midnight Neon" (Dark Mode)
*Best for OLED screens and a premium, high-tech feel.*

| Element | Color | Hex Code | Note |
| :--- | :--- | :--- | :--- |
| **Background** | Deep Slate | `#0F172A` | Richer than pure black. |
| **Cards** | Dark Slate | `#1E293B` | Slightly lighter than bg. |
| **Primary Text** | Off-White | `#F8FAFC` | High contrast. |
| **Secondary Text** | Slate Grey | `#94A3B8` | Muted. |
| **Accents** | Neon Pastels | `#34D399` (Green), `#A78BFA` (Purple) | Glowing effect. |

---

## 3. Flutter Implementation

### Dependencies
Add these to your `pubspec.yaml`:
```yaml
dependencies:
  google_fonts: ^6.1.0
  percent_indicator: ^4.2.3