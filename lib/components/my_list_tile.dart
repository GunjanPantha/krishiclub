import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final String imageUrl;
  final VoidCallback? onTap;

  const MyListTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.imageUrl = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: imageUrl.isNotEmpty
              ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
              : null,
          title: Text(title),
          subtitle: Text(
            subTitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
