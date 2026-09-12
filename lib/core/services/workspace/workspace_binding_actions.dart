import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:Kelivo/core/models/assistant.dart';
import 'package:Kelivo/core/models/workspace.dart';
import 'package:Kelivo/core/models/workspace_binding.dart';
import 'package:Kelivo/core/providers/assistant_provider.dart';
import 'package:Kelivo/core/services/chat/chat_service.dart';
import 'package:Kelivo/l10n/app_localizations.dart';
import 'package:Kelivo/shared/widgets/snackbar.dart';

/// Conversation extras applied when starting a chat with [assistant].
Map<String, dynamic> workspaceExtrasForNewConversation({
  required Assistant? assistant,
  required Workspace? Function(String id) workspaceById,
}) {
  final workspaceId = assistant?.defaultWorkspaceId;
  if (workspaceId == null || workspaceId.isEmpty) {
    return const <String, dynamic>{};
  }
  final workspace = workspaceById(workspaceId);
  if (workspace == null) {
    return const <String, dynamic>{};
  }
  return WorkspaceBinding(
    workspaceId: workspace.id,
    cwd: workspace.defaultCwd,
  ).applyTo({});
}

/// Writes the per-conversation workspace binding.
///
/// Binding is conversation-scoped: it never touches
/// [Assistant.defaultWorkspaceId], which assistant settings own.
class WorkspaceBindingActions {
  WorkspaceBindingActions({required this.chat});

  final ChatService chat;

  Future<void> bind({
    required String conversationId,
    required Workspace workspace,
  }) async {
    await chat.updateConversationExtras(
      conversationId,
      WorkspaceBinding(
        workspaceId: workspace.id,
        cwd: workspace.defaultCwd,
      ).applyTo,
    );
  }

  Future<void> unbind({required String conversationId}) async {
    await chat.updateConversationExtras(
      conversationId,
      const WorkspaceBinding().applyTo,
    );
  }
}

/// Clears [Assistant.defaultWorkspaceId] on every assistant bound to [workspaceId].
Future<void> clearAssistantDefaultsForDeletedWorkspace(
  AssistantProvider assistants, {
  required String workspaceId,
}) async {
  for (final assistant in List<Assistant>.of(assistants.assistants)) {
    if (assistant.defaultWorkspaceId == workspaceId) {
      await assistants.updateAssistant(
        assistant.copyWith(clearDefaultWorkspaceId: true),
      );
    }
  }
}

Future<void> bindConversationWorkspace(
  BuildContext context, {
  required String conversationId,
  required Workspace workspace,
}) async {
  await WorkspaceBindingActions(
    chat: context.read<ChatService>(),
  ).bind(conversationId: conversationId, workspace: workspace);
}

Future<void> unbindConversationWorkspace(
  BuildContext context, {
  required String conversationId,
}) async {
  await WorkspaceBindingActions(
    chat: context.read<ChatService>(),
  ).unbind(conversationId: conversationId);
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  showAppSnackBar(
    context,
    message: l10n.workspaceUnbindHint,
    type: NotificationType.info,
  );
}

