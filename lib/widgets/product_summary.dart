import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/screens/analytics_screen.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:life_auctor/utils/app_strings.dart';
import 'package:life_auctor/utils/theme_extensions.dart';

class ProductSummaryCard extends StatelessWidget {
  const ProductSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<ItemProviderV3>(
      builder: (context, itemProvider, child) {
        final totalItems = itemProvider.totalItems;
        final expiringSoonCount = itemProvider.expiringSoon;
        final expiredCount = itemProvider.expired;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
            vertical: AppConstants.spacing8,
          ),
          padding: EdgeInsets.all(AppConstants.spacing16),
          decoration: BoxDecoration(
            color: context.adaptiveBackgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.summaryCardBorderRadius),
            border: Border.all(color: context.adaptiveBorderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.productSummaryTitle,
                style: TextStyle(
                  fontSize: AppConstants.fontSize14,
                  fontWeight: FontWeight.w500,
                  color: context.adaptiveTextColor,
                ),
              ),
              SizedBox(height: AppConstants.spacing12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildItem(context, '$totalItems', AppStrings.productSummaryTotally, Colors.green.shade200),
                  _buildItem(context, '$expiringSoonCount', AppStrings.productSummaryExpireSoon, Colors.yellow.shade200),
                  _buildItem(context, '$expiredCount', AppStrings.productSummaryExpired, Colors.pink.shade200),
                ],
              ),
              SizedBox(height: AppConstants.spacing8),

              // see more
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
                    );
                  },
                  child: Text(
                    AppStrings.productSummarySeeMore,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: context.adaptiveIconColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(BuildContext context, String number, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppConstants.summaryItemWidth,
          height: AppConstants.summaryItemHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppConstants.summaryItemBorderRadius),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: AppConstants.fontSize16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        SizedBox(height: AppConstants.spacing6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSize11,
            color: context.adaptiveSecondaryTextColor,
          ),
        ),
      ],
    );
  }
}
