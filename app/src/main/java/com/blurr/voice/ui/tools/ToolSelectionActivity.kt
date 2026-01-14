package com.blurr.voice.ui.tools

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.blurr.voice.data.ToolPreferences
import com.blurr.voice.mcp.MCPServerManager
import com.blurr.voice.tools.ToolRegistry
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Activity for selecting which tools to enable/disable
 * 
 * Displays:
 * - Built-in tools from ToolRegistry
 * - MCP tools from MCPClient
 * - Toggle switches for each tool
 * - Categories for organization
 */
class ToolSelectionActivity : ComponentActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val toolPreferences = ToolPreferences(this)
        val toolRegistry = ToolRegistry(this)
        val mcpServerManager = MCPServerManager(this)
        
        setContent {
            MaterialTheme {
                ToolSelectionScreen(
                    viewModel = viewModel(
                        factory = ToolSelectionViewModelFactory(
                            toolPreferences,
                            toolRegistry,
                            mcpServerManager
                        )
                    ),
                    onBackPressed = { finish() }
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ToolSelectionScreen(
    viewModel: ToolSelectionViewModel = viewModel(),
    onBackPressed: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Tool Selection") },
                navigationIcon = {
                    IconButton(onClick = onBackPressed) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                },
                actions = {
                    TextButton(onClick = { viewModel.enableAllTools() }) {
                        Text("Enable All")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = 16.dp)
        ) {
            // Built-in Tools Section
            if (uiState.builtInTools.isNotEmpty()) {
                item {
                    SectionHeader(title = "Built-in Tools")
                }
                
                items(uiState.builtInTools) { toolItem ->
                    ToolToggleItem(
                        toolItem = toolItem,
                        onToggle = { enabled ->
                            viewModel.toggleTool(toolItem.name, enabled)
                        }
                    )
                }
                
                item { Spacer(modifier = Modifier.height(16.dp)) }
            }
            
            // MCP Tools Section
            if (uiState.mcpTools.isNotEmpty()) {
                item {
                    SectionHeader(title = "MCP Tools")
                }
                
                items(uiState.mcpTools) { toolItem ->
                    ToolToggleItem(
                        toolItem = toolItem,
                        onToggle = { enabled ->
                            viewModel.toggleTool(toolItem.name, enabled)
                        }
                    )
                }
            }
            
            // Empty State
            if (uiState.builtInTools.isEmpty() && uiState.mcpTools.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 48.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "No tools available",
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun SectionHeader(title: String) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleMedium,
        fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(vertical = 12.dp)
    )
}

@Composable
fun ToolToggleItem(
    toolItem: ToolItem,
    onToggle: (Boolean) -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (toolItem.isEnabled) {
                MaterialTheme.colorScheme.primaryContainer
            } else {
                MaterialTheme.colorScheme.surfaceVariant
            }
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = toolItem.displayName,
                        style = MaterialTheme.typography.bodyLarge,
                        fontWeight = FontWeight.Medium
                    )
                    
                    if (toolItem.category.isNotBlank()) {
                        Spacer(modifier = Modifier.width(8.dp))
                        SuggestionChip(
                            onClick = { },
                            label = { 
                                Text(
                                    text = toolItem.category,
                                    style = MaterialTheme.typography.labelSmall
                                ) 
                            },
                            modifier = Modifier.height(24.dp)
                        )
                    }
                }
                
                if (toolItem.description.isNotBlank()) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = toolItem.description,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            Spacer(modifier = Modifier.width(16.dp))
            
            Switch(
                checked = toolItem.isEnabled,
                onCheckedChange = onToggle,
                thumbContent = if (toolItem.isEnabled) {
                    {
                        Icon(
                            imageVector = Icons.Filled.Check,
                            contentDescription = null,
                            modifier = Modifier.size(SwitchDefaults.IconSize)
                        )
                    }
                } else {
                    null
                }
            )
        }
    }
}

/**
 * ViewModel for Tool Selection
 */
class ToolSelectionViewModel(
    private val toolPreferences: ToolPreferences,
    private val toolRegistry: ToolRegistry,
    private val mcpServerManager: MCPServerManager
) : ViewModel() {
    
    private val _uiState = MutableStateFlow(ToolSelectionUiState())
    val uiState: StateFlow<ToolSelectionUiState> = _uiState.asStateFlow()
    
    init {
        loadTools()
    }
    
    private fun loadTools() {
        viewModelScope.launch {
            // Load built-in tools
            val builtInTools = toolRegistry.getAllTools().map { tool ->
                ToolItem(
                    name = tool.name,
                    displayName = tool.name.replace("_", " ").capitalize(),
                    description = tool.description,
                    category = extractCategory(tool.name),
                    isEnabled = toolPreferences.isToolEnabled(tool.name),
                    isMCP = false
                )
            }
            
            // Load MCP tools from all connected servers
            val mcpTools = mcpServerManager.getTools().map { toolInfo ->
                ToolItem(
                    name = toolInfo.name,
                    displayName = toolInfo.name.replace("_", " ").capitalize(),
                    description = toolInfo.description ?: "",
                    category = "MCP",
                    isEnabled = toolPreferences.isToolEnabled(toolInfo.name),
                    isMCP = true
                )
            }
            
            _uiState.value = ToolSelectionUiState(
                builtInTools = builtInTools,
                mcpTools = mcpTools
            )
        }
    }
    
    fun toggleTool(toolName: String, enabled: Boolean) {
        if (enabled) {
            toolPreferences.enableTool(toolName)
        } else {
            toolPreferences.disableTool(toolName)
        }
        
        // Update UI state
        _uiState.value = _uiState.value.copy(
            builtInTools = _uiState.value.builtInTools.map {
                if (it.name == toolName) it.copy(isEnabled = enabled) else it
            },
            mcpTools = _uiState.value.mcpTools.map {
                if (it.name == toolName) it.copy(isEnabled = enabled) else it
            }
        )
    }
    
    fun enableAllTools() {
        toolPreferences.enableAllTools()
        
        _uiState.value = _uiState.value.copy(
            builtInTools = _uiState.value.builtInTools.map { it.copy(isEnabled = true) },
            mcpTools = _uiState.value.mcpTools.map { it.copy(isEnabled = true) }
        )
    }
    
    private fun extractCategory(toolName: String): String {
        return when {
            toolName.startsWith("search_") -> "Search"
            toolName.startsWith("generate_") -> "Generate"
            toolName.startsWith("document_") -> "Document"
            toolName.startsWith("google_") -> "Google"
            toolName.startsWith("phone_") -> "Phone"
            else -> ""
        }
    }
}

/**
 * UI State
 */
data class ToolSelectionUiState(
    val builtInTools: List<ToolItem> = emptyList(),
    val mcpTools: List<ToolItem> = emptyList()
)

data class ToolItem(
    val name: String,
    val displayName: String,
    val description: String,
    val category: String,
    val isEnabled: Boolean,
    val isMCP: Boolean
)

/**
 * ViewModel Factory
 */
class ToolSelectionViewModelFactory(
    private val toolPreferences: ToolPreferences,
    private val toolRegistry: ToolRegistry,
    private val mcpServerManager: MCPServerManager
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(ToolSelectionViewModel::class.java)) {
            return ToolSelectionViewModel(toolPreferences, toolRegistry, mcpServerManager) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
