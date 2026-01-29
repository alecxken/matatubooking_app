# TransLine App Enhancement - Implementation Plan

## Overview
Comprehensive enhancement of the TransLine mobile booking app with complete trip management functionality, standardized theme with San Francisco font, and robust API integration.

## Current State Analysis

### ✅ Existing Features
1. Authentication (Login/Logout/Profile)
2. Trip listing and filtering by date
3. Seat selection and booking
4. Payment processing (Cash, M-Pesa)
5. Trip details with 5 tabs (Seats, Expenses, Manifest, Parcels)
6. Parcel management (CRUD)
7. Trip expenses management
8. Trip manifest generation
9. Basic trip CRUD via modal
10. Role-based access control

### ❌ Missing Features (Based on API Documentation)
1. **Owner Management** - Full CRUD for vehicle owners
2. **Vehicle Management** - Full CRUD for vehicles (currently only dropdown)
3. **Driver Management** - Full CRUD for drivers (currently only dropdown)
4. **Route Management** - Full CRUD for routes with subroutes (currently only dropdown)
5. **Destination Management** - Full CRUD for destinations (currently only dropdown)
6. **Expense Management** - Full CRUD for default expense templates
7. **Template Management** - Reusable trip templates with scheduling
8. **Bulk Trip Creation** - Create multiple trips from templates
9. **Dynamic Dropdown Loading** - Trip modal uses hardcoded data instead of API
10. **Delete Trip UI** - API exists but no UI implementation

## Implementation Plan

### Phase 1: Foundation Setup ✅

#### 1.1 Font Integration
- [ ] Add San Francisco font family (.ttf files)
- [ ] Update pubspec.yaml with font assets
- [ ] Configure font fallbacks for Android/iOS

#### 1.2 Theme Standardization
- [ ] Update TranslinerTheme with San Francisco font
- [ ] Standardize all text styles
- [ ] Ensure consistent spacing, shadows, and colors
- [ ] Add theme-aware widgets

#### 1.3 API Service Enhancement
- [ ] Add all missing API endpoints from documentation:
  - Owner endpoints (list, create, update, delete)
  - Vehicle endpoints (list, create, update, delete)
  - Driver endpoints (list, create, update, delete)
  - Route endpoints (list, create, update, delete, subroutes)
  - Destination endpoints (list, create, update, delete)
  - Expense endpoints (list, create, update, delete, defaults)
  - Template endpoints (list, create, update, delete, add trips)
  - Bulk trip creation endpoint
- [ ] Implement proper error handling
- [ ] Add request/response logging

### Phase 2: Data Models 🔨

#### 2.1 Create New Models
- [ ] OwnerModel - Vehicle owner entity
- [ ] VehicleModel - Vehicle entity with owner relationship
- [ ] DriverModel - Driver entity
- [ ] RouteModel - Route entity with subroutes
- [ ] SubrouteModel - Route detail entity
- [ ] DestinationModel - Destination entity
- [ ] ExpenseTemplateModel - Default expense template
- [ ] TripTemplateModel - Reusable trip template
- [ ] TemplateTripsModel - Trip within template

#### 2.2 Update Existing Models
- [ ] Add fromJson/toJson for all models
- [ ] Add validation methods
- [ ] Add helper methods for business logic

### Phase 3: State Management 📊

#### 3.1 Create New Providers
- [ ] OwnerProvider - Manage owners state
- [ ] VehicleProvider - Manage vehicles state
- [ ] DriverProvider - Manage drivers state
- [ ] RouteProvider - Manage routes state
- [ ] DestinationProvider - Manage destinations state
- [ ] ExpenseTemplateProvider - Manage expense templates
- [ ] TripTemplateProvider - Manage trip templates

#### 3.2 Update Existing Providers
- [ ] TripProvider - Add bulk creation, template integration
- [ ] Update loading states and error handling

### Phase 4: Trip Management Screens 🖥️

#### 4.1 Owner Management Screen
**Route:** `/operations/owners`
**Features:**
- List all owners (searchable, filterable)
- Add new owner (form with validation)
- Edit owner (inline or modal)
- Delete owner (with confirmation)
- View owner details (vehicles owned, stats)

**UI Components:**
- Owner list with cards
- Add/Edit owner form modal
- Delete confirmation dialog
- Search bar
- Filter chips (Active/Inactive)

#### 4.2 Vehicle Management Screen
**Route:** `/operations/vehicles`
**Features:**
- List all vehicles (searchable, filterable by type, owner)
- Add new vehicle (form with owner dropdown)
- Edit vehicle details
- Delete vehicle (check for active trips first)
- View vehicle stats (total trips, revenue, occupancy)

**UI Components:**
- Vehicle cards with registration, type, owner
- Add/Edit vehicle form modal
- Owner selection dropdown (from API)
- Delete confirmation dialog
- Filter by vehicle type, status, owner

#### 4.3 Driver Management Screen
**Route:** `/operations/drivers`
**Features:**
- List all drivers (searchable)
- Add new driver (form with validation)
- Edit driver details
- Delete driver (check for assigned trips)
- View driver stats (trips completed, ratings)

**UI Components:**
- Driver cards with photo placeholder
- Add/Edit driver form modal
- Delete confirmation dialog
- Status badges (Active/Inactive)

#### 4.4 Route Management Screen
**Route:** `/operations/routes`
**Features:**
- List all routes with direction
- Add new route
- Edit route details
- Delete route
- Manage subroutes (source-destination-fare combinations)
- View route stats (frequency, revenue)

**UI Components:**
- Route list with expandable subroutes
- Add/Edit route form modal
- Subroute management (nested CRUD)
- Fare calculator
- Delete confirmation dialog

#### 4.5 Destination Management Screen
**Route:** `/operations/destinations`
**Features:**
- List all destinations (searchable)
- Add new destination(s) (comma-separated bulk add)
- Edit destination name
- Delete destination (check usage first)
- View destination stats (frequency, routes)

**UI Components:**
- Destination grid/list
- Bulk add form (comma-separated input)
- Edit inline or modal
- Delete confirmation dialog
- Usage indicator

#### 4.6 Expense Management Screen
**Route:** `/operations/expenses`
**Features:**
- List all default expenses (filterable by vehicle type, route)
- Add new expense template
- Edit expense template
- Delete expense template
- Duplicate expense for multiple vehicle types
- View expense usage stats

**UI Components:**
- Expense cards with amount, route, vehicle type
- Add/Edit expense form modal
- Multi-select vehicle types
- Filter by vehicle type, route
- Delete confirmation dialog

#### 4.7 Template Management Screen
**Route:** `/operations/templates`
**Features:**
- List all templates with days
- Create new template (name, days selection)
- Edit template details
- Delete template
- Manage trips within template (add, edit, delete)
- Preview template trips
- Duplicate template

**UI Components:**
- Template cards with day badges
- Day selector (weekday checkboxes)
- Trip list within template
- Add trip to template form
- Template preview calendar
- Delete confirmation dialog

#### 4.8 Bulk Trip Creation Screen
**Route:** `/operations/bulk-trips`
**Features:**
- Select template from dropdown
- Choose date range (from/to)
- Preview trips to be created
- Confirm creation
- View creation progress
- Handle conflicts (skip/overwrite)

**UI Components:**
- Template selector with preview
- Date range picker
- Trip preview list (grouped by date)
- Conflict resolution options
- Progress indicator
- Summary report after creation

### Phase 5: Screen Updates 🔧

#### 5.1 Update Operations Screen
- [ ] Add navigation cards for:
  - Owners (admin only)
  - Vehicles
  - Drivers
  - Routes
  - Destinations
  - Expense Templates (admin only)
  - Templates
  - Bulk Trip Creation
- [ ] Add icons and descriptions
- [ ] Role-based visibility

#### 5.2 Update Side Menu/Drawer
- [ ] Add "Trip Management" section (collapsible)
  - Templates
  - Bulk Creation
- [ ] Add "Operations" section (existing, enhanced)
  - Owners (admin)
  - Vehicles
  - Drivers
  - Routes
  - Destinations
  - Expense Templates (admin)
  - Parcels
- [ ] Reorganize menu structure
- [ ] Add icons for all menu items

#### 5.3 Fix Trip Management Modal
- [ ] Remove hardcoded dropdown data
- [ ] Load routes from API
- [ ] Load vehicles from API (filtered by route if needed)
- [ ] Load drivers from API
- [ ] Load destinations from API
- [ ] Add loading states for dropdowns
- [ ] Add validation for all fields
- [ ] Add error handling

#### 5.4 Add Delete Trip UI
- [ ] Add delete icon to trip cards
- [ ] Create confirmation dialog
- [ ] Check for existing bookings before delete
- [ ] Show warning if bookings exist
- [ ] Refresh trip list after delete
- [ ] Show success/error message

### Phase 6: Routing & Navigation 🗺️

#### 6.1 Update GoRouter Configuration
- [ ] Add routes for all new screens
- [ ] Implement route guards (role-based)
- [ ] Add smooth transitions
- [ ] Handle deep linking

**New Routes:**
```dart
/operations/owners
/operations/vehicles
/operations/drivers
/operations/routes
/operations/destinations
/operations/expenses
/operations/templates
/operations/bulk-trips
```

### Phase 7: UI/UX Enhancements 🎨

#### 7.1 Consistent Design System
- [ ] Standardize all forms (consistent spacing, labels, buttons)
- [ ] Standardize all cards (consistent elevation, padding, radius)
- [ ] Standardize all dialogs (consistent buttons, actions)
- [ ] Standardize all lists (consistent item heights, separators)
- [ ] Add empty states for all lists
- [ ] Add error states for all screens
- [ ] Add loading skeletons

#### 7.2 Reusable Widgets
- [ ] Create FormFieldWidget (consistent text fields)
- [ ] Create DropdownWidget (consistent dropdowns with search)
- [ ] Create DatePickerWidget (consistent date picker)
- [ ] Create TimePickerWidget (consistent time picker)
- [ ] Create ConfirmationDialog (consistent delete/action dialogs)
- [ ] Create StatsCard (for dashboard stats)
- [ ] Create EntityCard (for owner/vehicle/driver cards)
- [ ] Create SearchBar (consistent search UI)
- [ ] Create FilterChips (consistent filtering)

#### 7.3 Accessibility
- [ ] Add semantic labels for screen readers
- [ ] Ensure sufficient color contrast
- [ ] Add keyboard navigation support
- [ ] Add focus indicators

### Phase 8: Testing & Quality Assurance ✅

#### 8.1 API Integration Testing
- [ ] Test all new endpoints
- [ ] Test error handling
- [ ] Test authentication
- [ ] Test pagination
- [ ] Test filtering and searching

#### 8.2 UI Testing
- [ ] Test all CRUD operations
- [ ] Test form validation
- [ ] Test navigation flow
- [ ] Test role-based access
- [ ] Test loading states
- [ ] Test error states
- [ ] Test responsive design

#### 8.3 Integration Testing
- [ ] Test trip creation flow (modal → API → list refresh)
- [ ] Test bulk trip creation (template → date range → creation)
- [ ] Test dropdown population (API → dropdowns)
- [ ] Test delete operations (confirmation → API → list refresh)

### Phase 9: Documentation 📚

#### 9.1 Code Documentation
- [ ] Add doc comments for all public methods
- [ ] Document API service methods
- [ ] Document complex business logic
- [ ] Add README for each major feature

#### 9.2 User Documentation
- [ ] Create user guide for trip management
- [ ] Create admin guide for operations
- [ ] Add tooltips for complex features
- [ ] Add onboarding flow (optional)

## Technical Specifications

### Design System

#### Typography (San Francisco Font)
```dart
Display Large: SF Pro Display, 57px, Light
Display Medium: SF Pro Display, 45px, Regular
Display Small: SF Pro Display, 36px, Regular

Headline Large: SF Pro Display, 32px, Regular
Headline Medium: SF Pro Display, 28px, Medium
Headline Small: SF Pro Display, 24px, Medium

Title Large: SF Pro Text, 22px, Medium
Title Medium: SF Pro Text, 16px, Medium
Title Small: SF Pro Text, 14px, Medium

Body Large: SF Pro Text, 16px, Regular
Body Medium: SF Pro Text, 14px, Regular
Body Small: SF Pro Text, 12px, Regular

Label Large: SF Pro Text, 14px, Medium
Label Medium: SF Pro Text, 12px, Medium
Label Small: SF Pro Text, 11px, Medium
```

#### Color Palette
```dart
Primary: #DC2626 (Red-600)
Primary Container: #FEE2E2 (Red-100)
On Primary: #FFFFFF
On Primary Container: #7F1D1D (Red-900)

Secondary: #EF4444 (Red-500)
Secondary Container: #FEF2F2 (Red-50)
On Secondary: #FFFFFF
On Secondary Container: #991B1B (Red-800)

Success: #10B981 (Emerald-500)
Error: #EF4444 (Red-500)
Warning: #F59E0B (Amber-500)
Info: #3B82F6 (Blue-500)

Surface: #FFFFFF
Surface Variant: #F9FAFB (Gray-50)
On Surface: #1F2937 (Gray-800)
On Surface Variant: #6B7280 (Gray-500)

Outline: #D1D5DB (Gray-300)
Outline Variant: #E5E7EB (Gray-200)
```

#### Spacing
```dart
xs: 4px
sm: 8px
md: 16px
lg: 24px
xl: 32px
xxl: 48px
```

#### Border Radius
```dart
sm: 8px
md: 12px
lg: 16px
xl: 24px
full: 9999px
```

#### Elevation/Shadows
```dart
Level 1: 0 1px 2px rgba(0,0,0,0.05)
Level 2: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)
Level 3: 0 4px 6px rgba(0,0,0,0.1), 0 2px 4px rgba(0,0,0,0.06)
Level 4: 0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)
Level 5: 0 20px 25px rgba(0,0,0,0.1), 0 10px 10px rgba(0,0,0,0.04)
```

### API Integration Standards

#### Request/Response Format
```dart
// Standard Success Response
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... }
}

// Standard Error Response
{
  "success": false,
  "message": "Error message",
  "errors": {
    "field": ["Validation error"]
  }
}
```

#### Error Handling Strategy
1. Network errors → Show retry dialog
2. Validation errors → Show field-specific errors
3. Authentication errors → Redirect to login
4. Server errors → Show generic error with contact support
5. Not found errors → Show empty state

### State Management Patterns

#### Provider Structure
```dart
class EntityProvider extends ChangeNotifier {
  // State
  List<Entity> _entities = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Entity> get entities => _entities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Methods
  Future<void> fetchEntities() async { ... }
  Future<void> createEntity(Entity entity) async { ... }
  Future<void> updateEntity(String id, Entity entity) async { ... }
  Future<void> deleteEntity(String id) async { ... }

  // Helper methods
  Entity? getEntityById(String id) { ... }
  void clearError() { ... }
}
```

## Implementation Timeline

### Week 1: Foundation
- Day 1-2: Font integration, theme standardization
- Day 3-4: API service enhancement, data models
- Day 5: State management providers

### Week 2: Core Screens
- Day 1: Owner Management screen
- Day 2: Vehicle Management screen
- Day 3: Driver Management screen
- Day 4: Route Management screen
- Day 5: Destination Management screen

### Week 3: Advanced Features
- Day 1: Expense Management screen
- Day 2: Template Management screen
- Day 3-4: Bulk Trip Creation screen
- Day 5: Fix trip modal, add delete UI

### Week 4: Integration & Testing
- Day 1-2: Update navigation, side menu
- Day 3: Integration testing
- Day 4: UI/UX polish
- Day 5: Documentation, final testing

## Success Metrics

1. **Functionality**
   - ✅ All CRUD operations working for all entities
   - ✅ Bulk trip creation from templates working
   - ✅ Dynamic dropdown loading working
   - ✅ Delete confirmations working
   - ✅ All API endpoints integrated

2. **Performance**
   - ✅ API responses < 2 seconds
   - ✅ UI interactions smooth (60fps)
   - ✅ App startup < 3 seconds
   - ✅ Memory usage < 200MB

3. **User Experience**
   - ✅ Consistent design across all screens
   - ✅ Clear error messages
   - ✅ Loading states for all async operations
   - ✅ Empty states for all lists
   - ✅ Accessible to screen readers

4. **Code Quality**
   - ✅ No duplicate code
   - ✅ Consistent naming conventions
   - ✅ Well-documented public APIs
   - ✅ Proper error handling everywhere
   - ✅ Type-safe code

## Risk Mitigation

### API Integration Risks
- **Risk:** API endpoints not working as documented
- **Mitigation:** Test each endpoint thoroughly, add fallbacks

### Performance Risks
- **Risk:** Large lists causing performance issues
- **Mitigation:** Implement pagination, lazy loading, virtualization

### Data Consistency Risks
- **Risk:** Cached data becoming stale
- **Mitigation:** Implement proper cache invalidation, refresh strategies

### User Experience Risks
- **Risk:** Complex features overwhelming users
- **Mitigation:** Progressive disclosure, tooltips, onboarding

## Next Steps

1. ✅ Approve implementation plan
2. 🔨 Begin Phase 1: Foundation Setup
3. 🔨 Proceed with Phase 2-9 in sequence
4. ✅ Conduct final review and testing
5. 🚀 Deploy to production

---

*Document Version: 1.0*
*Last Updated: 2026-01-29*
*Prepared for: TransLine App Enhancement Project*
