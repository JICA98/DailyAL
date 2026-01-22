# Tablet View Update Tasks
This document contains a detailed breakdown of screens and widgets that require updates to support tablet layouts in the DailyAL application.
## Core Infrastructure
- [ ] **Verify Responsive Helper**
  - **File**: [lib/util/responsive_helper.dart](file:///home/jica/repo/DailyAL/lib/util/responsive_helper.dart)
  - **Status**: Mostly implemented.
  - **Task**: Ensure [ScreenSize](file:///home/jica/repo/DailyAL/lib/util/responsive_helper.dart#14-23) enum and breakpoints match exactly:
    - compact: < 600
    - medium: 600 - 839
    - expanded: 840 - 1199
    - large: >= 1200
    - extraLarge: >= 1600 (optional but good for validation)
  - **Instruction**: Confirm [getScreenSize](file:///home/jica/repo/DailyAL/lib/util/responsive_helper.dart#14-23), [isTabletOrLarger](file:///home/jica/repo/DailyAL/lib/util/responsive_helper.dart#24-28) and padding methods are aligned with requirements.
---
## Screen-Specific Tasks
### 1. Content Detailed Screen (Priority: High)
- **File**: [lib/screens/contentdetailedscreen.dart](file:///home/jica/repo/DailyAL/lib/screens/contentdetailedscreen.dart)
- **Current State**: Has basic [Row](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/animecharacterwidget.dart#232-259) based split for `_isTablet`. Left panel width is clamped between 350-550. Right pane filters out sections.
- **Issues**:
  - Left panel width logic is hardcoded, not using [ResponsiveHelper](file:///home/jica/repo/DailyAL/lib/util/responsive_helper.dart#13-112) breakpoints.
  - "Hero Image" is likely just the standard image widget, needs adapting for aspect ratio.
  - Right pane tabs might be missing new sections (User Updates, Forums, etc.) or just showing them in a list.
  - Divider resize logic needs to be robust (min/max constraints).
- **Instructions**:
  - **Layout**: Implement `AdaptiveLayout` (or [_buildTabletLayout](file:///home/jica/repo/DailyAL/lib/screens/contentdetailedscreen.dart#960-1089) logic) to switch between `_buildCompactLayout` (Phone), `_buildMediumLayout` (Split view), `_buildExpandedLayout`.
  - **Left Pane**: 
    - Width: 35% (Medium), 40% (Expanded), Fixed 480px (Large).
    - Content: Hero Image (Aspect Ratio 1:1.4), Title (with Lang toggle), Score/Ranking Badges, Quick Stats, Synopsis (collapsible), Genres, More Info, Quick Actions.
  - **Right Pane**:
    - Layout: `CustomScrollView` with `SliverAppBar` (Sticky Tabs).
    - Tabs: Characters & Staff (Grid), Episodes, Reviews, Recommendations, Related, Media, News, User Updates, Forums, Pictures, Stats.
    - Behavior: Independent scrolling.
  - **Divider**: Implement the "Resizable Divider Enhancement" logic provided in the prompt.
### 2. Home Home & Home Page (Priority: High)
- **Files**: [lib/screens/homescreen.dart](file:///home/jica/repo/DailyAL/lib/screens/homescreen.dart), [lib/pages/homepage.dart](file:///home/jica/repo/DailyAL/lib/pages/homepage.dart)
- **Current State**: [homescreen.dart](file:///home/jica/repo/DailyAL/lib/screens/homescreen.dart) has logic for `NavigationRail` but [homepage.dart](file:///home/jica/repo/DailyAL/lib/pages/homepage.dart) layout is mostly single column logic (`_columnWidget`).
- **Instructions**:
  - **[homescreen.dart](file:///home/jica/repo/DailyAL/lib/screens/homescreen.dart)**:
    - Confirm `NavigationRail` is active for `ScreenSize.expanded` or larger.
    - Ensure adaptive bottom navigation for smaller screens.
  - **[homepage.dart](file:///home/jica/repo/DailyAL/lib/pages/homepage.dart)**:
    - Implement `_buildTabletHomeContent` which uses a `CustomScrollView`.
    - **News & Rankings**: Group into a 60/40 Split View (Left: Anime/Manga Lists, Ranking; Right: News, Forums, Seasonal).
    - **Grid**: Use `AdaptiveAnimeCard` grid for lists instead of horizontal scrolling lists where appropriate, or ensure horizontal lists show more items.
### 3. Anime Character Widget
- **File**: [lib/pages/animedetailed/animecharacterwidget.dart](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/animecharacterwidget.dart)
- **Current State**: Uses `PageView` with [ListView](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/animecharacterwidget.dart#38-46) for grid ([_buildGridView](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/animecharacterwidget.dart#113-141)).
- **Instructions**:
  - Replace [_buildGridView](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/animecharacterwidget.dart#113-141) with `GridView.builder`.
  - **Grid Delegate**: `SliverGridDelegateWithFixedCrossAxisCount`.
  - **Columns**: Use `ResponsiveHelper.getCrossAxisCount(context)` approach (2 columns for Tablet).
  - **Card**: Redesign `_buildCharacterCard` to be wider (AspectRatio ~3) on tablet, showing Voice Actor info nicely next to character info.
### 4. Recommendations & Related Widgets
- **File**: [lib/pages/animedetailed/recommanimewidget.dart](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/recommanimewidget.dart)
- **Current State**: Uses `horizontalList`.
- **Instructions**:
  - **Responsive Grid**: Create/Use `_buildAdaptiveGrid` for recommendations on Tablet.
  - **Columns**: 3 (Phone), 4 (Small Tab), 5 (Large Tab), 6 (Desktop).
  - **Card**: Ensure cards resize properly and don't stretch images.
### 5. Clubs Page & List
- **Files**: [lib/pages/clubspage.dart](file:///home/jica/repo/DailyAL/lib/pages/clubspage.dart), [lib/widgets/club/clublistwidget.dart](file:///home/jica/repo/DailyAL/lib/widgets/club/clublistwidget.dart)
- **Current State**: [ClubListWidget](file:///home/jica/repo/DailyAL/lib/widgets/club/clublistwidget.dart#12-20) uses [ListView](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/animecharacterwidget.dart#38-46) (Single Column).
- **Instructions**:
  - **[clublistwidget.dart](file:///home/jica/repo/DailyAL/lib/widgets/club/clublistwidget.dart)**:
    - In [build](file:///home/jica/repo/DailyAL/lib/widgets/club/clublistwidget.dart#95-107), check `ResponsiveHelper.isTabletOrLarger`.
    - If Tablet, use `GridView.builder` with `crossAxisCount: 2`.
    - If Phone, keep [ListView](file:///home/jica/repo/DailyAL/lib/pages/animedetailed/animecharacterwidget.dart#38-46).
### 6. Explore Page
- **File**: [lib/pages/explorepage.dart](file:///home/jica/repo/DailyAL/lib/pages/explorepage.dart)
- **Current State**: `CustomScrollView` with vertical list of horizontal scrolling sections.
- **Instructions**:
  - **Ranking/Genre**: These are full width. On large screens, consider side-by-side or a Grid for Top Anime/Manga if appropriate.
  - **Seasonal/Recommendations**: Currently horizontal lists. On very large screens, ensure they utilize width (padding) or show more items.
  - **Review Section**: [_reviewsBuilder](file:///home/jica/repo/DailyAL/lib/pages/explorepage.dart#188-208). Ensure review cards don't become too wide/stretched. Limit max width of cards or use Grid.
### 7. Forum Page
- **File**: [lib/pages/forumpage.dart](file:///home/jica/repo/DailyAL/lib/pages/forumpage.dart)
- **Current State**: Has tablet logic ([_buildTabletForumLayout](file:///home/jica/repo/DailyAL/lib/pages/forumpage.dart#265-439), [_buildCompactBoardGrid](file:///home/jica/repo/DailyAL/lib/pages/forumpage.dart#509-536)).
- **Instructions**:
  - **Review**: Validate that [_buildTabletForumLayout](file:///home/jica/repo/DailyAL/lib/pages/forumpage.dart#265-439) matches the specific "Two Column" requirement for Anime/Manga discussions and "Compact Board Grid" matches the desired column count (3 for Large Tablet).
  - **Update**: If breakpoints don't match [ResponsiveHelper](file:///home/jica/repo/DailyAL/lib/util/responsive_helper.dart#13-112), update them.
## General UI Polish Tasks
- [ ] **Poster Aspect Ratio**: Ensure all `CachedNetworkImage` for posters use `aspectRatio: 1/1.4`.
- [ ] **Text Size**: Verify `Theme.of(context).textTheme` is used so text scales, but consider larger font sizes for specific tablet headers if needed.
- [ ] **Touch Targets**: Ensure buttons are accessible on touch screens (min 48x48dp).