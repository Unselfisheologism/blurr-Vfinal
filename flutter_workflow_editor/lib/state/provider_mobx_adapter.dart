/// Provider to MobX State Adapter
/// Handles bidirectional synchronization between Provider (WorkflowState) and MobX (vyuh_node_flow)
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/workflow.dart';
import 'node_flow_controller.dart';
import 'workflow_state.dart';

/// Adapter for synchronizing Provider state with MobX node flow controller
class ProviderMobXAdapter {
  final WorkflowState workflowState;
  final WorkflowNodeFlowController nodeFlowController;
  final Uuid _uuid = const Uuid();

  Timer? _debounceTimer;
  bool _isSyncingFromWorkflowState = false;
  bool _isSyncingFromNodeFlow = false;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  // Listeners
  VoidCallback? _workflowStateListener;
  StreamSubscription? _nodeFlowSubscription;

  ProviderMobXAdapter({
    required this.workflowState,
    required this.nodeFlowController,
  }) {
    _setupBidirectionalSync();
  }

  /// Setup bidirectional synchronization
  void _setupBidirectionalSync() {
    // Listen to WorkflowState changes
    _workflowStateListener = () {
      if (!_isSyncingFromNodeFlow) {
        _debouncedSyncFromWorkflowState();
      }
    };
    workflowState.addListener(_workflowStateListener!);

    // Listen to NodeFlowController changes
    _nodeFlowSubscription = nodeFlowController.onChange.listen((_) {
      if (!_isSyncingFromWorkflowState) {
        _debouncedSyncFromNodeFlow();
      }
    });

    // Initial sync
    if (workflowState.currentWorkflow != null) {
      _syncFromWorkflowState();
    }
  }

  /// Debounced sync from WorkflowState to NodeFlowController
  void _debouncedSyncFromWorkflowState() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _syncFromWorkflowState();
    });
  }

  /// Debounced sync from NodeFlowController to WorkflowState
  void _debouncedSyncFromNodeFlow() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _syncFromNodeFlow();
    });
  }

  /// Sync nodes and connections from WorkflowState to NodeFlowController
  void _syncFromWorkflowState() {
    if (workflowState.currentWorkflow == null) return;

    _isSyncingFromWorkflowState = true;

    try {
      nodeFlowController.importFromWorkflow(workflowState.currentWorkflow!);
    } catch (e) {
      debugPrint('Error syncing from WorkflowState: $e');
    } finally {
      _isSyncingFromWorkflowState = false;
    }
  }

  /// Sync nodes and connections from NodeFlowController to WorkflowState
  void _syncFromNodeFlow() {
    _isSyncingFromNodeFlow = true;

    try {
      final currentWorkflow = workflowState.currentWorkflow;
      if (currentWorkflow == null) return;

      // Export from NodeFlowController to Workflow model
      final updatedWorkflow = nodeFlowController.exportToWorkflow(
        workflowId: currentWorkflow.id,
        name: currentWorkflow.name,
        description: currentWorkflow.description ?? '',
      );

      // Update WorkflowState with the new workflow
      // Note: We need to update the internal state without triggering a full notify
      // For now, we'll just update the currentWorkflow directly
      // In a more robust implementation, we might add a silentUpdate method to WorkflowState

      // Since WorkflowState is a ChangeNotifier, we need to be careful not to create
      // an infinite loop. We'll update the state without calling notifyListeners
      // by accessing private fields if necessary, or using a different approach

      // For this implementation, we'll just call the existing methods
      // The debouncing and the _isSyncingFromNodeFlow flag should prevent infinite loops

      // Create a new workflow with updated nodes and connections
      final newWorkflow = currentWorkflow.copyWith(
        nodes: updatedWorkflow.nodes,
        connections: updatedWorkflow.connections,
        updatedAt: DateTime.now(),
      );

      // Update the workflow state silently
      _updateWorkflowSilently(newWorkflow);
    } catch (e) {
      debugPrint('Error syncing from NodeFlow: $e');
    } finally {
      _isSyncingFromNodeFlow = false;
    }
  }

  /// Update workflow state from the node editor.
  ///
  /// The adapter guards against sync loops using [_isSyncingFromNodeFlow] and
  /// [_isSyncingFromWorkflowState].
  void _updateWorkflowSilently(Workflow workflow) {
    workflowState.setCurrentWorkflowFromEditor(workflow);
  }

  /// Add a node from WorkflowState and sync to NodeFlowController
  void addNode({
    required String type,
    required String name,
    required Map<String, dynamic> data,
    Offset? position,
  }) {
    // Add to WorkflowState
    workflowState.addNode(
      type: type,
      name: name,
      data: data,
      position: position,
    );

    // Sync to NodeFlowController will happen via listener
  }

  /// Remove a node and sync
  void removeNode(String nodeId) {
    // Remove from WorkflowState
    workflowState.removeNode(nodeId);

    // Sync to NodeFlowController will happen via listener
  }

  /// Update node data and sync
  void updateNodeData(String nodeId, Map<String, dynamic> data) {
    // Update in WorkflowState
    workflowState.updateNodeData(nodeId, data);

    // Sync to NodeFlowController will happen via listener
  }

  /// Update node position and sync
  void updateNodePosition(String nodeId, Offset position) {
    // Update in WorkflowState
    workflowState.updateNodePosition(nodeId, position);

    // Sync to NodeFlowController will happen via listener
  }

  /// Add a connection and sync
  void addConnection({
    required String sourceNodeId,
    required String targetNodeId,
    required String sourcePortId,
    required String targetPortId,
  }) {
    // Add to WorkflowState
    workflowState.addConnection(
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      sourcePortId: sourcePortId,
      targetPortId: targetPortId,
    );

    // Sync to NodeFlowController will happen via listener
  }

  /// Remove a connection and sync
  void removeConnection(String connectionId) {
    // Remove from WorkflowState
    workflowState.removeConnection(connectionId);

    // Sync to NodeFlowController will happen via listener
  }

  /// Trigger a manual sync from WorkflowState
  void syncFromWorkflowState() {
    _syncFromWorkflowState();
  }

  /// Trigger a manual sync from NodeFlowController
  void syncFromNodeFlow() {
    _syncFromNodeFlow();
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();

    if (_workflowStateListener != null) {
      workflowState.removeListener(_workflowStateListener!);
      _workflowStateListener = null;
    }

    _nodeFlowSubscription?.cancel();
    _nodeFlowSubscription = null;
  }
}
