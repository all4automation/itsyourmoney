import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? suffixText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const QuestionField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.suffixText,
    this.keyboardType = TextInputType.number,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
          ),
        ),
      ],
    );
  }
}
