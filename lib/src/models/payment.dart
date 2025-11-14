class Payment {
  final int paymentId;
  final int bookingId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String status;

  Payment({
    required this.paymentId,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      bookingId: json['bookingId'],
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentDate: DateTime.parse(json['paymentDate']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status,
    };
  }
}