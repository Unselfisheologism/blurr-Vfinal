/// Local storage service for workflows
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workflow.dart';

class StorageService {
  static const String _workflowsKey = 'workflows';
  static const String _workflowPrefix = 'workflow_';

  /// Save workflow
  Future<void> saveWorkflow(Workflow workflow) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save workflow data
    final json = jsonEncode(workflow.toJson());
    await prefs.setString('$_workflowPrefix${workflow.id}', json);

    // Update workflows list
    final workflowIds = await getWorkflowIds();
    if (!workflowIds.contains(workflow.id)) {
      workflowIds.add(workflow.id);
      await prefs.setStringList(_workflowsKey, workflowIds);
    }
  }

  /// Load workflow by ID
  Future<Workflow?> loadWorkflow(String workflowId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_workflowPrefix$workflowId');
    
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return Workflow.fromJson(data);
    } catch (e) {
      print('Error loading workflow: $e');
      return null;
    }
  }

  /// Delete workflow
  Future<void> deleteWorkflow(String workflowId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove workflow data
    await prefs.remove('$_workflowPrefix$workflowId');

    // Update workflows list
    final workflowIds = await getWorkflowIds();
    workflowIds.remove(workflowId);
    await prefs.setStringList(_workflowsKey, workflowIds);
  }

  /// Get list of workflow IDs
  Future<List<String>> getWorkflowIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_workflowsKey) ?? [];
  }

  /// Get list of all workflows (metadata only)
  Future<List<Map<String, dynamic>>> getWorkflowsList() async {
    final workflowIds = await getWorkflowIds();
    final workflows = <Map<String, dynamic>>[];

    for (final id in workflowIds) {
      final workflow = await loadWorkflow(id);
      if (workflow != null) {
        workflows.add({
          'id': workflow.id,
          'name': workflow.name,
          'description': workflow.description,
          'active': workflow.active,
          'updatedAt': workflow.updatedAt.toIso8601String(),
        });
      }
    }

    return workflows;
  }

  /// Export workflow as JSON
  Future<String> exportWorkflow(Workflow workflow) async {
    return jsonEncode(workflow.toJson());
  }

  /// Import workflow from JSON
  Future<Workflow?> importWorkflow(String json) async {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final workflow = Workflow.fromJson(data);
      
      // Save imported workflow
      await saveWorkflow(workflow);
      
      return workflow;
    } catch (e) {
      print('Error importing workflow: $e');
      return null;
    }
  }

  /// Clear all workflows (for testing)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final workflowIds = await getWorkflowIds();

    for (final id in workflowIds) {
      await prefs.remove('$_workflowPrefix$id');
    }

    await prefs.remove(_workflowsKey);
  }
}
