import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrocaOleoPage extends StatefulWidget {
  const TrocaOleoPage({super.key});

  @override
  State<TrocaOleoPage> createState() => _TrocaOleoPageState();
}

class _TrocaOleoPageState extends State<TrocaOleoPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> veiculos = [];

  String? veiculoSelecionado;
  String? selectedServiceType;
  String selectedInterval = '10000';
  String? observacoes;

  int kmAtualVeiculo = 0;
  DateTime? dataTroca;

  final serviceTypes = [
    'Troca de óleo',
    'Filtro de óleo',
    'Revisão geral',
    'Inspeção preventiva',
  ];

  final intervalOptions = ['8000', '10000', '12000', '15000', '20000'];

  @override
  void initState() {
    super.initState();
    carregarVeiculos();
  }

  Future<void> carregarVeiculos() async {
    try {
      final response = await supabase.from('vehicles').select().order('plate');
      final parsed = List<Map<String, dynamic>>.from(
        (response as List<dynamic>).map(
          (item) => Map<String, dynamic>.from(item as Map<String, dynamic>),
        ),
      );
      setState(() {
        veiculos = parsed;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );

    if (data != null) {
      setState(() {
        dataTroca = data;
      });
    }
  }

  Future<void> salvarTroca() async {
    try {
      if (veiculoSelecionado == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecione um veículo')));
        return;
      }

      if (_formKey.currentState?.validate() != true) return;

      if (dataTroca == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a data da troca')),
        );
        return;
      }

      await supabase.from('oil_changes').insert({
        'vehicle_plate': veiculoSelecionado,
        'current_km': kmAtualVeiculo,
        'service_type': selectedServiceType,
        'oil_change_date': dataTroca!.toIso8601String(),
        'next_change_km': kmAtualVeiculo + int.parse(selectedInterval),
        'notes': observacoes ?? '',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Troca registrada. Próxima troca em ${kmAtualVeiculo + 10000} km',
          ),
        ),
      );

      setState(() {
        veiculoSelecionado = null;
        kmAtualVeiculo = 0;
        dataTroca = null;
      });

      carregarVeiculos();
    } catch (e) {
      debugPrint(e.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Troca de Óleo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Registrar troca de óleo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: veiculoSelecionado,
                    decoration: const InputDecoration(labelText: 'Veículo'),
                    items: veiculos.map((v) {
                      return DropdownMenuItem<String>(
                        value: v['plate']?.toString(),
                        child: Text(v['plate']?.toString() ?? '--'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final veiculo = veiculos.firstWhere(
                        (v) => v['plate'] == value,
                        orElse: () => {},
                      );
                      setState(() {
                        veiculoSelecionado = value;
                        kmAtualVeiculo = veiculo['odometer'] is int
                            ? veiculo['odometer'] as int
                            : int.tryParse(
                                    veiculo['odometer']?.toString() ?? '0',
                                  ) ??
                                  0;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione um veículo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(24),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'KM Atual do Veículo: $kmAtualVeiculo km',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedServiceType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de serviço',
                    ),
                    items: serviceTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      selectedServiceType = value;
                      if (value == 'Troca de óleo') {
                        selectedInterval = '10000';
                      } else if (value == 'Filtro de óleo') {
                        selectedInterval = '12000';
                      } else if (value == 'Revisão geral') {
                        selectedInterval = '15000';
                      } else if (value == 'Inspeção preventiva') {
                        selectedInterval = '8000';
                      }
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione o tipo de serviço';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedInterval,
                    decoration: const InputDecoration(
                      labelText: 'Intervalo para próxima revisão (km)',
                    ),
                    items: intervalOptions
                        .map(
                          (km) => DropdownMenuItem<String>(
                            value: km,
                            child: Text('$km km'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedInterval = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observações adicionais',
                      hintText: 'Ex: verificar filtro, calibrar nível do óleo',
                    ),
                    onChanged: (value) {
                      observacoes = value;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: selecionarData,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      dataTroca == null
                          ? 'Selecionar Data da Troca'
                          : '${dataTroca!.day}/${dataTroca!.month}/${dataTroca!.year}',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: salvarTroca,
                      child: const Text('Salvar Troca de Óleo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
