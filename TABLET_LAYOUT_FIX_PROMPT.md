# DailyAL Tablet Layout Enhancement Prompt

## 🎯 Overview
Fix stretched and broken UI elements on tablet devices in the DailyAL Flutter app. Implement Material 3 responsive design patterns with dual-page layouts for optimal tablet experience.

---

## 📋 Current Issues

### Critical Problems
1. **UI Element Stretching**: Many widgets appear stretched on tablet screens (≥600dp width)
2. **Alignment Issues**: Elements are improperly aligned causing visual inconsistency
3. **Half-Cut Elements**: Some UI components are partially visible/truncated
4. **Poor Poster Display**: Anime/manga posters don't scale properly and look disproportionate
5. **Single-Column Layout**: Phone layout is stretched on tablets instead of using available screen real estate

### Affected Screens
- **Primary**: `contentdetailedscreen.dart` (anime/manga details)
- **Secondary**: `homescreen.dart`, `homepage.dart`, and other main screens
- **Widgets**: Poster cards, character lists, recommendation widgets, synopsis sections

---

## 🎨 Design Requirements

### 1. Material 3 Responsive Breakpoints
Implement proper breakpoints following Material Design guidelines:

```dart
// Screen size classification
enum ScreenSize {
  compact,      // 0-599dp (phones)
  medium,       // 600-839dp (small tablets, foldables)
  expanded,     // 840-1199dp (large tablets)
  large,        // 1200-1599dp (desktops)
  extraLarge,   // 1600dp+ (ultra-wide)
}

// Breakpoint detection
bool get isCompact => MediaQuery.of(context).size.width < 600;
bool get isMedium => MediaQuery.of(context).size.width >= 600 && 
                     MediaQuery.of(context).size.width < 840;
bool get isExpanded => MediaQuery.of(context).size.width >= 840 &&
                       MediaQuery.of(context).size.width < 1200;
bool get isLarge => MediaQuery.of(context).size.width >= 1200;
```

### 2. Dual-Page Layout for Content Details

#### A. Anime/Manga Details Screen Layout

**Left Pane (Fixed/Primary - 30-40% width):**
- Hero image/poster (properly sized with aspect ratio)
- Title (with language toggle: Romaji/English/Native)
- Score and ranking badges
- Synopsis (scrollable if long)
- Key metadata:
  - Type, Episodes, Status, Season
  - Aired dates, Producers, Studios
  - Genres (with chips/tags)
  - Source, Rating, Duration
- Quick actions (Add to List, Share, Open in Browser)
- Statistics summary

**Right Pane (Scrollable/Secondary - 60-70% width):**
- Tabbed interface with:
  - **Characters & Staff**: Horizontal scrollable character cards with VA info
  - **Episodes**: Episode list with thumbnails and air dates
  - **Reviews**: User reviews with ratings
  - **Recommendations**: Related anime/manga suggestions
  - **Related**: Sequels, prequels, adaptations
  - **Media**: Videos, promos, opening/ending songs
  - **News & Articles**: Latest news and featured articles
  - **User Updates**: Recent status updates from friends
  - **Forums**: Discussion topics
  - **Pictures**: Gallery view
  - **Stats**: Detailed statistics and graphs

#### B. Layout Behavior
```dart
// Responsive layout switching
Widget build(BuildContext context) {
  if (isCompact) {
    return _buildCompactLayout(); // Single column, full screen
  } else if (isMedium) {
    return _buildMediumLayout(); // Split view with collapsible left pane
  } else {
    return _buildExpandedLayout(); // Full dual-pane with resizable divider
  }
}
```

### 3. Adaptive Component Sizing

#### Character Screen Specifics
- **Split Layout**: Use a `Row` with a fixed-width left panel (400px) and flexible right panel.
- **Dynamic Background**: Use a `Stack` to place a `Background` widget behind the content.
- **Carousel Sync**: Sync the background image with the carousel's current index.

#### Forum Screen Specifics
- **Master-Detail Layout**: Use `Row` with 350px width for topic list (Master) and Expanded for posts (Detail).
- **Navigation Override**: On tablets, selecting a topic updates the right pane instead of pushing a new route.

#### Poster/Image Cards
```dart
// Adaptive poster dimensions
double getPosterWidth(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 600) return 120; // Phone
  if (screenWidth < 840) return 160; // Small tablet
  if (screenWidth < 1200) return 200; // Large tablet
  return 240; // Desktop
}

double getPosterHeight(BuildContext context) {
  return getPosterWidth(context) * 1.4; // Maintain 1:1.4 aspect ratio
}

// Grid layout adaptation
int getCrossAxisCount(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 600) return 3; // Phone: 3 columns
  if (screenWidth < 840) return 4; // Small tablet: 4 columns
  if (screenWidth < 1200) return 5; // Large tablet: 5 columns
  return 6; // Desktop: 6 columns
}
```

#### Character Cards
```dart
// Character list layout
Widget buildCharacterList(BuildContext context) {
  final isTablet = MediaQuery.of(context).size.width >= 600;
  
  return isTablet
      ? GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns on tablet
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3, // Wider cards
          ),
          itemBuilder: (context, index) => CharacterCard(character: characters[index]),
        )
      : ListView.builder(
          itemBuilder: (context, index) => CharacterCard(character: characters[index]),
        );
}
```

---

## 🛠️ Implementation Guide

### Phase 1: Core Infrastructure

#### 1.1 Create Responsive Helper Class
```dart
// lib/util/responsive_helper.dart
class ResponsiveHelper {
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.compact;
    if (width < 840) return ScreenSize.medium;
    if (width < 1200) return ScreenSize.expanded;
    if (width < 1600) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }
  
  static bool isTabletOrLarger(BuildContext context) {
    return getScreenSize(context).index >= ScreenSize.medium.index;
  }
  
  static double getHorizontalPadding(BuildContext context) {
    final size = getScreenSize(context);
    return switch (size) {
      ScreenSize.compact => 12.0,
      ScreenSize.medium => 16.0,
      ScreenSize.expanded => 24.0,
      ScreenSize.large => 32.0,
      ScreenSize.extraLarge => 40.0,
    };
  }
  
  static EdgeInsets getContentPadding(BuildContext context) {
    final horizontalPadding = getHorizontalPadding(context);
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 16.0,
    );
  }
}
```

#### 1.2 Create Adaptive Layout Builder
```dart
// lib/widgets/common/adaptive_layout.dart
class AdaptiveLayout extends StatelessWidget {
  final Widget Function(BuildContext) compactBuilder;
  final Widget Function(BuildContext)? mediumBuilder;
  final Widget Function(BuildContext)? expandedBuilder;
  
  const AdaptiveLayout({
    required this.compactBuilder,
    this.mediumBuilder,
    this.expandedBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    
    return switch (screenSize) {
      ScreenSize.compact => compactBuilder(context),
      ScreenSize.medium => (mediumBuilder ?? compactBuilder)(context),
      _ => (expandedBuilder ?? mediumBuilder ?? compactBuilder)(context),
    };
  }
}
```

### Phase 2: Content Detail Screen Refactoring

#### 2.1 Update `contentdetailedscreen.dart`

**Current Issues in File:**
- Lines 129-144: Basic tablet detection exists but needs expansion
- Lines 894-1100: Tablet layout partially implemented but needs improvement
- Fixed width left panel (_leftPanelWidth = 500.0) doesn't adapt to different tablet sizes

**Required Changes:**

1. **Enhanced Screen Size Detection**
```dart
// Replace existing _isTablet, _isLargeTablet properties with:
ScreenSize get _screenSize => ResponsiveHelper.getScreenSize(context);
bool get _isCompact => _screenSize == ScreenSize.compact;
bool get _isMedium => _screenSize == ScreenSize.medium;
bool get _isExpanded => _screenSize.index >= ScreenSize.expanded.index;

// Adaptive panel widths
double get _leftPanelWidth {
  final screenWidth = MediaQuery.of(context).size.width;
  return switch (_screenSize) {
    ScreenSize.medium => screenWidth * 0.35,      // 35% on small tablets
    ScreenSize.expanded => screenWidth * 0.40,    // 40% on large tablets
    ScreenSize.large => 480.0,                     // Fixed 480px on desktop
    ScreenSize.extraLarge => 560.0,               // Fixed 560px on ultra-wide
    _ => screenWidth,                              // Full width on phones
  };
}

double get _maxLeftPanelWidth {
  return switch (_screenSize) {
    ScreenSize.medium => 320.0,
    ScreenSize.expanded => 500.0,
    _ => 600.0,
  };
}

double get _minLeftPanelWidth => 280.0;
```

2. **Improve Left Pane Content**
```dart
// Refactor _buildTabletLayout() left pane section:
Widget _buildLeftPane() {
  return SizedBox(
    width: _leftPanelWidth,
    child: Material(
      elevation: 2,
      child: CustomScrollView(
        slivers: [
          _buildLeftPaneAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: ResponsiveHelper.getContentPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image with proper aspect ratio
                  _buildHeroImage(),
                  SB.h16,
                  
                  // Title Section
                  _buildTitleSection(),
                  SB.h12,
                  
                  // Score & Ranking Badges
                  _buildScoreSection(),
                  SB.h16,
                  
                  // Quick Stats Chips
                  _buildQuickStats(),
                  SB.h16,
                  
                  // Synopsis (collapsible if long)
                  _buildSynopsisSection(),
                  SB.h16,
                  
                  // Genres
                  _buildGenreChips(),
                  SB.h16,
                  
                  // More Info Section
                  _buildDetailedInfo(),
                  SB.h16,
                  
                  // Quick Actions
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildHeroImage() {
  final imageWidth = _leftPanelWidth - (ResponsiveHelper.getHorizontalPadding(context) * 2);
  final imageHeight = imageWidth * 1.4; // Maintain aspect ratio
  
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: CachedNetworkImage(
      imageUrl: _url,
      width: imageWidth,
      height: imageHeight,
      fit: BoxFit.cover,
      placeholder: (context, url) => ShimmerWidget(
        width: imageWidth,
        height: imageHeight,
      ),
    ),
  );
}
```

3. **Enhance Right Pane with Better Tab Bar**
```dart
Widget _buildRightPane() {
  return Expanded(
    child: Material(
      elevation: 1,
      child: Stack(
        children: [
          CustomScrollView(
            controller: _autoScrollController,
            slivers: [
              // Sticky TabBar
              SliverAppBar(
                pinned: true,
                floating: true,
                automaticallyImplyLeading: false,
                title: Text(
                  animeTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                bottom: _buildAdaptiveTabBar(),
                actions: _buildAppBarActions(),
              ),
              
              // Tabbed Content
              _buildRightPaneContent(),
              
              SB.lh80,
            ],
          ),
          
          // Floating Edit Widget
          if (showContentEdit) _buildFloatingEditWidget(),
        ],
      ),
    ),
  );
}

PreferredSizeWidget _buildAdaptiveTabBar() {
  // Use scrollable tabs on smaller tablets, fixed on larger screens
  final isScrollable = _screenSize.index <= ScreenSize.medium.index;
  
  return TabBar(
    controller: _tabController,
    isScrollable: isScrollable,
    tabs: visibleTabSections.map((title) => Tab(text: title)).toList(),
    indicatorSize: TabBarIndicatorSize.tab,
    labelStyle: Theme.of(context).textTheme.labelLarge,
  );
}
```

4. **Resizable Divider Enhancement**
```dart
Widget _buildResizableDivider() {
  return MouseRegion(
    cursor: SystemMouseCursors.resizeColumn,
    child: GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          final newWidth = _leftPanelWidth + details.delta.dx;
          _leftPanelWidth = newWidth.clamp(
            _minLeftPanelWidth,
            _maxLeftPanelWidth,
          );
        });
      },
      child: Container(
        width: 8,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1,
            ),
            right: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ),
  );
}
```

### Phase 3: Widget Adaptations

#### 3.1 Poster/Card Widgets
Update all anime/manga card widgets to use adaptive sizing:

```dart
// lib/widgets/home/anime_card.dart (or similar)
class AdaptiveAnimeCard extends StatelessWidget {
  final Node node;
  
  @override
  Widget build(BuildContext context) {
    final posterWidth = ResponsiveHelper.getPosterWidth(context);
    final posterHeight = posterWidth * 1.4;
    
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image with fixed aspect ratio
            SizedBox(
              width: posterWidth,
              height: posterHeight,
              child: CachedNetworkImage(
                imageUrl: node.mainPicture?.large ?? '',
                fit: BoxFit.cover,
              ),
            ),
            
            // Title Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    node.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (node.meanScore != null) ...[
                    SB.h4,
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SB.w4,
                        Text(
                          node.meanScore!.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 3.2 Character List Widget
```dart
// lib/pages/animedetailed/animecharacterwidget.dart
Widget build(BuildContext context) {
  final isTablet = ResponsiveHelper.isTabletOrLarger(context);
  final crossAxisCount = isTablet ? 2 : 1;
  
  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    padding: ResponsiveHelper.getContentPadding(context),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isTablet ? 3.5 : 4.5,
    ),
    itemCount: animeCharacterList.length,
    itemBuilder: (context, index) {
      final character = animeCharacterList[index];
      return _buildCharacterCard(context, character, isTablet);
    },
  );
}

Widget _buildCharacterCard(BuildContext context, CharacterHtml character, bool isTablet) {
  final imageSize = isTablet ? 80.0 : 60.0;
  
  return Card(
    child: InkWell(
      onTap: () => _navigateToCharacter(context, character),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Character Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: character.imageUrl ?? '',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
            SB.w12,
            
            // Character Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    character.name ?? '',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (character.role != null) ...[
                    SB.h4,
                    Text(
                      character.role!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                  if (isTablet && character.voiceActor != null) ...[
                    SB.h8,
                    Row(
                      children: [
                        Icon(Icons.mic, size: 14),
                        SB.w4,
                        Expanded(
                          child: Text(
                            character.voiceActor!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Phase 4: Homepage Adaptations

#### 4.1 Update `homepage.dart`
```dart
// lib/pages/homepage.dart
Widget build(BuildContext context) {
  final isTablet = ResponsiveHelper.isTabletOrLarger(context);
  
  return CustomScrollView(
    controller: scrollController,
    slivers: [
      // Adaptive App Bar
      HomeAppBar(isTablet: isTablet),
      
      // Content based on screen size
      if (isTablet)
        _buildTabletHomeContent()
      else
        _buildPhoneHomeContent(),
    ],
  );
}

Widget _buildTabletHomeContent() {
  return SliverPadding(
    padding: ResponsiveHelper.getContentPadding(context),
    sliver: SliverList(
      delegate: SliverChildListDelegate([
        // Featured Section - Full Width
        _buildFeaturedSection(),
        SB.h24,
        
        // Two Column Layout for content sections
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (60%)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _buildAnimeListSection(),
                  SB.h24,
                  _buildMangaListSection(),
                  SB.h24,
                  _buildRankingSection(),
                ],
              ),
            ),
            SB.w24,
            
            // Right Column (40%)
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildNewsSection(),
                  SB.h24,
                  _buildForumSection(),
                  SB.h24,
                  _buildSeasonalSection(),
                ],
              ),
            ),
          ],
        ),
      ]),
    ),
  );
}
```

#### 4.2 Adaptive Grid Layouts
```dart
// For recommendation widgets, seasonal anime, etc.
Widget _buildAdaptiveGrid(List<Node> items) {
  final screenSize = ResponsiveHelper.getScreenSize(context);
  
  final crossAxisCount = switch (screenSize) {
    ScreenSize.compact => 3,
    ScreenSize.medium => 4,
    ScreenSize.expanded => 5,
    ScreenSize.large => 6,
    ScreenSize.extraLarge => 7,
  };
  
  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.7, // Poster aspect ratio
    ),
    itemCount: items.length,
    itemBuilder: (context, index) => AdaptiveAnimeCard(node: items[index]),
  );
}
```

### Phase 5: Material 3 Enhancements

#### 5.1 Surface Elevation and Containers
```dart
// Use Material 3 elevated containers for visual hierarchy
Widget _buildContentSection({
  required String title,
  required Widget child,
  VoidCallback? onViewAll,
}) {
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: Theme.of(context).dividerColor.withOpacity(0.2),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(S.current.View_All),
                ),
            ],
          ),
          SB.h12,
          child,
        ],
      ),
    ),
  );
}
```

#### 5.2 Adaptive Navigation Rail (Optional)
```dart
// For large tablets/desktop - alternative to bottom nav
class AdaptiveHomeScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  
  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final useNavigationRail = screenSize.index >= ScreenSize.expanded.index;
    
    if (useNavigationRail) {
      return Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text(S.current.Home),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: Text(S.current.Explore),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum),
                label: Text(S.current.Forum),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text(S.current.Profile),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      );
    } else {
      return Scaffold(
        body: body,
        bottomNavigationBar: BottomNavBar(
          startIndex: selectedIndex,
          onChanged: onDestinationSelected,
        ),
      );
    }
  }
}
```

---

## 🎯 Specific File Changes

### Priority 1: Core Files
1. **`lib/screens/contentdetailedscreen.dart`** (Lines 120-1100)
   - Enhance tablet detection (lines 129-144)
   - Refactor `_buildTabletLayout()` (lines 942-1075)
   - Improve left/right pane content distribution
   - Add adaptive sizing for all widgets

2. **`lib/util/responsive_helper.dart`** (NEW FILE)
   - Create responsive utility class
   - Screen size detection
   - Adaptive sizing functions

3. **`lib/widgets/common/adaptive_layout.dart`** (NEW FILE)
   - Adaptive layout builder widget
   - Screen size-based widget switching

### Priority 2: Widget Updates
4. **`lib/widgets/home/*.dart`** (Various files)
   - Update poster card sizing
   - Adaptive grid layouts
   - Responsive padding and spacing

5. **`lib/pages/animedetailed/animecharacterwidget.dart`**
   - Dual-column layout for tablets
   - Larger character cards with more info

6. **`lib/pages/animedetailed/recommanimewidget.dart`**
   - Adaptive grid columns
   - Properly sized recommendation cards

### Priority 3: Main Screens
7. **`lib/pages/homepage.dart`**
   - Two-column layout for tablets
   - Adaptive section arrangements

8. **`lib/screens/homescreen.dart`**
   - Optional: Navigation Rail for large screens
   - Adaptive bottom navigation

---

## 🧪 Testing Checklist

### Device Testing
- [ ] Phone (< 600dp): Single column, standard layout
- [ ] Small Tablet (600-839dp): Dual-pane with 35% left panel
- [ ] Large Tablet (840-1199dp): Dual-pane with 40% left panel
- [ ] Desktop (1200dp+): Fixed width panels

### Orientation Testing
- [ ] Portrait mode: All layouts work correctly
- [ ] Landscape mode: Maximum screen utilization
- [ ] Rotation: Smooth transitions between orientations

### UI Element Testing
- [ ] Posters: Maintain aspect ratio, no stretching
- [ ] Text: Proper line breaks, no overflow
- [ ] Cards: Appropriate sizing, no cutoff
- [ ] Grids: Correct column counts per screen size
- [ ] Images: Load correctly, proper placeholder sizes
- [ ] Tabs: Scrollable on small screens, fixed on large
- [ ] Divider: Resizable, smooth drag interaction

### Interaction Testing
- [ ] Left panel: Scrolls independently
- [ ] Right panel: Scrolls independently with sticky tabs
- [ ] Resizable divider: Smooth dragging, respects min/max
- [ ] Navigation: Works correctly on all screen sizes
- [ ] Floating button: Positioned correctly
- [ ] Edit widget: Displays properly on all sizes

---

## 📚 Material Design References

### Key Resources
1. **Layout Guidelines**: https://m3.material.io/foundations/layout/applying-layout/window-size-classes
2. **Canonical Layouts**: https://m3.material.io/foundations/layout/canonical-layouts/overview
3. **Responsive Grids**: https://m3.material.io/foundations/layout/applying-layout/compact
4. **Large Screen Guidance**: https://developer.android.com/guide/topics/large-screens/support-different-screen-sizes

### Material 3 Patterns to Use
- **Surface Elevation**: Differentiate content areas
- **Adaptive Layouts**: Switch between layouts based on screen size
- **Responsive Grids**: Dynamic column counts
- **Navigation Rail**: For large screens (optional)
- **Split View**: Master-detail pattern for content
- **Floating Action Button**: Context-aware positioning

---

## 🚀 Implementation Steps

### Step 1: Setup (Week 1)
1. Create `responsive_helper.dart` utility class
2. Create `adaptive_layout.dart` widget
3. Add screen size detection throughout app

### Step 2: Content Detail Screen (Week 2)
1. Refactor `contentdetailedscreen.dart` tablet layout
2. Improve left pane content and sizing
3. Enhance right pane with better tabs
4. Add/improve resizable divider

### Step 3: Widget Adaptations (Week 2-3)
1. Update all poster/card widgets with adaptive sizing
2. Fix character list widget for dual-column
3. Update recommendation widgets
4. Fix synopsis and info widgets

### Step 4: Homepage & Other Screens (Week 3-4)
1. Implement two-column homepage layout for tablets
2. Update explore page layouts
3. Update user profile layouts
4. Optional: Add navigation rail for large screens

### Step 5: Testing & Polish (Week 4)
1. Test on all device sizes
2. Test portrait and landscape orientations
3. Fix any remaining alignment issues
4. Polish animations and transitions
5. Performance optimization

---

## 💡 Additional Enhancements

### Performance Optimizations
```dart
// Use const constructors where possible
const SizedBox(height: 16)

// Lazy load heavy widgets
AutomaticKeepAliveClientMixin for tabs

// Cache network images properly
CachedNetworkImage with proper sizing

// Optimize list rendering
ListView.builder with proper itemExtent
```

### Accessibility
```dart
// Semantic labels for screen readers
Semantics(
  label: 'Anime poster for ${node.title}',
  child: PosterImage(node),
)

// Minimum touch target sizes
Container(
  constraints: BoxConstraints(minHeight: 48, minWidth: 48),
  child: InkWell(...),
)
```

### Animation Enhancements
```dart
// Smooth layout transitions
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: _leftPanelWidth,
)

// Hero animations for navigation
Hero(
  tag: 'anime-${node.id}',
  child: PosterImage(node),
)
```

---

## 📝 Notes

- **Backward Compatibility**: Ensure phone layouts remain unchanged
- **Performance**: Monitor frame rates on lower-end devices
- **Theme Support**: Ensure all changes work with light/dark themes
- **Localization**: Test with different text lengths (i18n)
- **Network Handling**: Proper loading states and error handling
- **State Management**: Preserve scroll positions and user interactions

---

## ✅ Success Criteria

The implementation will be considered successful when:

1. ✅ No UI elements are stretched or distorted on any screen size
2. ✅ All elements are properly aligned and visible (no cut-offs)
3. ✅ Posters maintain proper aspect ratios across all devices
4. ✅ Dual-pane layout works smoothly on tablets (600dp+)
5. ✅ Left and right panes scroll independently
6. ✅ Resizable divider works smoothly with min/max constraints
7. ✅ Character lists display in 2 columns on tablets
8. ✅ Homepage utilizes available space efficiently
9. ✅ All animations and transitions are smooth (60 FPS)
10. ✅ Layout adapts properly on orientation changes
11. ✅ Material 3 design principles are followed throughout
12. ✅ App passes accessibility standards (WCAG 2.1 Level AA)

---

**Last Updated**: October 24, 2025  
**Version**: 1.0  
**Target Flutter Version**: 3.x+  
**Target Material Version**: Material 3
