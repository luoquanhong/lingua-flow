import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 48, height: 48,
        child: CircularProgressIndicator(strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary.withOpacity(0.7))))),
      if (message != null) ...[
        const SizedBox(height: 16),
        Text(message!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
      ],
    ]));
  }
}

class ShimmerLoadingWidget extends StatelessWidget {
  final int itemCount;
  const ShimmerLoadingWidget({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(baseColor: AppColors.divider, highlightColor: AppColors.surface, child: ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMd), itemCount: itemCount,
      itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(bottom: AppSizes.paddingSm),
        child: Container(height: 72, decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd))))));
  }
}
