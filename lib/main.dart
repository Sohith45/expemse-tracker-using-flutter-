import 'package:flutter/material.dart';

void main() => runApp(const ExpenseApp());

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Expense {
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense(this.title, this.amount, this.category, this.date);
}

const categories = ['Food', 'Travel', 'Study', 'Shopping', 'Other'];

const categoryIcons = {
  'Food': Icons.restaurant,
  'Travel': Icons.directions_bus,
  'Study': Icons.menu_book,
  'Shopping': Icons.shopping_bag,
  'Other': Icons.category,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];

  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  void _addExpense() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = categories.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('New expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setDialog(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text);
                if (titleCtrl.text.trim().isEmpty ||
                    amount == null ||
                    amount <= 0) {
                  return;
                }
                setState(() => _expenses.insert(
                    0,
                    Expense(titleCtrl.text.trim(), amount, category,
                        DateTime.now())));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total spent'),
                  Text('₹${_total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _byCategory.entries
                        .map((e) => Chip(
                            label: Text(
                                '${e.key}: ₹${e.value.toStringAsFixed(0)}')))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('No expenses yet. Tap Add.'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (ctx, i) {
                      final e = _expenses[i];
                      return Dismissible(
                        key: ObjectKey(e),
                        background: Container(color: Colors.red),
                        onDismissed: (_) =>
                            setState(() => _expenses.removeAt(i)),
                        child: ListTile(
                          leading: CircleAvatar(
                              child: Icon(categoryIcons[e.category])),
                          title: Text(e.title),
                          subtitle: Text(
                              '${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}'),
                          trailing: Text('₹${e.amount.toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}