import 'package:flutter/material.dart';

// 1. Transaction Model (Includes Date)
class Transaction {
final String type; // e.g., 'Transfer', 'Deposit'
final double amount;
final DateTime date;
final String account; // Recipient/Sender

Transaction({
required this.type,
required this.amount,
required this.date,
required this.account,
});
}

// Simple Mock Bank Service
class BankService {
double balance = 1000.00;
final List<Transaction> _transactions = [
Transaction(type: 'Deposit', amount: 500.00, date: DateTime.now().subtract(const Duration(days: 5)), account: 'Initial'),
Transaction(type: 'Withdrawal', amount: 50.00, date: DateTime.now().subtract(const Duration(days: 2)), account: 'ATM'),
];

List<Transaction> get transactions => _transactions.reversed.toList(); // Newest first

bool transfer({required double amount, required String recipient}) {
if (amount > 0) {
balance -= amount;
_transactions.add(Transaction(
type: 'Transfer',
amount: amount,
date: DateTime.now(),
account: recipient,
));
return true;
}
return false;
}
}

final bankService = BankService();
const String currentAccount = '123456789';

void main() {
runApp(const SimpleBankApp());
}

class SimpleBankApp extends StatelessWidget {
const SimpleBankApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Simple Bank App',
theme: ThemeData(
brightness: Brightness.light,
primarySwatch: Colors.grey,
scaffoldBackgroundColor: Colors.white,
appBarTheme: const AppBarTheme(
backgroundColor: Colors.white,
foregroundColor: Colors.black,
elevation: 1,
),
textTheme: const TextTheme(
bodyMedium: TextStyle(color: Colors.black),
headlineMedium: TextStyle(color: Colors.black),
),
),
home: const LoginScreen(),
);
}
}

// ------------------------------------------------------------------
// 2. Login Screen 🔑
// ------------------------------------------------------------------

class LoginScreen extends StatelessWidget {
const LoginScreen({super.key});

void _login(BuildContext context) {
Navigator.of(context).pushReplacement(
MaterialPageRoute(builder: (context) => const AppHomePage()),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Login')),
body: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
'Welcome',
style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
),
const SizedBox(height: 30),
const TextField(
decoration: InputDecoration(
labelText: 'Username',
border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 15),
const TextField(
obscureText: true,
decoration: InputDecoration(
labelText: 'Password',
border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 30),
ElevatedButton(
onPressed: () => _login(context),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey,
minimumSize: const Size(double.infinity, 50),
),
child: const Text('LOG IN', style: TextStyle(color: Colors.black, fontSize: 18)),
),
],
),
),
);
}
}

// ------------------------------------------------------------------
// 3. App Home Page 🏠
// ------------------------------------------------------------------

class AppHomePage extends StatelessWidget {
const AppHomePage({super.key});

void _openTransfer(BuildContext context) {
Navigator.of(context).push(
MaterialPageRoute(builder: (context) => const TransferScreen()),
);
}

void _viewTransactions(BuildContext context) {
// Navigate to the new TransactionsHistoryScreen
Navigator.of(context).push(
MaterialPageRoute(builder: (context) => const TransactionsHistoryScreen()),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Home')),
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text(
'Current Account: $currentAccount',
style: const TextStyle(fontSize: 20, color: Colors.black),
),
const SizedBox(height: 30),
ElevatedButton.icon(
icon: const Icon(Icons.send, color: Colors.black),
label: const Text('Open Transfer Page', style: TextStyle(color: Colors.black)),
onPressed: () => _openTransfer(context),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[300],
minimumSize: const Size(250, 50),
),
),
const SizedBox(height: 15),
ElevatedButton.icon(
icon: const Icon(Icons.list_alt, color: Colors.black),
label: const Text('View Transactions History', style: TextStyle(color: Colors.black)),
onPressed: () => _viewTransactions(context),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[300],
minimumSize: const Size(250, 50),
),
),
],
),
),
);
}
}

// ------------------------------------------------------------------
// 4. Transfer Screen 💸
// ------------------------------------------------------------------

class TransferScreen extends StatefulWidget {
const TransferScreen({super.key});

@override
State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
final TextEditingController _amountController = TextEditingController();
final TextEditingController _recipientController = TextEditingController();
String _message = 'Enter recipient and amount';
Color _messageColor = Colors.black;

void _submitTransfer() {
final amount = double.tryParse(_amountController.text.trim());
final recipient = _recipientController.text.trim();

if (amount == null || amount <= 0 || recipient.isEmpty) {
setState(() {
_message = 'Invalid amount or recipient.';
_messageColor = Colors.red;
});
return;
}

if (bankService.transfer(amount: amount, recipient: recipient)) {
setState(() {
_message = 'Transfer successful! New balance: \$${bankService.balance.toStringAsFixed(2)}';
_messageColor = Colors.green;
_amountController.clear();
// Force redraw of transaction screen if it was open
// (In a real app, use state management for this)
});
} else {
setState(() {
_message = 'Transfer failed: Amount must be greater than zero.';
_messageColor = Colors.red;
});
}
}

@override
void dispose() {
_amountController.dispose();
_recipientController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Money Transfer')),
body: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Current Balance: \$${bankService.balance.toStringAsFixed(2)}',
style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
),
const SizedBox(height: 20),
TextField(
controller: _recipientController,
decoration: InputDecoration(
labelText: 'Recipient Account Number',
border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
filled: true,
fillColor: Colors.white,
),
),
const SizedBox(height: 15),
TextField(
controller: _amountController,
decoration: InputDecoration(
labelText: 'Amount (\$)',
border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
filled: true,
fillColor: Colors.white,
),
keyboardType: TextInputType.number,
),
const SizedBox(height: 30),
ElevatedButton(
onPressed: _submitTransfer,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey,
minimumSize: const Size(double.infinity, 50),
),
child: const Text('TRANSFER', style: TextStyle(color: Colors.black, fontSize: 18)),
),
const SizedBox(height: 20),
Text(
_message,
style: TextStyle(color: _messageColor, fontSize: 16, fontWeight: FontWeight.bold),
),
],
),
),
);
}
}

// ------------------------------------------------------------------
// 5. Transactions History Screen (New) 📋
// ------------------------------------------------------------------

class TransactionsHistoryScreen extends StatelessWidget {
const TransactionsHistoryScreen({super.key});

@override
Widget build(BuildContext context) {
final transactions = bankService.transactions;

return Scaffold(
appBar: AppBar(title: const Text('Transaction History')),
body: transactions.isEmpty
? const Center(child: Text('No transactions found.', style: TextStyle(color: Colors.black54)))
    : ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: transactions.length,
itemBuilder: (context, index) {
final t = transactions[index];

// Determine color and sign
final isDebit = t.type == 'Transfer' || t.type == 'Withdrawal';
final amountSign = isDebit ? '-' : '+';
final amountColor = isDebit ? Colors.red : Colors.green;

// Format date to a readable string
final dateFormatted = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')} ${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}';

return Card(
elevation: 1,
margin: const EdgeInsets.symmetric(vertical: 8),
child: ListTile(
leading: Icon(
isDebit ? Icons.arrow_upward : Icons.arrow_downward,
color: amountColor,
),
title: Text(
'${t.type} to/from: ${t.account}',
style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
),
subtitle: Text(
'Date: $dateFormatted',
style: const TextStyle(color: Colors.black54),
),
trailing: Text(
'$amountSign\$${t.amount.toStringAsFixed(2)}',
style: TextStyle(
color: amountColor,
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
),
);
},
),
);
}
}