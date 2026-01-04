import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/components/buttons.dart';
import '../../../core/ui/components/inputs.dart';
import '../../../core/ui/components/layout.dart';
import '../../../core/ui/tokens.dart';
import '../../auth/domain/auth_state.dart';
import '../../network/domain/field.dart';
import '../../network/domain/field_providers.dart';
import '../data/feed_repository.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timelineController = TextEditingController();
  String _type = 'looking_vendor';
  String _compType = 'negotiable';
  final Set<String> _selectedFields = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(feedRepositoryProvider);
      final post = await repo.createPost(
        authorId: user.id,
        type: _type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        compensationType: _compType,
        timeline: _timelineController.text.trim(),
        fieldIds: _selectedFields.toList(),
      );
      if (mounted) {
        context.push(
          '/post/${post.id}',
          extra: post,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(fieldsProvider);

    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SectionHeader(title: 'Brief'),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Intent type'),
                    items: const [
                      DropdownMenuItem(
                        value: 'looking_vendor',
                        child: Text('Looking for vendor'),
                      ),
                      DropdownMenuItem(
                        value: 'open_project',
                        child: Text('Open project'),
                      ),
                      DropdownMenuItem(
                        value: 'collaboration',
                        child: Text('Collaboration'),
                      ),
                      DropdownMenuItem(
                        value: 'offer_service',
                        child: Text('Offering service'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _type = value ?? _type),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'e.g. Boutique store rebrand with Shopify launch',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AppTextArea(
                    controller: _descriptionController,
                    label: 'Describe the intent',
                    hint: 'Share context, goals, and success measures.',
                    maxLines: 6,
                    validator: (value) =>
                        value == null || value.length < 12
                            ? 'Share at least a short brief'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  const SectionHeader(title: 'Details'),
                  DropdownButtonFormField<String>(
                    value: _compType,
                    decoration: const InputDecoration(labelText: 'Compensation'),
                    items: const [
                      DropdownMenuItem(
                        value: 'paid',
                        child: Text('Paid'),
                      ),
                      DropdownMenuItem(
                        value: 'rev_share',
                        child: Text('Revenue share'),
                      ),
                      DropdownMenuItem(
                        value: 'negotiable',
                        child: Text('Negotiable'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _compType = value ?? _compType),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  AppTextField(
                    controller: _timelineController,
                    label: 'Timeline / urgency',
                    hint: 'e.g. Kickoff in 2 weeks, launch by Q3',
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'Relevant fields',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  fields.when(
                    data: (items) => Wrap(
                      spacing: AppSpacing.s8,
                      runSpacing: AppSpacing.s8,
                      children: items
                          .map((field) => _FieldChip(
                                field: field,
                                selected: _selectedFields.contains(field.id),
                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      _selectedFields.add(field.id);
                                    } else {
                                      _selectedFields.remove(field.id);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                    error: (error, _) => Text('Could not load fields: $error'),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  PrimaryButton(
                    label: 'Publish intent',
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldChip extends StatelessWidget {
  const _FieldChip({
    required this.field,
    required this.selected,
    required this.onSelected,
  });

  final Field field;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(field.name),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
