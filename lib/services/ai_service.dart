import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class AiService {
  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// Suggests an expense category based on description and amount.
  Future<String> categorizeExpense(String description, double amount) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': EnvConfig.openRouterModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Categorize household expenses. Reply with ONLY one word: '
                  'Rent, Groceries, Utilities, Internet, Entertainment, Transport, Dining, Cleaning, or Other.',
            },
            {
              'role': 'user',
              'content': 'Expense: "$description" for \$$amount. Category?',
            },
          ],
          'max_tokens': 10,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ((data['choices'] as List)[0]['message']['content'] as String)
            .trim();
      }
    } catch (_) {}
    return 'Other';
  }

  /// Suggests how to fairly divide pending chores among household members.
  Future<String> getChoreAssignmentSuggestion(
    List<String> members,
    List<String> pendingChores,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.openRouterApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': EnvConfig.openRouterModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Help fairly assign household chores. Be brief and friendly.',
            },
            {
              'role': 'user',
              'content':
                  'Members: ${members.join(", ")}. Chores: ${pendingChores.join(", ")}. How to divide fairly?',
            },
          ],
          'max_tokens': 200,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ((data['choices'] as List)[0]['message']['content'] as String)
            .trim();
      }
    } catch (_) {}
    return 'Try rotating chores weekly for fairness!';
  }
}
