class Usuario {
  const Usuario({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.papel,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String papel;

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: int.parse(map['id'].toString()),
      username: map['username']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      papel: map['papel']?.toString() ?? 'ESPECTADOR',
    );
  }

  String get nomeCompleto => '$firstName $lastName'.trim();

  bool get ehAdmin => papel.toUpperCase() == 'ADMIN';
}
