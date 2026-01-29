# Trip Management Implementation Guide

## Overview

This guide explains how to complete the trip management system implementation using the Owner Management screen as a reference template. All the foundation has been set up:

✅ **Completed:**
- San Francisco-like typography (Inter font via Google Fonts)
- Standardized Material 3 theme
- All data models (Owner, Vehicle, Driver, Route, Destination, Expense Template, Trip Template)
- Comprehensive API service with all endpoints
- Unified state management provider
- Reference implementation: Owner Management Screen
- Updated routing and navigation

📋 **Remaining Work:**
- Vehicle Management Screen
- Driver Management Screen
- Route Management Screen (with subroutes)
- Destination Management Screen
- Expense Management Screen
- Template Management Screen
- Bulk Trip Creation Screen

---

## Quick Start

### 1. Prerequisites

Run the following command to install dependencies:

```bash
flutter pub get
```

### 2. Test the Reference Implementation

1. Run the app
2. Login with admin credentials
3. Navigate to Operations → Owners
4. Test CRUD operations (Create, Read, Update, Delete)

---

## Architecture Overview

### File Structure

```
lib/
├── models/                          # Data models
│   ├── owner_model.dart            ✅ Complete
│   ├── vehicle_model.dart          ✅ Complete
│   ├── driver_model.dart           ✅ Complete
│   ├── route_model.dart            ✅ Complete (includes SubrouteModel)
│   ├── destination_model.dart      ✅ Complete
│   ├── expense_template_model.dart ✅ Complete
│   └── trip_template_model.dart    ✅ Complete (includes TemplateTripsModel, DropdownOptionsModel)
│
├── services/                        # API Services
│   ├── api_service.dart            ✅ Existing
│   └── trip_management_api_service.dart ✅ Complete
│
├── providers/                       # State Management
│   ├── auth_provider.dart          ✅ Existing
│   ├── trip_provider.dart          ✅ Existing
│   ├── app_settings_provider.dart  ✅ Existing
│   └── trip_management_provider.dart ✅ Complete
│
├── screens/
│   ├── trip_management/
│   │   ├── owner_management_screen.dart       ✅ Complete (Reference Implementation)
│   │   ├── vehicle_management_screen.dart     📋 TODO
│   │   ├── driver_management_screen.dart      📋 TODO
│   │   ├── route_management_screen.dart       📋 TODO
│   │   ├── destination_management_screen.dart 📋 TODO
│   │   ├── expense_management_screen.dart     📋 TODO
│   │   ├── template_management_screen.dart    📋 TODO
│   │   └── bulk_trip_creation_screen.dart     📋 TODO
│   │
│   └── operations/
│       └── operations_screen.dart  ✅ Updated
│
├── theme/
│   └── transliner_theme.dart       ✅ Complete
│
└── main.dart                        ✅ Updated
```

---

## How to Implement a New Management Screen

### Step-by-Step Process

Each management screen follows the same pattern as `owner_management_screen.dart`. Follow these steps:

#### 1. Create the Screen File

Create a new file in `lib/screens/trip_management/`:

```dart
// Example: vehicle_management_screen.dart
// Copy owner_management_screen.dart and modify as follows
```

#### 2. Rename Classes

Replace "Owner" with your entity name throughout:

- `OwnerManagementScreen` → `VehicleManagementScreen`
- `_OwnerCard` → `_VehicleCard`
- `_OwnerFormDialog` → `_VehicleFormDialog`

#### 3. Update Provider References

Change all provider method calls to match your entity:

```dart
// From:
provider.fetchOwners()
provider.createOwner(owner)
provider.updateOwner(id, owner)
provider.deleteOwner(id)

// To:
provider.fetchVehicles()
provider.createVehicle(vehicle)
provider.updateVehicle(id, vehicle)
provider.deleteVehicle(id)
```

#### 4. Update Model References

Change model imports and usage:

```dart
// From:
import '../../models/owner_model.dart';
OwnerModel owner;

// To:
import '../../models/vehicle_model.dart';
VehicleModel vehicle;
```

#### 5. Customize Form Fields

Modify the form dialog to match your entity's fields:

**Example for Vehicle Management:**

```dart
// Replace Owner form fields with Vehicle fields
TextFormField(
  controller: _regNoController,
  decoration: const InputDecoration(
    labelText: 'Registration Number',
    hintText: 'KAA 123A',
    prefixIcon: Icon(Icons.directions_bus),
  ),
),
TextFormField(
  controller: _vehicleTypeController,
  decoration: const InputDecoration(
    labelText: 'Vehicle Type',
    hintText: 'Bus - 50 Seater',
    prefixIcon: Icon(Icons.category),
  ),
),
TextFormField(
  controller: _seatsController,
  decoration: const InputDecoration(
    labelText: 'Number of Seats',
    hintText: '50',
    prefixIcon: Icon(Icons.airline_seat_recline_normal),
  ),
  keyboardType: TextInputType.number,
),
```

#### 6. Customize Card Display

Update the card widget to display relevant entity information:

**Example for Vehicle Card:**

```dart
class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  // ...

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: TranslinerSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  size: 40,
                  color: TranslinerTheme.primaryRed,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.regNo,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        vehicle.vehicleType,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${vehicle.seats} seats',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Status badge
                // ...
              ],
            ),
            // Actions
            // ...
          ],
        ),
      ),
    );
  }
}
```

#### 7. Add Route

Update `main.dart` to add the route:

```dart
GoRoute(
  path: '/operations/vehicles',
  builder: (context, state) => const VehicleManagementScreen(),
),
```

#### 8. Update Operations Screen

Update `operations_screen.dart` to add navigation:

```dart
_buildOperationCard(
  title: 'Vehicles',
  subtitle: 'Fleet vehicle details',
  icon: Icons.directions_bus,
  color: Colors.green,
  onTap: () => context.go('/operations/vehicles'),
),
```

---

## Screen-Specific Implementation Details

### 1. Vehicle Management Screen

**Fields:**
- Registration Number (reg_no)
- Vehicle Type (vehicle_type)
- Vehicle Owner (dropdown from owners)
- Number of Seats (seats)
- Status

**Special Features:**
- Owner dropdown populated from `provider.owners`
- Seat count validation (minimum 1)
- Cannot delete if vehicle has active trips

**Form Example:**
```dart
DropdownButtonFormField<int>(
  decoration: const InputDecoration(
    labelText: 'Owner',
    prefixIcon: Icon(Icons.business),
  ),
  items: provider.owners.map((owner) {
    return DropdownMenuItem(
      value: owner.id,
      child: Text(owner.fullName),
    );
  }).toList(),
  onChanged: (value) {
    setState(() => _selectedOwnerId = value);
  },
),
```

### 2. Driver Management Screen

**Fields:**
- First Name
- Other Name
- Phone Number
- ID Number
- Status

**Special Features:**
- Same structure as Owner Management (simplest implementation)
- Can copy owner_management_screen.dart with minimal changes

### 3. Route Management Screen

**Fields:**
- Route Name (e.g., "Nairobi - Mombasa")
- Direction (e.g., "Southbound")
- Base Fare
- Status
- **Subroutes** (expandable list)

**Special Features:**
- **Two-level management:** Routes and Subroutes
- Expandable route cards to show subroutes
- Add Subroute dialog (nested form)

**Subroute Fields:**
- Source (destination dropdown)
- Destination (destination dropdown)
- Fare

**Implementation:**
```dart
class RouteManagementScreen extends StatefulWidget {
  // Main route list

  Widget _buildRouteCard(RouteModel route) {
    return ExpansionTile(
      title: Text(route.name),
      subtitle: Text('${route.subroutes.length} subroutes'),
      children: [
        // List of subroutes
        ...route.subroutes.map((subroute) =>
          _buildSubrouteItem(subroute)
        ),
        // Add subroute button
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Subroute'),
          onTap: () => _showAddSubrouteDialog(route),
        ),
      ],
    );
  }
}
```

### 4. Destination Management Screen

**Fields:**
- Destination Name
- Status

**Special Features:**
- **Bulk creation:** Support comma-separated input
- Example: "Nairobi, Mombasa, Kisumu" creates 3 destinations
- Simple list view (no complex cards needed)

**Bulk Creation Form:**
```dart
TextFormField(
  controller: _destinationsController,
  decoration: const InputDecoration(
    labelText: 'Destinations',
    hintText: 'Nairobi, Mombasa, Kisumu',
    prefixIcon: Icon(Icons.location_on),
    helperText: 'Separate multiple destinations with commas',
  ),
  maxLines: 3,
),

// In save method:
final destinations = _destinationsController.text;
final result = await provider.createDestinations(destinations);
```

### 5. Expense Management Screen

**Fields:**
- Expense Name (e.g., "Fuel")
- Amount
- Route (optional)
- Vehicle Types (multi-select)
- Status

**Special Features:**
- **Multi-select vehicle types:** Can create same expense for multiple vehicle types at once
- Route filter (optional association)

**Multi-Select Implementation:**
```dart
class _ExpenseFormDialog extends StatefulWidget {
  final List<String> _selectedVehicleTypes = [];

  Widget _buildVehicleTypeSelector() {
    final types = ['14 Seater', '22 Seater', '32 Seater', '51 Seater'];

    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = _selectedVehicleTypes.contains(type);
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedVehicleTypes.add(type);
              } else {
                _selectedVehicleTypes.remove(type);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _saveExpense() async {
    // ...
    final result = await provider.createExpenseTemplate(
      expense,
      vehicleTypes: _selectedVehicleTypes,
    );
  }
}
```

### 6. Template Management Screen

**Fields:**
- Template Name
- Days (multi-select: Mon, Tue, Wed, Thu, Fri, Sat, Sun)
- Status
- **Trips within template** (sub-list)

**Special Features:**
- **Two-level management:** Templates and Template Trips
- Day selector (checkboxes for each day of week)
- Add trips to template

**Template Trip Fields:**
- Vehicle Type
- Route
- Origin
- Destination
- Departure Time
- Vehicle (optional)
- Driver (optional)

**Day Selector Implementation:**
```dart
Widget _buildDaySelector() {
  final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  return Wrap(
    spacing: 8,
    children: days.map((day) {
      final isSelected = _selectedDays.contains(day);
      return FilterChip(
        label: Text(day.substring(0, 3)),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedDays.add(day);
            } else {
              _selectedDays.remove(day);
            }
          });
        },
      );
    }).toList(),
  );
}
```

### 7. Bulk Trip Creation Screen

This screen is different - it's a wizard/stepper rather than CRUD:

**Steps:**
1. Select Template
2. Choose Date Range (from/to)
3. Preview Trips to be Created
4. Confirm and Create

**Implementation:**
```dart
class BulkTripCreationScreen extends StatefulWidget {
  @override
  State<BulkTripCreationScreen> createState() => _BulkTripCreationScreenState();
}

class _BulkTripCreationScreenState extends State<BulkTripCreationScreen> {
  int _currentStep = 0;
  TripTemplateModel? _selectedTemplate;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<Map<String, dynamic>> _previewTrips = [];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Trip Creation'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: [
          Step(
            title: const Text('Select Template'),
            content: _buildTemplateSelector(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Date Range'),
            content: _buildDateRangeSelector(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Preview'),
            content: _buildPreview(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Create'),
            content: _buildConfirmation(),
            isActive: _currentStep >= 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Consumer<TripManagementProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: provider.activeTripTemplates.length,
          itemBuilder: (context, index) {
            final template = provider.activeTripTemplates[index];
            return RadioListTile<int>(
              title: Text(template.name),
              subtitle: Text('${template.daysAbbreviated} • ${template.tripCount} trips'),
              value: template.id!,
              groupValue: _selectedTemplate?.id,
              onChanged: (value) {
                setState(() {
                  _selectedTemplate = template;
                });
              },
            );
          },
        );
      },
    );
  }

  Future<void> _createTrips() async {
    final provider = context.read<TripManagementProvider>();
    final apiService = TripManagementApiService();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating trips...'),
          ],
        ),
      ),
    );

    try {
      final result = await apiService.createBulkTrips(
        templateId: _selectedTemplate!.id!,
        fromDate: _fromDate!.toIso8601String().split('T')[0],
        toDate: _toDate!.toIso8601String().split('T')[0],
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Go back to previous screen

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully created ${result['trips_created']} trips'),
            backgroundColor: TranslinerTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: TranslinerTheme.errorRed,
          ),
        );
      }
    }
  }
}
```

---

## Common Patterns

### 1. Loading State

All screens use this pattern:

```dart
if (provider.isLoading) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}
```

### 2. Error State

```dart
if (provider.error != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: TranslinerTheme.errorRed),
        SizedBox(height: 16),
        Text('Error loading data'),
        SizedBox(height: 8),
        Text(provider.error!),
        SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

### 3. Empty State

```dart
if (filteredItems.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_circle_outline, size: 64, color: TranslinerTheme.gray400),
        SizedBox(height: 16),
        Text('No items yet'),
        SizedBox(height: 8),
        Text('Add your first item to get started'),
        SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _showAddDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ],
    ),
  );
}
```

### 4. Form Validation

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    ],
  ),
)

// In save method:
if (!_formKey.currentState!.validate()) return;
```

### 5. Delete Confirmation

```dart
void _showDeleteConfirmation(Model item) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Item'),
      content: Text('Are you sure you want to delete ${item.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context);
            await _deleteItem(item);
          },
          style: FilledButton.styleFrom(
            backgroundColor: TranslinerTheme.errorRed,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

---

## API Integration Reference

All API methods are available in the provider. Here's how to use them:

### Owner Operations
```dart
// Fetch all
await provider.fetchOwners();

// Create
final owner = OwnerModel(firstName: 'John', otherName: 'Doe', phone: '0700000000');
await provider.createOwner(owner);

// Update
await provider.updateOwner(id, owner);

// Delete
await provider.deleteOwner(id);

// Access data
final owners = provider.owners;
final activeOwners = provider.activeOwners;
```

### Vehicle Operations
```dart
await provider.fetchVehicles();
await provider.createVehicle(vehicle);
await provider.updateVehicle(id, vehicle);
await provider.deleteVehicle(id);

final vehicles = provider.vehicles;
final vehiclesByType = provider.getVehiclesByType('Bus - 50 Seater');
```

### Driver Operations
```dart
await provider.fetchDrivers();
await provider.createDriver(driver);
await provider.updateDriver(id, driver);
await provider.deleteDriver(id);

final drivers = provider.drivers;
```

### Route Operations
```dart
await provider.fetchRoutes();
await provider.createRoute(route);
await provider.updateRoute(id, route);
await provider.deleteRoute(id);
await provider.addSubroute(subroute);

final routes = provider.routes;
```

### Destination Operations
```dart
await provider.fetchDestinations();
await provider.createDestinations('Nairobi, Mombasa, Kisumu'); // Bulk creation
await provider.updateDestination(id, destination);
await provider.deleteDestination(id);

final destinations = provider.destinations;
```

### Expense Template Operations
```dart
await provider.fetchExpenseTemplates();
await provider.createExpenseTemplate(
  expense,
  vehicleTypes: ['Bus - 50 Seater', 'Bus - 33 Seater'],
);
await provider.updateExpenseTemplate(id, expense);
await provider.deleteExpenseTemplate(id);
await provider.getDefaultExpenses(vehicleType: 'Bus - 50 Seater');

final expenseTemplates = provider.expenseTemplates;
```

### Trip Template Operations
```dart
await provider.fetchTripTemplates();
await provider.createTripTemplate(template);
await provider.updateTripTemplate(id, template);
await provider.deleteTripTemplate(id);
await provider.addTripToTemplate(templateTrip);

final templates = provider.tripTemplates;
```

### Dropdown Options
```dart
await provider.fetchDropdownOptions();
final options = provider.dropdownOptions;

// Access individual dropdowns
final owners = options?.owners ?? [];
final vehicles = options?.vehicles ?? [];
final drivers = options?.drivers ?? [];
final routes = options?.routes ?? [];
final destinations = options?.destinations ?? [];
final templates = options?.templates ?? [];
```

---

## Testing Checklist

For each screen you implement, test:

- [ ] Screen loads without errors
- [ ] Loading state displays correctly
- [ ] Error state displays correctly
- [ ] Empty state displays correctly
- [ ] Can view list of items
- [ ] Can search/filter items
- [ ] Can create new item
- [ ] Form validation works
- [ ] Can update existing item
- [ ] Can delete item with confirmation
- [ ] Success/error messages display correctly
- [ ] Navigation works correctly
- [ ] Pull-to-refresh works
- [ ] Theme is consistent
- [ ] Responsive on different screen sizes

---

## Troubleshooting

### Common Issues

**1. Provider not found**
```
Error: Could not find the correct Provider<TripManagementProvider>
```
**Solution:** Ensure TripManagementProvider is registered in main.dart:
```dart
ChangeNotifierProvider(create: (_) => TripManagementProvider()),
```

**2. API 401 Unauthorized**
```
Error: Unauthorized - Please login again
```
**Solution:** Set the token in the provider after login:
```dart
final provider = context.read<TripManagementProvider>();
provider.setToken(authToken);
```

**3. Navigation not working**
```
Error: Could not find a generator for route RouteSettings("/operations/vehicles")
```
**Solution:** Add the route in main.dart GoRouter configuration:
```dart
GoRoute(
  path: '/operations/vehicles',
  builder: (context, state) => const VehicleManagementScreen(),
),
```

**4. Form not validating**
```
Form submits even with empty fields
```
**Solution:** Ensure you're calling validate before saving:
```dart
if (!_formKey.currentState!.validate()) return;
```

---

## Best Practices

### 1. Code Organization
- One screen per file
- Keep widgets small and focused
- Extract reusable widgets
- Use const constructors where possible

### 2. State Management
- Always check loading/error states
- Clear errors after displaying
- Use RefreshIndicator for pull-to-refresh
- Dispose controllers in dispose()

### 3. UI/UX
- Provide clear feedback for all actions
- Show loading indicators for async operations
- Use confirmation dialogs for destructive actions
- Implement empty states
- Make forms user-friendly with hints and validation

### 4. Performance
- Use const widgets where possible
- Avoid rebuilding entire screens
- Use Consumer only where needed
- Implement pagination for large lists (future enhancement)

### 5. Error Handling
- Try-catch all API calls
- Display user-friendly error messages
- Provide retry options
- Log errors for debugging

---

## Next Steps

1. **Implement Remaining Screens** (in order of priority):
   - Vehicle Management (most similar to Owner Management)
   - Driver Management (identical structure to Owner Management)
   - Destination Management (simple, supports bulk creation)
   - Route Management (intermediate complexity with subroutes)
   - Expense Management (intermediate complexity with multi-select)
   - Template Management (complex with nested trips)
   - Bulk Trip Creation (wizard-style, different pattern)

2. **Enhance Existing Functionality**:
   - Add search/filter to trip modal dropdowns
   - Implement pagination for large lists
   - Add export functionality (CSV, PDF)
   - Add analytics/statistics views
   - Implement real-time updates (WebSockets/polling)

3. **Testing**:
   - Write widget tests for each screen
   - Write integration tests for workflows
   - Test error scenarios
   - Test with different user roles

4. **Documentation**:
   - Add inline code comments
   - Create user manual
   - Document API endpoints
   - Create video tutorials

---

## Additional Resources

### Theme Usage

```dart
// Colors
TranslinerTheme.primaryRed
TranslinerTheme.successGreen
TranslinerTheme.errorRed
TranslinerTheme.warningYellow
TranslinerTheme.infoBlue

// Spacing
TranslinerSpacing.pagePadding
TranslinerSpacing.cardPadding
TranslinerSpacing.verticalSpaceMD
TranslinerSpacing.horizontalSpaceSM

// Shadows
TranslinerShadows.level1  // Subtle
TranslinerShadows.level2  // Card
TranslinerShadows.level3  // Elevated
TranslinerShadows.level4  // Modal
TranslinerShadows.level5  // Maximum

// Decorations
TranslinerDecorations.premiumCard
TranslinerDecorations.simpleCard
TranslinerDecorations.primaryButton

// Border Radius
TranslinerRadius.borderSM
TranslinerRadius.borderMD
TranslinerRadius.borderLG
```

### Text Styles

```dart
// Using theme text styles
Theme.of(context).textTheme.displayLarge
Theme.of(context).textTheme.headlineMedium
Theme.of(context).textTheme.titleLarge
Theme.of(context).textTheme.bodyMedium
Theme.of(context).textTheme.labelSmall
```

### Common Widgets

```dart
// Buttons
FilledButton(onPressed: () {}, child: Text('Primary'))
OutlinedButton(onPressed: () {}, child: Text('Secondary'))
TextButton(onPressed: () {}, child: Text('Tertiary'))

// Form Fields
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Hint',
    prefixIcon: Icon(Icons.person),
  ),
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)

// Cards
Card(
  child: Padding(
    padding: TranslinerSpacing.cardPadding,
    child: // content
  ),
)
```

---

## Support

If you encounter issues:

1. Check this guide first
2. Review the reference implementation (owner_management_screen.dart)
3. Check API documentation in IMPLEMENTATION_PLAN.md
4. Review provider methods in trip_management_provider.dart
5. Test API endpoints manually with Postman/curl

---

## Summary

You now have:

✅ Complete foundation for trip management
✅ Working reference implementation (Owner Management)
✅ All necessary models, services, and providers
✅ Comprehensive guide for implementing remaining screens
✅ Best practices and patterns to follow

**Start with Vehicle Management** (closest to Owner Management) to gain confidence, then proceed with the others!

Good luck! 🚀
