import 'package:flutter/material.dart';
import '../models/cryptocurrency.dart';
import '../models/portfolio.dart';

class AddCryptoDialog extends StatefulWidget {
  final Cryptocurrency crypto;
  final List<Portfolio> portfolios;
  final Function(Portfolio, Cryptocurrency, double) onAdd;

  const AddCryptoDialog({
    Key? key,
    required this.crypto,
    required this.portfolios,
    required this.onAdd,
  }) : super(key: key);

  @override
  _AddCryptoDialogState createState() => _AddCryptoDialogState();
}

class _AddCryptoDialogState extends State<AddCryptoDialog> {
  late int selectedPortfolioIndex;
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedPortfolioIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.crypto.name} to Portfolio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: selectedPortfolioIndex,
            items: List.generate(
              widget.portfolios.length,
              (index) => DropdownMenuItem(
                value: index,
                child: Text(widget.portfolios[index].name),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedPortfolioIndex = value);
              }
            },
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter amount',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text) ?? 0.0;
            if (amount > 0) {
              widget.onAdd(
                widget.portfolios[selectedPortfolioIndex],
                widget.crypto,
                amount,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}
