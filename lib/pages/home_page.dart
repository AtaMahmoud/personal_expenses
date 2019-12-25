import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../widgets/transaction_list.dart';
import '../models/transaction.dart';
import '../widgets/chart.dart';
import '../widgets/new_transaction.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Transaction> _userTransactions = [];
  bool _showChart = false;
  List<Transaction> get _recentTransaction {
    return _userTransactions.where((transaction) {
      return transaction.date
          .isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  void _startAddNewTransaction() {
    showModalBottomSheet(
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
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Personal Expenses'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(),
                )
              ],
            ),
          )
        : AppBar(
            title: Text('Personal Expenses'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(),
              )
            ],
          );
    final bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    final transactionList = Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.6,
        child: TransactionList(_userTransactions, _deleteTransaction));
    final body = SafeArea(
        child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          if (isLandscape)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Show Chart",
                  style: Theme.of(context).textTheme.title,
                ),
                Switch.adaptive(
                  activeColor: Theme.of(context).accentColor,
                  value: _showChart,
                  onChanged: (value) {
                    setState(() {
                      _showChart = value;
                    });
                  },
                )
              ],
            ),
          if (!isLandscape) ...[
            Container(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.3,
                child: Chart(_recentTransaction)),
            transactionList
          ],
          if (isLandscape) ...[
            _showChart
                ? Container(
                    height: (mediaQuery.size.height -
                            appBar.preferredSize.height -
                            mediaQuery.padding.top) *
                        0.7,
                    child: Chart(_recentTransaction))
                : transactionList
          ]
        ],
      ),
    ));

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: body,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: body,
            floatingActionButton: FloatingActionButton(
              child: Icon(
                Icons.add,
              ),
              onPressed: () => _startAddNewTransaction(),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
