import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lcr/configs/context.dart';
import 'package:lcr/screens/components/comic_image_provider.dart';
import 'package:lcr/src/rust/api/backend.dart';

class ComicCard extends StatelessWidget {
  final ComicInfo comic;
  final Function(ComicInfo comic)? onPressCard;
  final Function(ComicInfo comic)? onEdit;
  final Function(ComicInfo comic)? onStarModify;
  final Function(ComicInfo comic)? onLongPress;

  const ComicCard({
    super.key,
    required this.comic,
    this.onPressCard,
    this.onEdit,
    this.onStarModify,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(child: _inner(context));
  }

  Widget _inner(BuildContext context) {
    return InkWell(
      onTap: () => onPressCard?.call(comic),
      onLongPress: () => onLongPress?.call(comic),
      child: Container(
        margin: EdgeInsets.all(listGridGap),
        child: _row(context),
      ),
    );
  }

  Widget _row(BuildContext context) {
    late Widget image;
    if (comic.cover.isEmpty) {
      image = Image.asset(
        "assets/cover_placeholder.png",
        width: coverWidth,
        height: coverHeight,
        fit: BoxFit.cover,
      );
    } else {
      image = Image(
        image: comicImageProvider(comicId: comic.id, path: comic.cover),
        width: coverWidth,
        height: coverHeight,
        fit: BoxFit.cover,
      );
    }

    return Row(
      children: [
        Container(
          width: coverWidth,
          height: coverHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(coverRadius),
          ),
          margin: EdgeInsets.only(right: listGridGap),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(coverRadius)),
            child: image,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: listGridGap),
            constraints: BoxConstraints(maxHeight: coverHeight),
            child: _info(context),
          ),
        ),
        Container(
          constraints: BoxConstraints(maxHeight: coverHeight),
          child: _flags(context),
        ),
      ],
    );
  }

  Widget _info(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comic.title,
          style: cardTitleStyle(theme),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),
        if (comic.author.isNotEmpty)
          Text(
            comic.author,
            style: cardAuthorStyle(theme),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(height: 8),
        if (comic.tags.isNotEmpty)
          Text(
            comic.tags.join(", "),
            style: cardTagStyle(theme),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Spacer(),
        if (comic.lastReadTime > 0 && comic.lastReadChapterId.isNotEmpty)
          Text(
            "${_formatLastRead()}\n${comic.lastReadChapterTitle} (P ${comic.lastReadPageIndex + 1})",
            style: cardLogStyle(theme),
          ),
      ],
    );
  }

  String _formatLastRead() {
    if (comic.lastReadTime <= 0) {
      return "";
    }
    final date = DateTime.fromMillisecondsSinceEpoch(comic.lastReadTime * 1000);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
    return formattedDate;
  }

  Widget _flags(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (onEdit != null)
          Container(
            margin: EdgeInsets.only(bottom: cardIconMargin),
            child: IconButton(
              icon: Icon(Icons.edit, size: cardIconSize, color: Colors.grey),
              onPressed: () => onEdit?.call(comic),
            ),
          ),
        if (onStarModify != null)
          Container(
            margin: EdgeInsets.only(bottom: cardIconMargin),
            child: IconButton(
              icon: Icon(
                comic.star ? Icons.star : Icons.star_border,
                size: cardIconSize,
                color: Colors.amber,
              ),
              onPressed: () => onStarModify?.call(comic),
            ),
          ),
        Spacer(),
      ],
    );
  }
}
