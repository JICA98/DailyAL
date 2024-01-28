// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Top Anime`
  String get top_anime {
    return Intl.message(
      'Top Anime',
      name: 'top_anime',
      desc: '',
      args: [],
    );
  }

  /// `Top Manga`
  String get top_mange {
    return Intl.message(
      'Top Manga',
      name: 'top_mange',
      desc: '',
      args: [],
    );
  }

  /// `Top Airing`
  String get top_airing {
    return Intl.message(
      'Top Airing',
      name: 'top_airing',
      desc: '',
      args: [],
    );
  }

  /// `Popular Anime`
  String get popular_anime {
    return Intl.message(
      'Popular Anime',
      name: 'popular_anime',
      desc: '',
      args: [],
    );
  }

  /// `Popular Manga`
  String get popular_manga {
    return Intl.message(
      'Popular Manga',
      name: 'popular_manga',
      desc: '',
      args: [],
    );
  }

  /// `Suggested Anime`
  String get suggested_anime {
    return Intl.message(
      'Suggested Anime',
      name: 'suggested_anime',
      desc: '',
      args: [],
    );
  }

  /// `Top Upcoming Anime`
  String get Top_Upcoming_Anime {
    return Intl.message(
      'Top Upcoming Anime',
      name: 'Top_Upcoming_Anime',
      desc: '',
      args: [],
    );
  }

  /// `Most Popular Anime`
  String get Most_Popular_Anime {
    return Intl.message(
      'Most Popular Anime',
      name: 'Most_Popular_Anime',
      desc: '',
      args: [],
    );
  }

  /// `Top Anime by Score`
  String get Top_Anime_by_Score {
    return Intl.message(
      'Top Anime by Score',
      name: 'Top_Anime_by_Score',
      desc: '',
      args: [],
    );
  }

  /// `Top Airing Anime`
  String get Top_Airing_Anime {
    return Intl.message(
      'Top Airing Anime',
      name: 'Top_Airing_Anime',
      desc: '',
      args: [],
    );
  }

  /// `All time Favorites`
  String get All_time_Favorites {
    return Intl.message(
      'All time Favorites',
      name: 'All_time_Favorites',
      desc: '',
      args: [],
    );
  }

  /// `Top Anime Movies`
  String get Top_Anime_Movies {
    return Intl.message(
      'Top Anime Movies',
      name: 'Top_Anime_Movies',
      desc: '',
      args: [],
    );
  }

  /// `Top OVA`
  String get Top_OVA {
    return Intl.message(
      'Top OVA',
      name: 'Top_OVA',
      desc: '',
      args: [],
    );
  }

  /// `Top Specials`
  String get Top_Specials {
    return Intl.message(
      'Top Specials',
      name: 'Top_Specials',
      desc: '',
      args: [],
    );
  }

  /// `Top TV Shows`
  String get Top_TV_Shows {
    return Intl.message(
      'Top TV Shows',
      name: 'Top_TV_Shows',
      desc: '',
      args: [],
    );
  }

  /// `Top All Manga`
  String get Top_All_Manga {
    return Intl.message(
      'Top All Manga',
      name: 'Top_All_Manga',
      desc: '',
      args: [],
    );
  }

  /// `Top Manga`
  String get Top_Manga {
    return Intl.message(
      'Top Manga',
      name: 'Top_Manga',
      desc: '',
      args: [],
    );
  }

  /// `Top Oneshots`
  String get Top_Oneshots {
    return Intl.message(
      'Top Oneshots',
      name: 'Top_Oneshots',
      desc: '',
      args: [],
    );
  }

  /// `Top Doujin`
  String get Top_Doujin {
    return Intl.message(
      'Top Doujin',
      name: 'Top_Doujin',
      desc: '',
      args: [],
    );
  }

  /// `Top Light Novels`
  String get Top_Light_Novels {
    return Intl.message(
      'Top Light Novels',
      name: 'Top_Light_Novels',
      desc: '',
      args: [],
    );
  }

  /// `Top Novels`
  String get Top_Novels {
    return Intl.message(
      'Top Novels',
      name: 'Top_Novels',
      desc: '',
      args: [],
    );
  }

  /// `Top Manhwa`
  String get Top_Manhwa {
    return Intl.message(
      'Top Manhwa',
      name: 'Top_Manhwa',
      desc: '',
      args: [],
    );
  }

  /// `Top Manhua`
  String get Top_Manhua {
    return Intl.message(
      'Top Manhua',
      name: 'Top_Manhua',
      desc: '',
      args: [],
    );
  }

  /// `Top Manga Bypopularity`
  String get Top_Manga_Bypopularity {
    return Intl.message(
      'Top Manga Bypopularity',
      name: 'Top_Manga_Bypopularity',
      desc: '',
      args: [],
    );
  }

  /// `Top Favorite Manga`
  String get Top_Favorite_Manga {
    return Intl.message(
      'Top Favorite Manga',
      name: 'Top_Favorite_Manga',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get View_All {
    return Intl.message(
      'View All',
      name: 'View_All',
      desc: '',
      args: [],
    );
  }

  /// `search here...`
  String get Search_Bar_Text {
    return Intl.message(
      'search here...',
      name: 'Search_Bar_Text',
      desc: '',
      args: [],
    );
  }

  /// `Synopsis`
  String get Synopsis {
    return Intl.message(
      'Synopsis',
      name: 'Synopsis',
      desc: '',
      args: [],
    );
  }

  /// `Related`
  String get Related {
    return Intl.message(
      'Related',
      name: 'Related',
      desc: '',
      args: [],
    );
  }

  /// `Characters`
  String get Characters {
    return Intl.message(
      'Characters',
      name: 'Characters',
      desc: '',
      args: [],
    );
  }

  /// `Episodes`
  String get Episodes {
    return Intl.message(
      'Episodes',
      name: 'Episodes',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get Reviews {
    return Intl.message(
      'Reviews',
      name: 'Reviews',
      desc: '',
      args: [],
    );
  }

  /// `More Info`
  String get More_Info {
    return Intl.message(
      'More Info',
      name: 'More_Info',
      desc: '',
      args: [],
    );
  }

  /// `Forums`
  String get Forums {
    return Intl.message(
      'Forums',
      name: 'Forums',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get Recommended {
    return Intl.message(
      'Recommended',
      name: 'Recommended',
      desc: '',
      args: [],
    );
  }

  /// `Stats`
  String get Stats {
    return Intl.message(
      'Stats',
      name: 'Stats',
      desc: '',
      args: [],
    );
  }

  /// `Pictures`
  String get Pictures {
    return Intl.message(
      'Pictures',
      name: 'Pictures',
      desc: '',
      args: [],
    );
  }

  /// `Related Anime`
  String get Related_Anime {
    return Intl.message(
      'Related Anime',
      name: 'Related_Anime',
      desc: '',
      args: [],
    );
  }

  /// `users`
  String get Users {
    return Intl.message(
      'users',
      name: 'Users',
      desc: '',
      args: [],
    );
  }

  /// `Popularity`
  String get Popularity {
    return Intl.message(
      'Popularity',
      name: 'Popularity',
      desc: '',
      args: [],
    );
  }

  /// `Studios`
  String get Studios {
    return Intl.message(
      'Studios',
      name: 'Studios',
      desc: '',
      args: [],
    );
  }

  /// `Authors`
  String get Authors {
    return Intl.message(
      'Authors',
      name: 'Authors',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get Members {
    return Intl.message(
      'Members',
      name: 'Members',
      desc: '',
      args: [],
    );
  }

  /// `Play Promo`
  String get Play_Promo {
    return Intl.message(
      'Play Promo',
      name: 'Play_Promo',
      desc: '',
      args: [],
    );
  }

  /// `No Character Info Provided.`
  String get No_Character_Info_Provided {
    return Intl.message(
      'No Character Info Provided.',
      name: 'No_Character_Info_Provided',
      desc: '',
      args: [],
    );
  }

  /// `Loading Content`
  String get Loading_Content {
    return Intl.message(
      'Loading Content',
      name: 'Loading_Content',
      desc: '',
      args: [],
    );
  }

  /// `title not found..`
  String get title_not_found {
    return Intl.message(
      'title not found..',
      name: 'title_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't Launch`
  String get Couldn_Launch {
    return Intl.message(
      'Couldn\'t Launch',
      name: 'Couldn_Launch',
      desc: '',
      args: [],
    );
  }

  /// `Discussion`
  String get Discussion {
    return Intl.message(
      'Discussion',
      name: 'Discussion',
      desc: '',
      args: [],
    );
  }

  /// `No Discussions Yet..`
  String get No_Discussions_Yet {
    return Intl.message(
      'No Discussions Yet..',
      name: 'No_Discussions_Yet',
      desc: '',
      args: [],
    );
  }

  /// `View all Discussions`
  String get View_all_Discussions {
    return Intl.message(
      'View all Discussions',
      name: 'View_all_Discussions',
      desc: '',
      args: [],
    );
  }

  /// `replies`
  String get replies {
    return Intl.message(
      'replies',
      name: 'replies',
      desc: '',
      args: [],
    );
  }

  /// `Last Post`
  String get Last_Post {
    return Intl.message(
      'Last Post',
      name: 'Last_Post',
      desc: '',
      args: [],
    );
  }

  /// `No Pictures yet..`
  String get No_Pictures_yet {
    return Intl.message(
      'No Pictures yet..',
      name: 'No_Pictures_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Reviews yet..`
  String get No_Reviews_yet {
    return Intl.message(
      'No Reviews yet..',
      name: 'No_Reviews_yet',
      desc: '',
      args: [],
    );
  }

  /// `Story`
  String get Story {
    return Intl.message(
      'Story',
      name: 'Story',
      desc: '',
      args: [],
    );
  }

  /// `Animation`
  String get Animation {
    return Intl.message(
      'Animation',
      name: 'Animation',
      desc: '',
      args: [],
    );
  }

  /// `Sound`
  String get Sound {
    return Intl.message(
      'Sound',
      name: 'Sound',
      desc: '',
      args: [],
    );
  }

  /// `Character`
  String get Character {
    return Intl.message(
      'Character',
      name: 'Character',
      desc: '',
      args: [],
    );
  }

  /// `Enjoyment`
  String get Enjoyment {
    return Intl.message(
      'Enjoyment',
      name: 'Enjoyment',
      desc: '',
      args: [],
    );
  }

  /// `Watching`
  String get Watching {
    return Intl.message(
      'Watching',
      name: 'Watching',
      desc: '',
      args: [],
    );
  }

  /// `On Hold`
  String get On_Hold {
    return Intl.message(
      'On Hold',
      name: 'On_Hold',
      desc: '',
      args: [],
    );
  }

  /// `PTW`
  String get PTW {
    return Intl.message(
      'PTW',
      name: 'PTW',
      desc: '',
      args: [],
    );
  }

  /// `Dropped`
  String get Dropped {
    return Intl.message(
      'Dropped',
      name: 'Dropped',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get Completed {
    return Intl.message(
      'Completed',
      name: 'Completed',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get Statistics {
    return Intl.message(
      'Statistics',
      name: 'Statistics',
      desc: '',
      args: [],
    );
  }

  /// `No Recommendations yet..`
  String get No_Recommendations_yet {
    return Intl.message(
      'No Recommendations yet..',
      name: 'No_Recommendations_yet',
      desc: '',
      args: [],
    );
  }

  /// `No Related Content yet..`
  String get No_Related_Content_yet {
    return Intl.message(
      'No Related Content yet..',
      name: 'No_Related_Content_yet',
      desc: '',
      args: [],
    );
  }

  /// `Opening Songs`
  String get Opening_Songs {
    return Intl.message(
      'Opening Songs',
      name: 'Opening_Songs',
      desc: '',
      args: [],
    );
  }

  /// `Ending Songs`
  String get Ending_Songs {
    return Intl.message(
      'Ending Songs',
      name: 'Ending_Songs',
      desc: '',
      args: [],
    );
  }

  /// `Background`
  String get Background {
    return Intl.message(
      'Background',
      name: 'Background',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get None {
    return Intl.message(
      'None',
      name: 'None',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while the URL is loaded.`
  String get Please_wait_while_the_URL_is_loaded {
    return Intl.message(
      'Please wait while the URL is loaded.',
      name: 'Please_wait_while_the_URL_is_loaded',
      desc: '',
      args: [],
    );
  }

  /// `Play on Youtube`
  String get Play_on_Youtube {
    return Intl.message(
      'Play on Youtube',
      name: 'Play_on_Youtube',
      desc: '',
      args: [],
    );
  }

  /// `Home Page`
  String get Home_Page {
    return Intl.message(
      'Home Page',
      name: 'Home_Page',
      desc: '',
      args: [],
    );
  }

  /// `Forums Page`
  String get Forums_Page {
    return Intl.message(
      'Forums Page',
      name: 'Forums_Page',
      desc: '',
      args: [],
    );
  }

  /// `User Page`
  String get User_Page {
    return Intl.message(
      'User Page',
      name: 'User_Page',
      desc: '',
      args: [],
    );
  }

  /// `Customize Home Page`
  String get Customize_Home_Page {
    return Intl.message(
      'Customize Home Page',
      name: 'Customize_Home_Page',
      desc: '',
      args: [],
    );
  }

  /// `Home Page items`
  String get Home_Page_items {
    return Intl.message(
      'Home Page items',
      name: 'Home_Page_items',
      desc: '',
      args: [],
    );
  }

  /// `Long press to drag/drop and reorder the list`
  String get Reorder_home_page {
    return Intl.message(
      'Long press to drag/drop and reorder the list',
      name: 'Reorder_home_page',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get Reset {
    return Intl.message(
      'Reset',
      name: 'Reset',
      desc: '',
      args: [],
    );
  }

  /// `Reset homepage`
  String get Reset_homepage {
    return Intl.message(
      'Reset homepage',
      name: 'Reset_homepage',
      desc: '',
      args: [],
    );
  }

  /// `This will reset the homepage layout to its original state and is un-doable.`
  String get Reset_homepage_warning {
    return Intl.message(
      'This will reset the homepage layout to its original state and is un-doable.',
      name: 'Reset_homepage_warning',
      desc: '',
      args: [],
    );
  }

  /// `Exceeded max. no. of items`
  String get max_items_home {
    return Intl.message(
      'Exceeded max. no. of items',
      name: 'max_items_home',
      desc: '',
      args: [],
    );
  }

  /// `Add an Item`
  String get Add_an_Item {
    return Intl.message(
      'Add an Item',
      name: 'Add_an_Item',
      desc: '',
      args: [],
    );
  }

  /// `You will have to restart to see the changes'`
  String get Restart_to_see_changes {
    return Intl.message(
      'You will have to restart to see the changes\'',
      name: 'Restart_to_see_changes',
      desc: '',
      args: [],
    );
  }

  /// `No. of items in each category`
  String get No_of_items_in_each_category {
    return Intl.message(
      'No. of items in each category',
      name: 'No_of_items_in_each_category',
      desc: '',
      args: [],
    );
  }

  /// `For Ex, by default seasonal anime has 14 items`
  String get No_of_items_desc {
    return Intl.message(
      'For Ex, by default seasonal anime has 14 items',
      name: 'No_of_items_desc',
      desc: '',
      args: [],
    );
  }

  /// `Select the no. of items`
  String get Select_the_no_of_items {
    return Intl.message(
      'Select the no. of items',
      name: 'Select_the_no_of_items',
      desc: '',
      args: [],
    );
  }

  /// `Content type`
  String get Content_type {
    return Intl.message(
      'Content type',
      name: 'Content_type',
      desc: '',
      args: [],
    );
  }

  /// `You need to login to view these settings.`
  String get Login_toView_Settings {
    return Intl.message(
      'You need to login to view these settings.',
      name: 'Login_toView_Settings',
      desc: '',
      args: [],
    );
  }

  /// `Select Ranking Type`
  String get Select_Ranking_Type {
    return Intl.message(
      'Select Ranking Type',
      name: 'Select_Ranking_Type',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get Auto {
    return Intl.message(
      'Auto',
      name: 'Auto',
      desc: '',
      args: [],
    );
  }

  /// `Season`
  String get Season {
    return Intl.message(
      'Season',
      name: 'Season',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get Year {
    return Intl.message(
      'Year',
      name: 'Year',
      desc: '',
      args: [],
    );
  }

  /// `Select Board`
  String get Select_Board {
    return Intl.message(
      'Select Board',
      name: 'Select_Board',
      desc: '',
      args: [],
    );
  }

  /// `You cannot select board with subboard`
  String get Cannot_select_board_with_subb {
    return Intl.message(
      'You cannot select board with subboard',
      name: 'Cannot_select_board_with_subb',
      desc: '',
      args: [],
    );
  }

  /// `Select Sub board`
  String get Select_Sub_board {
    return Intl.message(
      'Select Sub board',
      name: 'Select_Sub_board',
      desc: '',
      args: [],
    );
  }

  /// `You cannot select subboard with board`
  String get Cannot_select_subboard_with_board {
    return Intl.message(
      'You cannot select subboard with board',
      name: 'Cannot_select_subboard_with_board',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get Category {
    return Intl.message(
      'Category',
      name: 'Category',
      desc: '',
      args: [],
    );
  }

  /// `Sub Category`
  String get Sub_Category {
    return Intl.message(
      'Sub Category',
      name: 'Sub_Category',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get Delete {
    return Intl.message(
      'Delete',
      name: 'Delete',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get Title {
    return Intl.message(
      'Title',
      name: 'Title',
      desc: '',
      args: [],
    );
  }

  /// `Min. title length is 3`
  String get Min_title_length {
    return Intl.message(
      'Min. title length is 3',
      name: 'Min_title_length',
      desc: '',
      args: [],
    );
  }

  /// `Please select a board or sub board`
  String get Please_select_a_board_or_sub_board {
    return Intl.message(
      'Please select a board or sub board',
      name: 'Please_select_a_board_or_sub_board',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get Yes {
    return Intl.message(
      'Yes',
      name: 'Yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get No {
    return Intl.message(
      'No',
      name: 'No',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get Save {
    return Intl.message(
      'Save',
      name: 'Save',
      desc: '',
      args: [],
    );
  }

  /// `Notification Settings`
  String get Notification_Settings {
    return Intl.message(
      'Notification Settings',
      name: 'Notification_Settings',
      desc: '',
      args: [],
    );
  }

  /// `Receive notifications on`
  String get Receive_notifications_on {
    return Intl.message(
      'Receive notifications on',
      name: 'Receive_notifications_on',
      desc: '',
      args: [],
    );
  }

  /// `Anime on Watching List gets aired`
  String get Anime_on_Watching_List_gets_aired {
    return Intl.message(
      'Anime on Watching List gets aired',
      name: 'Anime_on_Watching_List_gets_aired',
      desc: '',
      args: [],
    );
  }

  /// `Anime on PTW List gets aired`
  String get Anime_on_PTW_List_gets_aired {
    return Intl.message(
      'Anime on PTW List gets aired',
      name: 'Anime_on_PTW_List_gets_aired',
      desc: '',
      args: [],
    );
  }

  /// `You may still get alerts for upto 3 days for the notifications which have already been scheduled for you. Please note that these settings will only work when you have logged in.`
  String get Notification_settings_warning {
    return Intl.message(
      'You may still get alerts for upto 3 days for the notifications which have already been scheduled for you. Please note that these settings will only work when you have logged in.',
      name: 'Notification_settings_warning',
      desc: '',
      args: [],
    );
  }

  /// `Primary background color`
  String get Primary_background_color {
    return Intl.message(
      'Primary background color',
      name: 'Primary_background_color',
      desc: '',
      args: [],
    );
  }

  /// `Nav bar/Panel color`
  String get Nav_Panel_color {
    return Intl.message(
      'Nav bar/Panel color',
      name: 'Nav_Panel_color',
      desc: '',
      args: [],
    );
  }

  /// `Navigation icon color`
  String get Navigation_icon_color {
    return Intl.message(
      'Navigation icon color',
      name: 'Navigation_icon_color',
      desc: '',
      args: [],
    );
  }

  /// `App bar text color`
  String get App_bar_text_color {
    return Intl.message(
      'App bar text color',
      name: 'App_bar_text_color',
      desc: '',
      args: [],
    );
  }

  /// `App bar icon color`
  String get App_bar_icon_color {
    return Intl.message(
      'App bar icon color',
      name: 'App_bar_icon_color',
      desc: '',
      args: [],
    );
  }

  /// `App bar/Button color`
  String get App_bar_Button_color {
    return Intl.message(
      'App bar/Button color',
      name: 'App_bar_Button_color',
      desc: '',
      args: [],
    );
  }

  /// `Secondary text color`
  String get Secondary_text_color {
    return Intl.message(
      'Secondary text color',
      name: 'Secondary_text_color',
      desc: '',
      args: [],
    );
  }

  /// `Theme Settings`
  String get Theme_Settings {
    return Intl.message(
      'Theme Settings',
      name: 'Theme_Settings',
      desc: '',
      args: [],
    );
  }

  /// `Select a Theme`
  String get Select_a_Theme {
    return Intl.message(
      'Select a Theme',
      name: 'Select_a_Theme',
      desc: '',
      args: [],
    );
  }

  /// `This is a feature in progress!`
  String get Theme_settings_warning {
    return Intl.message(
      'This is a feature in progress!',
      name: 'Theme_settings_warning',
      desc: '',
      args: [],
    );
  }

  /// `Background Image`
  String get Background_Image {
    return Intl.message(
      'Background Image',
      name: 'Background_Image',
      desc: '',
      args: [],
    );
  }

  /// `Show or hide background image from all the screens.`
  String get Background_Image_desc {
    return Intl.message(
      'Show or hide background image from all the screens.',
      name: 'Background_Image_desc',
      desc: '',
      args: [],
    );
  }

  /// `Expand User Details`
  String get Expand_User_Details {
    return Intl.message(
      'Expand User Details',
      name: 'Expand_User_Details',
      desc: '',
      args: [],
    );
  }

  /// `Choose to expand the user details in all the user screens by default.`
  String get Expand_User_Details_desc {
    return Intl.message(
      'Choose to expand the user details in all the user screens by default.',
      name: 'Expand_User_Details_desc',
      desc: '',
      args: [],
    );
  }

  /// `NSFW Preference`
  String get NSFW_Preference {
    return Intl.message(
      'NSFW Preference',
      name: 'NSFW_Preference',
      desc: '',
      args: [],
    );
  }

  /// `Turn this off if you don't need NSFW content from MAL API Call. Please note that this toggle wil not work on Jikan API Calls and HTML parsing.`
  String get NSFW_Preference_desc {
    return Intl.message(
      'Turn this off if you don\'t need NSFW content from MAL API Call. Please note that this toggle wil not work on Jikan API Calls and HTML parsing.',
      name: 'NSFW_Preference_desc',
      desc: '',
      args: [],
    );
  }

  /// `Keep pages in memory`
  String get Keep_pages_in_memory {
    return Intl.message(
      'Keep pages in memory',
      name: 'Keep_pages_in_memory',
      desc: '',
      args: [],
    );
  }

  /// `Turn this on if you want home page, forums and user profile to stay as you left them.`
  String get Keep_pages_in_memory_desc {
    return Intl.message(
      'Turn this on if you want home page, forums and user profile to stay as you left them.',
      name: 'Keep_pages_in_memory_desc',
      desc: '',
      args: [],
    );
  }

  /// `Show priority in anime/manga list`
  String get Show_priority_in_anime_manga_list {
    return Intl.message(
      'Show priority in anime/manga list',
      name: 'Show_priority_in_anime_manga_list',
      desc: '',
      args: [],
    );
  }

  /// `Turn this on if you want to see the priority of your anime/manga, ie. high/low/medium`
  String get Show_priority_in_anime_manga_list_desc {
    return Intl.message(
      'Turn this on if you want to see the priority of your anime/manga, ie. high/low/medium',
      name: 'Show_priority_in_anime_manga_list_desc',
      desc: '',
      args: [],
    );
  }

  /// `User Statistics Chart Preferences`
  String get User_Statistics_Chart_Preferences {
    return Intl.message(
      'User Statistics Chart Preferences',
      name: 'User_Statistics_Chart_Preferences',
      desc: '',
      args: [],
    );
  }

  /// `Chart color`
  String get Chart_color {
    return Intl.message(
      'Chart color',
      name: 'Chart_color',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get Clear {
    return Intl.message(
      'Clear',
      name: 'Clear',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get Select {
    return Intl.message(
      'Select',
      name: 'Select',
      desc: '',
      args: [],
    );
  }

  /// `Anime Discussions`
  String get Anime_Discussions {
    return Intl.message(
      'Anime Discussions',
      name: 'Anime_Discussions',
      desc: '',
      args: [],
    );
  }

  /// `Manga Discussions`
  String get Manga_Discussions {
    return Intl.message(
      'Manga Discussions',
      name: 'Manga_Discussions',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get Settings {
    return Intl.message(
      'Settings',
      name: 'Settings',
      desc: '',
      args: [],
    );
  }

  /// `Select from six different themes.`
  String get Theme_setting_desc {
    return Intl.message(
      'Select from six different themes.',
      name: 'Theme_setting_desc',
      desc: '',
      args: [],
    );
  }

  /// `Setup local notifications.`
  String get Notification_setting_desc {
    return Intl.message(
      'Setup local notifications.',
      name: 'Notification_setting_desc',
      desc: '',
      args: [],
    );
  }

  /// `Customize your home page.`
  String get HomePageSettings_desc {
    return Intl.message(
      'Customize your home page.',
      name: 'HomePageSettings_desc',
      desc: '',
      args: [],
    );
  }

  /// `User Preferences`
  String get User_Preferences {
    return Intl.message(
      'User Preferences',
      name: 'User_Preferences',
      desc: '',
      args: [],
    );
  }

  /// `Customize background image, etc.`
  String get User_Preferences_desc {
    return Intl.message(
      'Customize background image, etc.',
      name: 'User_Preferences_desc',
      desc: '',
      args: [],
    );
  }

  /// `Rate & Review`
  String get Rate_Review {
    return Intl.message(
      'Rate & Review',
      name: 'Rate_Review',
      desc: '',
      args: [],
    );
  }

  /// `This will help us make the app better.`
  String get Rate_Review_desc {
    return Intl.message(
      'This will help us make the app better.',
      name: 'Rate_Review_desc',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get Logout {
    return Intl.message(
      'Log Out',
      name: 'Logout',
      desc: '',
      args: [],
    );
  }

  /// `User not Logged in`
  String get User_not_Logged_in {
    return Intl.message(
      'User not Logged in',
      name: 'User_not_Logged_in',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get Log_In {
    return Intl.message(
      'Log In',
      name: 'Log_In',
      desc: '',
      args: [],
    );
  }

  /// `Home Page Settings`
  String get Home_Page_Setting {
    return Intl.message(
      'Home Page Settings',
      name: 'Home_Page_Setting',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: [],
    );
  }

  /// `List`
  String get List {
    return Intl.message(
      'List',
      name: 'List',
      desc: '',
      args: [],
    );
  }

  /// `Social`
  String get Social {
    return Intl.message(
      'Social',
      name: 'Social',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get Favorites {
    return Intl.message(
      'Favorites',
      name: 'Favorites',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't connect to the network`
  String get Couldnt_connect_network {
    return Intl.message(
      'Couldn\'t connect to the network',
      name: 'Couldnt_connect_network',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get Friends {
    return Intl.message(
      'Friends',
      name: 'Friends',
      desc: '',
      args: [],
    );
  }

  /// `friends`
  String get friends {
    return Intl.message(
      'friends',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  /// `No friends found..`
  String get No_friends_found {
    return Intl.message(
      'No friends found..',
      name: 'No_friends_found',
      desc: '',
      args: [],
    );
  }

  /// `No clubs found..`
  String get No_clubs_found {
    return Intl.message(
      'No clubs found..',
      name: 'No_clubs_found',
      desc: '',
      args: [],
    );
  }

  /// `Loading clubs`
  String get Loading_clubs {
    return Intl.message(
      'Loading clubs',
      name: 'Loading_clubs',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't open Club!`
  String get Couldnt_open_Club {
    return Intl.message(
      'Couldn\'t open Club!',
      name: 'Couldnt_open_Club',
      desc: '',
      args: [],
    );
  }

  /// `friends since`
  String get Friend_since {
    return Intl.message(
      'friends since',
      name: 'Friend_since',
      desc: '',
      args: [],
    );
  }

  /// `last seen`
  String get last_seen {
    return Intl.message(
      'last seen',
      name: 'last_seen',
      desc: '',
      args: [],
    );
  }

  /// `Sort the list based on`
  String get Sort_the_list_based_on {
    return Intl.message(
      'Sort the list based on',
      name: 'Sort_the_list_based_on',
      desc: '',
      args: [],
    );
  }

  /// `No Content`
  String get No_Content {
    return Intl.message(
      'No Content',
      name: 'No_Content',
      desc: '',
      args: [],
    );
  }

  /// `Load More`
  String get Load_More {
    return Intl.message(
      'Load More',
      name: 'Load_More',
      desc: '',
      args: [],
    );
  }

  /// `No More found!`
  String get No_More_found {
    return Intl.message(
      'No More found!',
      name: 'No_More_found',
      desc: '',
      args: [],
    );
  }

  /// `Trying to fetch your account details`
  String get Account_fetch_details {
    return Intl.message(
      'Trying to fetch your account details',
      name: 'Account_fetch_details',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to get all the benifits from MAL world.`
  String get Sign_in_Suggestions {
    return Intl.message(
      'Sign in to get all the benifits from MAL world.',
      name: 'Sign_in_Suggestions',
      desc: '',
      args: [],
    );
  }

  /// `Setup Timed out. Please try again.`
  String get Setup_timed_out {
    return Intl.message(
      'Setup Timed out. Please try again.',
      name: 'Setup_timed_out',
      desc: '',
      args: [],
    );
  }

  /// `Tap to Sign In`
  String get Tap_to_Sign_In {
    return Intl.message(
      'Tap to Sign In',
      name: 'Tap_to_Sign_In',
      desc: '',
      args: [],
    );
  }

  /// `Keep track of your favorite anime/manga`
  String get Intro_line_One {
    return Intl.message(
      'Keep track of your favorite anime/manga',
      name: 'Intro_line_One',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Surf through the forums to your hearts content.`
  String get Intro_line_Two {
    return Intl.message(
      'Surf through the forums to your hearts content.',
      name: 'Intro_line_Two',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get Skip {
    return Intl.message(
      'Skip',
      name: 'Skip',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get Previous {
    return Intl.message(
      'Previous',
      name: 'Previous',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get Next {
    return Intl.message(
      'Next',
      name: 'Next',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't retreive Content`
  String get Couldnt_retreive_Content {
    return Intl.message(
      'Couldn\'t retreive Content',
      name: 'Couldnt_retreive_Content',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get Details {
    return Intl.message(
      'Details',
      name: 'Details',
      desc: '',
      args: [],
    );
  }

  /// `Voice Acting Roles`
  String get Voice_Acting_Roles {
    return Intl.message(
      'Voice Acting Roles',
      name: 'Voice_Acting_Roles',
      desc: '',
      args: [],
    );
  }

  /// `Published Manga`
  String get Published_Manga {
    return Intl.message(
      'Published Manga',
      name: 'Published_Manga',
      desc: '',
      args: [],
    );
  }

  /// `Voice Actors`
  String get Voice_Actors {
    return Intl.message(
      'Voice Actors',
      name: 'Voice_Actors',
      desc: '',
      args: [],
    );
  }

  /// `Anime Staff`
  String get Anime_Staff {
    return Intl.message(
      'Anime Staff',
      name: 'Anime_Staff',
      desc: '',
      args: [],
    );
  }

  /// `general`
  String get general {
    return Intl.message(
      'general',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `related articles`
  String get related_articles {
    return Intl.message(
      'related articles',
      name: 'related_articles',
      desc: '',
      args: [],
    );
  }

  /// `Views`
  String get Views {
    return Intl.message(
      'Views',
      name: 'Views',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get Comments {
    return Intl.message(
      'Comments',
      name: 'Comments',
      desc: '',
      args: [],
    );
  }

  /// `Poll Question`
  String get Poll_Question {
    return Intl.message(
      'Poll Question',
      name: 'Poll_Question',
      desc: '',
      args: [],
    );
  }

  /// `Sort By`
  String get Sort_By {
    return Intl.message(
      'Sort By',
      name: 'Sort_By',
      desc: '',
      args: [],
    );
  }

  /// `Copied to Clipboard!`
  String get Copied_to_Clipboard {
    return Intl.message(
      'Copied to Clipboard!',
      name: 'Copied_to_Clipboard',
      desc: '',
      args: [],
    );
  }

  /// `No. of Posts`
  String get No_of_Posts {
    return Intl.message(
      'No. of Posts',
      name: 'No_of_Posts',
      desc: '',
      args: [],
    );
  }

  /// `Discussions`
  String get Discussions {
    return Intl.message(
      'Discussions',
      name: 'Discussions',
      desc: '',
      args: [],
    );
  }

  /// `No results found!`
  String get No_results_found {
    return Intl.message(
      'No results found!',
      name: 'No_results_found',
      desc: '',
      args: [],
    );
  }

  /// `Select a Category`
  String get Select_a_Category {
    return Intl.message(
      'Select a Category',
      name: 'Select_a_Category',
      desc: '',
      args: [],
    );
  }

  /// `Tags will not be applied with the search query.`
  String get Tags_unApplied {
    return Intl.message(
      'Tags will not be applied with the search query.',
      name: 'Tags_unApplied',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get Filter {
    return Intl.message(
      'Filter',
      name: 'Filter',
      desc: '',
      args: [],
    );
  }

  /// `Select either Board or Sub-Board`
  String get Select_either_Board_or_Sub_Board {
    return Intl.message(
      'Select either Board or Sub-Board',
      name: 'Select_either_Board_or_Sub_Board',
      desc: '',
      args: [],
    );
  }

  /// `Username of the person who created the topic`
  String get Topic_Username_desc {
    return Intl.message(
      'Username of the person who created the topic',
      name: 'Topic_Username_desc',
      desc: '',
      args: [],
    );
  }

  /// `Any Username`
  String get Any_Username {
    return Intl.message(
      'Any Username',
      name: 'Any_Username',
      desc: '',
      args: [],
    );
  }

  /// `Filter type of results`
  String get Filter_type_of_results {
    return Intl.message(
      'Filter type of results',
      name: 'Filter_type_of_results',
      desc: '',
      args: [],
    );
  }

  /// `Filter status of results`
  String get Filter_status_of_results {
    return Intl.message(
      'Filter status of results',
      name: 'Filter_status_of_results',
      desc: '',
      args: [],
    );
  }

  /// `Include the genre here`
  String get Include_the_genre_here {
    return Intl.message(
      'Include the genre here',
      name: 'Include_the_genre_here',
      desc: '',
      args: [],
    );
  }

  /// `Exclude the genre here`
  String get Exclude_the_genre_here {
    return Intl.message(
      'Exclude the genre here',
      name: 'Exclude_the_genre_here',
      desc: '',
      args: [],
    );
  }

  /// `Order results with respect to a property`
  String get Order_results_property {
    return Intl.message(
      'Order results with respect to a property',
      name: 'Order_results_property',
      desc: '',
      args: [],
    );
  }

  /// `Sort Order by`
  String get Sort_Order_by {
    return Intl.message(
      'Sort Order by',
      name: 'Sort_Order_by',
      desc: '',
      args: [],
    );
  }

  /// `Filter score of results`
  String get Filter_score_of_results {
    return Intl.message(
      'Filter score of results',
      name: 'Filter_score_of_results',
      desc: '',
      args: [],
    );
  }

  /// `Filter start date of results`
  String get Filter_start_date_of_results {
    return Intl.message(
      'Filter start date of results',
      name: 'Filter_start_date_of_results',
      desc: '',
      args: [],
    );
  }

  /// `Filter end date of results`
  String get Filter_end_date_of_results {
    return Intl.message(
      'Filter end date of results',
      name: 'Filter_end_date_of_results',
      desc: '',
      args: [],
    );
  }

  /// `Search manga by the letter/character it starts with`
  String get Starting_with_manga {
    return Intl.message(
      'Search manga by the letter/character it starts with',
      name: 'Starting_with_manga',
      desc: '',
      args: [],
    );
  }

  /// `Filter type of results, By default ordered by Member Count`
  String get Filter_type_of_results_anime {
    return Intl.message(
      'Filter type of results, By default ordered by Member Count',
      name: 'Filter_type_of_results_anime',
      desc: '',
      args: [],
    );
  }

  /// `Filter age rating of results`
  String get Filter_age_rating_of_results {
    return Intl.message(
      'Filter age rating of results',
      name: 'Filter_age_rating_of_results',
      desc: '',
      args: [],
    );
  }

  /// `Search anime by the letter/character it starts with`
  String get Starting_with_anime {
    return Intl.message(
      'Search anime by the letter/character it starts with',
      name: 'Starting_with_anime',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get Start_Date {
    return Intl.message(
      'Start Date',
      name: 'Start_Date',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get End_Date {
    return Intl.message(
      'End Date',
      name: 'End_Date',
      desc: '',
      args: [],
    );
  }

  /// `Starting With`
  String get Starting_With {
    return Intl.message(
      'Starting With',
      name: 'Starting_With',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get Location {
    return Intl.message(
      'Location',
      name: 'Location',
      desc: '',
      args: [],
    );
  }

  /// `Age low`
  String get Age_low {
    return Intl.message(
      'Age low',
      name: 'Age_low',
      desc: '',
      args: [],
    );
  }

  /// `Age high`
  String get Age_high {
    return Intl.message(
      'Age high',
      name: 'Age_high',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get Gender {
    return Intl.message(
      'Gender',
      name: 'Gender',
      desc: '',
      args: [],
    );
  }

  /// `Don't care by default`
  String get Gender_desc {
    return Intl.message(
      'Don\'t care by default',
      name: 'Gender_desc',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get Tags {
    return Intl.message(
      'Tags',
      name: 'Tags',
      desc: '',
      args: [],
    );
  }

  /// `For Ex: Recommendation tag will give you some awesome recommendations.`
  String get Featured_Tags_desc {
    return Intl.message(
      'For Ex: Recommendation tag will give you some awesome recommendations.',
      name: 'Featured_Tags_desc',
      desc: '',
      args: [],
    );
  }

  /// `For Ex: Recommendation tag will give you some awesome recommendations.`
  String get News_Tags_desc {
    return Intl.message(
      'For Ex: Recommendation tag will give you some awesome recommendations.',
      name: 'News_Tags_desc',
      desc: '',
      args: [],
    );
  }

  /// `Search for`
  String get Search_for {
    return Intl.message(
      'Search for',
      name: 'Search_for',
      desc: '',
      args: [],
    );
  }

  /// `Search for your favourite anime, manga and more..`
  String get Search_Page_Intro {
    return Intl.message(
      'Search for your favourite anime, manga and more..',
      name: 'Search_Page_Intro',
      desc: '',
      args: [],
    );
  }

  /// `Featured Articles`
  String get Featured_Articles {
    return Intl.message(
      'Featured Articles',
      name: 'Featured_Articles',
      desc: '',
      args: [],
    );
  }

  /// `News`
  String get News {
    return Intl.message(
      'News',
      name: 'News',
      desc: '',
      args: [],
    );
  }

  /// `Search Results`
  String get Search_Results {
    return Intl.message(
      'Search Results',
      name: 'Search_Results',
      desc: '',
      args: [],
    );
  }

  /// `Top Anime Categories`
  String get Top_Anime_Categories {
    return Intl.message(
      'Top Anime Categories',
      name: 'Top_Anime_Categories',
      desc: '',
      args: [],
    );
  }

  /// `Search By Season`
  String get Search_By_Season {
    return Intl.message(
      'Search By Season',
      name: 'Search_By_Season',
      desc: '',
      args: [],
    );
  }

  /// `Genre Include`
  String get Genre_Include {
    return Intl.message(
      'Genre Include',
      name: 'Genre_Include',
      desc: '',
      args: [],
    );
  }

  /// `Genre Exclude`
  String get Genre_Exclude {
    return Intl.message(
      'Genre Exclude',
      name: 'Genre_Exclude',
      desc: '',
      args: [],
    );
  }

  /// `Order By`
  String get Order_by {
    return Intl.message(
      'Order By',
      name: 'Order_by',
      desc: '',
      args: [],
    );
  }

  /// `Anime Discussion`
  String get Anime_Discussion {
    return Intl.message(
      'Anime Discussion',
      name: 'Anime_Discussion',
      desc: '',
      args: [],
    );
  }

  /// `Manga Discussion`
  String get Manga_Discussion {
    return Intl.message(
      'Manga Discussion',
      name: 'Manga_Discussion',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get Support {
    return Intl.message(
      'Support',
      name: 'Support',
      desc: '',
      args: [],
    );
  }

  /// `Suggestions`
  String get Suggestions {
    return Intl.message(
      'Suggestions',
      name: 'Suggestions',
      desc: '',
      args: [],
    );
  }

  /// `Updates & Announcements`
  String get Updates_Announcements {
    return Intl.message(
      'Updates & Announcements',
      name: 'Updates_Announcements',
      desc: '',
      args: [],
    );
  }

  /// `Current Events`
  String get Current_Events {
    return Intl.message(
      'Current Events',
      name: 'Current_Events',
      desc: '',
      args: [],
    );
  }

  /// `Games, Computers & Tech Support`
  String get Games_Computers_Tech_Support {
    return Intl.message(
      'Games, Computers & Tech Support',
      name: 'Games_Computers_Tech_Support',
      desc: '',
      args: [],
    );
  }

  /// `Introductions`
  String get Introductions {
    return Intl.message(
      'Introductions',
      name: 'Introductions',
      desc: '',
      args: [],
    );
  }

  /// `Forum Games`
  String get Forum_Games {
    return Intl.message(
      'Forum Games',
      name: 'Forum_Games',
      desc: '',
      args: [],
    );
  }

  /// `Music & Entertainment`
  String get Music_Entertainment {
    return Intl.message(
      'Music & Entertainment',
      name: 'Music_Entertainment',
      desc: '',
      args: [],
    );
  }

  /// `Casual Discussion`
  String get Casual_Discussion {
    return Intl.message(
      'Casual Discussion',
      name: 'Casual_Discussion',
      desc: '',
      args: [],
    );
  }

  /// `Creative Corner`
  String get Creative_Corner {
    return Intl.message(
      'Creative Corner',
      name: 'Creative_Corner',
      desc: '',
      args: [],
    );
  }

  /// `MAL Contests`
  String get MAL_Contests {
    return Intl.message(
      'MAL Contests',
      name: 'MAL_Contests',
      desc: '',
      args: [],
    );
  }

  /// `MAL Guidelines & FAQ`
  String get MAL_Guidelines_FAQ {
    return Intl.message(
      'MAL Guidelines & FAQ',
      name: 'MAL_Guidelines_FAQ',
      desc: '',
      args: [],
    );
  }

  /// `News Discussion`
  String get News_Discussion {
    return Intl.message(
      'News Discussion',
      name: 'News_Discussion',
      desc: '',
      args: [],
    );
  }

  /// `Anime & Manga Recommendations`
  String get Anime_Manga_Recommendations {
    return Intl.message(
      'Anime & Manga Recommendations',
      name: 'Anime_Manga_Recommendations',
      desc: '',
      args: [],
    );
  }

  /// `DB Modification Requests`
  String get DB_Modification_Requests {
    return Intl.message(
      'DB Modification Requests',
      name: 'DB_Modification_Requests',
      desc: '',
      args: [],
    );
  }

  /// `Series Discussion`
  String get Series_Discussion {
    return Intl.message(
      'Series Discussion',
      name: 'Series_Discussion',
      desc: '',
      args: [],
    );
  }

  /// `Anime Series`
  String get Anime_Series {
    return Intl.message(
      'Anime Series',
      name: 'Anime_Series',
      desc: '',
      args: [],
    );
  }

  /// `Anime DB`
  String get Anime_DB {
    return Intl.message(
      'Anime DB',
      name: 'Anime_DB',
      desc: '',
      args: [],
    );
  }

  /// `Character & People DB`
  String get Character_People_DB {
    return Intl.message(
      'Character & People DB',
      name: 'Character_People_DB',
      desc: '',
      args: [],
    );
  }

  /// `Manga Series`
  String get Manga_Series {
    return Intl.message(
      'Manga Series',
      name: 'Manga_Series',
      desc: '',
      args: [],
    );
  }

  /// `Manga DB`
  String get Manga_DB {
    return Intl.message(
      'Manga DB',
      name: 'Manga_DB',
      desc: '',
      args: [],
    );
  }

  /// `Interview`
  String get Interview {
    return Intl.message(
      'Interview',
      name: 'Interview',
      desc: '',
      args: [],
    );
  }

  /// `Live Action`
  String get Live_Action {
    return Intl.message(
      'Live Action',
      name: 'Live_Action',
      desc: '',
      args: [],
    );
  }

  /// `Recap`
  String get Recap {
    return Intl.message(
      'Recap',
      name: 'Recap',
      desc: '',
      args: [],
    );
  }

  /// `Recommendation`
  String get Recommendation {
    return Intl.message(
      'Recommendation',
      name: 'Recommendation',
      desc: '',
      args: [],
    );
  }

  /// `Collection`
  String get Collection {
    return Intl.message(
      'Collection',
      name: 'Collection',
      desc: '',
      args: [],
    );
  }

  /// `Analysis`
  String get Analysis {
    return Intl.message(
      'Analysis',
      name: 'Analysis',
      desc: '',
      args: [],
    );
  }

  /// `Japanese Life`
  String get Japanese_Life {
    return Intl.message(
      'Japanese Life',
      name: 'Japanese_Life',
      desc: '',
      args: [],
    );
  }

  /// `Anime Terms`
  String get Anime_Terms {
    return Intl.message(
      'Anime Terms',
      name: 'Anime_Terms',
      desc: '',
      args: [],
    );
  }

  /// `Quotes`
  String get Quotes {
    return Intl.message(
      'Quotes',
      name: 'Quotes',
      desc: '',
      args: [],
    );
  }

  /// `Anime Archetypes`
  String get Anime_Archetypes {
    return Intl.message(
      'Anime Archetypes',
      name: 'Anime_Archetypes',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get Action {
    return Intl.message(
      'Action',
      name: 'Action',
      desc: '',
      args: [],
    );
  }

  /// `Animals`
  String get Animals {
    return Intl.message(
      'Animals',
      name: 'Animals',
      desc: '',
      args: [],
    );
  }

  /// `Arch Enemies`
  String get Arch_Enemies {
    return Intl.message(
      'Arch Enemies',
      name: 'Arch_Enemies',
      desc: '',
      args: [],
    );
  }

  /// `Background Analysis`
  String get Background_Analysis {
    return Intl.message(
      'Background Analysis',
      name: 'Background_Analysis',
      desc: '',
      args: [],
    );
  }

  /// `Brother complex`
  String get Brother_complex {
    return Intl.message(
      'Brother complex',
      name: 'Brother_complex',
      desc: '',
      args: [],
    );
  }

  /// `Character Analysis`
  String get Character_Analysis {
    return Intl.message(
      'Character Analysis',
      name: 'Character_Analysis',
      desc: '',
      args: [],
    );
  }

  /// `Cold hearted`
  String get Cold_hearted {
    return Intl.message(
      'Cold hearted',
      name: 'Cold_hearted',
      desc: '',
      args: [],
    );
  }

  /// `Cute Girls`
  String get Cute_Girls {
    return Intl.message(
      'Cute Girls',
      name: 'Cute_Girls',
      desc: '',
      args: [],
    );
  }

  /// `Cute Guys`
  String get Cute_Guys {
    return Intl.message(
      'Cute Guys',
      name: 'Cute_Guys',
      desc: '',
      args: [],
    );
  }

  /// `Despair`
  String get Despair {
    return Intl.message(
      'Despair',
      name: 'Despair',
      desc: '',
      args: [],
    );
  }

  /// `Director`
  String get Director {
    return Intl.message(
      'Director',
      name: 'Director',
      desc: '',
      args: [],
    );
  }

  /// `Fan Made`
  String get Fan_Made {
    return Intl.message(
      'Fan Made',
      name: 'Fan_Made',
      desc: '',
      args: [],
    );
  }

  /// `Fashion`
  String get Fashion {
    return Intl.message(
      'Fashion',
      name: 'Fashion',
      desc: '',
      args: [],
    );
  }

  /// `Figures`
  String get Figures {
    return Intl.message(
      'Figures',
      name: 'Figures',
      desc: '',
      args: [],
    );
  }

  /// `First Impression`
  String get First_Impression {
    return Intl.message(
      'First Impression',
      name: 'First_Impression',
      desc: '',
      args: [],
    );
  }

  /// `Friendship`
  String get Friendship {
    return Intl.message(
      'Friendship',
      name: 'Friendship',
      desc: '',
      args: [],
    );
  }

  /// `Funny`
  String get Funny {
    return Intl.message(
      'Funny',
      name: 'Funny',
      desc: '',
      args: [],
    );
  }

  /// `Games`
  String get Games {
    return Intl.message(
      'Games',
      name: 'Games',
      desc: '',
      args: [],
    );
  }

  /// `Heart-warming`
  String get Heart_warming {
    return Intl.message(
      'Heart-warming',
      name: 'Heart_warming',
      desc: '',
      args: [],
    );
  }

  /// `History and Culture`
  String get History_and_Culture {
    return Intl.message(
      'History and Culture',
      name: 'History_and_Culture',
      desc: '',
      args: [],
    );
  }

  /// `Honor`
  String get Honor {
    return Intl.message(
      'Honor',
      name: 'Honor',
      desc: '',
      args: [],
    );
  }

  /// `Horror`
  String get Horror {
    return Intl.message(
      'Horror',
      name: 'Horror',
      desc: '',
      args: [],
    );
  }

  /// `Kawaii`
  String get Kawaii {
    return Intl.message(
      'Kawaii',
      name: 'Kawaii',
      desc: '',
      args: [],
    );
  }

  /// `Love`
  String get Love {
    return Intl.message(
      'Love',
      name: 'Love',
      desc: '',
      args: [],
    );
  }

  /// `Magical`
  String get Magical {
    return Intl.message(
      'Magical',
      name: 'Magical',
      desc: '',
      args: [],
    );
  }

  /// `Mangaka`
  String get Mangaka {
    return Intl.message(
      'Mangaka',
      name: 'Mangaka',
      desc: '',
      args: [],
    );
  }

  /// `Moe`
  String get Moe {
    return Intl.message(
      'Moe',
      name: 'Moe',
      desc: '',
      args: [],
    );
  }

  /// `Monsters`
  String get Monsters {
    return Intl.message(
      'Monsters',
      name: 'Monsters',
      desc: '',
      args: [],
    );
  }

  /// `Music`
  String get Music {
    return Intl.message(
      'Music',
      name: 'Music',
      desc: '',
      args: [],
    );
  }

  /// `Plot twist`
  String get Plot_twist {
    return Intl.message(
      'Plot twist',
      name: 'Plot_twist',
      desc: '',
      args: [],
    );
  }

  /// `Review`
  String get Review {
    return Intl.message(
      'Review',
      name: 'Review',
      desc: '',
      args: [],
    );
  }

  /// `Seiyuu`
  String get Seiyuu {
    return Intl.message(
      'Seiyuu',
      name: 'Seiyuu',
      desc: '',
      args: [],
    );
  }

  /// `Sister Complex`
  String get Sister_Complex {
    return Intl.message(
      'Sister Complex',
      name: 'Sister_Complex',
      desc: '',
      args: [],
    );
  }

  /// `School Life`
  String get School_Life {
    return Intl.message(
      'School Life',
      name: 'School_Life',
      desc: '',
      args: [],
    );
  }

  /// `Attack on Titan`
  String get Attack_on_Titan {
    return Intl.message(
      'Attack on Titan',
      name: 'Attack_on_Titan',
      desc: '',
      args: [],
    );
  }

  /// `Weapons`
  String get Weapons {
    return Intl.message(
      'Weapons',
      name: 'Weapons',
      desc: '',
      args: [],
    );
  }

  /// `Sports`
  String get Sports {
    return Intl.message(
      'Sports',
      name: 'Sports',
      desc: '',
      args: [],
    );
  }

  /// `Hot`
  String get Hot {
    return Intl.message(
      'Hot',
      name: 'Hot',
      desc: '',
      args: [],
    );
  }

  /// `Food`
  String get Food {
    return Intl.message(
      'Food',
      name: 'Food',
      desc: '',
      args: [],
    );
  }

  /// `Family`
  String get Family {
    return Intl.message(
      'Family',
      name: 'Family',
      desc: '',
      args: [],
    );
  }

  /// `Supernatural`
  String get Supernatural {
    return Intl.message(
      'Supernatural',
      name: 'Supernatural',
      desc: '',
      args: [],
    );
  }

  /// `Superhuman`
  String get Superhuman {
    return Intl.message(
      'Superhuman',
      name: 'Superhuman',
      desc: '',
      args: [],
    );
  }

  /// `Game Adaptation`
  String get Game_Adaptation {
    return Intl.message(
      'Game Adaptation',
      name: 'Game_Adaptation',
      desc: '',
      args: [],
    );
  }

  /// `Sci-fi`
  String get Sci_fi {
    return Intl.message(
      'Sci-fi',
      name: 'Sci_fi',
      desc: '',
      args: [],
    );
  }

  /// `GIF`
  String get GIF {
    return Intl.message(
      'GIF',
      name: 'GIF',
      desc: '',
      args: [],
    );
  }

  /// `Art`
  String get Art {
    return Intl.message(
      'Art',
      name: 'Art',
      desc: '',
      args: [],
    );
  }

  /// `One Piece`
  String get One_Piece {
    return Intl.message(
      'One Piece',
      name: 'One_Piece',
      desc: '',
      args: [],
    );
  }

  /// `Naruto`
  String get Naruto {
    return Intl.message(
      'Naruto',
      name: 'Naruto',
      desc: '',
      args: [],
    );
  }

  /// `Dragon Ball`
  String get Dragon_Ball {
    return Intl.message(
      'Dragon Ball',
      name: 'Dragon_Ball',
      desc: '',
      args: [],
    );
  }

  /// `Bleach`
  String get Bleach {
    return Intl.message(
      'Bleach',
      name: 'Bleach',
      desc: '',
      args: [],
    );
  }

  /// `Fairy Tail`
  String get Fairy_Tail {
    return Intl.message(
      'Fairy Tail',
      name: 'Fairy_Tail',
      desc: '',
      args: [],
    );
  }

  /// `Ghibli`
  String get Ghibli {
    return Intl.message(
      'Ghibli',
      name: 'Ghibli',
      desc: '',
      args: [],
    );
  }

  /// `SAO`
  String get SAO {
    return Intl.message(
      'SAO',
      name: 'SAO',
      desc: '',
      args: [],
    );
  }

  /// `Sailor Moon`
  String get Sailor_Moon {
    return Intl.message(
      'Sailor Moon',
      name: 'Sailor_Moon',
      desc: '',
      args: [],
    );
  }

  /// `Tokyo Ghoul`
  String get Tokyo_Ghoul {
    return Intl.message(
      'Tokyo Ghoul',
      name: 'Tokyo_Ghoul',
      desc: '',
      args: [],
    );
  }

  /// `Hunter x Hunter`
  String get Hunter_x_Hunter {
    return Intl.message(
      'Hunter x Hunter',
      name: 'Hunter_x_Hunter',
      desc: '',
      args: [],
    );
  }

  /// `Death Note`
  String get Death_Note {
    return Intl.message(
      'Death Note',
      name: 'Death_Note',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get Video {
    return Intl.message(
      'Video',
      name: 'Video',
      desc: '',
      args: [],
    );
  }

  /// `Trivia`
  String get Trivia {
    return Intl.message(
      'Trivia',
      name: 'Trivia',
      desc: '',
      args: [],
    );
  }

  /// `One Punch Man`
  String get One_Punch_Man {
    return Intl.message(
      'One Punch Man',
      name: 'One_Punch_Man',
      desc: '',
      args: [],
    );
  }

  /// `Meme`
  String get Meme {
    return Intl.message(
      'Meme',
      name: 'Meme',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get Events {
    return Intl.message(
      'Events',
      name: 'Events',
      desc: '',
      args: [],
    );
  }

  /// `Technology`
  String get Technology {
    return Intl.message(
      'Technology',
      name: 'Technology',
      desc: '',
      args: [],
    );
  }

  /// `Editorial`
  String get Editorial {
    return Intl.message(
      'Editorial',
      name: 'Editorial',
      desc: '',
      args: [],
    );
  }

  /// `Cosplay`
  String get Cosplay {
    return Intl.message(
      'Cosplay',
      name: 'Cosplay',
      desc: '',
      args: [],
    );
  }

  /// `Crowdfunding`
  String get Crowdfunding {
    return Intl.message(
      'Crowdfunding',
      name: 'Crowdfunding',
      desc: '',
      args: [],
    );
  }

  /// `New Anime`
  String get New_Anime {
    return Intl.message(
      'New Anime',
      name: 'New_Anime',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2015`
  String get Spring_2015 {
    return Intl.message(
      'Spring 2015',
      name: 'Spring_2015',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2015`
  String get Summer_2015 {
    return Intl.message(
      'Summer 2015',
      name: 'Summer_2015',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2015`
  String get Fall_2015 {
    return Intl.message(
      'Fall 2015',
      name: 'Fall_2015',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2016`
  String get Winter_2016 {
    return Intl.message(
      'Winter 2016',
      name: 'Winter_2016',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2016`
  String get Spring_2016 {
    return Intl.message(
      'Spring 2016',
      name: 'Spring_2016',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get Preview {
    return Intl.message(
      'Preview',
      name: 'Preview',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast`
  String get Broadcast {
    return Intl.message(
      'Broadcast',
      name: 'Broadcast',
      desc: '',
      args: [],
    );
  }

  /// `English Dub`
  String get English_Dub {
    return Intl.message(
      'English Dub',
      name: 'English_Dub',
      desc: '',
      args: [],
    );
  }

  /// `BD DVD`
  String get BD_DVD {
    return Intl.message(
      'BD DVD',
      name: 'BD_DVD',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2016`
  String get Summer_2016 {
    return Intl.message(
      'Summer 2016',
      name: 'Summer_2016',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2016`
  String get Fall_2016 {
    return Intl.message(
      'Fall 2016',
      name: 'Fall_2016',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2017`
  String get Winter_2017 {
    return Intl.message(
      'Winter 2017',
      name: 'Winter_2017',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2017`
  String get Spring_2017 {
    return Intl.message(
      'Spring 2017',
      name: 'Spring_2017',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2017`
  String get Summer_2017 {
    return Intl.message(
      'Summer 2017',
      name: 'Summer_2017',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2017`
  String get Fall_2017 {
    return Intl.message(
      'Fall 2017',
      name: 'Fall_2017',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2007`
  String get Spring_2007 {
    return Intl.message(
      'Spring 2007',
      name: 'Spring_2007',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2007`
  String get Summer_2007 {
    return Intl.message(
      'Summer 2007',
      name: 'Summer_2007',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2007`
  String get Fall_2007 {
    return Intl.message(
      'Fall 2007',
      name: 'Fall_2007',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2008`
  String get Winter_2008 {
    return Intl.message(
      'Winter 2008',
      name: 'Winter_2008',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2008`
  String get Spring_2008 {
    return Intl.message(
      'Spring 2008',
      name: 'Spring_2008',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2008`
  String get Summer_2008 {
    return Intl.message(
      'Summer 2008',
      name: 'Summer_2008',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2008`
  String get Fall_2008 {
    return Intl.message(
      'Fall 2008',
      name: 'Fall_2008',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2009`
  String get Winter_2009 {
    return Intl.message(
      'Winter 2009',
      name: 'Winter_2009',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2009`
  String get Spring_2009 {
    return Intl.message(
      'Spring 2009',
      name: 'Spring_2009',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2009`
  String get Summer_2009 {
    return Intl.message(
      'Summer 2009',
      name: 'Summer_2009',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2009`
  String get Fall_2009 {
    return Intl.message(
      'Fall 2009',
      name: 'Fall_2009',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2010`
  String get Winter_2010 {
    return Intl.message(
      'Winter 2010',
      name: 'Winter_2010',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2010`
  String get Spring_2010 {
    return Intl.message(
      'Spring 2010',
      name: 'Spring_2010',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2010`
  String get Summer_2010 {
    return Intl.message(
      'Summer 2010',
      name: 'Summer_2010',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2010`
  String get Fall_2010 {
    return Intl.message(
      'Fall 2010',
      name: 'Fall_2010',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2011`
  String get Winter_2011 {
    return Intl.message(
      'Winter 2011',
      name: 'Winter_2011',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2011`
  String get Spring_2011 {
    return Intl.message(
      'Spring 2011',
      name: 'Spring_2011',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2011`
  String get Summer_2011 {
    return Intl.message(
      'Summer 2011',
      name: 'Summer_2011',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2011`
  String get Fall_2011 {
    return Intl.message(
      'Fall 2011',
      name: 'Fall_2011',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2012`
  String get Winter_2012 {
    return Intl.message(
      'Winter 2012',
      name: 'Winter_2012',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2012`
  String get Spring_2012 {
    return Intl.message(
      'Spring 2012',
      name: 'Spring_2012',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2012`
  String get Summer_2012 {
    return Intl.message(
      'Summer 2012',
      name: 'Summer_2012',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2012`
  String get Fall_2012 {
    return Intl.message(
      'Fall 2012',
      name: 'Fall_2012',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2013`
  String get Winter_2013 {
    return Intl.message(
      'Winter 2013',
      name: 'Winter_2013',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2013`
  String get Spring_2013 {
    return Intl.message(
      'Spring 2013',
      name: 'Spring_2013',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2013`
  String get Summer_2013 {
    return Intl.message(
      'Summer 2013',
      name: 'Summer_2013',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2013`
  String get Fall_2013 {
    return Intl.message(
      'Fall 2013',
      name: 'Fall_2013',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2014`
  String get Winter_2014 {
    return Intl.message(
      'Winter 2014',
      name: 'Winter_2014',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2014`
  String get Spring_2014 {
    return Intl.message(
      'Spring 2014',
      name: 'Spring_2014',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2014`
  String get Summer_2014 {
    return Intl.message(
      'Summer 2014',
      name: 'Summer_2014',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2014`
  String get Fall_2014 {
    return Intl.message(
      'Fall 2014',
      name: 'Fall_2014',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2015`
  String get Winter_2015 {
    return Intl.message(
      'Winter 2015',
      name: 'Winter_2015',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2018`
  String get Winter_2018 {
    return Intl.message(
      'Winter 2018',
      name: 'Winter_2018',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2018`
  String get Spring_2018 {
    return Intl.message(
      'Spring 2018',
      name: 'Spring_2018',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2018`
  String get Summer_2018 {
    return Intl.message(
      'Summer 2018',
      name: 'Summer_2018',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2018`
  String get Fall_2018 {
    return Intl.message(
      'Fall 2018',
      name: 'Fall_2018',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2019`
  String get Winter_2019 {
    return Intl.message(
      'Winter 2019',
      name: 'Winter_2019',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2019`
  String get Spring_2019 {
    return Intl.message(
      'Spring 2019',
      name: 'Spring_2019',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2019`
  String get Summer_2019 {
    return Intl.message(
      'Summer 2019',
      name: 'Summer_2019',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2019`
  String get Fall_2019 {
    return Intl.message(
      'Fall 2019',
      name: 'Fall_2019',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2020`
  String get Winter_2020 {
    return Intl.message(
      'Winter 2020',
      name: 'Winter_2020',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2020`
  String get Spring_2020 {
    return Intl.message(
      'Spring 2020',
      name: 'Spring_2020',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2020`
  String get Fall_2020 {
    return Intl.message(
      'Fall 2020',
      name: 'Fall_2020',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2020`
  String get Summer_2020 {
    return Intl.message(
      'Summer 2020',
      name: 'Summer_2020',
      desc: '',
      args: [],
    );
  }

  /// `Screening`
  String get Screening {
    return Intl.message(
      'Screening',
      name: 'Screening',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2021`
  String get Winter_2021 {
    return Intl.message(
      'Winter 2021',
      name: 'Winter_2021',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2021`
  String get Spring_2021 {
    return Intl.message(
      'Spring 2021',
      name: 'Spring_2021',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2021`
  String get Summer_2021 {
    return Intl.message(
      'Summer 2021',
      name: 'Summer_2021',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2021`
  String get Fall_2021 {
    return Intl.message(
      'Fall 2021',
      name: 'Fall_2021',
      desc: '',
      args: [],
    );
  }

  /// `Winter 2022`
  String get Winter_2022 {
    return Intl.message(
      'Winter 2022',
      name: 'Winter_2022',
      desc: '',
      args: [],
    );
  }

  /// `Spring 2022`
  String get Spring_2022 {
    return Intl.message(
      'Spring 2022',
      name: 'Spring_2022',
      desc: '',
      args: [],
    );
  }

  /// `Summer 2022`
  String get Summer_2022 {
    return Intl.message(
      'Summer 2022',
      name: 'Summer_2022',
      desc: '',
      args: [],
    );
  }

  /// `Fall 2022`
  String get Fall_2022 {
    return Intl.message(
      'Fall 2022',
      name: 'Fall_2022',
      desc: '',
      args: [],
    );
  }

  /// `Adapts Manga`
  String get Adapts_Manga {
    return Intl.message(
      'Adapts Manga',
      name: 'Adapts_Manga',
      desc: '',
      args: [],
    );
  }

  /// `Light Novels`
  String get Light_Novels {
    return Intl.message(
      'Light Novels',
      name: 'Light_Novels',
      desc: '',
      args: [],
    );
  }

  /// `New Manga`
  String get New_Manga {
    return Intl.message(
      'New Manga',
      name: 'New_Manga',
      desc: '',
      args: [],
    );
  }

  /// `Series End`
  String get Series_End {
    return Intl.message(
      'Series End',
      name: 'Series_End',
      desc: '',
      args: [],
    );
  }

  /// `Hiatus`
  String get Hiatus {
    return Intl.message(
      'Hiatus',
      name: 'Hiatus',
      desc: '',
      args: [],
    );
  }

  /// `Special Chapter`
  String get Special_Chapter {
    return Intl.message(
      'Special Chapter',
      name: 'Special_Chapter',
      desc: '',
      args: [],
    );
  }

  /// `Life Event`
  String get Life_Event {
    return Intl.message(
      'Life Event',
      name: 'Life_Event',
      desc: '',
      args: [],
    );
  }

  /// `Staff`
  String get Staff {
    return Intl.message(
      'Staff',
      name: 'Staff',
      desc: '',
      args: [],
    );
  }

  /// `Musician`
  String get Musician {
    return Intl.message(
      'Musician',
      name: 'Musician',
      desc: '',
      args: [],
    );
  }

  /// `New CD`
  String get New_CD {
    return Intl.message(
      'New CD',
      name: 'New_CD',
      desc: '',
      args: [],
    );
  }

  /// `OP ED`
  String get OP_ED {
    return Intl.message(
      'OP ED',
      name: 'OP_ED',
      desc: '',
      args: [],
    );
  }

  /// `Anime Expo`
  String get Anime_Expo {
    return Intl.message(
      'Anime Expo',
      name: 'Anime_Expo',
      desc: '',
      args: [],
    );
  }

  /// `Exhibition`
  String get Exhibition {
    return Intl.message(
      'Exhibition',
      name: 'Exhibition',
      desc: '',
      args: [],
    );
  }

  /// `Interest`
  String get Interest {
    return Intl.message(
      'Interest',
      name: 'Interest',
      desc: '',
      args: [],
    );
  }

  /// `Manga Awards`
  String get Manga_Awards {
    return Intl.message(
      'Manga Awards',
      name: 'Manga_Awards',
      desc: '',
      args: [],
    );
  }

  /// `Live`
  String get Live {
    return Intl.message(
      'Live',
      name: 'Live',
      desc: '',
      args: [],
    );
  }

  /// `Anime Awards`
  String get Anime_Awards {
    return Intl.message(
      'Anime Awards',
      name: 'Anime_Awards',
      desc: '',
      args: [],
    );
  }

  /// `People Awards`
  String get People_Awards {
    return Intl.message(
      'People Awards',
      name: 'People_Awards',
      desc: '',
      args: [],
    );
  }

  /// `Otakon`
  String get Otakon {
    return Intl.message(
      'Otakon',
      name: 'Otakon',
      desc: '',
      args: [],
    );
  }

  /// `Anime Festival Asia`
  String get Anime_Festival_Asia {
    return Intl.message(
      'Anime Festival Asia',
      name: 'Anime_Festival_Asia',
      desc: '',
      args: [],
    );
  }

  /// `Comiket`
  String get Comiket {
    return Intl.message(
      'Comiket',
      name: 'Comiket',
      desc: '',
      args: [],
    );
  }

  /// `Wonder Festival`
  String get Wonder_Festival {
    return Intl.message(
      'Wonder Festival',
      name: 'Wonder_Festival',
      desc: '',
      args: [],
    );
  }

  /// `Japan Expo`
  String get Japan_Expo {
    return Intl.message(
      'Japan Expo',
      name: 'Japan_Expo',
      desc: '',
      args: [],
    );
  }

  /// `AnimeJapan`
  String get AnimeJapan {
    return Intl.message(
      'AnimeJapan',
      name: 'AnimeJapan',
      desc: '',
      args: [],
    );
  }

  /// `Machi Asobi`
  String get Machi_Asobi {
    return Intl.message(
      'Machi Asobi',
      name: 'Machi_Asobi',
      desc: '',
      args: [],
    );
  }

  /// `Anime NYC`
  String get Anime_NYC {
    return Intl.message(
      'Anime NYC',
      name: 'Anime_NYC',
      desc: '',
      args: [],
    );
  }

  /// `Sakura-con`
  String get Sakura_con {
    return Intl.message(
      'Sakura-con',
      name: 'Sakura_con',
      desc: '',
      args: [],
    );
  }

  /// `Anime Central`
  String get Anime_Central {
    return Intl.message(
      'Anime Central',
      name: 'Anime_Central',
      desc: '',
      args: [],
    );
  }

  /// `SMASH`
  String get SMASH {
    return Intl.message(
      'SMASH',
      name: 'SMASH',
      desc: '',
      args: [],
    );
  }

  /// `NYCC`
  String get NYCC {
    return Intl.message(
      'NYCC',
      name: 'NYCC',
      desc: '',
      args: [],
    );
  }

  /// `Jump Festa`
  String get Jump_Festa {
    return Intl.message(
      'Jump Festa',
      name: 'Jump_Festa',
      desc: '',
      args: [],
    );
  }

  /// `Anime Sales`
  String get Anime_Sales {
    return Intl.message(
      'Anime Sales',
      name: 'Anime_Sales',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get Licenses {
    return Intl.message(
      'Licenses',
      name: 'Licenses',
      desc: '',
      args: [],
    );
  }

  /// `Manga Sales`
  String get Manga_Sales {
    return Intl.message(
      'Manga Sales',
      name: 'Manga_Sales',
      desc: '',
      args: [],
    );
  }

  /// `Music Sales`
  String get Music_Sales {
    return Intl.message(
      'Music Sales',
      name: 'Music_Sales',
      desc: '',
      args: [],
    );
  }

  /// `Light Novel Sales`
  String get Light_Novel_Sales {
    return Intl.message(
      'Light Novel Sales',
      name: 'Light_Novel_Sales',
      desc: '',
      args: [],
    );
  }

  /// `First Volume Sales`
  String get First_Volume_Sales {
    return Intl.message(
      'First Volume Sales',
      name: 'First_Volume_Sales',
      desc: '',
      args: [],
    );
  }

  /// `Magazines`
  String get Magazines {
    return Intl.message(
      'Magazines',
      name: 'Magazines',
      desc: '',
      args: [],
    );
  }

  /// `Companies`
  String get Companies {
    return Intl.message(
      'Companies',
      name: 'Companies',
      desc: '',
      args: [],
    );
  }

  /// `KonoSugoi`
  String get KonoSugoi {
    return Intl.message(
      'KonoSugoi',
      name: 'KonoSugoi',
      desc: '',
      args: [],
    );
  }

  /// `Yearly Rankings`
  String get Yearly_Rankings {
    return Intl.message(
      'Yearly Rankings',
      name: 'Yearly_Rankings',
      desc: '',
      args: [],
    );
  }

  /// `More Information`
  String get More_Information {
    return Intl.message(
      'More Information',
      name: 'More_Information',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get Type {
    return Intl.message(
      'Type',
      name: 'Type',
      desc: '',
      args: [],
    );
  }

  /// `UNKNOWN`
  String get UNKNOWN {
    return Intl.message(
      'UNKNOWN',
      name: 'UNKNOWN',
      desc: '',
      args: [],
    );
  }

  /// `Premiered`
  String get Premiered {
    return Intl.message(
      'Premiered',
      name: 'Premiered',
      desc: '',
      args: [],
    );
  }

  /// `Chapters`
  String get Chapters {
    return Intl.message(
      'Chapters',
      name: 'Chapters',
      desc: '',
      args: [],
    );
  }

  /// `Aired`
  String get Aired {
    return Intl.message(
      'Aired',
      name: 'Aired',
      desc: '',
      args: [],
    );
  }

  /// `Published`
  String get Published {
    return Intl.message(
      'Published',
      name: 'Published',
      desc: '',
      args: [],
    );
  }

  /// `Source`
  String get Source {
    return Intl.message(
      'Source',
      name: 'Source',
      desc: '',
      args: [],
    );
  }

  /// `Serialization`
  String get Serialization {
    return Intl.message(
      'Serialization',
      name: 'Serialization',
      desc: '',
      args: [],
    );
  }

  /// `Genres`
  String get Genres {
    return Intl.message(
      'Genres',
      name: 'Genres',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get Duration {
    return Intl.message(
      'Duration',
      name: 'Duration',
      desc: '',
      args: [],
    );
  }

  /// `Rating`
  String get Rating {
    return Intl.message(
      'Rating',
      name: 'Rating',
      desc: '',
      args: [],
    );
  }

  /// `Synonyms`
  String get Synonyms {
    return Intl.message(
      'Synonyms',
      name: 'Synonyms',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get Status {
    return Intl.message(
      'Status',
      name: 'Status',
      desc: '',
      args: [],
    );
  }

  /// `Adventure`
  String get Adventure {
    return Intl.message(
      'Adventure',
      name: 'Adventure',
      desc: '',
      args: [],
    );
  }

  /// `Cars`
  String get Cars {
    return Intl.message(
      'Cars',
      name: 'Cars',
      desc: '',
      args: [],
    );
  }

  /// `Comedy`
  String get Comedy {
    return Intl.message(
      'Comedy',
      name: 'Comedy',
      desc: '',
      args: [],
    );
  }

  /// `Dementia`
  String get Dementia {
    return Intl.message(
      'Dementia',
      name: 'Dementia',
      desc: '',
      args: [],
    );
  }

  /// `Demons`
  String get Demons {
    return Intl.message(
      'Demons',
      name: 'Demons',
      desc: '',
      args: [],
    );
  }

  /// `Mystery`
  String get Mystery {
    return Intl.message(
      'Mystery',
      name: 'Mystery',
      desc: '',
      args: [],
    );
  }

  /// `Drama`
  String get Drama {
    return Intl.message(
      'Drama',
      name: 'Drama',
      desc: '',
      args: [],
    );
  }

  /// `Ecchi`
  String get Ecchi {
    return Intl.message(
      'Ecchi',
      name: 'Ecchi',
      desc: '',
      args: [],
    );
  }

  /// `Fantasy`
  String get Fantasy {
    return Intl.message(
      'Fantasy',
      name: 'Fantasy',
      desc: '',
      args: [],
    );
  }

  /// `Game`
  String get Game {
    return Intl.message(
      'Game',
      name: 'Game',
      desc: '',
      args: [],
    );
  }

  /// `Hentai`
  String get Hentai {
    return Intl.message(
      'Hentai',
      name: 'Hentai',
      desc: '',
      args: [],
    );
  }

  /// `Historical`
  String get Historical {
    return Intl.message(
      'Historical',
      name: 'Historical',
      desc: '',
      args: [],
    );
  }

  /// `Kids`
  String get Kids {
    return Intl.message(
      'Kids',
      name: 'Kids',
      desc: '',
      args: [],
    );
  }

  /// `Magic`
  String get Magic {
    return Intl.message(
      'Magic',
      name: 'Magic',
      desc: '',
      args: [],
    );
  }

  /// `Martial_Arts`
  String get Martial_Arts {
    return Intl.message(
      'Martial_Arts',
      name: 'Martial_Arts',
      desc: '',
      args: [],
    );
  }

  /// `Mecha`
  String get Mecha {
    return Intl.message(
      'Mecha',
      name: 'Mecha',
      desc: '',
      args: [],
    );
  }

  /// `Parody`
  String get Parody {
    return Intl.message(
      'Parody',
      name: 'Parody',
      desc: '',
      args: [],
    );
  }

  /// `Samurai`
  String get Samurai {
    return Intl.message(
      'Samurai',
      name: 'Samurai',
      desc: '',
      args: [],
    );
  }

  /// `Romance`
  String get Romance {
    return Intl.message(
      'Romance',
      name: 'Romance',
      desc: '',
      args: [],
    );
  }

  /// `School`
  String get School {
    return Intl.message(
      'School',
      name: 'School',
      desc: '',
      args: [],
    );
  }

  /// `Sci-Fi`
  String get Sci_Fi {
    return Intl.message(
      'Sci-Fi',
      name: 'Sci_Fi',
      desc: '',
      args: [],
    );
  }

  /// `Shoujo`
  String get Shoujo {
    return Intl.message(
      'Shoujo',
      name: 'Shoujo',
      desc: '',
      args: [],
    );
  }

  /// `Yuri`
  String get Yuri {
    return Intl.message(
      'Yuri',
      name: 'Yuri',
      desc: '',
      args: [],
    );
  }

  /// `Shounen`
  String get Shounen {
    return Intl.message(
      'Shounen',
      name: 'Shounen',
      desc: '',
      args: [],
    );
  }

  /// `Yaoi`
  String get Yaoi {
    return Intl.message(
      'Yaoi',
      name: 'Yaoi',
      desc: '',
      args: [],
    );
  }

  /// `Space`
  String get Space {
    return Intl.message(
      'Space',
      name: 'Space',
      desc: '',
      args: [],
    );
  }

  /// `Super_Power`
  String get Super_Power {
    return Intl.message(
      'Super_Power',
      name: 'Super_Power',
      desc: '',
      args: [],
    );
  }

  /// `Vampire`
  String get Vampire {
    return Intl.message(
      'Vampire',
      name: 'Vampire',
      desc: '',
      args: [],
    );
  }

  /// `Harem`
  String get Harem {
    return Intl.message(
      'Harem',
      name: 'Harem',
      desc: '',
      args: [],
    );
  }

  /// `Slice_Of_Life`
  String get Slice_Of_Life {
    return Intl.message(
      'Slice_Of_Life',
      name: 'Slice_Of_Life',
      desc: '',
      args: [],
    );
  }

  /// `Military`
  String get Military {
    return Intl.message(
      'Military',
      name: 'Military',
      desc: '',
      args: [],
    );
  }

  /// `Police`
  String get Police {
    return Intl.message(
      'Police',
      name: 'Police',
      desc: '',
      args: [],
    );
  }

  /// `Psychological`
  String get Psychological {
    return Intl.message(
      'Psychological',
      name: 'Psychological',
      desc: '',
      args: [],
    );
  }

  /// `Thriller`
  String get Thriller {
    return Intl.message(
      'Thriller',
      name: 'Thriller',
      desc: '',
      args: [],
    );
  }

  /// `Seinen`
  String get Seinen {
    return Intl.message(
      'Seinen',
      name: 'Seinen',
      desc: '',
      args: [],
    );
  }

  /// `Josei`
  String get Josei {
    return Intl.message(
      'Josei',
      name: 'Josei',
      desc: '',
      args: [],
    );
  }

  /// `Slice_of_Life`
  String get Slice_of_Life {
    return Intl.message(
      'Slice_of_Life',
      name: 'Slice_of_Life',
      desc: '',
      args: [],
    );
  }

  /// `Doujunshi`
  String get Doujunshi {
    return Intl.message(
      'Doujunshi',
      name: 'Doujunshi',
      desc: '',
      args: [],
    );
  }

  /// `Game_Bender`
  String get Game_Bender {
    return Intl.message(
      'Game_Bender',
      name: 'Game_Bender',
      desc: '',
      args: [],
    );
  }

  /// `No Title`
  String get No_Title {
    return Intl.message(
      'No Title',
      name: 'No_Title',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get Date {
    return Intl.message(
      'Date',
      name: 'Date',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get User {
    return Intl.message(
      'User',
      name: 'User',
      desc: '',
      args: [],
    );
  }

  /// `Ago`
  String get Ago {
    return Intl.message(
      'Ago',
      name: 'Ago',
      desc: '',
      args: [],
    );
  }

  /// `Show Spoiler`
  String get Show_Spoiler {
    return Intl.message(
      'Show Spoiler',
      name: 'Show_Spoiler',
      desc: '',
      args: [],
    );
  }

  /// `Last Post by`
  String get Last_Post_by {
    return Intl.message(
      'Last Post by',
      name: 'Last_Post_by',
      desc: '',
      args: [],
    );
  }

  /// `No Image`
  String get No_Image {
    return Intl.message(
      'No Image',
      name: 'No_Image',
      desc: '',
      args: [],
    );
  }

  /// `These filters will be used when you do your next search`
  String get Filter_After_search {
    return Intl.message(
      'These filters will be used when you do your next search',
      name: 'Filter_After_search',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message(
      'Cancel',
      name: 'Cancel',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get Close {
    return Intl.message(
      'Close',
      name: 'Close',
      desc: '',
      args: [],
    );
  }

  /// `Apply Filters`
  String get Apply_Filters {
    return Intl.message(
      'Apply Filters',
      name: 'Apply_Filters',
      desc: '',
      args: [],
    );
  }

  /// `Please use filter *1 along with *2`
  String get Filter_along_with {
    return Intl.message(
      'Please use filter *1 along with *2',
      name: 'Filter_along_with',
      desc: '',
      args: [],
    );
  }

  /// `You cannot use *1 filter along with *2`
  String get Filter_cannot_with {
    return Intl.message(
      'You cannot use *1 filter along with *2',
      name: 'Filter_cannot_with',
      desc: '',
      args: [],
    );
  }

  /// `Your List Status`
  String get Your_List_Status {
    return Intl.message(
      'Your List Status',
      name: 'Your_List_Status',
      desc: '',
      args: [],
    );
  }

  /// `Dates & Priority`
  String get Dates_Priority {
    return Intl.message(
      'Dates & Priority',
      name: 'Dates_Priority',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get Others {
    return Intl.message(
      'Others',
      name: 'Others',
      desc: '',
      args: [],
    );
  }

  /// `Negative episode not allowed.`
  String get Negative_episode_not_allowed {
    return Intl.message(
      'Negative episode not allowed.',
      name: 'Negative_episode_not_allowed',
      desc: '',
      args: [],
    );
  }

  /// `Maximum reached!`
  String get Maximum_reached {
    return Intl.message(
      'Maximum reached!',
      name: 'Maximum_reached',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't Update!`
  String get Couldnt_Update {
    return Intl.message(
      'Couldn\'t Update!',
      name: 'Couldnt_Update',
      desc: '',
      args: [],
    );
  }

  /// `Negative volumes not allowed.`
  String get Negative_volumes_not_allowed {
    return Intl.message(
      'Negative volumes not allowed.',
      name: 'Negative_volumes_not_allowed',
      desc: '',
      args: [],
    );
  }

  /// `Negative chapters not allowed.`
  String get Negative_chapters_not_allowed {
    return Intl.message(
      'Negative chapters not allowed.',
      name: 'Negative_chapters_not_allowed',
      desc: '',
      args: [],
    );
  }

  /// `No Connection`
  String get No_Connection {
    return Intl.message(
      'No Connection',
      name: 'No_Connection',
      desc: '',
      args: [],
    );
  }

  /// `Do you wish to delete this item from the list?`
  String get Item_delete_confi {
    return Intl.message(
      'Do you wish to delete this item from the list?',
      name: 'Item_delete_confi',
      desc: '',
      args: [],
    );
  }

  /// `This opertaion cannot be undone!`
  String get Item_delete_desc {
    return Intl.message(
      'This opertaion cannot be undone!',
      name: 'Item_delete_desc',
      desc: '',
      args: [],
    );
  }

  /// `Login & Add to List`
  String get Login_Add_to_List {
    return Intl.message(
      'Login & Add to List',
      name: 'Login_Add_to_List',
      desc: '',
      args: [],
    );
  }

  /// `Add to List`
  String get Add_to_List {
    return Intl.message(
      'Add to List',
      name: 'Add_to_List',
      desc: '',
      args: [],
    );
  }

  /// `Delete from List`
  String get Delete_from_List {
    return Intl.message(
      'Delete from List',
      name: 'Delete_from_List',
      desc: '',
      args: [],
    );
  }

  /// `Finish Date`
  String get Finish_Date {
    return Intl.message(
      'Finish Date',
      name: 'Finish_Date',
      desc: '',
      args: [],
    );
  }

  /// `Priority`
  String get Priority {
    return Intl.message(
      'Priority',
      name: 'Priority',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get Low {
    return Intl.message(
      'Low',
      name: 'Low',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get Medium {
    return Intl.message(
      'Medium',
      name: 'Medium',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get High {
    return Intl.message(
      'High',
      name: 'High',
      desc: '',
      args: [],
    );
  }

  /// `What is your priority level to watch/read this?`
  String get Priority_level_qn {
    return Intl.message(
      'What is your priority level to watch/read this?',
      name: 'Priority_level_qn',
      desc: '',
      args: [],
    );
  }

  /// `Rewatching`
  String get Rewatching {
    return Intl.message(
      'Rewatching',
      name: 'Rewatching',
      desc: '',
      args: [],
    );
  }

  /// `Rereading`
  String get Rereading {
    return Intl.message(
      'Rereading',
      name: 'Rereading',
      desc: '',
      args: [],
    );
  }

  /// `Times Rewatched`
  String get Times_Rewatched {
    return Intl.message(
      'Times Rewatched',
      name: 'Times_Rewatched',
      desc: '',
      args: [],
    );
  }

  /// `Times Reread`
  String get Times_Reread {
    return Intl.message(
      'Times Reread',
      name: 'Times_Reread',
      desc: '',
      args: [],
    );
  }

  /// `Rewatch`
  String get Rewatch {
    return Intl.message(
      'Rewatch',
      name: 'Rewatch',
      desc: '',
      args: [],
    );
  }

  /// `Reread`
  String get Reread {
    return Intl.message(
      'Reread',
      name: 'Reread',
      desc: '',
      args: [],
    );
  }

  /// `Value`
  String get Value {
    return Intl.message(
      'Value',
      name: 'Value',
      desc: '',
      args: [],
    );
  }

  /// `Very Low`
  String get Very_Low {
    return Intl.message(
      'Very Low',
      name: 'Very_Low',
      desc: '',
      args: [],
    );
  }

  /// `Very High`
  String get Very_High {
    return Intl.message(
      'Very High',
      name: 'Very_High',
      desc: '',
      args: [],
    );
  }

  /// `Seen`
  String get Seen {
    return Intl.message(
      'Seen',
      name: 'Seen',
      desc: '',
      args: [],
    );
  }

  /// `My Status`
  String get My_Status {
    return Intl.message(
      'My Status',
      name: 'My_Status',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't Delete`
  String get Couldnt_Delete {
    return Intl.message(
      'Couldn\'t Delete',
      name: 'Couldnt_Delete',
      desc: '',
      args: [],
    );
  }

  /// `Volumes`
  String get Volumes {
    return Intl.message(
      'Volumes',
      name: 'Volumes',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get Read {
    return Intl.message(
      'Read',
      name: 'Read',
      desc: '',
      args: [],
    );
  }

  /// `Login to See more`
  String get Login_to_See_more {
    return Intl.message(
      'Login to See more',
      name: 'Login_to_See_more',
      desc: '',
      args: [],
    );
  }

  /// `Updating`
  String get Updating {
    return Intl.message(
      'Updating',
      name: 'Updating',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get Male {
    return Intl.message(
      'Male',
      name: 'Male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get Female {
    return Intl.message(
      'Female',
      name: 'Female',
      desc: '',
      args: [],
    );
  }

  /// `Reading`
  String get Reading {
    return Intl.message(
      'Reading',
      name: 'Reading',
      desc: '',
      args: [],
    );
  }

  /// `Anime Statistics`
  String get Anime_Statistics {
    return Intl.message(
      'Anime Statistics',
      name: 'Anime_Statistics',
      desc: '',
      args: [],
    );
  }

  /// `Just a sec!`
  String get Just_a_sec {
    return Intl.message(
      'Just a sec!',
      name: 'Just_a_sec',
      desc: '',
      args: [],
    );
  }

  /// `This link will take you to`
  String get Url_open_conf {
    return Intl.message(
      'This link will take you to',
      name: 'Url_open_conf',
      desc: '',
      args: [],
    );
  }

  /// `continue?`
  String get Continue {
    return Intl.message(
      'continue?',
      name: 'Continue',
      desc: '',
      args: [],
    );
  }

  /// `Logout Confirmation`
  String get Logout_Confirmation {
    return Intl.message(
      'Logout Confirmation',
      name: 'Logout_Confirmation',
      desc: '',
      args: [],
    );
  }

  /// `Do you wish to logout?`
  String get Do_you_wish_to_logout {
    return Intl.message(
      'Do you wish to logout?',
      name: 'Do_you_wish_to_logout',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't sign out now!`
  String get Couldnt_sign_out_now {
    return Intl.message(
      'Couldn\'t sign out now!',
      name: 'Couldnt_sign_out_now',
      desc: '',
      args: [],
    );
  }

  /// `Cannot launch`
  String get Cannot_launch {
    return Intl.message(
      'Cannot launch',
      name: 'Cannot_launch',
      desc: '',
      args: [],
    );
  }

  /// `years ago`
  String get years_ago {
    return Intl.message(
      'years ago',
      name: 'years_ago',
      desc: '',
      args: [],
    );
  }

  /// `an year ago`
  String get year_ago {
    return Intl.message(
      'an year ago',
      name: 'year_ago',
      desc: '',
      args: [],
    );
  }

  /// `Last year`
  String get Last_year {
    return Intl.message(
      'Last year',
      name: 'Last_year',
      desc: '',
      args: [],
    );
  }

  /// `a month ago`
  String get month_ago {
    return Intl.message(
      'a month ago',
      name: 'month_ago',
      desc: '',
      args: [],
    );
  }

  /// `months ago`
  String get months_ago {
    return Intl.message(
      'months ago',
      name: 'months_ago',
      desc: '',
      args: [],
    );
  }

  /// `weeks ago`
  String get weeks_ago {
    return Intl.message(
      'weeks ago',
      name: 'weeks_ago',
      desc: '',
      args: [],
    );
  }

  /// `a week ago`
  String get week_ago {
    return Intl.message(
      'a week ago',
      name: 'week_ago',
      desc: '',
      args: [],
    );
  }

  /// `Last week`
  String get Last_week {
    return Intl.message(
      'Last week',
      name: 'Last_week',
      desc: '',
      args: [],
    );
  }

  /// `Last month`
  String get Last_month {
    return Intl.message(
      'Last month',
      name: 'Last_month',
      desc: '',
      args: [],
    );
  }

  /// `days ago`
  String get days_ago {
    return Intl.message(
      'days ago',
      name: 'days_ago',
      desc: '',
      args: [],
    );
  }

  /// `a day ago`
  String get day_ago {
    return Intl.message(
      'a day ago',
      name: 'day_ago',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get Yesterday {
    return Intl.message(
      'Yesterday',
      name: 'Yesterday',
      desc: '',
      args: [],
    );
  }

  /// `hours ago`
  String get hours_ago {
    return Intl.message(
      'hours ago',
      name: 'hours_ago',
      desc: '',
      args: [],
    );
  }

  /// `An hour ago`
  String get hour_ago {
    return Intl.message(
      'An hour ago',
      name: 'hour_ago',
      desc: '',
      args: [],
    );
  }

  /// `minutes ago`
  String get minutes_ago {
    return Intl.message(
      'minutes ago',
      name: 'minutes_ago',
      desc: '',
      args: [],
    );
  }

  /// `a minute ago`
  String get minute_ago {
    return Intl.message(
      'a minute ago',
      name: 'minute_ago',
      desc: '',
      args: [],
    );
  }

  /// `seconds ago`
  String get seconds_ago {
    return Intl.message(
      'seconds ago',
      name: 'seconds_ago',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get Just_now {
    return Intl.message(
      'Just now',
      name: 'Just_now',
      desc: '',
      args: [],
    );
  }

  /// `Select a suitable color`
  String get Select_a_suitable_color {
    return Intl.message(
      'Select a suitable color',
      name: 'Select_a_suitable_color',
      desc: '',
      args: [],
    );
  }

  /// `Language Settings`
  String get Language_settings {
    return Intl.message(
      'Language Settings',
      name: 'Language_settings',
      desc: '',
      args: [],
    );
  }

  /// `Choose from English, Portuguese`
  String get Language_settings_desc {
    return Intl.message(
      'Choose from English, Portuguese',
      name: 'Language_settings_desc',
      desc: '',
      args: [],
    );
  }

  /// `Choose a language`
  String get Choose_a_Language {
    return Intl.message(
      'Choose a language',
      name: 'Choose_a_Language',
      desc: '',
      args: [],
    );
  }

  /// `A new episode is out!`
  String get A_new_episode_is_out {
    return Intl.message(
      'A new episode is out!',
      name: 'A_new_episode_is_out',
      desc: '',
      args: [],
    );
  }

  /// `Update your <b><i>watchlist</i></b> as soon as you watch the episode`
  String get Notif_Update_watchList {
    return Intl.message(
      'Update your <b><i>watchlist</i></b> as soon as you watch the episode',
      name: 'Notif_Update_watchList',
      desc: '',
      args: [],
    );
  }

  /// `An anime in your <b><i>PTW<i></b> is airing. Check it out and let us now.`
  String get Notif_Update_PTW {
    return Intl.message(
      'An anime in your <b><i>PTW<i></b> is airing. Check it out and let us now.',
      name: 'Notif_Update_PTW',
      desc: '',
      args: [],
    );
  }

  /// `Episode Reminder`
  String get Episode_Reminder {
    return Intl.message(
      'Episode Reminder',
      name: 'Episode_Reminder',
      desc: '',
      args: [],
    );
  }

  /// `just got aired`
  String get just_got_aired {
    return Intl.message(
      'just got aired',
      name: 'just_got_aired',
      desc: '',
      args: [],
    );
  }

  /// `Auto Translate Synopsis`
  String get Auto_Translate_Synopsis {
    return Intl.message(
      'Auto Translate Synopsis',
      name: 'Auto_Translate_Synopsis',
      desc: '',
      args: [],
    );
  }

  /// `Translate the above synopsis`
  String get Translate_Synopsis {
    return Intl.message(
      'Translate the above synopsis',
      name: 'Translate_Synopsis',
      desc: '',
      args: [],
    );
  }

  /// `Show Original`
  String get Show_Original {
    return Intl.message(
      'Show Original',
      name: 'Show_Original',
      desc: '',
      args: [],
    );
  }

  /// `Promo Videos`
  String get Promo_Videos {
    return Intl.message(
      'Promo Videos',
      name: 'Promo_Videos',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't get promos`
  String get Couldnt_get_promos {
    return Intl.message(
      'Couldn\'t get promos',
      name: 'Couldnt_get_promos',
      desc: '',
      args: [],
    );
  }

  /// `User Updates`
  String get User_Updates {
    return Intl.message(
      'User Updates',
      name: 'User_Updates',
      desc: '',
      args: [],
    );
  }

  /// `Episodes Seen`
  String get Episodes_seen {
    return Intl.message(
      'Episodes Seen',
      name: 'Episodes_seen',
      desc: '',
      args: [],
    );
  }

  /// `User logged in..`
  String get Logged_In {
    return Intl.message(
      'User logged in..',
      name: 'Logged_In',
      desc: '',
      args: [],
    );
  }

  /// `Defaults to English if the app doesn't support the system locale or country code.`
  String get English_Default {
    return Intl.message(
      'Defaults to English if the app doesn\'t support the system locale or country code.',
      name: 'English_Default',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get English {
    return Intl.message(
      'English',
      name: 'English',
      desc: '',
      args: [],
    );
  }

  /// `Portuguese`
  String get Portuguese {
    return Intl.message(
      'Portuguese',
      name: 'Portuguese',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get Spanish {
    return Intl.message(
      'Spanish',
      name: 'Spanish',
      desc: '',
      args: [],
    );
  }

  /// `German`
  String get German {
    return Intl.message(
      'German',
      name: 'German',
      desc: '',
      args: [],
    );
  }

  /// `French`
  String get French {
    return Intl.message(
      'French',
      name: 'French',
      desc: '',
      args: [],
    );
  }

  /// `Indonesian`
  String get Indonesian {
    return Intl.message(
      'Indonesian',
      name: 'Indonesian',
      desc: '',
      args: [],
    );
  }

  /// `Russian`
  String get Russian {
    return Intl.message(
      'Russian',
      name: 'Russian',
      desc: '',
      args: [],
    );
  }

  /// `Turkish`
  String get Turkish {
    return Intl.message(
      'Turkish',
      name: 'Turkish',
      desc: '',
      args: [],
    );
  }

  /// `Japanese`
  String get Japanese {
    return Intl.message(
      'Japanese',
      name: 'Japanese',
      desc: '',
      args: [],
    );
  }

  /// `Korean`
  String get Korean {
    return Intl.message(
      'Korean',
      name: 'Korean',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get All {
    return Intl.message(
      'All',
      name: 'All',
      desc: '',
      args: [],
    );
  }

  /// `include`
  String get Include {
    return Intl.message(
      'include',
      name: 'Include',
      desc: '',
      args: [],
    );
  }

  /// `Custom Tag`
  String get Custom_tag {
    return Intl.message(
      'Custom Tag',
      name: 'Custom_tag',
      desc: '',
      args: [],
    );
  }

  /// `insert a custom tag`
  String get Custom_tag_desc {
    return Intl.message(
      'insert a custom tag',
      name: 'Custom_tag_desc',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get Arabic {
    return Intl.message(
      'Arabic',
      name: 'Arabic',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get Collapse {
    return Intl.message(
      'Collapse',
      name: 'Collapse',
      desc: '',
      args: [],
    );
  }

  /// `Choose a language.`
  String get Language_settings_desc_v2 {
    return Intl.message(
      'Choose a language.',
      name: 'Language_settings_desc_v2',
      desc: '',
      args: [],
    );
  }

  /// `Loading Profile`
  String get Loading_Profile {
    return Intl.message(
      'Loading Profile',
      name: 'Loading_Profile',
      desc: '',
      args: [],
    );
  }

  /// `Logged in as`
  String get Logged_In_as {
    return Intl.message(
      'Logged in as',
      name: 'Logged_In_as',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Anime`
  String get WeeklyAnime {
    return Intl.message(
      'Weekly Anime',
      name: 'WeeklyAnime',
      desc: '',
      args: [],
    );
  }

  /// `Anime`
  String get Anime_Caps {
    return Intl.message(
      'Anime',
      name: 'Anime_Caps',
      desc: '',
      args: [],
    );
  }

  /// `Manga`
  String get Manga_Caps {
    return Intl.message(
      'Manga',
      name: 'Manga_Caps',
      desc: '',
      args: [],
    );
  }

  /// `People`
  String get People_Caps {
    return Intl.message(
      'People',
      name: 'People_Caps',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get monday {
    return Intl.message(
      'Monday',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message(
      'Tuesday',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message(
      'Wednesday',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get thursday {
    return Intl.message(
      'Thursday',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get friday {
    return Intl.message(
      'Friday',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get saturday {
    return Intl.message(
      'Saturday',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get sunday {
    return Intl.message(
      'Sunday',
      name: 'sunday',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Show Only Last Quote`
  String get ShowOnlyLastQuote {
    return Intl.message(
      'Show Only Last Quote',
      name: 'ShowOnlyLastQuote',
      desc: '',
      args: [],
    );
  }

  /// `Show only the last quote for the post.`
  String get ShowOnlyLastQuote_desc {
    return Intl.message(
      'Show only the last quote for the post.',
      name: 'ShowOnlyLastQuote_desc',
      desc: '',
      args: [],
    );
  }

  /// `oldest`
  String get Oldest {
    return Intl.message(
      'oldest',
      name: 'Oldest',
      desc: '',
      args: [],
    );
  }

  /// `newest`
  String get Newest {
    return Intl.message(
      'newest',
      name: 'Newest',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get Dark {
    return Intl.message(
      'Dark',
      name: 'Dark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get Light {
    return Intl.message(
      'Light',
      name: 'Light',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get Custom {
    return Intl.message(
      'Custom',
      name: 'Custom',
      desc: '',
      args: [],
    );
  }

  /// `Select an image to set as the background image`
  String get Select_Image {
    return Intl.message(
      'Select an image to set as the background image',
      name: 'Select_Image',
      desc: '',
      args: [],
    );
  }

  /// `This image will be set as the background image for the home page.`
  String get Select_Image_desc {
    return Intl.message(
      'This image will be set as the background image for the home page.',
      name: 'Select_Image_desc',
      desc: '',
      args: [],
    );
  }

  /// `You didn't select any image.`
  String get Image_Not_Selected {
    return Intl.message(
      'You didn\'t select any image.',
      name: 'Image_Not_Selected',
      desc: '',
      args: [],
    );
  }

  /// `Remove Image from Home Page`
  String get Remove_Image {
    return Intl.message(
      'Remove Image from Home Page',
      name: 'Remove_Image',
      desc: '',
      args: [],
    );
  }

  /// `This will remove the image from the home page.`
  String get Remove_Image_desc {
    return Intl.message(
      'This will remove the image from the home page.',
      name: 'Remove_Image_desc',
      desc: '',
      args: [],
    );
  }

  /// `Choose from light, dark or custom themes.`
  String get Theme_setting_desc_v2 {
    return Intl.message(
      'Choose from light, dark or custom themes.',
      name: 'Theme_setting_desc_v2',
      desc: '',
      args: [],
    );
  }

  /// `Genre Include/Exclude`
  String get Genre_Include_Exclude {
    return Intl.message(
      'Genre Include/Exclude',
      name: 'Genre_Include_Exclude',
      desc: '',
      args: [],
    );
  }

  /// `Single tap to include or double tap to exclude a genre.`
  String get Genre_Include_Exclude_desc {
    return Intl.message(
      'Single tap to include or double tap to exclude a genre.',
      name: 'Genre_Include_Exclude_desc',
      desc: '',
      args: [],
    );
  }

  /// `Avant_Garde`
  String get Avant_Garde {
    return Intl.message(
      'Avant_Garde',
      name: 'Avant_Garde',
      desc: '',
      args: [],
    );
  }

  /// `Award_Winning`
  String get Award_Winning {
    return Intl.message(
      'Award_Winning',
      name: 'Award_Winning',
      desc: '',
      args: [],
    );
  }

  /// `Boys_Love`
  String get Boys_Love {
    return Intl.message(
      'Boys_Love',
      name: 'Boys_Love',
      desc: '',
      args: [],
    );
  }

  /// `Girls_Love`
  String get Girls_Love {
    return Intl.message(
      'Girls_Love',
      name: 'Girls_Love',
      desc: '',
      args: [],
    );
  }

  /// `Gourmet`
  String get Gourmet {
    return Intl.message(
      'Gourmet',
      name: 'Gourmet',
      desc: '',
      args: [],
    );
  }

  /// `Suspense`
  String get Suspense {
    return Intl.message(
      'Suspense',
      name: 'Suspense',
      desc: '',
      args: [],
    );
  }

  /// `Erotica`
  String get Erotica {
    return Intl.message(
      'Erotica',
      name: 'Erotica',
      desc: '',
      args: [],
    );
  }

  /// `Adult_Cast`
  String get Adult_Cast {
    return Intl.message(
      'Adult_Cast',
      name: 'Adult_Cast',
      desc: '',
      args: [],
    );
  }

  /// `Anthropomorphic`
  String get Anthropomorphic {
    return Intl.message(
      'Anthropomorphic',
      name: 'Anthropomorphic',
      desc: '',
      args: [],
    );
  }

  /// `CGDCT`
  String get CGDCT {
    return Intl.message(
      'CGDCT',
      name: 'CGDCT',
      desc: '',
      args: [],
    );
  }

  /// `Childcare`
  String get Childcare {
    return Intl.message(
      'Childcare',
      name: 'Childcare',
      desc: '',
      args: [],
    );
  }

  /// `Combat_Sports`
  String get Combat_Sports {
    return Intl.message(
      'Combat_Sports',
      name: 'Combat_Sports',
      desc: '',
      args: [],
    );
  }

  /// `Crossdressing`
  String get Crossdressing {
    return Intl.message(
      'Crossdressing',
      name: 'Crossdressing',
      desc: '',
      args: [],
    );
  }

  /// `Delinquents`
  String get Delinquents {
    return Intl.message(
      'Delinquents',
      name: 'Delinquents',
      desc: '',
      args: [],
    );
  }

  /// `Detective`
  String get Detective {
    return Intl.message(
      'Detective',
      name: 'Detective',
      desc: '',
      args: [],
    );
  }

  /// `Educational`
  String get Educational {
    return Intl.message(
      'Educational',
      name: 'Educational',
      desc: '',
      args: [],
    );
  }

  /// `Gag_Humor`
  String get Gag_Humor {
    return Intl.message(
      'Gag_Humor',
      name: 'Gag_Humor',
      desc: '',
      args: [],
    );
  }

  /// `Gore`
  String get Gore {
    return Intl.message(
      'Gore',
      name: 'Gore',
      desc: '',
      args: [],
    );
  }

  /// `High_Stakes_Game`
  String get High_Stakes_Game {
    return Intl.message(
      'High_Stakes_Game',
      name: 'High_Stakes_Game',
      desc: '',
      args: [],
    );
  }

  /// `Idols_Female`
  String get Idols_Female {
    return Intl.message(
      'Idols_Female',
      name: 'Idols_Female',
      desc: '',
      args: [],
    );
  }

  /// `Idols_Male`
  String get Idols_Male {
    return Intl.message(
      'Idols_Male',
      name: 'Idols_Male',
      desc: '',
      args: [],
    );
  }

  /// `Isekai`
  String get Isekai {
    return Intl.message(
      'Isekai',
      name: 'Isekai',
      desc: '',
      args: [],
    );
  }

  /// `Iyashikei`
  String get Iyashikei {
    return Intl.message(
      'Iyashikei',
      name: 'Iyashikei',
      desc: '',
      args: [],
    );
  }

  /// `Love_Polygon`
  String get Love_Polygon {
    return Intl.message(
      'Love_Polygon',
      name: 'Love_Polygon',
      desc: '',
      args: [],
    );
  }

  /// `Magical_Sex_Shift`
  String get Magical_Sex_Shift {
    return Intl.message(
      'Magical_Sex_Shift',
      name: 'Magical_Sex_Shift',
      desc: '',
      args: [],
    );
  }

  /// `Mahou_Shoujo`
  String get Mahou_Shoujo {
    return Intl.message(
      'Mahou_Shoujo',
      name: 'Mahou_Shoujo',
      desc: '',
      args: [],
    );
  }

  /// `Medical`
  String get Medical {
    return Intl.message(
      'Medical',
      name: 'Medical',
      desc: '',
      args: [],
    );
  }

  /// `Mythology`
  String get Mythology {
    return Intl.message(
      'Mythology',
      name: 'Mythology',
      desc: '',
      args: [],
    );
  }

  /// `Organized_Crime`
  String get Organized_Crime {
    return Intl.message(
      'Organized_Crime',
      name: 'Organized_Crime',
      desc: '',
      args: [],
    );
  }

  /// `Otaku_Culture`
  String get Otaku_Culture {
    return Intl.message(
      'Otaku_Culture',
      name: 'Otaku_Culture',
      desc: '',
      args: [],
    );
  }

  /// `Performing_Arts`
  String get Performing_Arts {
    return Intl.message(
      'Performing_Arts',
      name: 'Performing_Arts',
      desc: '',
      args: [],
    );
  }

  /// `Pets`
  String get Pets {
    return Intl.message(
      'Pets',
      name: 'Pets',
      desc: '',
      args: [],
    );
  }

  /// `Racing`
  String get Racing {
    return Intl.message(
      'Racing',
      name: 'Racing',
      desc: '',
      args: [],
    );
  }

  /// `Reincarnation`
  String get Reincarnation {
    return Intl.message(
      'Reincarnation',
      name: 'Reincarnation',
      desc: '',
      args: [],
    );
  }

  /// `Reverse_Harem`
  String get Reverse_Harem {
    return Intl.message(
      'Reverse_Harem',
      name: 'Reverse_Harem',
      desc: '',
      args: [],
    );
  }

  /// `Romantic_Subtext`
  String get Romantic_Subtext {
    return Intl.message(
      'Romantic_Subtext',
      name: 'Romantic_Subtext',
      desc: '',
      args: [],
    );
  }

  /// `Showbiz`
  String get Showbiz {
    return Intl.message(
      'Showbiz',
      name: 'Showbiz',
      desc: '',
      args: [],
    );
  }

  /// `Strategy_Game`
  String get Strategy_Game {
    return Intl.message(
      'Strategy_Game',
      name: 'Strategy_Game',
      desc: '',
      args: [],
    );
  }

  /// `Survival`
  String get Survival {
    return Intl.message(
      'Survival',
      name: 'Survival',
      desc: '',
      args: [],
    );
  }

  /// `Team_Sports`
  String get Team_Sports {
    return Intl.message(
      'Team_Sports',
      name: 'Team_Sports',
      desc: '',
      args: [],
    );
  }

  /// `Time_Travel`
  String get Time_Travel {
    return Intl.message(
      'Time_Travel',
      name: 'Time_Travel',
      desc: '',
      args: [],
    );
  }

  /// `Video_Game`
  String get Video_Game {
    return Intl.message(
      'Video_Game',
      name: 'Video_Game',
      desc: '',
      args: [],
    );
  }

  /// `Visual_Arts`
  String get Visual_Arts {
    return Intl.message(
      'Visual_Arts',
      name: 'Visual_Arts',
      desc: '',
      args: [],
    );
  }

  /// `Workplace`
  String get Workplace {
    return Intl.message(
      'Workplace',
      name: 'Workplace',
      desc: '',
      args: [],
    );
  }

  /// `Auto add start/finish date`
  String get Auto_Add_Start_End_Date {
    return Intl.message(
      'Auto add start/finish date',
      name: 'Auto_Add_Start_End_Date',
      desc: '',
      args: [],
    );
  }

  /// `Automatically adds start and end date when status is moved to watching/completed.`
  String get Auto_Add_Start_End_Date_Desc {
    return Intl.message(
      'Automatically adds start and end date when status is moved to watching/completed.',
      name: 'Auto_Add_Start_End_Date_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Show airing time on anime list`
  String get Show_Airing_info_AnimeList {
    return Intl.message(
      'Show airing time on anime list',
      name: 'Show_Airing_info_AnimeList',
      desc: '',
      args: [],
    );
  }

  /// `Show airing info of ongoing anime with the next episode count`
  String get Show_Airing_info_AnimeList_Desc {
    return Intl.message(
      'Show airing info of ongoing anime with the next episode count',
      name: 'Show_Airing_info_AnimeList_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Made with`
  String get Made_With_Flutter {
    return Intl.message(
      'Made with',
      name: 'Made_With_Flutter',
      desc: '',
      args: [],
    );
  }

  /// `Background for Anime/Manga`
  String get Anime_Manga_BG {
    return Intl.message(
      'Background for Anime/Manga',
      name: 'Anime_Manga_BG',
      desc: '',
      args: [],
    );
  }

  /// `Show anime/manga picture as background`
  String get Anime_Manga_BG_Desc {
    return Intl.message(
      'Show anime/manga picture as background',
      name: 'Anime_Manga_BG_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Streaming Platforms`
  String get Streaming_Platforms {
    return Intl.message(
      'Streaming Platforms',
      name: 'Streaming_Platforms',
      desc: '',
      args: [],
    );
  }

  /// `Add or Edit your about section.`
  String get Add_Edit_Msg {
    return Intl.message(
      'Add or Edit your about section.',
      name: 'Add_Edit_Msg',
      desc: '',
      args: [],
    );
  }

  /// `Edit about`
  String get Edit_About {
    return Intl.message(
      'Edit about',
      name: 'Edit_About',
      desc: '',
      args: [],
    );
  }

  /// `After editing, it will take some time before this section is refreshed`
  String get Edit_Refresh_Message {
    return Intl.message(
      'After editing, it will take some time before this section is refreshed',
      name: 'Edit_Refresh_Message',
      desc: '',
      args: [],
    );
  }

  /// `Buy me a coffee`
  String get Buy_Me_A_Copy {
    return Intl.message(
      'Buy me a coffee',
      name: 'Buy_Me_A_Copy',
      desc: '',
      args: [],
    );
  }

  /// `Support the development of this app here`
  String get Buy_Me_A_Copy_Desc {
    return Intl.message(
      'Support the development of this app here',
      name: 'Buy_Me_A_Copy_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get Videos {
    return Intl.message(
      'Videos',
      name: 'Videos',
      desc: '',
      args: [],
    );
  }

  /// `Promotional`
  String get Promotional {
    return Intl.message(
      'Promotional',
      name: 'Promotional',
      desc: '',
      args: [],
    );
  }

  /// `Music Videos`
  String get Music_Videos {
    return Intl.message(
      'Music Videos',
      name: 'Music_Videos',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get Home {
    return Intl.message(
      'Home',
      name: 'Home',
      desc: '',
      args: [],
    );
  }

  /// `Community`
  String get Community {
    return Intl.message(
      'Community',
      name: 'Community',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get Profile {
    return Intl.message(
      'Profile',
      name: 'Profile',
      desc: '',
      args: [],
    );
  }

  /// `Grid`
  String get Grid {
    return Intl.message(
      'Grid',
      name: 'Grid',
      desc: '',
      args: [],
    );
  }

  /// `Open in Browser`
  String get Open_In_Browser {
    return Intl.message(
      'Open in Browser',
      name: 'Open_In_Browser',
      desc: '',
      args: [],
    );
  }

  /// `Prefer list view for user page`
  String get Default_Display_Type {
    return Intl.message(
      'Prefer list view for user page',
      name: 'Default_Display_Type',
      desc: '',
      args: [],
    );
  }

  /// `User page uses list view instead of grid view`
  String get Default_Display_Type_Desc {
    return Intl.message(
      'User page uses list view instead of grid view',
      name: 'Default_Display_Type_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Report Confirmation`
  String get Report_Confirmation {
    return Intl.message(
      'Report Confirmation',
      name: 'Report_Confirmation',
      desc: '',
      args: [],
    );
  }

  /// `by clicking 'Continue', you will be taken to the official MyAnimeList website where you can report or block.`
  String get Report_Description {
    return Intl.message(
      'by clicking \'Continue\', you will be taken to the official MyAnimeList website where you can report or block.',
      name: 'Report_Description',
      desc: '',
      args: [],
    );
  }

  /// `Report Post`
  String get Report_Post {
    return Intl.message(
      'Report Post',
      name: 'Report_Post',
      desc: '',
      args: [],
    );
  }

  /// `Report User`
  String get Report_User {
    return Intl.message(
      'Report User',
      name: 'Report_User',
      desc: '',
      args: [],
    );
  }

  /// `Signature`
  String get Signature {
    return Intl.message(
      'Signature',
      name: 'Signature',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get ContinueW {
    return Intl.message(
      'Continue',
      name: 'ContinueW',
      desc: '',
      args: [],
    );
  }

  /// `Nice`
  String get Nice {
    return Intl.message(
      'Nice',
      name: 'Nice',
      desc: '',
      args: [],
    );
  }

  /// `Love it`
  String get Love_it {
    return Intl.message(
      'Love it',
      name: 'Love_it',
      desc: '',
      args: [],
    );
  }

  /// `Confusing`
  String get Confusing {
    return Intl.message(
      'Confusing',
      name: 'Confusing',
      desc: '',
      args: [],
    );
  }

  /// `Informative`
  String get Informative {
    return Intl.message(
      'Informative',
      name: 'Informative',
      desc: '',
      args: [],
    );
  }

  /// `Well written`
  String get Well_written {
    return Intl.message(
      'Well written',
      name: 'Well_written',
      desc: '',
      args: [],
    );
  }

  /// `Creative`
  String get Creative {
    return Intl.message(
      'Creative',
      name: 'Creative',
      desc: '',
      args: [],
    );
  }

  /// `Media`
  String get Media {
    return Intl.message(
      'Media',
      name: 'Media',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get Report {
    return Intl.message(
      'Report',
      name: 'Report',
      desc: '',
      args: [],
    );
  }

  /// `Report this recommendation`
  String get Report_Recommendation {
    return Intl.message(
      'Report this recommendation',
      name: 'Report_Recommendation',
      desc: '',
      args: [],
    );
  }

  /// `Recommendation made by`
  String get Recommendation_made_by {
    return Intl.message(
      'Recommendation made by',
      name: 'Recommendation_made_by',
      desc: '',
      args: [],
    );
  }

  /// `Loading all recommendations with comments. This will take some time. Please be patient.`
  String get Recommendation_Loading {
    return Intl.message(
      'Loading all recommendations with comments. This will take some time. Please be patient.',
      name: 'Recommendation_Loading',
      desc: '',
      args: [],
    );
  }

  /// `Recommendations`
  String get Recommendations {
    return Intl.message(
      'Recommendations',
      name: 'Recommendations',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get Explore {
    return Intl.message(
      'Explore',
      name: 'Explore',
      desc: '',
      args: [],
    );
  }

  /// `Random`
  String get Random {
    return Intl.message(
      'Random',
      name: 'Random',
      desc: '',
      args: [],
    );
  }

  /// `Plan To Watch`
  String get Plan_To_Watch {
    return Intl.message(
      'Plan To Watch',
      name: 'Plan_To_Watch',
      desc: '',
      args: [],
    );
  }

  /// `Plan To Read`
  String get Plan_To_Read {
    return Intl.message(
      'Plan To Read',
      name: 'Plan_To_Read',
      desc: '',
      args: [],
    );
  }

  /// `Loading Random Anime`
  String get Loading_Random_Anime {
    return Intl.message(
      'Loading Random Anime',
      name: 'Loading_Random_Anime',
      desc: '',
      args: [],
    );
  }

  /// `Loading Random Manga`
  String get Loading_Random_Manga {
    return Intl.message(
      'Loading Random Manga',
      name: 'Loading_Random_Manga',
      desc: '',
      args: [],
    );
  }

  /// `Loading Random Anime from your`
  String get Loading_Random_Anime_From {
    return Intl.message(
      'Loading Random Anime from your',
      name: 'Loading_Random_Anime_From',
      desc: '',
      args: [],
    );
  }

  /// `Loading Random Manga from your`
  String get Loading_Random_Manga_From {
    return Intl.message(
      'Loading Random Manga from your',
      name: 'Loading_Random_Manga_From',
      desc: '',
      args: [],
    );
  }

  /// `No Item was found in your`
  String get No_Item_Found_In_Your {
    return Intl.message(
      'No Item was found in your',
      name: 'No_Item_Found_In_Your',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get Categories {
    return Intl.message(
      'Categories',
      name: 'Categories',
      desc: '',
      args: [],
    );
  }

  /// `Top ONA`
  String get Top_ONA {
    return Intl.message(
      'Top ONA',
      name: 'Top_ONA',
      desc: '',
      args: [],
    );
  }

  /// `Seasonal`
  String get Seasonal {
    return Intl.message(
      'Seasonal',
      name: 'Seasonal',
      desc: '',
      args: [],
    );
  }

  /// `If you liked`
  String get If_You_Liked {
    return Intl.message(
      'If you liked',
      name: 'If_You_Liked',
      desc: '',
      args: [],
    );
  }

  /// `...then you might like`
  String get Then_You_Might {
    return Intl.message(
      '...then you might like',
      name: 'Then_You_Might',
      desc: '',
      args: [],
    );
  }

  /// `Review on`
  String get Review_On {
    return Intl.message(
      'Review on',
      name: 'Review_On',
      desc: '',
      args: [],
    );
  }

  /// `Translate above text`
  String get Translate_Above_Text {
    return Intl.message(
      'Translate above text',
      name: 'Translate_Above_Text',
      desc: '',
      args: [],
    );
  }

  /// `Translate below text`
  String get Translate_Below_Text {
    return Intl.message(
      'Translate below text',
      name: 'Translate_Below_Text',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get Copy {
    return Intl.message(
      'Copy',
      name: 'Copy',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get Share {
    return Intl.message(
      'Share',
      name: 'Share',
      desc: '',
      args: [],
    );
  }

  /// `Show Menu`
  String get Show_Menu {
    return Intl.message(
      'Show Menu',
      name: 'Show_Menu',
      desc: '',
      args: [],
    );
  }

  /// `Url`
  String get Url {
    return Intl.message(
      'Url',
      name: 'Url',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get Select_All {
    return Intl.message(
      'Select all',
      name: 'Select_All',
      desc: '',
      args: [],
    );
  }

  /// `Select one`
  String get Select_One {
    return Intl.message(
      'Select one',
      name: 'Select_One',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get Score {
    return Intl.message(
      'Score',
      name: 'Score',
      desc: '',
      args: [],
    );
  }

  /// `Rank`
  String get Rank {
    return Intl.message(
      'Rank',
      name: 'Rank',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get Edit {
    return Intl.message(
      'Edit',
      name: 'Edit',
      desc: '',
      args: [],
    );
  }

  /// `Review by`
  String get Review_By {
    return Intl.message(
      'Review by',
      name: 'Review_By',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get Name {
    return Intl.message(
      'Name',
      name: 'Name',
      desc: '',
      args: [],
    );
  }

  /// `entries`
  String get Entries {
    return Intl.message(
      'entries',
      name: 'Entries',
      desc: '',
      args: [],
    );
  }

  /// `restacks`
  String get Restacks {
    return Intl.message(
      'restacks',
      name: 'Restacks',
      desc: '',
      args: [],
    );
  }

  /// `Similar`
  String get Similar {
    return Intl.message(
      'Similar',
      name: 'Similar',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get History {
    return Intl.message(
      'History',
      name: 'History',
      desc: '',
      args: [],
    );
  }

  /// `CLEAR ALL`
  String get Clear_All {
    return Intl.message(
      'CLEAR ALL',
      name: 'Clear_All',
      desc: '',
      args: [],
    );
  }

  /// `Clear all history`
  String get Clear_All_Desc {
    return Intl.message(
      'Clear all history',
      name: 'Clear_All_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Interest Stack`
  String get Interest_Stack {
    return Intl.message(
      'Interest Stack',
      name: 'Interest_Stack',
      desc: '',
      args: [],
    );
  }

  /// `nothing yet...`
  String get Nothing_yet {
    return Intl.message(
      'nothing yet...',
      name: 'Nothing_yet',
      desc: '',
      args: [],
    );
  }

  /// `Recent Anime`
  String get Recent_Anime {
    return Intl.message(
      'Recent Anime',
      name: 'Recent_Anime',
      desc: '',
      args: [],
    );
  }

  /// `Recent Manga`
  String get Recent_Manga {
    return Intl.message(
      'Recent Manga',
      name: 'Recent_Manga',
      desc: '',
      args: [],
    );
  }

  /// `Interest Stack Type`
  String get Interest_Stack_Type_Desc {
    return Intl.message(
      'Interest Stack Type',
      name: 'Interest_Stack_Type_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Interest Stacks`
  String get Interest_Stacks {
    return Intl.message(
      'Interest Stacks',
      name: 'Interest_Stacks',
      desc: '',
      args: [],
    );
  }

  /// `Days`
  String get Days {
    return Intl.message(
      'Days',
      name: 'Days',
      desc: '',
      args: [],
    );
  }

  /// `Hours`
  String get Hours {
    return Intl.message(
      'Hours',
      name: 'Hours',
      desc: '',
      args: [],
    );
  }

  /// `Minutes`
  String get Minutes {
    return Intl.message(
      'Minutes',
      name: 'Minutes',
      desc: '',
      args: [],
    );
  }

  /// `Seconds`
  String get Seconds {
    return Intl.message(
      'Seconds',
      name: 'Seconds',
      desc: '',
      args: [],
    );
  }

  /// `Countdown Timer for Anime`
  String get Show_CountDown_Time {
    return Intl.message(
      'Countdown Timer for Anime',
      name: 'Show_CountDown_Time',
      desc: '',
      args: [],
    );
  }

  /// `Shows next episode and countdown timer for anime page`
  String get Show_CountDown_Time_Desc {
    return Intl.message(
      'Shows next episode and countdown timer for anime page',
      name: 'Show_CountDown_Time_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get Notfications {
    return Intl.message(
      'Notifications',
      name: 'Notfications',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any scheduled notifications. Please move any anime to 'Watching' or 'Plan To Watch'.`
  String get No_Scheduled_Notificatons {
    return Intl.message(
      'You don\'t have any scheduled notifications. Please move any anime to \'Watching\' or \'Plan To Watch\'.',
      name: 'No_Scheduled_Notificatons',
      desc: '',
      args: [],
    );
  }

  /// `Anime/Mange tile size`
  String get Tile_Size_Title {
    return Intl.message(
      'Anime/Mange tile size',
      name: 'Tile_Size_Title',
      desc: '',
      args: [],
    );
  }

  /// `Sets tile of anime and manga cards in home page (XS, S, M, L, XL)`
  String get Tile_Size_Desc {
    return Intl.message(
      'Sets tile of anime and manga cards in home page (XS, S, M, L, XL)',
      name: 'Tile_Size_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarks`
  String get Bookmarks {
    return Intl.message(
      'Bookmarks',
      name: 'Bookmarks',
      desc: '',
      args: [],
    );
  }

  /// `Nothing bookmarked in`
  String get Nothing_bookmarked_in {
    return Intl.message(
      'Nothing bookmarked in',
      name: 'Nothing_bookmarked_in',
      desc: '',
      args: [],
    );
  }

  /// `Characters and Staffs`
  String get Characters_and_staff {
    return Intl.message(
      'Characters and Staffs',
      name: 'Characters_and_staff',
      desc: '',
      args: [],
    );
  }

  /// `Preferred language for title`
  String get PreferredTitle {
    return Intl.message(
      'Preferred language for title',
      name: 'PreferredTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select between english, japanese and romanized titles for your anime/manga`
  String get PreferredTitle_Desc {
    return Intl.message(
      'Select between english, japanese and romanized titles for your anime/manga',
      name: 'PreferredTitle_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Requesting for notification access`
  String get RequestPermission {
    return Intl.message(
      'Requesting for notification access',
      name: 'RequestPermission',
      desc: '',
      args: [],
    );
  }

  /// `Permision was denied!`
  String get RequestPermissionDenied {
    return Intl.message(
      'Permision was denied!',
      name: 'RequestPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `No more items found...`
  String get NoMoreItemsFound {
    return Intl.message(
      'No more items found...',
      name: 'NoMoreItemsFound',
      desc: '',
      args: [],
    );
  }

  /// `Allow Notifications`
  String get ConfirmNotifPerm {
    return Intl.message(
      'Allow Notifications',
      name: 'ConfirmNotifPerm',
      desc: '',
      args: [],
    );
  }

  /// `Do you wish to allow notifications for this app. This includes notifications when an episode is aired from your PTW (Plan To Watch) and Watching list.`
  String get ConfirmNotifPermDesc {
    return Intl.message(
      'Do you wish to allow notifications for this app. This includes notifications when an episode is aired from your PTW (Plan To Watch) and Watching list.',
      name: 'ConfirmNotifPermDesc',
      desc: '',
      args: [],
    );
  }

  /// `Discord Invite`
  String get DiscordInvite {
    return Intl.message(
      'Discord Invite',
      name: 'DiscordInvite',
      desc: '',
      args: [],
    );
  }

  /// `Click here to join the official Discord Server`
  String get DiscordInviteDesc {
    return Intl.message(
      'Click here to join the official Discord Server',
      name: 'DiscordInviteDesc',
      desc: '',
      args: [],
    );
  }

  /// `Adaptations`
  String get Adaptations {
    return Intl.message(
      'Adaptations',
      name: 'Adaptations',
      desc: '',
      args: [],
    );
  }

  /// `Anime in your Plan to watch list`
  String get PlanToWatchDesc {
    return Intl.message(
      'Anime in your Plan to watch list',
      name: 'PlanToWatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `Anime in your Watching list`
  String get WatchingDesc {
    return Intl.message(
      'Anime in your Watching list',
      name: 'WatchingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Test notifications on your device`
  String get TestNotification {
    return Intl.message(
      'Test notifications on your device',
      name: 'TestNotification',
      desc: '',
      args: [],
    );
  }

  /// `Show large images in notifications`
  String get PreferLargeImageNotif {
    return Intl.message(
      'Show large images in notifications',
      name: 'PreferLargeImageNotif',
      desc: '',
      args: [],
    );
  }

  /// `Show large images instead of icons of your anime in the notifications`
  String get PreferLargeImageNotifDesc {
    return Intl.message(
      'Show large images instead of icons of your anime in the notifications',
      name: 'PreferLargeImageNotifDesc',
      desc: '',
      args: [],
    );
  }

  /// `Notification scheduled after 2 seconds`
  String get NotifScheduled {
    return Intl.message(
      'Notification scheduled after 2 seconds',
      name: 'NotifScheduled',
      desc: '',
      args: [],
    );
  }

  /// `Search anime, manga & more`
  String get SearchBarHintText {
    return Intl.message(
      'Search anime, manga & more',
      name: 'SearchBarHintText',
      desc: '',
      args: [],
    );
  }

  /// `Select a rating`
  String get SelectARating {
    return Intl.message(
      'Select a rating',
      name: 'SelectARating',
      desc: '',
      args: [],
    );
  }

  /// `Appalling`
  String get Appalling {
    return Intl.message(
      'Appalling',
      name: 'Appalling',
      desc: '',
      args: [],
    );
  }

  /// `Horrible`
  String get Horrible {
    return Intl.message(
      'Horrible',
      name: 'Horrible',
      desc: '',
      args: [],
    );
  }

  /// `Very Bad`
  String get Very_Bad {
    return Intl.message(
      'Very Bad',
      name: 'Very_Bad',
      desc: '',
      args: [],
    );
  }

  /// `Bad`
  String get Bad {
    return Intl.message(
      'Bad',
      name: 'Bad',
      desc: '',
      args: [],
    );
  }

  /// `Average`
  String get Average {
    return Intl.message(
      'Average',
      name: 'Average',
      desc: '',
      args: [],
    );
  }

  /// `Fine`
  String get Fine {
    return Intl.message(
      'Fine',
      name: 'Fine',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get Good {
    return Intl.message(
      'Good',
      name: 'Good',
      desc: '',
      args: [],
    );
  }

  /// `Very Good`
  String get Very_Good {
    return Intl.message(
      'Very Good',
      name: 'Very_Good',
      desc: '',
      args: [],
    );
  }

  /// `Great`
  String get Great {
    return Intl.message(
      'Great',
      name: 'Great',
      desc: '',
      args: [],
    );
  }

  /// `Masterpiece`
  String get Masterpiece {
    return Intl.message(
      'Masterpiece',
      name: 'Masterpiece',
      desc: '',
      args: [],
    );
  }

  /// `Reading status`
  String get Reading_Status {
    return Intl.message(
      'Reading status',
      name: 'Reading_Status',
      desc: '',
      args: [],
    );
  }

  /// `Pick a color`
  String get Pick_a_color {
    return Intl.message(
      'Pick a color',
      name: 'Pick_a_color',
      desc: '',
      args: [],
    );
  }

  /// `Leaving it to auto, will pick a color from your wallpaper`
  String get Pick_a_color_desc {
    return Intl.message(
      'Leaving it to auto, will pick a color from your wallpaper',
      name: 'Pick_a_color_desc',
      desc: '',
      args: [],
    );
  }

  /// `Select a theme mode`
  String get Select_mode {
    return Intl.message(
      'Select a theme mode',
      name: 'Select_mode',
      desc: '',
      args: [],
    );
  }

  /// `Leaving it to auto, will select your system theme mode`
  String get Select_mode_desc {
    return Intl.message(
      'Leaving it to auto, will select your system theme mode',
      name: 'Select_mode_desc',
      desc: '',
      args: [],
    );
  }

  /// `Select a background image`
  String get Select_bg {
    return Intl.message(
      'Select a background image',
      name: 'Select_bg',
      desc: '',
      args: [],
    );
  }

  /// `This image will apply to the home page`
  String get Select_bg_desc {
    return Intl.message(
      'This image will apply to the home page',
      name: 'Select_bg_desc',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get Selected {
    return Intl.message(
      'Selected',
      name: 'Selected',
      desc: '',
      args: [],
    );
  }

  /// `Anime/Manga page settings`
  String get Anime_Manga_settings {
    return Intl.message(
      'Anime/Manga page settings',
      name: 'Anime_Manga_settings',
      desc: '',
      args: [],
    );
  }

  /// `Customize anime/manga page tabs, ordering and more`
  String get Anime_Manga_settings_desc {
    return Intl.message(
      'Customize anime/manga page tabs, ordering and more',
      name: 'Anime_Manga_settings_desc',
      desc: '',
      args: [],
    );
  }

  /// `Customize Anime Tabs`
  String get Custom_anime_tabs {
    return Intl.message(
      'Customize Anime Tabs',
      name: 'Custom_anime_tabs',
      desc: '',
      args: [],
    );
  }

  /// `Customize Manga Tabs`
  String get Custom_manga_tabs {
    return Intl.message(
      'Customize Manga Tabs',
      name: 'Custom_manga_tabs',
      desc: '',
      args: [],
    );
  }

  /// `Customize Tabs`
  String get Customize_tabs {
    return Intl.message(
      'Customize Tabs',
      name: 'Customize_tabs',
      desc: '',
      args: [],
    );
  }

  /// `Clubs`
  String get Clubs {
    return Intl.message(
      'Clubs',
      name: 'Clubs',
      desc: '',
      args: [],
    );
  }

  /// `Start up page`
  String get StartUp_page {
    return Intl.message(
      'Start up page',
      name: 'StartUp_page',
      desc: '',
      args: [],
    );
  }

  /// `Select a startup page from home/forum/user/explore`
  String get Customize_Bottom_Navbar_desc {
    return Intl.message(
      'Select a startup page from home/forum/user/explore',
      name: 'Customize_Bottom_Navbar_desc',
      desc: '',
      args: [],
    );
  }

  /// `New features`
  String get New_features {
    return Intl.message(
      'New features',
      name: 'New_features',
      desc: '',
      args: [],
    );
  }

  /// `Explicit Genres`
  String get Explicit_Genres {
    return Intl.message(
      'Explicit Genres',
      name: 'Explicit_Genres',
      desc: '',
      args: [],
    );
  }

  /// `Themes`
  String get Themes {
    return Intl.message(
      'Themes',
      name: 'Themes',
      desc: '',
      args: [],
    );
  }

  /// `Demographics`
  String get Demographics {
    return Intl.message(
      'Demographics',
      name: 'Demographics',
      desc: '',
      args: [],
    );
  }

  /// `Select a score to filter by`
  String get Select_A_Score {
    return Intl.message(
      'Select a score to filter by',
      name: 'Select_A_Score',
      desc: '',
      args: [],
    );
  }

  /// `Helpful`
  String get Helpful {
    return Intl.message(
      'Helpful',
      name: 'Helpful',
      desc: '',
      args: [],
    );
  }

  /// `Sort Reviews by`
  String get Sort_Reviews_By {
    return Intl.message(
      'Sort Reviews by',
      name: 'Sort_Reviews_By',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast timezone for anime`
  String get Anime_Timezone_Pref {
    return Intl.message(
      'Broadcast timezone for anime',
      name: 'Anime_Timezone_Pref',
      desc: '',
      args: [],
    );
  }

  /// `JST`
  String get JST {
    return Intl.message(
      'JST',
      name: 'JST',
      desc: '',
      args: [],
    );
  }

  /// `UTC`
  String get UTC {
    return Intl.message(
      'UTC',
      name: 'UTC',
      desc: '',
      args: [],
    );
  }

  /// `Local Time`
  String get Local_Time {
    return Intl.message(
      'Local Time',
      name: 'Local_Time',
      desc: '',
      args: [],
    );
  }

  /// `Backup and Restore`
  String get Backup_And_Restore {
    return Intl.message(
      'Backup and Restore',
      name: 'Backup_And_Restore',
      desc: '',
      args: [],
    );
  }

  /// `Backup to cloud and restore`
  String get Backup_And_Restore_desc {
    return Intl.message(
      'Backup to cloud and restore',
      name: 'Backup_And_Restore_desc',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get Backup {
    return Intl.message(
      'Backup',
      name: 'Backup',
      desc: '',
      args: [],
    );
  }

  /// `This will backup your bookmarks, settings, etc`
  String get Backup_Desc {
    return Intl.message(
      'This will backup your bookmarks, settings, etc',
      name: 'Backup_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get Restore {
    return Intl.message(
      'Restore',
      name: 'Restore',
      desc: '',
      args: [],
    );
  }

  /// `Restore settings, bookmarks from the provided file`
  String get Restore_desc {
    return Intl.message(
      'Restore settings, bookmarks from the provided file',
      name: 'Restore_desc',
      desc: '',
      args: [],
    );
  }

  /// `Confirm backup?`
  String get Backup_Confirmation {
    return Intl.message(
      'Confirm backup?',
      name: 'Backup_Confirmation',
      desc: '',
      args: [],
    );
  }

  /// `This will save a back-up file to your downloads folder, please use this file to restore your profile.`
  String get Backup_Confirmation_Desc {
    return Intl.message(
      'This will save a back-up file to your downloads folder, please use this file to restore your profile.',
      name: 'Backup_Confirmation_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled Restore`
  String get Cancelled_Restore {
    return Intl.message(
      'Cancelled Restore',
      name: 'Cancelled_Restore',
      desc: '',
      args: [],
    );
  }

  /// `Restore success`
  String get Restore_Sucess {
    return Intl.message(
      'Restore success',
      name: 'Restore_Sucess',
      desc: '',
      args: [],
    );
  }

  /// `Restore failed`
  String get Restore_fail {
    return Intl.message(
      'Restore failed',
      name: 'Restore_fail',
      desc: '',
      args: [],
    );
  }

  /// `Back-up file is saved into your downloads folder!`
  String get BackUpFileSaved {
    return Intl.message(
      'Back-up file is saved into your downloads folder!',
      name: 'BackUpFileSaved',
      desc: '',
      args: [],
    );
  }

  /// `My Profile`
  String get My_Profile {
    return Intl.message(
      'My Profile',
      name: 'My_Profile',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get Loading {
    return Intl.message(
      'Loading',
      name: 'Loading',
      desc: '',
      args: [],
    );
  }

  /// `Profile Page`
  String get Profile_Page {
    return Intl.message(
      'Profile Page',
      name: 'Profile_Page',
      desc: '',
      args: [],
    );
  }

  /// `Manga Statistics`
  String get Manga_Stats {
    return Intl.message(
      'Manga Statistics',
      name: 'Manga_Stats',
      desc: '',
      args: [],
    );
  }

  /// `entry`
  String get Entry {
    return Intl.message(
      'entry',
      name: 'Entry',
      desc: '',
      args: [],
    );
  }

  /// `Mean Score`
  String get Mean_Score {
    return Intl.message(
      'Mean Score',
      name: 'Mean_Score',
      desc: '',
      args: [],
    );
  }

  /// `So far`
  String get So_far {
    return Intl.message(
      'So far',
      name: 'So_far',
      desc: '',
      args: [],
    );
  }

  /// `BirthDay`
  String get BirthDay {
    return Intl.message(
      'BirthDay',
      name: 'BirthDay',
      desc: '',
      args: [],
    );
  }

  /// `Generate Other charts`
  String get Generate_Other_charts {
    return Intl.message(
      'Generate Other charts',
      name: 'Generate_Other_charts',
      desc: '',
      args: [],
    );
  }

  /// `Loading advanced charts`
  String get Loading_Advanced_Charts {
    return Intl.message(
      'Loading advanced charts',
      name: 'Loading_Advanced_Charts',
      desc: '',
      args: [],
    );
  }

  /// `Score Distribution`
  String get Score_Distribution {
    return Intl.message(
      'Score Distribution',
      name: 'Score_Distribution',
      desc: '',
      args: [],
    );
  }

  /// `Genre Distribution`
  String get Genre_Distribution {
    return Intl.message(
      'Genre Distribution',
      name: 'Genre_Distribution',
      desc: '',
      args: [],
    );
  }

  /// `Studio Distribution`
  String get Studio_Distribution {
    return Intl.message(
      'Studio Distribution',
      name: 'Studio_Distribution',
      desc: '',
      args: [],
    );
  }

  /// `Author Distribution`
  String get Author_Distribution {
    return Intl.message(
      'Author Distribution',
      name: 'Author_Distribution',
      desc: '',
      args: [],
    );
  }

  /// `Unranked Shows`
  String get Un_Ranked_Shows {
    return Intl.message(
      'Unranked Shows',
      name: 'Un_Ranked_Shows',
      desc: '',
      args: [],
    );
  }

  /// `Genre`
  String get Genre {
    return Intl.message(
      'Genre',
      name: 'Genre',
      desc: '',
      args: [],
    );
  }

  /// `Count`
  String get Count {
    return Intl.message(
      'Count',
      name: 'Count',
      desc: '',
      args: [],
    );
  }

  /// `No enough data to generate the graph`
  String get No_Enough_Data_To_generate_Graph_Info {
    return Intl.message(
      'No enough data to generate the graph',
      name: 'No_Enough_Data_To_generate_Graph_Info',
      desc: '',
      args: [],
    );
  }

  /// `No enough data to generate the graph, atleast 3 unique genres are need`
  String get No_Enough_Data_To_generate_Graph {
    return Intl.message(
      'No enough data to generate the graph, atleast 3 unique genres are need',
      name: 'No_Enough_Data_To_generate_Graph',
      desc: '',
      args: [],
    );
  }

  /// `I liked it, they hated it`
  String get I_Liked_It_They_Hated_It {
    return Intl.message(
      'I liked it, they hated it',
      name: 'I_Liked_It_They_Hated_It',
      desc: '',
      args: [],
    );
  }

  /// `Add Friend`
  String get Add_Friend {
    return Intl.message(
      'Add Friend',
      name: 'Add_Friend',
      desc: '',
      args: [],
    );
  }

  /// `User found`
  String get User_found_as {
    return Intl.message(
      'User found',
      name: 'User_found_as',
      desc: '',
      args: [],
    );
  }

  /// `No history found`
  String get No_history_found {
    return Intl.message(
      'No history found',
      name: 'No_history_found',
      desc: '',
      args: [],
    );
  }

  /// `items`
  String get items {
    return Intl.message(
      'items',
      name: 'items',
      desc: '',
      args: [],
    );
  }

  /// `item`
  String get item {
    return Intl.message(
      'item',
      name: 'item',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get Today {
    return Intl.message(
      'Today',
      name: 'Today',
      desc: '',
      args: [],
    );
  }

  /// `Last Week`
  String get Last_Week {
    return Intl.message(
      'Last Week',
      name: 'Last_Week',
      desc: '',
      args: [],
    );
  }

  /// `Two Weeks ago`
  String get Two_Weeks_ago {
    return Intl.message(
      'Two Weeks ago',
      name: 'Two_Weeks_ago',
      desc: '',
      args: [],
    );
  }

  /// `Three Weeks ago`
  String get Three_Weeks_ago {
    return Intl.message(
      'Three Weeks ago',
      name: 'Three_Weeks_ago',
      desc: '',
      args: [],
    );
  }

  /// `Last Month`
  String get Last_Month {
    return Intl.message(
      'Last Month',
      name: 'Last_Month',
      desc: '',
      args: [],
    );
  }

  /// `Two Months ago`
  String get Two_Months_ago {
    return Intl.message(
      'Two Months ago',
      name: 'Two_Months_ago',
      desc: '',
      args: [],
    );
  }

  /// `Unseen`
  String get Unseen {
    return Intl.message(
      'Unseen',
      name: 'Unseen',
      desc: '',
      args: [],
    );
  }

  /// `Sort & Filter`
  String get Sort_and_Filter {
    return Intl.message(
      'Sort & Filter',
      name: 'Sort_and_Filter',
      desc: '',
      args: [],
    );
  }

  /// `Sort`
  String get Sort {
    return Intl.message(
      'Sort',
      name: 'Sort',
      desc: '',
      args: [],
    );
  }

  /// `Display`
  String get Display {
    return Intl.message(
      'Display',
      name: 'Display',
      desc: '',
      args: [],
    );
  }

  /// `No. of List users`
  String get numListUsers {
    return Intl.message(
      'No. of List users',
      name: 'numListUsers',
      desc: '',
      args: [],
    );
  }

  /// `No. of Scoring users`
  String get numScoringUsers {
    return Intl.message(
      'No. of Scoring users',
      name: 'numScoringUsers',
      desc: '',
      args: [],
    );
  }

  /// `No. of Episodes`
  String get numEpisodes {
    return Intl.message(
      'No. of Episodes',
      name: 'numEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast Start Date`
  String get broadCastStartDate {
    return Intl.message(
      'Broadcast Start Date',
      name: 'broadCastStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Broadcast End Date`
  String get broadCastEndDate {
    return Intl.message(
      'Broadcast End Date',
      name: 'broadCastEndDate',
      desc: '',
      args: [],
    );
  }

  /// `No. of Volumes`
  String get numVolumes {
    return Intl.message(
      'No. of Volumes',
      name: 'numVolumes',
      desc: '',
      args: [],
    );
  }

  /// `No. of Chapters`
  String get numChapters {
    return Intl.message(
      'No. of Chapters',
      name: 'numChapters',
      desc: '',
      args: [],
    );
  }

  /// `Published Start Date`
  String get publishedStartDate {
    return Intl.message(
      'Published Start Date',
      name: 'publishedStartDate',
      desc: '',
      args: [],
    );
  }

  /// `List Page`
  String get listPage {
    return Intl.message(
      'List Page',
      name: 'listPage',
      desc: '',
      args: [],
    );
  }

  /// `Display Type`
  String get Display_Type {
    return Intl.message(
      'Display Type',
      name: 'Display_Type',
      desc: '',
      args: [],
    );
  }

  /// `Display Sub Type`
  String get Display_Sub_Type {
    return Intl.message(
      'Display Sub Type',
      name: 'Display_Sub_Type',
      desc: '',
      args: [],
    );
  }

  /// `Comfortable`
  String get Comfortable {
    return Intl.message(
      'Comfortable',
      name: 'Comfortable',
      desc: '',
      args: [],
    );
  }

  /// `Compact`
  String get Compact {
    return Intl.message(
      'Compact',
      name: 'Compact',
      desc: '',
      args: [],
    );
  }

  /// `Cover Only`
  String get Cover_only {
    return Intl.message(
      'Cover Only',
      name: 'Cover_only',
      desc: '',
      args: [],
    );
  }

  /// `Spacious`
  String get Spacious {
    return Intl.message(
      'Spacious',
      name: 'Spacious',
      desc: '',
      args: [],
    );
  }

  /// `Grid Axis Size`
  String get Grid_Axis_Size {
    return Intl.message(
      'Grid Axis Size',
      name: 'Grid_Axis_Size',
      desc: '',
      args: [],
    );
  }

  /// `Image size too large, limit is 1.5MB`
  String get Image_Size_Too_Large {
    return Intl.message(
      'Image size too large, limit is 1.5MB',
      name: 'Image_Size_Too_Large',
      desc: '',
      args: [],
    );
  }

  /// `Error uploading image`
  String get Error_uploading_image {
    return Intl.message(
      'Error uploading image',
      name: 'Error_uploading_image',
      desc: '',
      args: [],
    );
  }

  /// `Profile background is set successfully`
  String get Profile_bg_set {
    return Intl.message(
      'Profile background is set successfully',
      name: 'Profile_bg_set',
      desc: '',
      args: [],
    );
  }

  /// `Invalid extension`
  String get Invalid_extension {
    return Intl.message(
      'Invalid extension',
      name: 'Invalid_extension',
      desc: '',
      args: [],
    );
  }

  /// `Profile background is removed successfully`
  String get Profile_bg_removed {
    return Intl.message(
      'Profile background is removed successfully',
      name: 'Profile_bg_removed',
      desc: '',
      args: [],
    );
  }

  /// `Error removing image`
  String get Error_removing_image {
    return Intl.message(
      'Error removing image',
      name: 'Error_removing_image',
      desc: '',
      args: [],
    );
  }

  /// `Do you wish to remove the background image?`
  String get Remove_the_Bg {
    return Intl.message(
      'Do you wish to remove the background image?',
      name: 'Remove_the_Bg',
      desc: '',
      args: [],
    );
  }

  /// `Grid Height`
  String get Grid_Height {
    return Intl.message(
      'Grid Height',
      name: 'Grid_Height',
      desc: '',
      args: [],
    );
  }

  /// `My List`
  String get My_List2 {
    return Intl.message(
      'My List',
      name: 'My_List2',
      desc: '',
      args: [],
    );
  }

  /// `Show content card`
  String get showAnimeMangaCard {
    return Intl.message(
      'Show content card',
      name: 'showAnimeMangaCard',
      desc: '',
      args: [],
    );
  }

  /// `Show card around the content in list view (comfirtable) wherever possible`
  String get showAnimeMangaCardDesc {
    return Intl.message(
      'Show card around the content in list view (comfirtable) wherever possible',
      name: 'showAnimeMangaCardDesc',
      desc: '',
      args: [],
    );
  }

  /// `More Links`
  String get moreLinks {
    return Intl.message(
      'More Links',
      name: 'moreLinks',
      desc: '',
      args: [],
    );
  }

  /// `Resources`
  String get Resources {
    return Intl.message(
      'Resources',
      name: 'Resources',
      desc: '',
      args: [],
    );
  }

  /// `Available At`
  String get Available_At {
    return Intl.message(
      'Available At',
      name: 'Available_At',
      desc: '',
      args: [],
    );
  }

  /// `Other Lists`
  String get Other_Lists {
    return Intl.message(
      'Other Lists',
      name: 'Other_Lists',
      desc: '',
      args: [],
    );
  }

  /// `Additional Titles`
  String get AdditionalTitles {
    return Intl.message(
      'Additional Titles',
      name: 'AdditionalTitles',
      desc: '',
      args: [],
    );
  }

  /// `Allow Youtube Player`
  String get Allow_YT_Player {
    return Intl.message(
      'Allow Youtube Player',
      name: 'Allow_YT_Player',
      desc: '',
      args: [],
    );
  }

  /// `Allow Youtube player to play videos in the app`
  String get Allow_YT_Player_Desc {
    return Intl.message(
      'Allow Youtube player to play videos in the app',
      name: 'Allow_YT_Player_Desc',
      desc: '',
      args: [],
    );
  }

  /// `Horizontal List`
  String get Horizontal_List {
    return Intl.message(
      'Horizontal List',
      name: 'Horizontal_List',
      desc: '',
      args: [],
    );
  }

  /// `Published End Date`
  String get publishedEndDate {
    return Intl.message(
      'Published End Date',
      name: 'publishedEndDate',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar', countryCode: 'EG'),
      Locale.fromSubtags(languageCode: 'de', countryCode: 'DE'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'id', countryCode: 'ID'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko', countryCode: 'KR'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
