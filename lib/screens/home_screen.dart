import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:life_auctor/widgets/buttons/quick_actions.dart';
import 'package:life_auctor/widgets/nav_bar.dart/app_bar.dart';
import 'package:life_auctor/widgets/product_summary.dart';
import 'package:life_auctor/widgets/guest_banner.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildMenuItem(
    BuildContext context, {
    required String assetPath,
    required String label,
    required VoidCallback onTap,
    required double iconSize,
    required double fontSize,
    required double containerPadding,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey,
                ),
              ),
              child: SvgPicture.asset(
                assetPath,
                height: iconSize,
                width: iconSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: containerPadding * 0.8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final horizontalPadding = width * 0.04;
            final verticalPadding = width * 0.025;
            final welcomeTextSize = width * 0.038;
            final iconSize = width * 0.18;
            final menuFontSize = width * 0.032;
            final containerPadding = width * 0.02;
            final crossAxisSpacing = width * 0.003;
            // Vertical spacing
            final mainAxisSpacing = width * 0.06;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding * 1.5,
                        vertical: verticalPadding * 1.2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A1E)
                            : const Color(0xffE8F5E9),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(
                        'Welcome to LifeAuctor! Your personal assistant is in touch!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: welcomeTextSize,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding * 0.5,
                    ),
                    child: const GuestBanner(
                      message: 'Sign up to sync your data across devices and access all features!',
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding * 0.8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ScanItemButton(onNavigate: widget.onNavigate),
                        ),
                        SizedBox(width: horizontalPadding * 0.8),
                        Expanded(
                          child: AddNewItemButton(
                            onNavigate: widget.onNavigate,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding * 0.6,
                    ),
                    child: ProductSummaryCard(),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuItem(
                                context,
                                assetPath: 'assets/images/my_items.svg',
                                label: 'My Items',
                                iconSize: iconSize,
                                fontSize: menuFontSize,
                                containerPadding: containerPadding,
                                onTap: () {
                                  widget.onNavigate?.call(4);
                                },
                              ),
                            ),
                            SizedBox(width: crossAxisSpacing),
                            Expanded(
                              child: _buildMenuItem(
                                context,
                                assetPath: 'assets/images/shopping_list.svg',
                                label: 'Shopping List',
                                iconSize: iconSize,
                                fontSize: menuFontSize,
                                containerPadding: containerPadding,
                                onTap: () {
                                  widget.onNavigate?.call(10);
                                },
                              ),
                            ),
                            SizedBox(width: crossAxisSpacing),
                            Expanded(
                              child: _buildMenuItem(
                                context,
                                assetPath: 'assets/images/barcode.svg',
                                label: 'Barcode Scanner',
                                iconSize: iconSize,
                                fontSize: menuFontSize,
                                containerPadding: containerPadding,
                                onTap: () {
                                  widget.onNavigate?.call(5);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: mainAxisSpacing),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuItem(
                                context,
                                assetPath: 'assets/images/community.svg',
                                label: 'Community',
                                iconSize: iconSize,
                                fontSize: menuFontSize,
                                containerPadding: containerPadding,
                                onTap: () {
                                  widget.onNavigate?.call(7);
                                },
                              ),
                            ),
                            SizedBox(width: crossAxisSpacing),
                            Expanded(
                              child: _buildMenuItem(
                                context,
                                assetPath: 'assets/images/analytics.svg',
                                label: 'Analytics',
                                iconSize: iconSize,
                                fontSize: menuFontSize,
                                containerPadding: containerPadding,
                                onTap: () {
                                  widget.onNavigate?.call(8);
                                },
                              ),
                            ),
                            SizedBox(width: crossAxisSpacing),
                            Expanded(
                              child: _buildMenuItem(
                                context,
                                assetPath: 'assets/images/history.svg',
                                label: 'History',
                                iconSize: iconSize,
                                fontSize: menuFontSize,
                                containerPadding: containerPadding,
                                onTap: () {
                                  widget.onNavigate?.call(9);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
