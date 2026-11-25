
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NutriTrackApp());

class Food {
  final String name, category, unit;
  final int calories;
  final double protein;
  const Food(this.name, this.category, this.unit, this.calories, this.protein);
}

const foods = <Food>[
  Food('Apple', 'Fruits', '1 medium', 95, 0.5),
  Food('Banana', 'Fruits', '1 medium', 105, 1.3),
  Food('Orange', 'Fruits', '1 medium', 62, 1.2),
  Food('Papaya', 'Fruits', '1 cup', 55, 0.9),
  Food('Mango', 'Fruits', '1 cup', 99, 1.4),
  Food('Guava', 'Fruits', '1 medium', 68, 2.6),
  Food('Watermelon', 'Fruits', '1 cup', 46, 0.9),
  Food('Pomegranate', 'Fruits', '1/2 cup', 72, 1.5),
  Food('Carrot', 'Vegetables', '1 medium', 25, 0.6),
  Food('Cucumber', 'Vegetables', '1 cup', 16, 0.7),
  Food('Spinach', 'Vegetables', '1 cup', 7, 0.9),
  Food('Broccoli', 'Vegetables', '1 cup', 55, 3.7),
  Food('Tomato', 'Vegetables', '1 medium', 22, 1.1),
  Food('Beetroot', 'Vegetables', '1 medium',  enh(44), 1.7),
  Food('Sweet potato', 'Vegetables', '1 medium', 112, 2.0),
  Food('Coconut water', 'Drinks', '1 glass (240 ml)', 46, 1.7),
  Food('Buttermilk', 'Drinks', '1 glass (240 ml)', 60, 3.0),
  Food('Milk', 'Drinks', '1 glass (240 ml)', 122, 8.0),
  Food('Lemon water (no sugar)', 'Drinks', '1 glass', 8, 0.1),
  Food('Plain water', 'Drinks', '1 glass (250 ml)', 0, 0),
  Food('Oats', 'Grains', '40 g', 150, 5.0),
  Food('Brown rice', 'Grains', '1 cup cooked', 216, 5.0),
  Food('Whole wheat roti', 'Grains', '1 medium', 110, 3.0),
  Food('Boiled egg', 'Protein', '1 large', 78, 6.3),
  Food('Paneer', 'Protein', '100 g', 265, 18.0),
  Food('Cooked chickpeas', 'Protein', '1/2 cup', 135, 7.3),
  Food('Almonds', 'Seeds & nuts', '10 pieces', 70, 2.6),
  Food('Chia seeds', 'Seeds & nuts', '1 tbsp', 58, 2.0),
];

int enh(int value) => value;

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NutriTrack',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xff23866b), useMaterial3: true),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final search = TextEditingController();
  final List<Food> consumed = [];
  final Map<String, TimeOfDay> mealTimes = {
    'Breakfast': const TimeOfDay(hour: 8, minute: 0),
    'Morning snack': const TimeOfDay(hour: 10, minute: 30),
    'Lunch': const TimeOfDay(hour: 12, minute: 40),
    'Evening snack': const TimeOfDay(hour: 16, minute: 30),
    'Dinner': const TimeOfDay(hour: 20, minute: 0),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getStringList('consumed') ?? [];
    final times = p.getStringList('mealTimes') ?? [];
    if (!mounted) return;
    setState(() {
      consumed.addAll(saved.map((n) => foods.firstWhere((f) => f.name == n,
          orElse: () => foods.first)).where((f) => saved.contains(f.name)));
      for (final row in times) {
        final parts = row.split('|');
        if (parts.length == 2 && mealTimes.containsKey(parts[0])) {
          final hm = parts[1].split(':');
          mealTimes[parts[0]] = TimeOfDay(hour: int.parse(hm[0]), minute: int.parse(hm[1]));
        }
      }
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('consumed', consumed.map((f) => f.name).toList());
    await p.setStringList('mealTimes', mealTimes.entries.map((e) =>
      '${e.key}|${e.value.hour}:${e.value.minute}').toList());
  }

  int get calories => consumed.fold(0, (s, f) => s + f.calories);
  double get protein => consumed.fold(0, (s, f) => s + f.protein);
  int countCategory(String c) => consumed.where((f) => f.category == c).length;

  Future<void> addFood(Food food) async {
    setState(() => consumed.add(food));
    await _save();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} added to today’s count')));
  }

  Future<void> editTime(String meal) async {
    final picked = await showTimePicker(context: context, initialTime: mealTimes[meal]!);
    if (picked != null) {
      setState(() => mealTimes[meal] = picked);
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      _foodPage(),
      _planPage(),
      _historyPage(),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('🥗 NutriTrack'), centerTitle: false),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Foods'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Diet plan'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Daily log'),
        ],
      ),
    );
  }

  Widget _dashboard() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Your daily food dashboard', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
    const SizedBox(height: 14),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Today’s intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _metric('Total items', '${consumed.length}', Icons.restaurant),
        _metric('Calories', '$calories kcal', Icons.local_fire_department),
        _metric('Protein', '${protein.toStringAsFixed(1)} g', Icons.fitness_center),
      ]),
      const Divider(height: 24),
      Text('🍎 Fruits: ${countCategory('Fruits')}     🥦 Vegetables: ${countCategory('Vegetables')}'),
      Text('🥤 Drinks: ${countCategory('Drinks')}     🌾 Other foods: ${consumed.length - countCategory('Fruits') - countCategory('Vegetables') - countCategory('Drinks')}'),
    ]))),
    const SizedBox(height: 10),
    const Text('Quick add', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    Wrap(spacing: 8, children: foods.take(8).map((f) => ActionChip(
      label: Text(f.name), onPressed: () => addFood(f))).toList()),
    const SizedBox(height: 14),
    FilledButton.icon(onPressed: () => setState(() => tab = 1),
      icon: const Icon(Icons.search), label: const Text('Search all foods')),
    OutlinedButton.icon(onPressed: () => setState(() => tab = 2),
      icon: const Icon(Icons.edit_calendar), label: const Text('Edit meal timings')),
  ]);

  Widget _metric(String title, String value, IconData icon) => Column(children: [
    Icon(icon, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
    Text(title, style: const TextStyle(fontSize: 12)),
  ]);

  Widget _foodPage() {
    final q = search.text.toLowerCase();
    final filtered = foods.where((f) => f.name.toLowerCase().contains(q) ||
      f.category.toLowerCase().contains(q)).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.all(16), child: TextField(
        controller: search, onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search fruits, vegetables, drinks…', border: OutlineInputBorder()))),
      Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (context, i) {
        final f = filtered[i];
        return ListTile(
          leading: CircleAvatar(child: Text(f.category == 'Fruits' ? '🍎' : f.category == 'Vegetables' ? '🥦' : f.category == 'Drinks' ? '🥤' : '🍽️')),
          title: Text(f.name), subtitle: Text('${f.category} • ${f.unit} • ${f.calories} kcal • ${f.protein} g protein'),
          trailing: IconButton(icon: const Icon(Icons.add_circle), onPressed: () => addFood(f)),
        );
      })),
    ]);
  }

  Widget _planPage() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Daily diet schedule', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const Text('Tap the time to edit it. Your choices are saved on this device.'),
    const SizedBox(height: 12),
    ...mealTimes.entries.map((e) => Card(child: ListTile(
      leading: const Icon(Icons.access_time),
      title: Text(e.key),
      subtitle: Text(_format(e.value)),
      trailing: TextButton(onPressed: () => editTime(e.key), child: const Text('EDIT')),
    ))),
    const SizedBox(height: 10),
    const Text('Suggested meal ideas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const ListTile(leading: Text('🌅'), title: Text('Breakfast'), subtitle: Text('Oats + milk + banana or idli + sambar')),
    const ListTile(leading: Text('🍛'), title: Text('Lunch'), subtitle: Text('Rice/roti + dal + vegetables + curd')),
    const ListTile(leading: Text('🥜'), title: Text('Snack'), subtitle: Text('One fruit + a small handful of nuts')),
    const ListTile(leading: Text('🌙'), title: Text('Dinner'), subtitle: Text('Roti + paneer/egg/dal + vegetables')),
  ]);

  Widget _historyPage() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Today’s food log', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    Text('${consumed.length} items • $calories kcal • ${protein.toStringAsFixed(1)} g protein'),
    const SizedBox(height: 12),
    if (consumed.isEmpty) const Text('No foods added yet. Open Foods and tap + to start.'),
    ...consumed.asMap().entries.map((e) => ListTile(
      leading: const Icon(Icons.check_circle_outline),
      title: Text(e.value.name),
      subtitle: Text('${e.value.category} • ${e.value.calories} kcal'),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
        setState(() => consumed.removeAt(e.key)); await _save();
      }),
    )),
    TextButton.icon(onPressed: () async { setState(consumed.clear); await _save(); },
      icon: const Icon(Icons.delete_sweep), label: const Text('Clear today’s list')),
  ]);

  String _format(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}
