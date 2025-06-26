class Customer {
  String kodecustomer;
  String namacustomer;

  Customer({
    required this.kodecustomer,
    required this.namacustomer,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      kodecustomer: json['kodecustomer'],
      namacustomer: json['namacustomer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kodecustomer': kodecustomer,
      'namacustomer': namacustomer,
    };
  }
}
