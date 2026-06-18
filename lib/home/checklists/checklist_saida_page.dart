import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/checklist_model.dart';
import '../../core/theme/app_theme.dart';

class ChecklistSaidaPage extends StatefulWidget {
  final String veiculoId;
  final String veiculoPlaca;
  final String motoristaId;

  const ChecklistSaidaPage({
    required this.veiculoId,
    required this.veiculoPlaca,
    required this.motoristaId,
    super.key,
  });

  @override
  State<ChecklistSaidaPage> createState() => _ChecklistSaidaPageState();
}

class _ChecklistSaidaPageState extends State<ChecklistSaidaPage> {
  final supabase = Supabase.instance.client;
  final imagePicker = ImagePicker();

  late Map<String, bool> itensVerificados;
  List<Uint8List> fotosCapturadas = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    itensVerificados = {for (var item in Checklist.itensChecklist) item: false};
  }

  Future<void> _capturarFoto() async {
    if (fotosCapturadas.length >= Checklist.fotosObrigatorias.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as fotos obrigatórias já foram capturadas'),
        ),
      );
      return;
    }

    try {
      final photo = await imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (!mounted) return;
        setState(() {
          fotosCapturadas.add(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao capturar foto: $e')));
      }
    }
  }

  Future<void> _removerFoto(int index) async {
    setState(() {
      fotosCapturadas.removeAt(index);
    });
  }

  Future<void> _salvarChecklist() async {
    if (fotosCapturadas.length < Checklist.fotosObrigatorias.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Faltam ${Checklist.fotosObrigatorias.length - fotosCapturadas.length} fotos obrigatórias',
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Upload de fotos
      List<String> fotoUrls = [];
      for (int i = 0; i < fotosCapturadas.length; i++) {
        final arquivo = fotosCapturadas[i];
        final fileName =
            'checklist_saida_${widget.veiculoId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        await supabase.storage
            .from('checklists')
            .uploadBinary(
              fileName,
              arquivo,
              fileOptions: const FileOptions(upsert: true),
            );
        final url = supabase.storage.from('checklists').getPublicUrl(fileName);
        fotoUrls.add(url);
      }

      // Salvar checklist no Supabase
      final checklistData = {
        'veiculo_id': widget.veiculoId,
        'motorista_id': widget.motoristaId,
        'tipo': 'saida',
        'data': DateTime.now().toIso8601String(),
        'itens': itensVerificados,
        'foto_urls': fotoUrls,
        'assinatura_url': '', // TODO: Implementar assinatura digital
        'aprovado': true,
        'criado_em': DateTime.now().toIso8601String(),
      };

      await supabase.from('checklists').insert(checklistData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checklist de saída registrado com sucesso!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar checklist: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist de Saída - ${widget.veiculoPlaca}'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de Itens do Checklist
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Itens do Checklist',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...Checklist.itensChecklist.map((item) {
                    return CheckboxListTile(
                      title: Text(item),
                      value: itensVerificados[item] ?? false,
                      onChanged: (value) {
                        setState(() {
                          itensVerificados[item] = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção de Fotos Obrigatórias
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fotos Obrigatórias (${fotosCapturadas.length}/${Checklist.fotosObrigatorias.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid de fotos
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: fotosCapturadas.length + 1,
                    itemBuilder: (context, index) {
                      if (index < fotosCapturadas.length) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Image.memory(
                                fotosCapturadas[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removerFoto(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      if (fotosCapturadas.length <
                          Checklist.fotosObrigatorias.length) {
                        return GestureDetector(
                          onTap: _capturarFoto,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary,
                                style: BorderStyle.solid,
                              ),
                              color: AppColors.primary.withValues(alpha: 0.05),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descrição de fotos obrigatórias
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📸 Fotos Obrigatórias:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...Checklist.fotosObrigatorias.map((foto) {
                          final index =
                              Checklist.fotosObrigatorias.indexOf(foto) + 1;
                          return Text('$index. $foto');
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            ElevatedButton(
              onPressed: isLoading ? null : _salvarChecklist,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Registrar Checklist de Saída'),
            ),
          ],
        ),
      ),
    );
  }
}
