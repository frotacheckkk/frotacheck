class Veiculo {
  final String? id;
  final String? placa;
  final String? modelo;

  Veiculo({this.id, this.placa, this.modelo});

  factory Veiculo.fromMap(Map<String, dynamic> map) => Veiculo(
    id: map['id'] as String?,
    placa: map['placa'] as String?,
    modelo: map['modelo'] as String?,
  );

  factory Veiculo.fromJson(Map<String, dynamic> json) => Veiculo.fromMap(json);

  Map<String, dynamic> toMap() => {'id': id, 'placa': placa, 'modelo': modelo};
}
