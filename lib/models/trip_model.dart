import 'dart:convert';

class TripModel {
  final String token;
  final String route;
  final String origin;
  final String destination;
  final String departureDate;
  final String departureTime;
  final String? vehicle;
  final String? driver;
  final String vehicleType;
  final String? tripType;
  final int bookedSeatsCount;
  final int availableSeats;
  final double fare;
  final String status;
  final String? template;

  TripModel({
    required this.token,
    required this.route,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    this.vehicle,
    this.driver,
    required this.vehicleType,
    this.tripType,
    required this.bookedSeatsCount,
    required this.availableSeats,
    required this.fare,
    required this.status,
    this.template,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      token: map['token'] ?? '',
      route: map['route'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      departureDate: map['departure_date'] ?? '',
      departureTime: map['departure_time'] ?? '',
      vehicle: map['vehicle'],
      driver: map['driver'],
      vehicleType: map['vehicle_type'] ?? '',
      tripType: map['trip_type'],
      bookedSeatsCount: map['booked_seats_count'] ?? 0,
      availableSeats: map['available_seats'] ?? 0,
      fare: (map['fare'] ?? 0).toDouble(),
      status: map['status'] ?? 'Active',
      template: map['template'],
    );
  }

  factory TripModel.fromJson(String source) =>
      TripModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'route': route,
      'origin': origin,
      'destination': destination,
      'departure_date': departureDate,
      'departure_time': departureTime,
      'vehicle': vehicle,
      'driver': driver,
      'vehicle_type': vehicleType,
      'trip_type': tripType,
      'booked_seats_count': bookedSeatsCount,
      'available_seats': availableSeats,
      'fare': fare,
      'status': status,
      'template': template,
    };
  }

  String toJson() => json.encode(toMap());

  // Get total seats
  int get totalSeats => bookedSeatsCount + availableSeats;

  // Get occupancy percentage
  double get occupancyPercentage =>
      totalSeats > 0 ? (bookedSeatsCount / totalSeats) * 100 : 0;

  // Get formatted departure time
  String get formattedDepartureTime {
    try {
      final timeParts = departureTime.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      // Return original if parsing fails
    }
    return departureTime;
  }

  // Get route display name
  String get routeDisplayName {
    if (route.toLowerCase().contains('nairobi')) {
      return route;
    }
    return '$origin - $destination';
  }

  // Check if trip is full
  bool get isFull => availableSeats <= 0;

  // Check if trip is nearly full (less than 25% available)
  bool get isNearlyFull => occupancyPercentage > 75;

  @override
  String toString() {
    return 'TripModel(token: $token, route: $route, departure: $departureDate $departureTime)';
  }
}

class SeatModel {
  final int seatNo;
  final String status; // 'available', 'booked', 'selected'
  final PassengerModel? passenger;

  SeatModel({required this.seatNo, required this.status, this.passenger});

  factory SeatModel.fromMap(Map<String, dynamic> map) {
    return SeatModel(
      seatNo: map['seat_no'] ?? 0,
      status: map['status'] ?? 'available',
      passenger: map['passenger'] != null
          ? PassengerModel.fromMap(map['passenger'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seat_no': seatNo,
      'status': status,
      'passenger': passenger?.toMap(),
    };
  }

  bool get isAvailable => status == 'available';
  bool get isBooked => status == 'booked';
  bool get isSelected => status == 'selected';

  SeatModel copyWith({int? seatNo, String? status, PassengerModel? passenger}) {
    return SeatModel(
      seatNo: seatNo ?? this.seatNo,
      status: status ?? this.status,
      passenger: passenger ?? this.passenger,
    );
  }
}

class PassengerModel {
  final int? bookingId;
  final String name;
  final String phone;
  final String bookingStatus;

  PassengerModel({
    this.bookingId,
    required this.name,
    required this.phone,
    required this.bookingStatus,
  });

  factory PassengerModel.fromMap(Map<String, dynamic> map) {
    return PassengerModel(
      bookingId: map['booking_id'],
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      bookingStatus: map['booking_status'] ?? 'Booked',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'name': name,
      'phone': phone,
      'booking_status': bookingStatus,
    };
  }

  String get maskedPhone {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 4)}****${phone.substring(phone.length - 3)}';
  }
}

class BookingModel {
  final String reference;
  final List<int> seats;
  final String passengerName;
  final double totalAmount;
  final double perSeatFare;
  final String paymentMethod;
  final String status;
  final TripModel? trip;

  BookingModel({
    required this.reference,
    required this.seats,
    required this.passengerName,
    required this.totalAmount,
    required this.perSeatFare,
    required this.paymentMethod,
    required this.status,
    this.trip,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      reference: map['reference'] ?? '',
      seats: List<int>.from(map['seats'] ?? []),
      passengerName: map['passenger_name'] ?? '',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      perSeatFare: (map['per_seat_fare'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? '',
      status: map['status'] ?? '',
      trip: map['trip'] != null ? TripModel.fromMap(map['trip']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'seats': seats,
      'passenger_name': passengerName,
      'total_amount': totalAmount,
      'per_seat_fare': perSeatFare,
      'payment_method': paymentMethod,
      'status': status,
      'trip': trip?.toMap(),
    };
  }

  String get seatsDisplay => seats.join(', ');

  bool get isPending => status.toLowerCase().contains('pending');
  bool get isConfirmed => status.toLowerCase().contains('confirmed');
  bool get isCancelled => status.toLowerCase().contains('cancelled');
}

class ExpenseModel {
  final String name;
  final double amount;
  final String? date;
  final String? capturedBy;

  ExpenseModel({
    required this.name,
    required this.amount,
    this.date,
    this.capturedBy,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      name: map['expense'] ?? map['name'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: map['date'],
      capturedBy: map['captured_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'date': date,
      'captured_by': capturedBy,
    };
  }
}

class ManifestModel {
  final TripModel trip;
  final List<ManifestPassenger> passengers;
  final SeatSummary seatSummary;
  final FinancialSummary financialSummary;
  final String generatedAt;

  ManifestModel({
    required this.trip,
    required this.passengers,
    required this.seatSummary,
    required this.financialSummary,
    required this.generatedAt,
  });

  factory ManifestModel.fromMap(Map<String, dynamic> map) {
    return ManifestModel(
      trip: TripModel.fromMap(map['trip_details'] ?? {}),
      passengers: (map['passenger_manifest'] as List? ?? [])
          .map((p) => ManifestPassenger.fromMap(p))
          .toList(),
      seatSummary: SeatSummary.fromMap(map['seat_summary'] ?? {}),
      financialSummary: FinancialSummary.fromMap(
        map['financial_summary'] ?? {},
      ),
      generatedAt: map['generated_at'] ?? '',
    );
  }
}

class ManifestPassenger {
  final int seatNo;
  final String passengerName;
  final String phone;
  final String? idNo;
  final double fare;
  final String paymentMethod;
  final String status;
  final String boardingPoint;
  final String destination;

  ManifestPassenger({
    required this.seatNo,
    required this.passengerName,
    required this.phone,
    this.idNo,
    required this.fare,
    required this.paymentMethod,
    required this.status,
    required this.boardingPoint,
    required this.destination,
  });

  factory ManifestPassenger.fromMap(Map<String, dynamic> map) {
    return ManifestPassenger(
      seatNo: map['seat_no'] ?? 0,
      passengerName: map['passenger_name'] ?? '',
      phone: map['phone'] ?? '',
      idNo: map['id_no'],
      fare: (map['fare'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? '',
      status: map['status'] ?? '',
      boardingPoint: map['boarding_point'] ?? '',
      destination: map['destination'] ?? '',
    );
  }
}

class SeatSummary {
  final int totalSeats;
  final int bookedSeats;
  final int availableSeats;
  final String occupancyRate;

  SeatSummary({
    required this.totalSeats,
    required this.bookedSeats,
    required this.availableSeats,
    required this.occupancyRate,
  });

  factory SeatSummary.fromMap(Map<String, dynamic> map) {
    return SeatSummary(
      totalSeats: map['total_seats'] ?? 0,
      bookedSeats: map['booked_seats'] ?? 0,
      availableSeats: map['available_seats'] ?? 0,
      occupancyRate: map['occupancy_rate'] ?? '0%',
    );
  }
}

class FinancialSummary {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final List<ExpenseModel> expenseBreakdown;

  FinancialSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.expenseBreakdown,
  });

  factory FinancialSummary.fromMap(Map<String, dynamic> map) {
    return FinancialSummary(
      totalRevenue: (map['total_revenue'] ?? 0).toDouble(),
      totalExpenses: (map['total_expenses'] ?? 0).toDouble(),
      netProfit: (map['net_profit'] ?? 0).toDouble(),
      expenseBreakdown: (map['expense_breakdown'] as List? ?? [])
          .map((e) => ExpenseModel.fromMap(e))
          .toList(),
    );
  }

  double get profitMargin =>
      totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;
}
