package com.twent.voice.tools.google

import android.content.Context
import android.util.Log
import com.twent.voice.auth.GoogleAuthManager
import com.twent.voice.tools.BaseTool
import com.twent.voice.tools.ToolParameter
import com.twent.voice.tools.ToolResult
import com.google.api.client.googleapis.extensions.android.gms.auth.GoogleAccountCredential
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import com.google.api.services.gmail.Gmail
import com.google.api.services.gmail.model.Message
import com.google.api.services.gmail.model.ModifyMessageRequest
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.Base64
import java.io.ByteArrayOutputStream
import java.util.Properties
import javax.mail.Session
import javax.mail.internet.InternetAddress
import javax.mail.internet.MimeMessage

/**
 * Gmail Tool - FREE Google Workspace Integration
 * 
 * Uses GoogleAuthManager from Story 4.13 for OAuth authentication.
 * Provides email reading, searching, composing, and sending capabilities.
 * 
 * Cost: $0 (uses user's quota: 1M queries/day per user)
 * Part of: Hybrid Integration Strategy (Story 4.13 + 4.15)
 */
class GmailTool(
    private val context: Context,
    private val authManager: GoogleAuthManager
) : BaseTool() {
    
    companion object {
        private const val TAG = "GmailTool"
        private const val APP_NAME = "Twent Voice Assistant"
    }
    
    override val name = "gmail"
    override val description = "Manage Gmail: read, search, compose, send, and organize emails using your Google account"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action to perform: list, read, search, send, reply, compose_draft, list_labels, add_label, mark_read, mark_unread, trash, delete",
            required = true
        ),
        ToolParameter(
            name = "max_results",
            type = "number",
            description = "Maximum number of emails to return (default: 10, max: 100)",
            required = false
        ),
        ToolParameter(
            name = "query",
            type = "string",
            description = "Search query (Gmail search syntax, e.g., 'from:user@example.com subject:meeting')",
            required = false
        ),
        ToolParameter(
            name = "message_id",
            type = "string",
            description = "Gmail message ID for read, reply, label operations",
            required = false
        ),
        ToolParameter(
            name = "to",
            type = "string",
            description = "Recipient email address(es), comma-separated",
            required = false
        ),
        ToolParameter(
            name = "cc",
            type = "string",
            description = "CC email address(es), comma-separated",
            required = false
        ),
        ToolParameter(
            name = "bcc",
            type = "string",
            description = "BCC email address(es), comma-separated",
            required = false
        ),
        ToolParameter(
            name = "subject",
            type = "string",
            description = "Email subject line",
            required = false
        ),
        ToolParameter(
            name = "body",
            type = "string",
            description = "Email body content (plain text)",
            required = false
        ),
        ToolParameter(
            name = "label",
            type = "string",
            description = "Label name or ID for add_label action",
            required = false
        ),
        ToolParameter(
            name = "include_spam_trash",
            type = "boolean",
            description = "Include spam and trash in search results (default: false)",
            required = false
        )
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        return withContext(Dispatchers.IO) {
            try {
                // Check if user is signed in
                if (!authManager.isSignedIn()) {
                    return@withContext ToolResult.failure(
                        name,
                        "Not signed in to Google. Please sign in first.",
                        mapOf("requires_auth" to true)
                    )
                }
                
                // Get action
                val action = getRequiredParam<String>(params, "action")
                
                // Build Gmail service
                val service = buildGmailService()
                    ?: return@withContext ToolResult.failure(
                        name,
                        "Failed to initialize Gmail service"
                    )
                
                // Execute action
                when (action.lowercase()) {
                    "list" -> listEmails(service, params)
                    "read" -> readEmail(service, params)
                    "search" -> searchEmails(service, params)
                    "send" -> sendEmail(service, params)
                    "reply" -> replyToEmail(service, params)
                    "compose_draft" -> composeDraft(service, params)
                    "list_labels" -> listLabels(service)
                    "add_label" -> addLabel(service, params)
                    "mark_read" -> markAsRead(service, params)
                    "mark_unread" -> markAsUnread(service, params)
                    "trash" -> trashEmail(service, params)
                    "delete" -> deleteEmail(service, params)
                    else -> ToolResult.failure(
                        name,
                        "Unknown action: $action. Available actions: list, read, search, send, reply, compose_draft, list_labels, add_label, mark_read, mark_unread, trash, delete"
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Gmail operation failed", e)
                ToolResult.failure(name, "Gmail error: ${e.message}")
            }
        }
    }
    
    /**
     * Build Gmail API service with user credentials
     */
    private fun buildGmailService(): Gmail? {
        try {
            val account = authManager.getAccount() ?: return null
            
            val credential = GoogleAccountCredential.usingOAuth2(
                context,
                listOf(
                    "https://www.googleapis.com/auth/gmail.readonly",
                    "https://www.googleapis.com/auth/gmail.compose",
                    "https://www.googleapis.com/auth/gmail.send",
                    "https://www.googleapis.com/auth/gmail.modify"
                )
            )
            credential.selectedAccount = account
            
            return Gmail.Builder(
                NetHttpTransport(),
                GsonFactory.getDefaultInstance(),
                credential
            )
                .setApplicationName(APP_NAME)
                .build()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to build Gmail service", e)
            return null
        }
    }
    
    /**
     * List recent emails
     */
    private suspend fun listEmails(service: Gmail, params: Map<String, Any>): ToolResult {
        val maxResults = getOptionalParam(params, "max_results", 10L).toLong()
        val includeSpamTrash = getOptionalParam(params, "include_spam_trash", false)
        
        val listResponse = service.users().messages()
            .list("me")
            .setMaxResults(maxResults)
            .setIncludeSpamTrash(includeSpamTrash)
            .execute()
        
        val messages = listResponse.messages ?: emptyList()
        
        // Get full details for each message
        val emailList = messages.map { messageRef ->
            val message = service.users().messages()
                .get("me", messageRef.id)
                .setFormat("metadata")
                .setMetadataHeaders(listOf("From", "To", "Subject", "Date"))
                .execute()
            
            extractEmailMetadata(message)
        }
        
        return ToolResult.success(
            name,
            mapOf(
                "count" to emailList.size,
                "emails" to emailList
            ),
            "Found ${emailList.size} emails"
        )
    }
    
    /**
     * Read full email content
     */
    private suspend fun readEmail(service: Gmail, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        
        val message = service.users().messages()
            .get("me", messageId)
            .setFormat("full")
            .execute()
        
        val metadata = extractEmailMetadata(message)
        val body = extractEmailBody(message)
        
        return ToolResult.success(
            name,
            mapOf(
                "message_id" to message.id,
                "thread_id" to message.threadId,
                "from" to metadata["from"],
                "to" to metadata["to"],
                "subject" to metadata["subject"],
                "date" to metadata["date"],
                "body" to body,
                "labels" to message.labelIds,
                "snippet" to message.snippet
            ),
            "Email retrieved successfully"
        )
    }
    
    /**
     * Search emails using Gmail query syntax
     */
    private suspend fun searchEmails(service: Gmail, params: Map<String, Any>): ToolResult {
        val query = getRequiredParam<String>(params, "query")
        val maxResults = getOptionalParam(params, "max_results", 10L).toLong()
        val includeSpamTrash = getOptionalParam(params, "include_spam_trash", false)
        
        val listResponse = service.users().messages()
            .list("me")
            .setQ(query)
            .setMaxResults(maxResults)
            .setIncludeSpamTrash(includeSpamTrash)
            .execute()
        
        val messages = listResponse.messages ?: emptyList()
        
        // Get metadata for each message
        val emailList = messages.map { messageRef ->
            val message = service.users().messages()
                .get("me", messageRef.id)
                .setFormat("metadata")
                .setMetadataHeaders(listOf("From", "To", "Subject", "Date"))
                .execute()
            
            extractEmailMetadata(message)
        }
        
        return ToolResult.success(
            name,
            mapOf(
                "query" to query,
                "count" to emailList.size,
                "emails" to emailList
            ),
            "Found ${emailList.size} emails matching: $query"
        )
    }
    
    /**
     * Send new email
     */
    private suspend fun sendEmail(service: Gmail, params: Map<String, Any>): ToolResult {
        val to = getRequiredParam<String>(params, "to")
        val subject = getRequiredParam<String>(params, "subject")
        val body = getRequiredParam<String>(params, "body")
        val cc = getOptionalParam<String?>(params, "cc", null)
        val bcc = getOptionalParam<String?>(params, "bcc", null)
        
        val mimeMessage = createMimeMessage(to, cc, bcc, subject, body)
        val encodedMessage = encodeMessage(mimeMessage)
        
        val message = Message().setRaw(encodedMessage)
        val sentMessage = service.users().messages().send("me", message).execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "message_id" to sentMessage.id,
                "thread_id" to sentMessage.threadId,
                "to" to to,
                "subject" to subject
            ),
            "Email sent successfully to $to"
        )
    }
    
    /**
     * Reply to existing email
     */
    private suspend fun replyToEmail(service: Gmail, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        val body = getRequiredParam<String>(params, "body")
        
        // Get original message to extract reply-to info
        val originalMessage = service.users().messages()
            .get("me", messageId)
            .setFormat("metadata")
            .setMetadataHeaders(listOf("From", "To", "Subject", "Message-ID", "References"))
            .execute()
        
        val metadata = extractEmailMetadata(originalMessage)
        val originalFrom = metadata["from"] as? String ?: ""
        val originalSubject = metadata["subject"] as? String ?: ""
        val replySubject = if (originalSubject.startsWith("Re:")) {
            originalSubject
        } else {
            "Re: $originalSubject"
        }
        
        val mimeMessage = createMimeMessage(
            to = originalFrom,
            cc = null,
            bcc = null,
            subject = replySubject,
            body = body
        )
        
        // Set thread ID for proper threading
        val encodedMessage = encodeMessage(mimeMessage)
        val message = Message()
            .setRaw(encodedMessage)
            .setThreadId(originalMessage.threadId)
        
        val sentMessage = service.users().messages().send("me", message).execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "message_id" to sentMessage.id,
                "thread_id" to sentMessage.threadId,
                "reply_to" to originalFrom,
                "subject" to replySubject
            ),
            "Reply sent successfully"
        )
    }
    
    /**
     * Compose draft email
     */
    private suspend fun composeDraft(service: Gmail, params: Map<String, Any>): ToolResult {
        val to = getRequiredParam<String>(params, "to")
        val subject = getRequiredParam<String>(params, "subject")
        val body = getRequiredParam<String>(params, "body")
        val cc = getOptionalParam<String?>(params, "cc", null)
        val bcc = getOptionalParam<String?>(params, "bcc", null)
        
        val mimeMessage = createMimeMessage(to, cc, bcc, subject, body)
        val encodedMessage = encodeMessage(mimeMessage)
        
        val message = Message().setRaw(encodedMessage)
        val draft = com.google.api.services.gmail.model.Draft().setMessage(message)
        val createdDraft = service.users().drafts().create("me", draft).execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "draft_id" to createdDraft.id,
                "message_id" to createdDraft.message.id,
                "to" to to,
                "subject" to subject
            ),
            "Draft created successfully"
        )
    }
    
    /**
     * List all Gmail labels
     */
    private suspend fun listLabels(service: Gmail): ToolResult {
        val listResponse = service.users().labels().list("me").execute()
        val labels = listResponse.labels?.map { label ->
            mapOf(
                "id" to label.id,
                "name" to label.name,
                "type" to label.type,
                "messages_total" to (label.messagesTotal ?: 0),
                "messages_unread" to (label.messagesUnread ?: 0)
            )
        } ?: emptyList()
        
        return ToolResult.success(
            name,
            mapOf(
                "count" to labels.size,
                "labels" to labels
            ),
            "Found ${labels.size} labels"
        )
    }
    
    /**
     * Add label to email
     */
    private suspend fun addLabel(service: Gmail, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        val label = getRequiredParam<String>(params, "label")
        
        val modifyRequest = ModifyMessageRequest().setAddLabelIds(listOf(label))
        service.users().messages().modify("me", messageId, modifyRequest).execute()
        
        return ToolResult.success(
            name,
            mapOf("message_id" to messageId, "label" to label),
            "Label '$label' added to message"
        )
    }
    
    /**
     * Mark email as read
     */
    private suspend fun markAsRead(service: Gmail, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        
        val modifyRequest = ModifyMessageRequest().setRemoveLabelIds(listOf("UNREAD"))
        service.users().messages().modify("me", messageId, modifyRequest).execute()
        
        return ToolResult.success(
            name,
            mapOf("message_id" to messageId),
            "Message marked as read"
        )
    }
    
    /**
     * Mark email as unread
     */
    private suspend fun markAsUnread(service: Gmail, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        
        val modifyRequest = ModifyMessageRequest().setAddLabelIds(listOf("UNREAD"))
        service.users().messages().modify("me", messageId, modifyRequest).execute()
        
        return ToolResult.success(
            name,
            mapOf("message_id" to messageId),
            "Message marked as unread"
        )
    }
    
    /**
     * Move email to trash
     */
    private suspend fun trashEmail(service: Gmail, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        
        service.users().messages().trash("me", messageId).execute()
        
        return ToolResult.success(
            name,
            mapOf("message_id" to messageId),
            "Message moved to trash"
        )
    }
    
    /**
     * Permanently delete email
     */
    private suspend fun deleteEmail(service: Gmail, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        
        service.users().messages().delete("me", messageId).execute()
        
        return ToolResult.success(
            name,
            mapOf("message_id" to messageId),
            "Message permanently deleted"
        )
    }
    
    /**
     * Extract email metadata from message
     */
    private fun extractEmailMetadata(message: Message): Map<String, Any> {
        val headers = message.payload?.headers ?: emptyList()
        
        return mapOf(
            "message_id" to message.id,
            "thread_id" to message.threadId,
            "from" to (headers.firstOrNull { it.name.equals("From", ignoreCase = true) }?.value ?: ""),
            "to" to (headers.firstOrNull { it.name.equals("To", ignoreCase = true) }?.value ?: ""),
            "subject" to (headers.firstOrNull { it.name.equals("Subject", ignoreCase = true) }?.value ?: ""),
            "date" to (headers.firstOrNull { it.name.equals("Date", ignoreCase = true) }?.value ?: ""),
            "snippet" to (message.snippet ?: ""),
            "labels" to (message.labelIds ?: emptyList())
        )
    }
    
    /**
     * Extract email body from message
     */
    private fun extractEmailBody(message: Message): String {
        val payload = message.payload ?: return ""
        
        // Try to get plain text body
        if (payload.body?.data != null) {
            return decodeBase64(payload.body.data)
        }
        
        // Check parts for text/plain
        val parts = payload.parts ?: emptyList()
        for (part in parts) {
            if (part.mimeType == "text/plain" && part.body?.data != null) {
                return decodeBase64(part.body.data)
            }
        }
        
        // Fallback to HTML if plain text not found
        for (part in parts) {
            if (part.mimeType == "text/html" && part.body?.data != null) {
                return decodeBase64(part.body.data)
            }
        }
        
        // Check nested parts
        for (part in parts) {
            val nestedParts = part.parts ?: continue
            for (nestedPart in nestedParts) {
                if (nestedPart.mimeType == "text/plain" && nestedPart.body?.data != null) {
                    return decodeBase64(nestedPart.body.data)
                }
            }
        }
        
        return message.snippet ?: ""
    }
    
    /**
     * Create MIME message
     */
    private fun createMimeMessage(
        to: String,
        cc: String?,
        bcc: String?,
        subject: String,
        body: String
    ): MimeMessage {
        val props = Properties()
        val session = Session.getDefaultInstance(props, null)
        val email = MimeMessage(session)
        
        val userEmail = authManager.getUserEmail() ?: "me"
        email.setFrom(InternetAddress(userEmail))
        email.addRecipients(
            javax.mail.Message.RecipientType.TO,
            InternetAddress.parse(to)
        )
        
        if (!cc.isNullOrBlank()) {
            email.addRecipients(
                javax.mail.Message.RecipientType.CC,
                InternetAddress.parse(cc)
            )
        }
        
        if (!bcc.isNullOrBlank()) {
            email.addRecipients(
                javax.mail.Message.RecipientType.BCC,
                InternetAddress.parse(bcc)
            )
        }
        
        email.subject = subject
        email.setText(body)
        
        return email
    }
    
    /**
     * Encode MIME message to base64url
     */
    private fun encodeMessage(message: MimeMessage): String {
        val buffer = ByteArrayOutputStream()
        message.writeTo(buffer)
        val bytes = buffer.toByteArray()
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes)
    }
    
    /**
     * Decode base64url string
     */
    private fun decodeBase64(encoded: String): String {
        val bytes = Base64.getUrlDecoder().decode(encoded)
        return String(bytes, Charsets.UTF_8)
    }
}
