/// MCP Server Connection Dialog
/// UI for adding and managing MCP server connections
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mcp_server_manager.dart';

class MCPServerDialog extends StatefulWidget {
  const MCPServerDialog({super.key});

  @override
  State<MCPServerDialog> createState() => _MCPServerDialogState();
}

class _MCPServerDialogState extends State<MCPServerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  String _selectedTransport = 'http';
  bool _isConnecting = false;
  bool _isTesting = false;
  String? _testResult;
  String? _connectionError;
  Map<String, dynamic>? _serverInfo;

  final List<Map<String, dynamic>> _transports = [
    {
      'value': 'http',
      'label': 'HTTP',
      'icon': Icons.http,
      'hint': 'http://localhost:3000/mcp',
    },
    {
      'value': 'sse',
      'label': 'SSE',
      'icon': Icons.stream,
      'hint': 'http://localhost:3000/sse',
    },
    {
      'value': 'stdio',
      'label': 'Stdio',
      'icon': Icons.settings_input_component,
      'hint': 'Process path (e.g., /usr/bin/python server.py)',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mcpManager = context.watch<MCPServerManager>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTransportSelector(),
                      const SizedBox(height: 16),
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildUrlField(),
                      const SizedBox(height: 16),
                      if (_connectionError != null)
                        _buildErrorBanner(_connectionError!),
                      if (_serverInfo != null)
                        _buildServerInfoBanner(_serverInfo!),
                      const SizedBox(height: 16),
                      _buildTestConnectionButton(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(mcpManager),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.cloud,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add MCP Server',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Connect to Model Context Protocol servers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transport Protocol',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: _transports.map((transport) {
            final isSelected = _selectedTransport == transport['value'];
            return ChoiceChip(
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTransport = transport['value'] as String;
                    _testResult = null;
                    _connectionError = null;
                    _serverInfo = null;
                  });
                }
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    transport['icon'] as IconData,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(transport['label'] as String),
                ],
              ),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Server Name',
        hintText: 'My MCP Server',
        prefixIcon: Icon(Icons.label_outline),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Server name is required';
        }
        return null;
      },
    );
  }

  Widget _buildUrlField() {
    final transport = _transports.firstWhere(
      (t) => t['value'] == _selectedTransport,
    );
    final hintText = transport['hint'] as String;

    return TextFormField(
      controller: _urlController,
      decoration: InputDecoration(
        labelText: _selectedTransport == 'stdio' ? 'Process Path' : 'Server URL',
        hintText: hintText,
        prefixIcon: Icon(
          _selectedTransport == 'stdio'
              ? Icons.code
              : Icons.link,
        ),
        suffixIcon: _selectedTransport == 'stdio'
            ? IconButton(
                icon: const Icon(Icons.folder_open),
                onPressed: _pickProcessPath,
                tooltip: 'Browse',
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return _selectedTransport == 'stdio'
              ? 'Process path is required'
              : 'Server URL is required';
        }
        if (_selectedTransport != 'stdio') {
          try {
            final uri = Uri.parse(value);
            if (!uri.isAbsolute) {
              return 'Please enter a valid URL';
            }
          } catch (e) {
            return 'Please enter a valid URL';
          }
        }
        return null;
      },
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerInfoBanner(Map<String, dynamic> info) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Successful',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (info['toolCount'] != null)
                  Text(
                    '${info['toolCount']} tools available',
                    style: const TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestConnectionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isTesting || _isConnecting ? null : _testConnection,
        icon: _isTesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.connected_tv),
        label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
    );
  }

  Widget _buildFooter(MCPServerManager mcpManager) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _isConnecting ? null : _connect,
            icon: _isConnecting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link),
            label: Text(_isConnecting ? 'Connecting...' : 'Connect'),
          ),
        ],
      ),
    );
  }

  void _pickProcessPath() async {
    // In a real implementation, this would use file_picker
    // For now, just show a hint
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker would open here for stdio transport'),
      ),
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
      _connectionError = null;
      _serverInfo = null;
    });

    final mcpManager = context.read<MCPServerManager>();
    final result = await mcpManager.validateConnection(
      serverName: _nameController.text.trim(),
      url: _urlController.text.trim(),
      transport: _selectedTransport,
    );

    setState(() {
      _isTesting = false;
      if (result['success'] as bool) {
        _serverInfo = result['serverInfo'] as Map<String, dynamic>?;
      } else {
        _connectionError = result['message'] as String? ?? 'Connection failed';
      }
    });
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    if (_serverInfo == null) {
      setState(() {
        _connectionError = 'Please test the connection first';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _connectionError = null;
    });

    final mcpManager = context.read<MCPServerManager>();
    final success = await mcpManager.connectServer(
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      transport: _selectedTransport,
    );

    setState(() {
      _isConnecting = false;
    });

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _connectionError = mcpManager.lastError ?? 'Connection failed';
        });
      }
    }
  }
}

/// Show MCP Server Dialog
Future<bool?> showMCPServerDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const MCPServerDialog(),
    barrierDismissible: true,
  );
}
