// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Heart-Connect';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get close => 'Fermer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get search => 'Rechercher';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Attention';

  @override
  String get retry => 'Réessayer';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get done => 'Terminé';

  @override
  String get all => 'Tout';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get tomorrow => 'Demain';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingWelcome =>
      'Partagez joie et gratitude\navec vos proches';

  @override
  String get onboardingDesc1 => 'Heart-Connect est';

  @override
  String get onboardingDesc2 => 'une application pour envoyer';

  @override
  String get onboardingDesc3 => 'des cartes chaleureuses';

  @override
  String get onboardingDesc4 => 'à ceux que vous aimez.';

  @override
  String get onboardingDesc5 => 'Pour les anniversaires et fêtes,';

  @override
  String get onboardingDesc6 => 'partagez vos';

  @override
  String get onboardingDesc7 => 'sentiments sincères.';

  @override
  String get onboardingEnterName => 'Entrez votre nom';

  @override
  String get onboardingNameHint => 'Nom ou surnom';

  @override
  String get onboardingNameDesc =>
      'Ce nom apparaîtra comme signature sur les cartes.\nVous pouvez le changer à tout moment dans les paramètres.';

  @override
  String get onboardingNameRequired => 'Veuillez entrer votre nom';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get permissionContacts => 'Accès aux contacts';

  @override
  String get permissionCalendar => 'Accès au calendrier';

  @override
  String get permissionWhyNeeded => 'Pourquoi est-ce nécessaire ?';

  @override
  String get permissionContactsDesc =>
      'L\'accès aux contacts est nécessaire pour envoyer des cartes à votre famille et vos amis.\n\nVous pouvez facilement sélectionner des destinataires parmi vos contacts enregistrés.';

  @override
  String get permissionCalendarDesc =>
      'L\'accès au calendrier est nécessaire pour obtenir les anniversaires et événements de vos proches.\n\nRecevez des rappels pour ne jamais manquer un jour important !';

  @override
  String get permissionPrivacy =>
      '🔒 Confidentialité\n\nLes informations collectées sont utilisées uniquement sur votre téléphone et ne sont jamais partagées.';

  @override
  String get permissionAllow => 'Autoriser l\'accès';

  @override
  String get permissionAllowContacts => 'Autoriser Contacts';

  @override
  String get permissionAllowCalendar => 'Autoriser Calendrier';

  @override
  String get permissionSkip => 'Plus tard';

  @override
  String get permissionSkipContacts =>
      'Si vous refusez, vous devrez entrer les contacts manuellement.';

  @override
  String get permissionSkipCalendar =>
      'Si vous refusez, vous devrez entrer les événements manuellement.';

  @override
  String get permissionSms => 'Accès SMS';

  @override
  String get permissionSmsDesc =>
      'L\'accès aux SMS est nécessaire pour voir l\'historique des messages avec vos contacts.\n\nVous pouvez voir vos conversations après avoir envoyé des cartes !';

  @override
  String get permissionAllowSms => 'Autoriser SMS';

  @override
  String get permissionSkipSms =>
      'Si vous refusez, vous ne pourrez pas voir l\'historique des messages.';

  @override
  String get permissionSendSms => 'Envoi SMS';

  @override
  String get permissionSendSmsDesc =>
      'L\'autorisation d\'envoyer des SMS est requise pour envoyer des cartes directement par message.\n\nSans cette autorisation, vous ne pouvez envoyer que via l\'application de messagerie.';

  @override
  String get permissionAllowSendSms => 'Autoriser l\'envoi SMS';

  @override
  String get navHome => 'Accueil';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navGallery => 'Galerie';

  @override
  String get navMessages => 'Messages';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get homeUpcoming => 'Événements à venir';

  @override
  String get homeNoEvents => 'Aucun événement prévu';

  @override
  String get homeQuickSend => 'Envoi rapide';

  @override
  String get homeRecentCards => 'Cartes récentes';

  @override
  String get homeWriteCard => 'Écrire une carte';

  @override
  String get homeDaysLeft => 'jours restants';

  @override
  String get homeDDay => 'Jour J';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsAll => 'Tous';

  @override
  String get contactsFamily => 'Famille';

  @override
  String get contactsFriends => 'Amis';

  @override
  String get contactsWork => 'Travail';

  @override
  String get contactsOthers => 'Autres';

  @override
  String get contactsFavorites => 'Favoris';

  @override
  String get contactsEmpty => 'Aucun contact';

  @override
  String get contactsSearchHint => 'Nom ou numéro...';

  @override
  String get contactsMyPeople => 'Mes proches';

  @override
  String get contactsMemories => 'Souvenirs';

  @override
  String get contactsRecent => 'Récents';

  @override
  String get contactsSearchPlaceholder => 'Rechercher nom, tag';

  @override
  String get contactsNoMemories => 'Aucun souvenir pour l\'instant.';

  @override
  String get contactsSendCard => 'Envoyer une carte';

  @override
  String get contactsCall => 'Appeler';

  @override
  String get contactsMessage => 'Message';

  @override
  String get contactsBirthday => 'Anniversaire';

  @override
  String get contactsAnniversary => 'Fête';

  @override
  String get contactsNoHistory => 'Aucun historique.';

  @override
  String get contactsSearchContent => 'Rechercher contenu';

  @override
  String get contactsNoSearchResult => 'Aucun résultat.';

  @override
  String get contactsMessageSent => 'Envoyé';

  @override
  String get contactsMessageReceived => 'Reçu';

  @override
  String get contactsGroups => 'Groupes';

  @override
  String get groupManage => 'Gérer les groupes';

  @override
  String get groupAdd => 'Ajouter un groupe';

  @override
  String get groupEdit => 'Modifier le groupe';

  @override
  String get groupDelete => 'Supprimer le groupe';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get groupNameHint => 'Entrez le nom du groupe';

  @override
  String get groupNameRequired => 'Veuillez entrer le nom du groupe';

  @override
  String groupDeleteConfirm(String name) {
    return 'Supprimer le groupe \"$name\" ?';
  }

  @override
  String get groupDeleteDesc =>
      'Seul le groupe sera supprimé, les contacts sont conservés.';

  @override
  String get groupEmpty => 'Aucun contact dans ce groupe';

  @override
  String get groupAddContact => 'Ajouter un contact';

  @override
  String get groupRemoveContact => 'Retirer du groupe';

  @override
  String get groupSelectGroups => 'Sélectionner les groupes';

  @override
  String get groupNoGroups => 'Aucun groupe enregistré';

  @override
  String get groupCreateFirst => 'Créez votre premier groupe !';

  @override
  String groupMemberCount(int count) {
    return '$count';
  }

  @override
  String get shareTitle => 'Partager';

  @override
  String get shareOtherApps => 'Autres applications';

  @override
  String get shareKakaoTalk => 'KakaoTalk';

  @override
  String get shareInstagram => 'Instagram';

  @override
  String get shareFacebook => 'Facebook';

  @override
  String get shareTwitter => 'X (Twitter)';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareTelegram => 'Telegram';

  @override
  String get galleryTitle => 'Galerie de cartes';

  @override
  String get galleryBirthday => 'Anniversaire';

  @override
  String get galleryChristmas => 'Noël';

  @override
  String get galleryNewYear => 'Nouvel An';

  @override
  String get galleryThanks => 'Merci';

  @override
  String get galleryMothersDay => 'Fête des parents';

  @override
  String get galleryTeachersDay => 'Fête des profs';

  @override
  String get galleryHalloween => 'Halloween';

  @override
  String get galleryThanksgiving => 'Action de grâce';

  @override
  String get galleryTravel => 'Voyage';

  @override
  String get galleryHobby => 'Loisirs';

  @override
  String get gallerySports => 'Sports';

  @override
  String get galleryQute => 'Mignon';

  @override
  String get galleryHeaven => 'Paradis';

  @override
  String get galleryMyPhotos => 'Mes photos';

  @override
  String get gallerySelectImage => 'Choisir image';

  @override
  String get galleryNoImages => 'Aucune image';

  @override
  String get selectCategory => 'Choisir catégorie';

  @override
  String get cardEditorTitle => 'Éditer la carte';

  @override
  String get cardEditorAddText => 'Texte';

  @override
  String get cardEditorAddSticker => 'Sticker';

  @override
  String get cardEditorAddImage => 'Image';

  @override
  String get cardEditorBackground => 'Fond';

  @override
  String get cardEditorFont => 'Police';

  @override
  String get cardEditorColor => 'Couleur';

  @override
  String get cardEditorSize => 'Taille';

  @override
  String get cardEditorPreview => 'Aperçu';

  @override
  String get cardEditorSend => 'Envoyer';

  @override
  String get cardEditorSave => 'Sauver';

  @override
  String get cardEditorShare => 'Partager';

  @override
  String get cardEditorEnterMessage => 'Votre message...';

  @override
  String get editorMessagePlaceholder => '보내실 내용을 입력하세요.';

  @override
  String get cardEditorGenerateAI => 'Message IA';

  @override
  String get cardEditorTextBox => 'Zone de texte';

  @override
  String get cardEditorZoomHint => 'Double-cliquez pour zoomer';

  @override
  String get cardEditorRecipient => 'Destinataire';

  @override
  String get cardEditorAddRecipient => 'Ajouter';

  @override
  String get recipientSelectTitle => 'Sélection destinataires';

  @override
  String get recipientSearchHint => 'Nom ou numéro...';

  @override
  String get recipientAddNew => 'Nouveau contact';

  @override
  String get recipientName => 'Nom';

  @override
  String get recipientPhone => 'Téléphone';

  @override
  String get recipientAdd => 'Ajouter';

  @override
  String get cardPreviewTitle => 'Confirmation';

  @override
  String get cardPreviewDesc => 'Voici l\'image finale qui sera envoyée.';

  @override
  String get cardPreviewZoomHint =>
      'Double-tap pour zoomer, glisser pour déplacer.';

  @override
  String get cardPreviewCheckHint =>
      'Veuillez vérifier l\'image avant l\'envoi.';

  @override
  String get cardPreviewConfirm => 'Confirmer (Suivant)';

  @override
  String get sendTitle => 'Gestion d\'envoi';

  @override
  String get sendRecipients => 'Destinataires';

  @override
  String get sendAddRecipient => 'Ajouter';

  @override
  String get sendStart => 'Démarrer';

  @override
  String get sendStop => 'Arrêter';

  @override
  String get sendContinue => 'Continuer';

  @override
  String get sendProgress => 'Envoi en cours';

  @override
  String get sendComplete => 'Envoi terminé';

  @override
  String get sendFailed => 'Échec';

  @override
  String get sendPending => 'En attente';

  @override
  String get sendTotalRecipients => 'Total destinataires';

  @override
  String get sendAutoResume => 'Reprise auto après 5';

  @override
  String get sendManagerTitle => 'Gestion destinataires';

  @override
  String get sendTotal => 'Total';

  @override
  String get sendPerson => '';

  @override
  String get sendSpamWarning =>
      'L\'envoi massif rapide peut être limité par les politiques anti-spam.\nIl est recommandé de désactiver la reprise automatique.';

  @override
  String totalPersonCount(int count) {
    return 'Total : $count';
  }

  @override
  String get cardHintZoomMode =>
      'Double-tapez sur le fond pour zoomer. Ajustez la taille et la position en mode zoom.';

  @override
  String get cardHintZoomEdit =>
      'Pincez pour redimensionner. Glissez pour déplacer. Double-tapez pour quitter.';

  @override
  String get cardHintDragging => 'Déplacement...';

  @override
  String get cardHintPinching => 'Redimensionnement...';

  @override
  String get savedCardsTitle => 'Cartes sauvegardées';

  @override
  String get savedCardsEmpty => 'Aucune carte sauvegardée.';

  @override
  String get cardSaveTitle => 'Sauvegarder';

  @override
  String get cardSaveName => 'Nom';

  @override
  String get cardSaveHint => 'Nom de la carte';

  @override
  String get cardNoTitle => 'Sans titre';

  @override
  String get cardImageFailed => 'Échec création image';

  @override
  String get messageHistory => 'Historique';

  @override
  String get messageNoHistory => 'Aucun historique';

  @override
  String get messageSent => 'Envoyé';

  @override
  String get messageViewed => 'Vu';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsName => 'Nom';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationTime => 'Heure notif.';

  @override
  String get settingsReceiveAlerts => 'Recevoir notif.';

  @override
  String get settingsSetTime => 'Régler l\'heure';

  @override
  String get settingsDesignSending => 'Design/Envoi';

  @override
  String get settingsCardBranding => 'Marque sur carte';

  @override
  String get settingsDataManage => 'Données';

  @override
  String get settingsBranding => 'Afficher marque';

  @override
  String get settingsSync => 'Sync';

  @override
  String get settingsSyncContacts => 'Sync Contacts';

  @override
  String get settingsSyncCalendar => 'Sync Calendrier';

  @override
  String get settingsBackup => 'Sauvegarde';

  @override
  String get settingsRestore => 'Restauration';

  @override
  String get settingsExport => 'Exporter';

  @override
  String get settingsImport => 'Importer';

  @override
  String get settingsCalendarSync => 'Calendrier';

  @override
  String get settingsOpenCalendar => 'Ouvrir calendrier';

  @override
  String get settingsCalendarGuide => 'Guide calendrier';

  @override
  String get settingsAppInfo => 'Infos App';

  @override
  String get settingsContactUs => 'Contact';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsExit => 'Quitter';

  @override
  String get settingsMyName => 'Mon nom';

  @override
  String get settingsNameOrNickname => 'Nom ou surnom';

  @override
  String get settingsNameHint => 'Nom affiché sur la carte';

  @override
  String get settingsNameUsageInfo =>
      'Ce nom est utilisé pour la signature en bas de la carte.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsTerms => 'Conditions';

  @override
  String get settingsHelp => 'Aide';

  @override
  String get settingsExternalCalendarGuide => 'Calendriers externes';

  @override
  String get settingsTest => 'Test';

  @override
  String get settingsGoogleCalendar => 'Google';

  @override
  String get settingsSamsungCalendar => 'Samsung';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsDarkModeDesc => 'Thème sombre';

  @override
  String get splashPreparing => 'Préparation...';

  @override
  String get splashLoadingData => 'Chargement données...';

  @override
  String get splashSyncingContacts => 'Sync contacts...';

  @override
  String get splashSyncingCalendar => 'Sync calendrier...';

  @override
  String get splashGeneratingSchedules => 'Génération plannings...';

  @override
  String get splashPreparingScreen => 'Préparation écran...';

  @override
  String get splashReady => 'Prêt !';

  @override
  String helloUser(String name) {
    return 'Bonjour, $name ! 👋';
  }

  @override
  String get errorNetwork => 'Erreur réseau';

  @override
  String get errorUnknown => 'Erreur inconnue';

  @override
  String get errorPermission => 'Permission requise';

  @override
  String get errorLoadFailed => 'Échec chargement';

  @override
  String get errorSaveFailed => 'Échec sauvegarde';

  @override
  String get errorSendFailed => 'Échec envoi';

  @override
  String get errorImageFailed => 'Échec image';

  @override
  String get confirmDelete => 'Supprimer ?';

  @override
  String get confirmExit => 'Quitter sans sauver ?';

  @override
  String get confirmSend => 'Envoyer ?';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateTomorrow => 'Demain';

  @override
  String get dateYesterday => 'Hier';

  @override
  String get dateThisWeek => 'Cette semaine';

  @override
  String get dateNextWeek => 'Semaine prochaine';

  @override
  String get dateThisMonth => 'Ce mois-ci';

  @override
  String daysRemaining(int days) {
    return 'Reste $days jours';
  }

  @override
  String daysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String sendResultSuccess(int count) {
    return 'Succès : $count';
  }

  @override
  String sendResultFailed(int count) {
    return 'Échec : $count';
  }

  @override
  String get eventBirthday => 'Anniversaire';

  @override
  String get eventAnniversary => 'Fête';

  @override
  String get eventHoliday => 'Férié';

  @override
  String get eventMeeting => 'Réunion';

  @override
  String get eventOther => 'Autre';

  @override
  String get scheduleEdit => 'Modifier';

  @override
  String get scheduleAdd => 'Ajouter';

  @override
  String get scheduleAddNew => 'Nouveau';

  @override
  String get scheduleTitle => 'Titre';

  @override
  String get scheduleRecipients => 'Pour';

  @override
  String get scheduleDate => 'Date';

  @override
  String get scheduleIconType => 'Icône';

  @override
  String get scheduleAddToCalendar => 'Ajouter au calendrier';

  @override
  String get scheduleAddedSuccess => 'Ajouté !';

  @override
  String get planEdit => 'Modifier';

  @override
  String get planDelete => 'Supprimer';

  @override
  String get planMoveToEnd => 'Déplacer fin';

  @override
  String get planReschedule => 'Reporter';

  @override
  String get planChangeIcon => 'Changer icône';

  @override
  String get planSelectIcon => 'Choisir icône';

  @override
  String planDeleteConfirm(String title) {
    return 'Supprimer \"$title\" ?';
  }

  @override
  String get iconNormal => 'Normal';

  @override
  String get iconHoliday => 'Vacances';

  @override
  String get iconBirthday => 'Anniv.';

  @override
  String get iconAnniversary => 'Fête';

  @override
  String get iconWork => 'Travail';

  @override
  String get iconPersonal => 'Perso';

  @override
  String get iconImportant => 'Important';

  @override
  String get cardWrite => 'Écrire';

  @override
  String get languageSelection => 'Choisir langue';

  @override
  String get previousLanguage => 'Langue préc.';

  @override
  String get nextLanguage => 'Langue suiv.';

  @override
  String get previewTitle => 'Aperçu';

  @override
  String get previewConfirm => 'Envoyer cette image ?';

  @override
  String get textBoxStyleTitle => 'Style texte';

  @override
  String get textBoxPreviewText => 'Aperçu style';

  @override
  String get textBoxShapeRounded => 'Arrondi';

  @override
  String get textBoxShapeSquare => 'Carré';

  @override
  String get textBoxShapeBevel => 'Biseauté';

  @override
  String get textBoxShapeCircle => 'Cercle';

  @override
  String get textBoxShapeBubble => 'Bulle';

  @override
  String get textBoxBackgroundColor => 'Couleur fond';

  @override
  String get textBoxOpacity => 'Opacité';

  @override
  String get textBoxBorderRadius => 'Rayon';

  @override
  String get textBoxBorder => 'Bordure';

  @override
  String get textBoxBorderWidth => 'Épaisseur';

  @override
  String get textBoxFooterStyle => 'Style pied de page';

  @override
  String get textBoxFooterHint =>
      'Changez la taille et la couleur de la police via la barre d\'outils en haut.';

  @override
  String get textBoxPreview => 'Aperçu style';

  @override
  String get textBoxSender => 'De';

  @override
  String get textBoxShapeLabel => 'Forme';

  @override
  String get shapeRounded => 'Arrondi';

  @override
  String get shapeRectangle => 'Rectangle';

  @override
  String get shapeBevel => 'Biseauté';

  @override
  String get shapeCircle => 'Cercle';

  @override
  String get shapeBubbleLeft => 'Bulle(G)';

  @override
  String get shapeBubbleCenter => 'Bulle(C)';

  @override
  String get shapeBubbleRight => 'Bulle(D)';

  @override
  String get shapeHeart => 'Cœur';

  @override
  String get shapeStar => 'Étoile';

  @override
  String get shapeDiamond => 'Losange';

  @override
  String get shapeHexagon => 'Hexagone';

  @override
  String get shapeCloud => 'Nuage';

  @override
  String get footerBgOpacity => 'Opacité fond';

  @override
  String get footerBgRadius => 'Rayon fond';

  @override
  String get contactPickerTitle => 'Destinataires';

  @override
  String get contactPickerSearchHint => 'Nom ou numéro...';

  @override
  String get contactPickerAllContacts => 'Tous';

  @override
  String get contactPickerFavorites => 'Favoris';

  @override
  String get contactPickerFamily => 'Famille';

  @override
  String get contactPickerAddNew => 'Ajouter';

  @override
  String get addContactTitle => 'Nouveau contact';

  @override
  String get addContactName => 'Nom';

  @override
  String get addContactPhone => 'Téléphone';

  @override
  String get addContactAdd => 'Ajouter';

  @override
  String get editorBackground => 'Fond';

  @override
  String get editorTextBox => 'Texte';

  @override
  String get photoPermissionTitle => 'Accès photos requis';

  @override
  String get photoPermissionDesc =>
      'L\'accès à la galerie est requis pour utiliser\nles photos de l\'appareil comme fond.';

  @override
  String get photoPermissionHowTo => '📱 Comment activer';

  @override
  String get photoPermissionStep1 => '1. Appuyez sur \"Ouvrir les paramètres\"';

  @override
  String get photoPermissionStep2 => '2. Appuyez sur \"Autorisations\"';

  @override
  String get photoPermissionStep3 => '3. Appuyez sur \"Photos et vidéos\"';

  @override
  String get photoPermissionStep4 => '4. Sélectionnez \"Autoriser\"';

  @override
  String get photoPermissionNote =>
      '⚡ Après autorisation, revenez ici\net les photos s\'afficheront.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get premiumImage => 'Image Premium';

  @override
  String get watchAdToUnlock => 'Regarder pub pour débloquer';

  @override
  String get unlockSuccess => 'Débloqué !';

  @override
  String get adNotReady =>
      'La publicité n\'est pas prête. Veuillez réessayer plus tard.';

  @override
  String get watchAd => 'Regarder la pub';

  @override
  String get premiumLocked => 'Verrouillé';
}
