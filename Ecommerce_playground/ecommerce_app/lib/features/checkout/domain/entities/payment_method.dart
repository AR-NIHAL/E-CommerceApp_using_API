import 'package:flutter/material.dart';

enum PaymentMethod {
  cashOnDelivery(
    label: 'Cash on Delivery',
    icon: Icons.payments_outlined,
  ),
  card(
    label: 'Debit / Credit Card',
    icon: Icons.credit_card_outlined,
  ),
  upi(
    label: 'UPI',
    icon: Icons.account_balance_wallet_outlined,
  );

  const PaymentMethod({required this.label, required this.icon});

  final String label;
  final IconData icon;

  bool get requiresCardFields => this == PaymentMethod.card;
}
