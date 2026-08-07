import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _mealController = TextEditingController(text: '2 slices white toast, orange juice, scrambled eggs');
  String _selectedMealType = 'Breakfast';
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  void _analyzeMeal() async {
    if (_mealController.text.isEmpty) return;
    setState(() => _isAnalyzing = true);

    final res = await _apiService.analyzeMeal(_mealController.text, mealType: _selectedMealType);

    setState(() {
      _isAnalyzing = false;
      _analysisResult = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module 9: Diabetic Meal Advisor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DoseBuddyTheme.accentAmber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: DoseBuddyTheme.accentAmber),
              ),
              child: Row(
                children: const [
                  Icon(Icons.restaurant_menu, color: DoseBuddyTheme.accentAmber, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI Meal & Glucose Predictor: Log your meal to estimate carbohydrate load, Glycemic Index, and postprandial glucose surge.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black80),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Meal Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMealType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.free_breakfast, color: DoseBuddyTheme.primaryTeal),
              ),
              items: _mealTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedMealType = val!),
            ),
            const SizedBox(height: 16),

            const Text('Describe Meal or Log Food', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _mealController,
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g. Oatmeal with blueberries, almonds, and skim milk...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: DoseBuddyTheme.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isAnalyzing ? null : _analyzeMeal,
              icon: _isAnalyzing
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.analytics, color: Colors.white),
              label: const Text(
                'ANALYZE MEAL WITH GEMINI AI',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            if (_analysisResult != null) ...[
              const SizedBox(height: 28),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Meal Nutrition Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(
                              '${_analysisResult!['glycemic_index']} GI',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: _analysisResult!['glycemic_index'] == 'High' ? Colors.red : DoseBuddyTheme.successGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricTile(
                              'Carbs (Grams)',
                              '${_analysisResult!['estimated_carbs_grams']}g',
                              Icons.grain,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricTile(
                              'Glucose Rise Surge',
                              '+${_analysisResult!['predicted_glucose_surge_mg_dl']} mg/dL',
                              Icons.trending_up,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Insulin & Timing Recommendation:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        _analysisResult!['insulin_timing_recommendation'] ?? '',
                        style: const TextStyle(fontSize: 15, color: Colors.black80),
                      ),
                      const SizedBox(height: 12),
                      const Text('Safety Guidance:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        _analysisResult!['safety_guidance'] ?? '',
                        style: const TextStyle(fontSize: 15, color: Colors.black80),
                      ),
                      if ((_analysisResult!['healthy_alternatives'] as List?)?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 16),
                        const Text('Lower-GI Healthy Alternatives:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DoseBuddyTheme.primaryTeal)),
                        const SizedBox(height: 6),
                        ...(_analysisResult!['healthy_alternatives'] as List).map(
                          (alt) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: DoseBuddyTheme.primaryTeal, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(alt, style: const TextStyle(fontSize: 15))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black60), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
