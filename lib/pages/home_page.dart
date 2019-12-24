import 'package:flutter/material.dart';
import 'package:personal_expenses/widgets/transaction_list.dart';

import '../models/transaction.dart';
import '../widgets/chart.dart';
import '../widgets/new_transaction.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transaction> _userTransactions = [];

  List<Transaction> get _recentTransaction {
    return _userTransactions.where((transaction) {
      return transaction.date
          .isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void _startAddNewTransaction(BuildContext context) {
    showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return NewTransaction(_addTransaction);
        });
  }

  void _addTransaction(String title, double amount, DateTime date) {
    setState(() {
      _userTransactions.add(Transaction(
          amount: amount,
          title: title,
          date: date,
          id: date.toIso8601String()));
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((transaction) => transaction.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Expenses'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Chart(_recentTransaction),
            TransactionList(_userTransactions, _deleteTransaction),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () => _startAddNewTransaction(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
