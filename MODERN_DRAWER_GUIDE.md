# Modern Glassy Drawer & Reports System Guide

## 🎨 Overview

Your TransLine app now features a **completely redesigned navigation system** with:

✅ **Futuristic glassy drawer** with glassmorphism effects
✅ **Montserrat font** for elegant typography
✅ **Role-based menu** (Admin, Manager, Supervisor, Clerk, Owner)
✅ **Reports screen** with calendar and trial balance view
✅ **Independent Parcels menu item**
✅ **Scalable architecture** for future features

---

## 🎯 Key Features

### 1. Modern Glassy Drawer

**Location:** `lib/widgets/modern_drawer.dart`

#### Visual Design
- **Glassmorphism Effect:**
  - Backdrop blur (10px)
  - Semi-transparent backgrounds
  - Layered gradient overlays
  - Smooth shadows and borders

- **Colors:**
  - Primary Red (#DC2626) - Selected items, main actions
  - Info Blue (#3B82F6) - Reports
  - Success Green (#10B981) - Badges, profit indicators
  - Warning Yellow (#F59E0B) - Parcels
  - Error Red (#EF4444) - Logout, expenses

- **Typography:**
  - **Montserrat Bold (700)** - Headers
  - **Montserrat SemiBold (600)** - Menu items
  - **Montserrat Medium (500)** - Body text
  - **Montserrat Regular (400)** - Secondary text

#### Menu Structure

The drawer shows different menu items based on user roles:

```
┌─────────────────────────────────────┐
│  [Avatar]                           │
│  User Name                          │
│  [ADMIN]                            │
├─────────────────────────────────────┤
│  🏠 Dashboard                       │
│  🚌 Trips                          │
│  📊 Reports (Admin, Manager, etc.)  │
│  📦 Parcels                         │
│  ⚙️  Trip Management ▼             │
│     ├─ 🗺️ Routes                   │
│     ├─ 📍 Destinations              │
│     ├─ 📋 Templates                 │
│     └─ 📅 Bulk Creation             │
│  🚛 Fleet ▼ (Admin, Manager)       │
│     ├─ 🚌 Vehicles                 │
│     └─ 👤 Drivers                   │
│  👨‍💼 Administration ▼ (Admin only)  │
│     ├─ 🏢 Owners                    │
│     ├─ 💰 Expense Types             │
│     └─ 👥 Users                     │
├─────────────────────────────────────┤
│  ⚙️  Settings                       │
│  🚪 Logout                          │
├─────────────────────────────────────┤
│  TransLine Cruiser                  │
│  v1.0.0 • by TenzaTech              │
└─────────────────────────────────────┘
```

---

### 2. Role-Based Access Control

#### Admin (super-admin, admin)
- ✅ Dashboard
- ✅ Trips
- ✅ Reports
- ✅ Parcels
- ✅ Trip Management (Routes, Destinations, Templates, Bulk Creation)
- ✅ Fleet (Vehicles, Drivers)
- ✅ Administration (Owners, Expense Types, Users)
- ✅ Settings
- ✅ Logout

#### Manager (manager)
- ✅ Dashboard
- ✅ Trips
- ✅ Reports
- ✅ Parcels
- ✅ Trip Management
- ✅ Fleet (Vehicles, Drivers)
- ✅ Settings
- ✅ Logout

#### Supervisor (supervisor)
- ✅ Dashboard
- ✅ Trips
- ✅ Reports
- ✅ Parcels
- ✅ Trip Management
- ✅ Settings
- ✅ Logout

#### Clerk / Booking Agent (clerk, booking-agent)
- ✅ Dashboard
- ✅ Trips
- ✅ Parcels
- ✅ Settings
- ✅ Logout

#### Owner (owner)
- ✅ Dashboard
- ✅ Trips
- ✅ Reports (can view their fleet's performance)
- ✅ Settings
- ✅ Logout

---

### 3. Reports Screen

**Location:** `lib/screens/reports/reports_screen.dart`
**Route:** `/reports`

#### Features

**📅 Calendar View:**
- Interactive month/week calendar
- Shows trip count per day as green badges
- Click any date to see trial balance
- Today's date highlighted in blue
- Selected date highlighted in red
- Weekends shown in red text

**💰 Trial Balance (shown when date is selected):**

```
┌────────────────────────────────────────┐
│ Trial Balance                          │
│ Monday, January 29, 2026               │
├────────────────────────────────────────┤
│ ┌─────────────┐  ┌─────────────┐     │
│ │ 📈 Total    │  │ 📉 Total    │     │
│ │   Revenue   │  │   Expenses  │     │
│ │ KES 180,000 │  │ KES 80,000  │     │
│ └─────────────┘  └─────────────┘     │
├────────────────────────────────────────┤
│ ✅ Net Profit                          │
│    KES 100,000                         │
│    55.6% margin                        │
├────────────────────────────────────────┤
│ Revenue Breakdown                      │
│ ┌────────────────────────────────────┐│
│ │ 🎫 Booking Revenue   KES 150,000  ││
│ └────────────────────────────────────┘│
│ ┌────────────────────────────────────┐│
│ │ 📦 Parcel Revenue    KES 30,000   ││
│ └────────────────────────────────────┘│
└────────────────────────────────────────┘
```

**Components:**
- **Total Revenue Card** - Green border, shows sum of booking + parcel revenue
- **Total Expenses Card** - Red border, shows all expenses for the day
- **Net Profit/Loss Card** -
  - Green if profit with ✅ icon
  - Red if loss with ⚠️ icon
  - Shows profit margin percentage
- **Revenue Breakdown** - List showing:
  - Booking Revenue (blue icon)
  - Parcel Revenue (yellow icon)

**Future Features (TODO):**
- Export to PDF/Excel button
- Date range filters
- Charts and graphs
- Week-over-week comparison
- Drill-down into specific trips
- Real-time data updates

---

## 📱 Usage Examples

### Example 1: Admin User Login

When an **Admin** logs in, they see the full menu:

```dart
✓ Dashboard
✓ Trips
✓ Reports (can analyze all performance)
✓ Parcels (can manage all parcels)
✓ Trip Management
  ├─ Routes
  ├─ Destinations
  ├─ Templates
  └─ Bulk Creation
✓ Fleet
  ├─ Vehicles
  └─ Drivers
✓ Administration
  ├─ Owners
  ├─ Expense Types
  └─ Users
✓ Settings
✓ Logout
```

### Example 2: Clerk User Login

When a **Clerk** logs in, they see a simplified menu:

```dart
✓ Dashboard
✓ Trips
✓ Parcels (can book parcels)
✓ Settings
✓ Logout
```

### Example 3: Using Reports

1. **Navigate to Reports:**
   - Open drawer
   - Click "Reports" (if you have access)

2. **View Calendar:**
   - See all days with trips (green badges show count)
   - Scroll through months using arrows

3. **Select a Date:**
   - Click on any date
   - Trial balance card appears below

4. **Analyze Performance:**
   - Check total revenue (booking + parcels)
   - Check total expenses
   - See net profit/loss
   - Review profit margin percentage

---

## 🛠️ Technical Implementation

### Dependencies Added

```yaml
# pubspec.yaml
dependencies:
  table_calendar: ^3.1.2  # Calendar widget
  fl_chart: ^0.69.0       # Charts (for future use)
  shimmer: ^3.0.0         # Loading animations
  google_fonts: ^6.2.1    # Montserrat font
```

### File Structure

```
lib/
├── widgets/
│   └── modern_drawer.dart          ✨ NEW - Glassy drawer
├── screens/
│   ├── home/
│   │   └── main_screen.dart        📝 UPDATED - Uses ModernDrawer
│   └── reports/
│       └── reports_screen.dart     ✨ NEW - Reports with calendar
└── main.dart                        📝 UPDATED - Added routes
```

### Routes Added

```dart
// Reports
GoRoute(
  path: '/reports',
  builder: (context, state) => const ReportsScreen(),
),

// Parcels (independent)
GoRoute(
  path: '/parcels',
  builder: (context, state) => ParcelsManagementScreen(),
),
```

---

## 🎨 Customization Guide

### Change Drawer Colors

Edit `lib/widgets/modern_drawer.dart`:

```dart
// Line ~60 - Background gradient
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    TranslinerTheme.primaryRed.withOpacity(0.05),  // Change this
    TranslinerTheme.infoBlue.withOpacity(0.05),    // Change this
    TranslinerTheme.primaryRed.withOpacity(0.03),  // Change this
  ],
),
```

### Change Menu Icons

Edit `lib/widgets/modern_drawer.dart` in `_getMenuItemsForRole()` method:

```dart
// Dashboard icon
items.add(DrawerMenuItem(
  icon: Icons.dashboard_rounded,  // Change icon here
  title: 'Dashboard',
  // ...
));
```

### Add New Menu Items

```dart
// In _getMenuItemsForRole() method
items.add(DrawerMenuItem(
  icon: Icons.your_icon_here,
  title: 'Your Feature',
  iconColor: TranslinerTheme.infoBlue,  // Optional color
  onTap: () {
    Navigator.pop(context);
    context.go('/your-route');
  },
));
```

### Add Sub-Menu Items

```dart
items.add(DrawerMenuItem(
  icon: Icons.category_rounded,
  title: 'Your Section',
  children: [
    DrawerMenuItem(
      icon: Icons.sub_icon_1,
      title: 'Sub Item 1',
      onTap: () {
        Navigator.pop(context);
        context.go('/your-route-1');
      },
    ),
    DrawerMenuItem(
      icon: Icons.sub_icon_2,
      title: 'Sub Item 2',
      onTap: () {
        Navigator.pop(context);
        context.go('/your-route-2');
      },
    ),
  ],
));
```

---

## 📊 Reports Data Integration

### Current State (Mock Data)

The reports screen currently uses mock data for demonstration:

```dart
// lib/screens/reports/reports_screen.dart
Future<void> _loadReportsData() async {
  // TODO: Replace with actual API calls
  // Mock data for demonstration
  setState(() {
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, i + 1);
      _tripCounts[_normalizeDate(date)] = (i % 5) + 1;
      _trialBalanceData[_normalizeDate(date)] = TrialBalanceData(
        bookingRevenue: (i + 1) * 15000.0,
        parcelRevenue: (i + 1) * 3000.0,
        expenses: (i + 1) * 8000.0,
      );
    }
  });
}
```

### How to Connect to Real API

1. **Create API Service Method:**

```dart
// In lib/services/api_service.dart or create new reports service
Future<Map<DateTime, TrialBalanceData>> getTrialBalanceData({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final response = await _makeRequest(
    'GET',
    '$baseUrl/api/reports/trial-balance?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}',
  );

  final Map<DateTime, TrialBalanceData> data = {};
  for (var entry in response['data']) {
    final date = DateTime.parse(entry['date']);
    data[date] = TrialBalanceData.fromJson(entry);
  }
  return data;
}
```

2. **Update Reports Screen:**

```dart
// Replace _loadReportsData() method
Future<void> _loadReportsData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final apiService = ApiService();
    final startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final data = await apiService.getTrialBalanceData(
      startDate: startDate,
      endDate: endDate,
    );

    setState(() {
      _trialBalanceData = data;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _isLoading = false;
    });
  }
}
```

3. **Update TrialBalanceData Model:**

```dart
class TrialBalanceData {
  final double bookingRevenue;
  final double parcelRevenue;
  final double expenses;

  TrialBalanceData({
    required this.bookingRevenue,
    required this.parcelRevenue,
    required this.expenses,
  });

  double get totalRevenue => bookingRevenue + parcelRevenue;
  double get netProfit => totalRevenue - expenses;

  // Add fromJson factory
  factory TrialBalanceData.fromJson(Map<String, dynamic> json) {
    return TrialBalanceData(
      bookingRevenue: (json['booking_revenue'] as num).toDouble(),
      parcelRevenue: (json['parcel_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
    );
  }
}
```

---

## 🚀 Next Steps

### Immediate (Ready to Use)
✅ Run `flutter pub get` to install new dependencies
✅ Test the new drawer navigation
✅ Test the reports screen
✅ Verify role-based access works correctly

### Short-Term Enhancements
- [ ] Connect reports to real API data
- [ ] Add export functionality (PDF/Excel)
- [ ] Add date range filters
- [ ] Add charts (revenue trend, expense breakdown)

### Long-Term Features
- [ ] Real-time updates (WebSockets)
- [ ] Comparison views (week-over-week, month-over-month)
- [ ] Predictive analytics
- [ ] Dashboard widgets
- [ ] Notification badges in drawer
- [ ] Dark mode support

---

## 🎯 Testing Checklist

### Drawer Testing
- [ ] Drawer opens smoothly with glassmorphic effect
- [ ] Avatar shows user initials correctly
- [ ] Role badge displays correctly
- [ ] Menu items show based on user role
- [ ] Expandable sections work smoothly
- [ ] Icons and colors display correctly
- [ ] Selected state highlights properly
- [ ] Logout confirmation works
- [ ] Navigation to screens works

### Reports Testing
- [ ] Calendar loads and displays correctly
- [ ] Trip count badges show on dates
- [ ] Date selection works
- [ ] Trial balance appears on selection
- [ ] Revenue breakdown displays correctly
- [ ] Net profit calculates correctly
- [ ] Profit margin displays
- [ ] Green/red coloring for profit/loss
- [ ] Currency formatting (KES) works
- [ ] Month navigation works

### Role-Based Access Testing

Test with different user roles:

| Test | Admin | Manager | Supervisor | Clerk | Owner |
|------|-------|---------|------------|-------|-------|
| Can see Reports | ✓ | ✓ | ✓ | ✗ | ✓ |
| Can see Trip Management | ✓ | ✓ | ✓ | ✗ | ✗ |
| Can see Fleet | ✓ | ✓ | ✗ | ✗ | ✗ |
| Can see Administration | ✓ | ✗ | ✗ | ✗ | ✗ |
| Can see Parcels | ✓ | ✓ | ✓ | ✓ | ✓ |

---

## 💡 Pro Tips

1. **Smooth Performance:**
   - The drawer uses backdrop blur, which may be GPU-intensive
   - Test on actual devices (not just emulator)
   - If performance issues, reduce blur sigma values

2. **Customization:**
   - All colors use TranslinerTheme constants
   - Easy to change entire color scheme
   - Montserrat font can be swapped in one place

3. **Scalability:**
   - Add new menu items in `_getMenuItemsForRole()` method
   - Role checks use AuthProvider methods
   - Easy to add new roles or permissions

4. **Maintenance:**
   - DrawerMenuItem model is reusable
   - Clear separation of concerns
   - Well-documented code

---

## 📞 Support

If you encounter issues:

1. Check this guide first
2. Verify dependencies are installed (`flutter pub get`)
3. Check user roles are configured correctly
4. Review console logs for errors
5. Test with different user roles

---

## 🎉 Summary

You now have:

✅ **Elegant glassmorphic drawer** with futuristic design
✅ **Role-based navigation** (5 different role configurations)
✅ **Reports screen** with calendar and trial balance
✅ **Independent Parcels** menu item
✅ **Scalable architecture** for future features
✅ **Montserrat typography** throughout
✅ **Professional, modern UI/UX**

The navigation system automatically adapts based on user roles, providing a clean,
professional experience for all users while maintaining security and access control.

Enjoy your new modern navigation system! 🚀

---

*Last Updated: 2026-01-29*
*Version: 1.0.0*
*Part of TransLine Cruiser App*
