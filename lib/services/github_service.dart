import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_service.dart';

class GitHubService {
  static const String _apiBaseUrl = 'https://api.github.com';
  static const String _owner = 'sedrowow';
  static const String _repo = 'productmanager';

  Future<bool> createIssue(String title, String description) async {
    final token = TokenService.getGitHubToken();
    if (token.isEmpty) {
      print('Error: GitHub token is not configured');
      return false;
    }

    final url = Uri.parse('$_apiBaseUrl/repos/$_owner/$_repo/issues');
    print('Attempting request to: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/vnd.github+json',
          'Authorization': 'Bearer $token',
          'X-GitHub-Api-Version': '2022-11-28',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': description,
          'labels': ['bug']
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 201;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
