import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/screens/characterscreen.dart';
import 'package:dailyanimelist/widgets/avatarwidget.dart';
import 'package:dal_commons/commons.dart';
import 'package:flutter/material.dart';

import '../main.dart';

/// A reusable widget that displays a character with their voice actors.
/// - If there's only 1 VA: Shows character on left, VA on right (no accordion)
/// - If there are multiple VAs: Shows accordion with horizontally scrollable VAs
class CharacterVATile extends StatelessWidget {
  final int? characterId;
  final String? characterImage;
  final String characterName;
  final String characterRole;
  final int? favorites;
  final List<StaffInfoList> staffList;

  const CharacterVATile({
    super.key,
    this.characterId,
    this.characterImage,
    required this.characterName,
    required this.characterRole,
    this.favorites,
    required this.staffList,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultipleVAs = staffList.length > 1;
    final hasSingleVA = staffList.length == 1;

    if (hasMultipleVAs) {
      return _buildAccordionTile(context);
    }
    return _buildSimpleTile(context, hasSingleVA);
  }

  Widget _buildAccordionTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8, bottom: 8),
          leading: _buildCharacterWidget(characterId, characterImage),
          title: _buildCharacterInfo(context),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${staffList.length} VAs',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          children: [
            _buildHorizontalVAList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalVAList(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: staffList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final staff = staffList[index];
          return _buildVACard(context, staff);
        },
      ),
    );
  }

  Widget _buildVACard(BuildContext context, StaffInfoList staff) {
    return GestureDetector(
      onTap: () {
        if (staff.id != null) {
          gotoPage(
            context: context,
            newPage: CharacterScreen(
              id: staff.id!,
              charaCategory: "seiyuu",
            ),
          );
        }
      },
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AvatarWidget(
                userRoundBorderforLoading: false,
                height: 60,
                width: 60,
                radius: BorderRadius.circular(8),
                url: staff.image?.large ?? staff.image?.medium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              staff.name ?? 'Unknown',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              staff.language ?? '',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTile(BuildContext context, bool hasSingleVA) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                _buildCharacterWidget(characterId, characterImage),
                const SizedBox(width: 10),
                Expanded(child: _buildCharacterInfo(context)),
              ],
            ),
          ),
          if (hasSingleVA)
            Expanded(
              child: _buildSingleVAWidget(context, staffList.first),
            )
        ],
      ),
    );
  }

  Widget _buildSingleVAWidget(BuildContext context, StaffInfoList staff) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                staff.name ?? 'Unknown',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              if (staff.language?.isNotEmpty ?? false)
                Text(
                  staff.language!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildSeiyuuWidget(
          staff.id,
          staff.image?.large ?? staff.image?.medium,
        ),
      ],
    );
  }

  Widget _buildCharacterInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          characterName,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        if (characterRole.isNotEmpty)
          Text(
            characterRole,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        const SizedBox(height: 5),
        if (favorites != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
              const SizedBox(width: 5),
              Text(
                favorites.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCharacterWidget(int? id, String? imageUrl) {
    final borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    );
    return Material(
      color: Colors.transparent,
      elevation: 4,
      borderRadius: borderRadius,
      child: AvatarWidget(
        userRoundBorderforLoading: false,
        height: 80,
        width: 60,
        onTap: () {
          if (id != null) {
            gotoPage(
              context: MyApp.navigatorKey.currentContext!,
              newPage: CharacterScreen(id: id, charaCategory: "character"),
            );
          }
        },
        radius: borderRadius,
        url: imageUrl,
      ),
    );
  }

  Widget _buildSeiyuuWidget(int? id, String? imageUrl) {
    final borderRadius = const BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    );
    return Material(
      color: Colors.transparent,
      elevation: 4,
      borderRadius: borderRadius,
      child: AvatarWidget(
        userRoundBorderforLoading: false,
        height: 80,
        width: 60,
        onTap: () {
          if (id != null) {
            gotoPage(
              context: MyApp.navigatorKey.currentContext!,
              newPage: CharacterScreen(
                id: id,
                charaCategory: "seiyuu",
              ),
            );
          }
        },
        radius: borderRadius,
        url: imageUrl,
      ),
    );
  }
}
