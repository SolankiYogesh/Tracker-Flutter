import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final String baseUrl = dotenv.env['API_URL']!;
  static final String apiKey = dotenv.env['API_KEY']!;
}
