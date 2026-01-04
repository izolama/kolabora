import 'package:flutter/material.dart';

import '../tokens.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

class AppTextArea extends StatelessWidget {
  const AppTextArea({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.maxLines = 4,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

class AppChipsSelect extends StatelessWidget {
  const AppChipsSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.label,
  });

  final List<String> options;
  final Set<String> selected;
  final void Function(Set<String>) onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Text(label!, style: Theme.of(context).textTheme.labelLarge),
          ),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: options
              .map(
                (opt) => ChoiceChip(
                  label: Text(opt),
                  selected: selected.contains(opt),
                  onSelected: (value) {
                    final next = {...selected};
                    if (value) {
                      next.add(opt);
                    } else {
                      next.remove(opt);
                    }
                    onChanged(next);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
