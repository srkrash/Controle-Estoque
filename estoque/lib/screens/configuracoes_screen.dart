import 'package:flutter/material.dart';
import '../services/config_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final _baseUrlController = TextEditingController();
  final ConfigService _configService = ConfigService();

  @override
  void initState() {
    super.initState();
    // Carrega a URL salva assim que a tela é iniciada
    _carregarConfiguracao();
  }

  Future<void> _carregarConfiguracao() async {
    final url = await _configService.getBaseUrl();
    if (url != null) {
      setState(() {
        _baseUrlController.text = url;
      });
    }
  }

  void _salvarConfiguracao() async {
    final url = _baseUrlController.text;
    await _configService.saveBaseUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuração salva com sucesso!')),
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Endereço do Servidor (ex: http://10.0.2.2:5000)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvarConfiguracao,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}