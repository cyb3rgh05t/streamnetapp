import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
  ];

  // App Identity
  String get appName;
  String get slogan;

  // Auth
  String get login;
  String get loginSubtitle;
  String get logout;
  String get logoutConfirmation;

  // Username
  String get username;
  String get usernamePlaceholder;
  String get usernameRequired;
  String get usernameMin3;

  // Password
  String get password;
  String get passwordPlaceholder;
  String get passwordRequired;
  String get passwordMin3;

  // Errors
  String get invalidCredentials;
  String get connectionError;
  String get connectedTo;

  // Navigation
  String get history;
  String get liveTV;
  String get movies;
  String get series;
  String get settings;
  String get search;

  // Loading
  String get connecting;
  String get loadingContent;
  String get preparingCategories;
  String get preparingLiveStreams;
  String get preparingMovies;
  String get preparingSeries;

  // Common
  String get errorOccurred;
  String get backToLogin;
  String get cancel;
  String get close;
  String get retry;
  String get save;
  String get delete;
  String get edit;
  String get refresh;

  // Account
  String get account;
  String get subscription;
  String get maxConnections;

  // Appearance
  String get appearance;
  String get theme;
  String get system;
  String get light;
  String get dark;
  String get language;

  // About
  String get about;
  String get appVersion;
  String get server;

  // Content
  String get noContent;
  String get noResults;
  String get loading;

  // Favorites
  String get favorites;
  String get addToFavorites;
  String get removeFromFavorites;

  // Watch
  String get continueWatching;
  String get watchNow;
  String get playNow;

  // Categories
  String get categories;
  String get allCategories;
  String get seeAll;

  // Content filters
  String get noChannelsFound;
  String get noMoviesFound;
  String get noSeriesFound;
  String get noEpisodesFound;
  String get season;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
    default:
      return AppLocalizationsEn();
  }
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'StreamNet TV';
  @override
  String get slogan => 'Your Premium IPTV Experience';

  @override
  String get login => 'Sign In';
  @override
  String get loginSubtitle => 'Sign in to continue';
  @override
  String get logout => 'Logout';
  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get username => 'Username';
  @override
  String get usernamePlaceholder => 'Enter your username';
  @override
  String get usernameRequired => 'Username is required';
  @override
  String get usernameMin3 => 'Username must be at least 3 characters';

  @override
  String get password => 'Password';
  @override
  String get passwordPlaceholder => 'Enter your password';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get passwordMin3 => 'Password must be at least 3 characters';

  @override
  String get invalidCredentials => 'Invalid username or password';
  @override
  String get connectionError => 'Connection error. Please try again.';
  @override
  String get connectedTo => 'Connected to StreamNet Server';

  @override
  String get history => 'History';
  @override
  String get liveTV => 'Live TV';
  @override
  String get movies => 'Movies';
  @override
  String get series => 'Series';
  @override
  String get settings => 'Settings';
  @override
  String get search => 'Search';

  @override
  String get connecting => 'Connecting...';
  @override
  String get loadingContent => 'Loading your content...';
  @override
  String get preparingCategories => 'Loading categories...';
  @override
  String get preparingLiveStreams => 'Loading live channels...';
  @override
  String get preparingMovies => 'Loading movies...';
  @override
  String get preparingSeries => 'Loading series...';

  @override
  String get errorOccurred => 'An error occurred';
  @override
  String get backToLogin => 'Back to Login';
  @override
  String get cancel => 'Cancel';
  @override
  String get close => 'Close';
  @override
  String get retry => 'Retry';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get refresh => 'Refresh';

  @override
  String get account => 'Account';
  @override
  String get subscription => 'Subscription';
  @override
  String get maxConnections => 'Max Connections';

  @override
  String get appearance => 'Appearance';
  @override
  String get theme => 'Theme';
  @override
  String get system => 'System';
  @override
  String get light => 'Light';
  @override
  String get dark => 'Dark';
  @override
  String get language => 'Language';

  @override
  String get about => 'About';
  @override
  String get appVersion => 'App Version';
  @override
  String get server => 'Server';

  @override
  String get noContent => 'No content available';
  @override
  String get noResults => 'No results found';
  @override
  String get loading => 'Loading...';

  @override
  String get favorites => 'Favorites';
  @override
  String get addToFavorites => 'Add to Favorites';
  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get continueWatching => 'Continue Watching';
  @override
  String get watchNow => 'Watch Now';
  @override
  String get playNow => 'Play Now';

  @override
  String get categories => 'Categories';
  @override
  String get allCategories => 'All Categories';
  @override
  String get seeAll => 'See All';

  @override
  String get noChannelsFound => 'No channels found';
  @override
  String get noMoviesFound => 'No movies found';
  @override
  String get noSeriesFound => 'No series found';
  @override
  String get noEpisodesFound => 'No episodes found';
  @override
  String get season => 'Season';
}

class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'StreamNet TV';
  @override
  String get slogan => 'Dein Premium IPTV Erlebnis';

  @override
  String get login => 'Anmelden';
  @override
  String get loginSubtitle => 'Melde dich an, um fortzufahren';
  @override
  String get logout => 'Abmelden';
  @override
  String get logoutConfirmation =>
      'Bist du sicher, dass du dich abmelden möchtest?';

  @override
  String get username => 'Benutzername';
  @override
  String get usernamePlaceholder => 'Gib deinen Benutzernamen ein';
  @override
  String get usernameRequired => 'Benutzername ist erforderlich';
  @override
  String get usernameMin3 => 'Benutzername muss mindestens 3 Zeichen haben';

  @override
  String get password => 'Passwort';
  @override
  String get passwordPlaceholder => 'Gib dein Passwort ein';
  @override
  String get passwordRequired => 'Passwort ist erforderlich';
  @override
  String get passwordMin3 => 'Passwort muss mindestens 3 Zeichen haben';

  @override
  String get invalidCredentials => 'Ungültiger Benutzername oder Passwort';
  @override
  String get connectionError => 'Verbindungsfehler. Bitte erneut versuchen.';
  @override
  String get connectedTo => 'Verbunden mit StreamNet Server';

  @override
  String get history => 'Verlauf';
  @override
  String get liveTV => 'Live TV';
  @override
  String get movies => 'Filme';
  @override
  String get series => 'Serien';
  @override
  String get settings => 'Einstellungen';
  @override
  String get search => 'Suche';

  @override
  String get connecting => 'Verbinden...';
  @override
  String get loadingContent => 'Lade deine Inhalte...';
  @override
  String get preparingCategories => 'Lade Kategorien...';
  @override
  String get preparingLiveStreams => 'Lade Live-Kanäle...';
  @override
  String get preparingMovies => 'Lade Filme...';
  @override
  String get preparingSeries => 'Lade Serien...';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';
  @override
  String get backToLogin => 'Zurück zur Anmeldung';
  @override
  String get cancel => 'Abbrechen';
  @override
  String get close => 'Schließen';
  @override
  String get retry => 'Erneut versuchen';
  @override
  String get save => 'Speichern';
  @override
  String get delete => 'Löschen';
  @override
  String get edit => 'Bearbeiten';
  @override
  String get refresh => 'Aktualisieren';

  @override
  String get account => 'Konto';
  @override
  String get subscription => 'Abonnement';
  @override
  String get maxConnections => 'Max. Verbindungen';

  @override
  String get appearance => 'Erscheinungsbild';
  @override
  String get theme => 'Design';
  @override
  String get system => 'System';
  @override
  String get light => 'Hell';
  @override
  String get dark => 'Dunkel';
  @override
  String get language => 'Sprache';

  @override
  String get about => 'Über';
  @override
  String get appVersion => 'App-Version';
  @override
  String get server => 'Server';

  @override
  String get noContent => 'Keine Inhalte verfügbar';
  @override
  String get noResults => 'Keine Ergebnisse gefunden';
  @override
  String get loading => 'Lädt...';

  @override
  String get favorites => 'Favoriten';
  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';
  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get continueWatching => 'Weiterschauen';
  @override
  String get watchNow => 'Jetzt ansehen';
  @override
  String get playNow => 'Jetzt abspielen';

  @override
  String get categories => 'Kategorien';
  @override
  String get allCategories => 'Alle Kategorien';
  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get noChannelsFound => 'Keine Kanäle gefunden';
  @override
  String get noMoviesFound => 'Keine Filme gefunden';
  @override
  String get noSeriesFound => 'Keine Serien gefunden';
  @override
  String get noEpisodesFound => 'Keine Episoden gefunden';
  @override
  String get season => 'Staffel';
}
