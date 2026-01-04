import 'package:flutter/material.dart';

import '../../../features/feed/domain/post.dart';
import '../../../features/profile/domain/profile.dart';
import '../tokens.dart';
import 'badges.dart';
import 'buttons.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onView,
    required this.onPrimaryAction,
    required this.primaryLabel,
  });

  final Post post;
  final VoidCallback onView;
  final VoidCallback onPrimaryAction;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    final metaStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TypeBadge(type: post.type),
                Text(
                  '${post.createdAt.toLocal().toString().split(' ').first}',
                  style: metaStyle,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              post.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s12),
            Wrap(
              spacing: AppSpacing.s12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Timeline: ${post.timeline}', style: metaStyle),
                Text('Comp: ${post.compensationType}', style: metaStyle),
                if (post.fields.isNotEmpty)
                  Text(
                    'Fields: ${post.fields.take(2).join(", ")}',
                    style: metaStyle,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GhostButton(label: 'View', onPressed: onView),
                const SizedBox(width: AppSpacing.s12),
                PrimaryButton(label: primaryLabel, onPressed: onPrimaryAction),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials =
        profile.displayName.isNotEmpty
            ? profile.displayName.trim()[0].toUpperCase()
            : '?';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(initials)),
        title: Text(
          profile.displayName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.role),
            if (profile.location != null)
              Text(
                profile.location!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (profile.bio != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s4),
                child: Text(
                  profile.bio!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
