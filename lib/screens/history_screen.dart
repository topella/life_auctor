import 'package:flutter/material.dart';
import 'package:life_auctor/utils/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:life_auctor/providers/history_provider.dart';
import 'package:life_auctor/models/history_event.dart';
import 'package:life_auctor/widgets/nav_bar/app_bar.dart';

// Helper function to group events by date
Map<String, List<HistoryEvent>> _groupEventsByDate(List<HistoryEvent> events) {
  final grouped = <String, List<HistoryEvent>>{};
  for (var event in events) {
    grouped.putIfAbsent(event.dateGroup, () => []).add(event);
  }
  return grouped;
}

// Event style configuration
class _EventStyleConfig {
  final IconData icon;
  final Color iconColor;

  const _EventStyleConfig(this.icon, this.iconColor);

  Color get backgroundColor => iconColor.withValues(alpha: 0.1);

  static const _configs = {
    HistoryEventType.addedItem: _EventStyleConfig(
      Icons.add_circle_outline,
      Colors.green,
    ),
    HistoryEventType.scannedBarcode: _EventStyleConfig(
      Icons.qr_code_scanner,
      Colors.blue,
    ),
    HistoryEventType.itemExpired: _EventStyleConfig(Icons.cancel, Colors.red),
    HistoryEventType.createdList: _EventStyleConfig(
      Icons.list_alt,
      Colors.purple,
    ),
    HistoryEventType.outOfStock: _EventStyleConfig(
      Icons.inventory_2_outlined,
      Colors.orange,
    ),
  };

  static _EventStyleConfig get(HistoryEventType type) => _configs[type]!;
}

// Theme configuration for responsive sizing and styling
class _HistoryTheme {
  final double width;
  final bool isDark;

  _HistoryTheme(this.width, this.isDark);

  // Sizes
  double get padding => width * 0.04;
  double get titleSize => width * 0.072;
  double get filterButtonSize => width * 0.037;
  double get searchBarHeight => width * 0.11;
  double get searchFontSize => width * 0.037;
  double get searchIconSize => width * 0.063;
  double get groupTitleSize => width * 0.045;
  double get eventTitleSize => width * 0.04;
  double get eventSubtitleSize => width * 0.035;
  double get eventTimeSize => width * 0.032;
  double get iconSize => width * 0.08;

  // Colors
  Color get backgroundColor =>
      isDark ? const Color(0xFF121212) : Colors.grey[100]!;
  Color get cardColor => isDark ? Colors.grey[850]! : Colors.white;
  Color get textColor => isDark ? Colors.white : Colors.black87;
  Color get subtitleColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;

  // Text Styles
  TextStyle get titleStyle => TextStyle(
    fontSize: titleSize,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  TextStyle get groupTitleStyle => TextStyle(
    fontSize: groupTitleSize,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  TextStyle get eventTitleStyle => TextStyle(
    fontSize: eventTitleSize,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  TextStyle get eventSubtitleStyle => TextStyle(
    fontSize: eventSubtitleSize,
    color: subtitleColor,
  );

  TextStyle get eventTimeStyle => TextStyle(
    fontSize: eventTimeSize,
    color: Colors.grey,
  );

  TextStyle get emptyTextStyle => TextStyle(
    fontSize: eventTitleSize,
    color: isDark ? Colors.grey : Colors.grey[600],
  );
}

class HistoryScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final VoidCallback? onBack;

  const HistoryScreen({super.key, this.onNavigate, this.onBack});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Items', 'Lists'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: CustomAppBar(showBackButton: true, onBack: widget.onBack),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onNavigate?.call(6),
        backgroundColor: AppConstants.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final theme = _HistoryTheme(constraints.maxWidth, isDark);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: theme.padding),
                  _SearchBar(theme: theme),
                  SizedBox(height: theme.padding),
                  Text('History', style: theme.titleStyle),
                  SizedBox(height: theme.padding),
                  _FilterButtons(
                    filters: _filters,
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filter) =>
                        setState(() => _selectedFilter = filter),
                    theme: theme,
                  ),
                  SizedBox(height: theme.padding),
                  Expanded(
                    child: _buildContent(historyProvider, theme),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(HistoryProvider provider, _HistoryTheme theme) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryGreen),
      );
    }

    if (provider.events.isEmpty) {
      return Center(
        child: Text('No history yet', style: theme.emptyTextStyle),
      );
    }

    final groupedEvents = _groupEventsByDate(provider.events);
    return _EventsList(grouped: groupedEvents, theme: theme);
  }
}

// Search Bar Widget
class _SearchBar extends StatelessWidget {
  final _HistoryTheme theme;

  const _SearchBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: theme.searchBarHeight,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.padding),
      ),
      padding: EdgeInsets.symmetric(horizontal: theme.padding),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey, size: theme.searchIconSize),
          SizedBox(width: theme.padding * 0.5),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: theme.searchFontSize,
                color: theme.textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Search history...',
                hintStyle: TextStyle(
                  fontSize: theme.searchFontSize,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(
            Icons.filter_list,
            color: Colors.grey,
            size: theme.searchIconSize,
          ),
        ],
      ),
    );
  }
}

// Filter Buttons Widget
class _FilterButtons extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final _HistoryTheme theme;

  const _FilterButtons({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.padding * 0.25),
          child: GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: theme.padding,
                vertical: theme.padding * 0.4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryGreen
                    : (theme.isDark ? Colors.grey[800] : Colors.white),
                borderRadius: BorderRadius.circular(theme.padding * 1.5),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: theme.filterButtonSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (theme.isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Events List Widget
class _EventsList extends StatelessWidget {
  final Map<String, List<HistoryEvent>> grouped;
  final _HistoryTheme theme;

  const _EventsList({required this.grouped, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped.keys.elementAt(index);
        final groupEvents = grouped[group]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: theme.padding * 0.5,
                top: theme.padding * 0.5,
              ),
              child: Text(group, style: theme.groupTitleStyle),
            ),
            ...groupEvents.map(
              (event) => _EventTile(event: event, theme: theme),
            ),
          ],
        );
      },
    );
  }
}

// Event Tile Widget
class _EventTile extends StatelessWidget {
  final HistoryEvent event;
  final _HistoryTheme theme;

  const _EventTile({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    final style = _EventStyleConfig.get(event.type);

    return Container(
      margin: EdgeInsets.only(bottom: theme.padding),
      padding: EdgeInsets.all(theme.padding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(theme.padding),
      ),
      child: Row(
        children: [
          Container(
            width: theme.iconSize,
            height: theme.iconSize,
            decoration: BoxDecoration(
              color: style.backgroundColor,
              borderRadius: BorderRadius.circular(theme.padding * 0.8),
            ),
            child: Icon(
              style.icon,
              color: style.iconColor,
              size: theme.iconSize * 0.6,
            ),
          ),
          SizedBox(width: theme.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: theme.eventTitleStyle),
                if (event.subtitle != null) ...[
                  SizedBox(height: theme.padding * 0.2),
                  Text(event.subtitle!, style: theme.eventSubtitleStyle),
                ],
              ],
            ),
          ),
          Text(event.timeString, style: theme.eventTimeStyle),
        ],
      ),
    );
  }
}
