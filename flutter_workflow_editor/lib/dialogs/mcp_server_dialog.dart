/// MCP Server Connection Dialog
/// Dialog for adding/editing MCP servers with transport protocol selection
library;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/mcp_server_manager.dart';
import '../services/platform_bridge.dart';

enum MCPTransport {
  http('HTTP', Icons.http, 'Uses REST API over HTTP'),
  sse('SSE', Icons.cloud_sync, 'Uses Server-Sent Events'),
  stdio('Stdio', Icons.terminal, 'Uses standard I/O pipes');

  const MCPTransport(this.displayName, this.icon, this.description);
  final String displayName;
  final IconData icon;
  final String description;
}

class MCPServerDialog extends StatefulWidget {
  final MCPServerConnection? existingServer;

  const MCPServerDialog({
    super.key,
    this.existingServer,
  });

  @override
  State<MCPServerDialog> createState() => _MCPServerDialogState();
}

class _MCPServerDialogState extends State<MCPServerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _stdioPathController = TextEditingController();

  MCPTransport _selectedTransport = MCPTransport.http;
  bool _isValidating = false;
  bool _isConnecting = false;
  String? _validationError;
  Map<String, dynamic>? _validationResult;

  @override
  void initState() {
    super.initState();
    if (widget.existingServer != null) {
      _nameController.text = widget.existingServer!.name;
      _urlController.text = widget.existingServer!.url;
      _selectedTransport = MCPTransport.values.firstWhere(
        (t) => t.name == widget.existingServer!.transport,
        orElse: () => MCPTransport.http,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _stdioPathController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
      _validationResult = null;
    });

    try {
      final serverName = _nameController.text.trim();
      final url = _selectedTransport == MCPTransport.stdio
          ? _stdioPathController.text.trim()
          : _urlController.text.trim();

      final platformBridge = PlatformBridge();
      final result = await platformBridge.validateMCPConnection(
        serverName: serverName,
        url: url,
        transport: _selectedTransport.name,
      );

      setState(() {
        _isValidating = false;
        _validationResult = result;
        if (result['success'] != true) {
          _validationError = result['message'] as String? ?? 'Connection failed';
        }
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isValidating = false;
        _validationError = e.toString();
      });
    }
  }

  Future<void> _saveConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    try {
      final serverName = _nameController.text.trim();
      final url = _selectedTransport == MCPTransport.stdio
          ? _stdioPathController.text.trim()
          : _urlController.text.trim();

      final manager = MCPServerManager.instance;
      final result = await manager.connectServer(
        name: serverName,
        url: url,
        transport: _selectedTransport.name,
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Connected to $serverName (${result['toolCount']} tools)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] as String? ?? 'Connection failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickStdioProcess() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe', 'sh', 'py', 'js', ''],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _stdioPathController.text = result.files.single.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingServer != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_queue, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(isEditing ? 'Edit MCP Server' : 'Add MCP Server'),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              // Server Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Server Name',
                  hintText: 'e.g., My Filesystem Server',
                  prefixIcon: Icon(Icons.server),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Server name is required';
                  }
                  return null;
                },
                enabled: !isConnecting && !isValidating,
              ),
              SizedBox(height: 16),

              // Transport Type
              DropdownButtonFormField<MCPTransport>(
                value: _selectedTransport,
                decoration: InputDecoration(
                  labelText: 'Transport Protocol',
                  prefixIcon: Icon(Icons.settings_ethernet),
                  border: OutlineInputBorder(),
                ),
                items: MCPTransport.values.map((transport) {
                  return DropdownMenuItem(
                    value: transport,
                    child: Row(
                      children: [
                        Icon(transport.icon, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transport.displayName,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(transport.description,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _isConnecting || isValidating || isEditing
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTransport = value;
                            _validationResult = null;
                            _validationError = null;
                          });
                        }
                      },
              ),
              SizedBox(height: 16),

              // URL or Stdio Path based on transport
              if (_selectedTransport != MCPTransport.stdio) ...[
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'e.g., http://localhost:3000',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Server URL is required';
                    }
                    if (!value.startsWith('http://') &&
                        !value.startsWith('https://')) {
                      return 'URL must start with http:// or https://';
                    }
                    return null;
                  },
                  enabled: !isConnecting && !isValidating,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stdioPathController,
                        decoration: InputDecoration(
                          labelText: 'Process Path',
                          hintText: 'e.g., /usr/local/bin/mcp-server',
                          prefixIcon: Icon(Icons.terminal),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Process path is required';
                          }
                          return null;
                        },
                        enabled: !isConnecting && !isValidating,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.folder_open),
                      onPressed: _isConnecting || isValidating
                          ? null
                          : _pickStdioProcess,
                      tooltip: 'Browse for executable',
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16),

              // Validation Result
              if (_validationError != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              if (_validationResult != null &&
                  _validationResult!['success'] == true) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connection successful!',
                              style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (_validationResult!['serverInfo'] != null)
                              Text(
                                'Server: ${(_validationResult!['serverInfo'] as Map)['name']}',
                                style: TextStyle(fontSize: 12),
                              ),
                            if (_validationResult!['toolCount'] != null)
                              Text(
                                'Available tools: ${_validationResult!['toolCount']}',
                                style: TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConnecting || _isValidating
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isConnecting || _isValidating ? null : _testConnection,
          icon: _isValidating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.link_off),
          label: Text('Test Connection'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isConnecting || _isValidating ? null : _saveConnection,
          icon: _isConnecting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.cloud_upload),
          label: Text(isEditing ? 'Update' : 'Connect'),
        ),
      ],
    );
  }
}
