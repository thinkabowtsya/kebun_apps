class SetupNotif {
  String someField;  

  SetupNotif({required this.someField});

  // Factory method to convert from JSON
  factory SetupNotif.fromJson(Map<String, dynamic> json) {
    return SetupNotif(
      someField: json['someField'],  // Gantilah dengan key yang sesuai
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'someField': someField, 
    };
  }
}
