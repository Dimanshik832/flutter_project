import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _enValues,
    'pl': _plValues,
    'ru': _ruValues,
  };

  String _getLocalizedValue(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _enValues[key] ?? key;
  }

  
  String get appName => _getLocalizedValue('app_name');
  String get ok => _getLocalizedValue('ok');
  String get cancel => _getLocalizedValue('cancel');
  String get save => _getLocalizedValue('save');
  String get edit => _getLocalizedValue('edit');
  String get delete => _getLocalizedValue('delete');
  String get back => _getLocalizedValue('back');
  String get search => _getLocalizedValue('search');
  String get details => _getLocalizedValue('details');
  String get copyEmail => _getLocalizedValue('copy_email');
  String get startDate => _getLocalizedValue('start_date');
  String get loading => _getLocalizedValue('loading');
  String get error => _getLocalizedValue('error');
  String get success => _getLocalizedValue('success');
  String get yes => _getLocalizedValue('yes');
  String get no => _getLocalizedValue('no');
  String get close => _getLocalizedValue('close');
  String get confirm => _getLocalizedValue('confirm');
  String get auth => _getLocalizedValue('auth');
  String get allScreens => _getLocalizedValue('all_screens');
  String get roleAdmin => _getLocalizedValue('role_admin');
  String get roleFirmOwner => _getLocalizedValue('role_firm_owner');
  String get roleFirmWorker => _getLocalizedValue('role_firm_worker');
  String get roleUser => _getLocalizedValue('role_user');
  String get roleBanned => _getLocalizedValue('role_banned');

  String errorWithDetails(String details) =>
      _getLocalizedValue('error_with_details').replaceAll('{details}', details);

  
  String get login => _getLocalizedValue('login');
  String get register => _getLocalizedValue('register');
  String get email => _getLocalizedValue('email');
  String get password => _getLocalizedValue('password');
  String get name => _getLocalizedValue('name');
  String get pleaseFillAllFields => _getLocalizedValue('please_fill_all_fields');
  String get quickLogin => _getLocalizedValue('quick_login');
  String get invalidEmail => _getLocalizedValue('invalid_email');
  String get weakPassword => _getLocalizedValue('weak_password');
  String get emailAlreadyInUse => _getLocalizedValue('email_already_in_use');
  String get userNotFound => _getLocalizedValue('user_not_found');
  String get wrongPassword => _getLocalizedValue('wrong_password');
  String get welcomeBack => _getLocalizedValue('welcome_back');
  String get createAccount => _getLocalizedValue('create_account');
  String get signInToContinue => _getLocalizedValue('sign_in_to_continue');
  String get registerToGetStarted => _getLocalizedValue('register_to_get_started');
  String get createAnAccount => _getLocalizedValue('create_an_account');
  String get alreadyHaveAccount => _getLocalizedValue('already_have_account');
  String get authenticationFailed => _getLocalizedValue('authentication_failed');
  String get loginFailed => _getLocalizedValue('login_failed');

  
  String helloUser(String userName) => _getLocalizedValue('hello_user').replaceAll('{userName}', userName);
  String get role => _getLocalizedValue('role');
  String get firmPanel => _getLocalizedValue('firm_panel');
  String get createFirm => _getLocalizedValue('create_firm');
  String get youHaveNoFirmYet => _getLocalizedValue('you_have_no_firm_yet');
  String get applicationBeingReviewed => _getLocalizedValue('application_being_reviewed');
  String get accountPendingApproval => _getLocalizedValue('account_pending_approval');
  String get previousApplicationRejected => _getLocalizedValue('previous_application_rejected');
  String get canSubmitNewOne => _getLocalizedValue('can_submit_new_one');
  String get fullName => _getLocalizedValue('full_name');
  String get nameAndSurname => _getLocalizedValue('name_and_surname');
  String get noName => _getLocalizedValue('no_name');
  String get album => _getLocalizedValue('album');
  String get submitApplication => _getLocalizedValue('submit_application');
  String get registerYourFirm => _getLocalizedValue('register_your_firm');
  String get firmNameRequired => _getLocalizedValue('firm_name_required');
  String get selectAtLeastOneCategory => _getLocalizedValue('select_at_least_one_category');
  String get userNotAuthenticated => _getLocalizedValue('user_not_authenticated');
  String get failedToRegisterFirm => _getLocalizedValue('failed_to_register_firm');

  
  String get settings => _getLocalizedValue('settings');
  String get appearance => _getLocalizedValue('appearance');
  String get language => _getLocalizedValue('language');
  String get support => _getLocalizedValue('support');
  String get systemTheme => _getLocalizedValue('system_theme');
  String get lightTheme => _getLocalizedValue('light_theme');
  String get darkTheme => _getLocalizedValue('dark_theme');
  String get english => _getLocalizedValue('english');
  String get polish => _getLocalizedValue('polish');
  String get russian => _getLocalizedValue('russian');
  String get notifications => _getLocalizedValue('notifications');
  String get reportBug => _getLocalizedValue('report_bug');
  String get contactAdmin => _getLocalizedValue('contact_admin');
  String get reportBugTitle => _getLocalizedValue('report_bug_title');
  String get reportBugMessage => _getLocalizedValue('report_bug_message');
  String get contactAdminTitle => _getLocalizedValue('contact_admin_title');
  String get contactAdminMessage => _getLocalizedValue('contact_admin_message');
  String get emailCopied => _getLocalizedValue('email_copied');
  String get account => _getLocalizedValue('account');
  String get pushNotifications => _getLocalizedValue('push_notifications');
  String get newsUpdates => _getLocalizedValue('news_updates');
  String get system => _getLocalizedValue('system');

  
  String get profile => _getLocalizedValue('profile');
  String get editProfile => _getLocalizedValue('edit_profile');
  String get changePassword => _getLocalizedValue('change_password');
  String get appSettings => _getLocalizedValue('app_settings');
  String get developerTools => _getLocalizedValue('developer_tools');
  String get devNavigation => _getLocalizedValue('dev_navigation');
  String get devDataUtils => _getLocalizedValue('dev_data_utils');
  String get devViewAllScreens => _getLocalizedValue('dev_view_all_screens');
  String get devBrowseAllScreens => _getLocalizedValue('dev_browse_all_screens');
  String get devDeleteAllReports => _getLocalizedValue('dev_delete_all_reports');
  String get devRemoveAllReportsSubtitle => _getLocalizedValue('dev_remove_all_reports_subtitle');
  String get devGenerateTestReports => _getLocalizedValue('dev_generate_test_reports');
  String get devCreate500TestReports => _getLocalizedValue('dev_create_500_test_reports');
  String get devAllScreens => _getLocalizedValue('dev_all_screens');
  String get devAllReportsDeleted => _getLocalizedValue('dev_all_reports_deleted');
  String devCreatedTestReports(int count) =>
      _getLocalizedValue('dev_created_test_reports').replaceAll('{count}', count.toString());
  String get devAllReportsSentToFirms => _getLocalizedValue('dev_all_reports_sent_to_firms');
  String get devTestPushEnqueued => _getLocalizedValue('dev_test_push_enqueued');
  String get devSendTestPush => _getLocalizedValue('dev_send_test_push');
  String get devQueueTestNotification => _getLocalizedValue('dev_queue_test_notification');
  String get logout => _getLocalizedValue('logout');
  String get logoutConfirm => _getLocalizedValue('logout_confirm');
  String get areYouSureLogout => _getLocalizedValue('are_you_sure_logout');
  String get passwordResetSent => _getLocalizedValue('password_reset_sent');

  
  String get myReports => _getLocalizedValue('my_reports');
  String get all => _getLocalizedValue('all');
  String get submitted => _getLocalizedValue('submitted');
  String get review => _getLocalizedValue('review');
  String get inProgress => _getLocalizedValue('in_progress');
  String get completed => _getLocalizedValue('completed');
  String get archived => _getLocalizedValue('archived');
  String get allTime => _getLocalizedValue('all_time');
  String get last7Days => _getLocalizedValue('last_7_days');
  String get last30Days => _getLocalizedValue('last_30_days');
  String get last90Days => _getLocalizedValue('last_90_days');
  String get searchByTitleRoomCategory => _getLocalizedValue('search_by_title_room_category');
  String get noReportsFound => _getLocalizedValue('no_reports_found');
  String get status => _getLocalizedValue('status');

  
  String get addReport => _getLocalizedValue('add_report');
  String get editReport => _getLocalizedValue('edit_report');
  String get title => _getLocalizedValue('title');
  String get description => _getLocalizedValue('description');
  String get roomNumber => _getLocalizedValue('room_number');
  String get category => _getLocalizedValue('category');
  String get photos => _getLocalizedValue('photos');
  String get uploadPhotos => _getLocalizedValue('upload_photos');
  String get takePhoto => _getLocalizedValue('take_photo');
  String get chooseFromGallery => _getLocalizedValue('choose_from_gallery');
  String get submitReport => _getLocalizedValue('submit_report');
  String get saveChanges => _getLocalizedValue('save_changes');
  String get somethingWentWrong => _getLocalizedValue('something_went_wrong');
  String get checkYourInput => _getLocalizedValue('check_your_input');
  String get reportCreatedSuccessfully => _getLocalizedValue('report_created_successfully');
  String get reportUpdatedSuccessfully => _getLocalizedValue('report_updated_successfully');
  String photosCount(int current, int max) => _getLocalizedValue('photos_count').replaceAll('{current}', current.toString()).replaceAll('{max}', max.toString());
  String addPhotosMax(int max) =>
      _getLocalizedValue('add_photos_max').replaceAll('{max}', max.toString());

  
  String get announcements => _getLocalizedValue('announcements');
  String get announcement => _getLocalizedValue('announcement');
  String get noAnnouncements => _getLocalizedValue('no_announcements');
  String get info => _getLocalizedValue('info');
  String get important => _getLocalizedValue('important');
  String get warning => _getLocalizedValue('warning');
  String get unknown => _getLocalizedValue('unknown');
  String get untitled => _getLocalizedValue('untitled');
  String get noDescription => _getLocalizedValue('no_description');
  String publishedAt(String date) =>
      _getLocalizedValue('published_at').replaceAll('{date}', date);
  String authorWithEmail(String email) =>
      _getLocalizedValue('author_with_email').replaceAll('{email}', email);

  
  String get registerFirm => _getLocalizedValue('register_firm');
  String get firmName => _getLocalizedValue('firm_name');
  String get editFirm => _getLocalizedValue('edit_firm');
  String get selectCategories => _getLocalizedValue('select_categories');
  String get categoriesLabel => _getLocalizedValue('categories_label');
  String get showMore => _getLocalizedValue('show_more');
  String get showLess => _getLocalizedValue('show_less');
  String get noCategoriesAvailable => _getLocalizedValue('no_categories_available');
  String get proposedPrice => _getLocalizedValue('proposed_price');
  String get numberOfWorkers => _getLocalizedValue('number_of_workers');
  String get selectDeadline => _getLocalizedValue('select_deadline');
  String get submitting => _getLocalizedValue('submitting');
  String get comment => _getLocalizedValue('comment');
  String get commentOptional => _getLocalizedValue('comment_optional');
  String get previewApplication => _getLocalizedValue('preview_application');
  String get confirmDetailsBelow => _getLocalizedValue('confirm_details_below');
  String get applicationDetails => _getLocalizedValue('application_details');
  String get price => _getLocalizedValue('price');
  String get deadline => _getLocalizedValue('deadline');
  String get workers => _getLocalizedValue('workers');
  String get noComment => _getLocalizedValue('no_comment');
  String get availableReports => _getLocalizedValue('available_reports');
  String get searchReports => _getLocalizedValue('search_reports');
  String get sortNewest => _getLocalizedValue('sort_newest');
  String get sortOldest => _getLocalizedValue('sort_oldest');
  String get sortAz => _getLocalizedValue('sort_az');
  String get apply => _getLocalizedValue('apply');
  String get noAvailableReports => _getLocalizedValue('no_available_reports');
  String get firmStatistics => _getLocalizedValue('firm_statistics');
  String get assigned => _getLocalizedValue('assigned');
  String get active => _getLocalizedValue('active');
  String get firmMembers => _getLocalizedValue('firm_members');
  String get addMember => _getLocalizedValue('add_member');
  String get noMembers => _getLocalizedValue('no_members');
  String get addEmployee => _getLocalizedValue('add_employee');
  String get employeeEmail => _getLocalizedValue('employee_email');
  String get addEmployeeAction => _getLocalizedValue('add_employee_action');
  String get noUserWithThisEmailFound => _getLocalizedValue('no_user_with_this_email_found');
  String get firmMemberRoleNotAllowed => _getLocalizedValue('firm_member_role_not_allowed');
  String get userAlreadyInFirm => _getLocalizedValue('user_already_in_firm');
  String get employeeAdded => _getLocalizedValue('employee_added');
  String get employeeRemoved => _getLocalizedValue('employee_removed');
  String get errorAddingEmployee => _getLocalizedValue('error_adding_employee');
  String get removeEmployee => _getLocalizedValue('remove_employee');
  String removeEmployeeConfirm(String email) =>
      _getLocalizedValue('remove_employee_confirm').replaceAll('{email}', email);
  String get firmNotFound => _getLocalizedValue('firm_not_found');
  String get firmHistory => _getLocalizedValue('firm_history');
  String get cancelled => _getLocalizedValue('cancelled');
  String get noHistoryRecords => _getLocalizedValue('no_history_records');
  String get cancelWork => _getLocalizedValue('cancel_work');
  String get cancelWorkConfirm => _getLocalizedValue('cancel_work_confirm');
  String get markAsCompleted => _getLocalizedValue('mark_as_completed');
  String get markAsCompletedConfirm => _getLocalizedValue('mark_as_completed_confirm');
  String get workCancelled => _getLocalizedValue('work_cancelled');
  String get markedAsCompleted => _getLocalizedValue('marked_as_completed');
  String get assignWorkers => _getLocalizedValue('assign_workers');
  String get noWorkersFound => _getLocalizedValue('no_workers_found');
  String get workerAlreadyAssigned => _getLocalizedValue('worker_already_assigned');
  String get workerWillBeRemoved => _getLocalizedValue('worker_will_be_removed');
  String get assignmentsUpdated => _getLocalizedValue('assignments_updated');
  String get selectWorkers => _getLocalizedValue('select_workers');
  String get assignedReports => _getLocalizedValue('assigned_reports');
  String get noAssignedReports => _getLocalizedValue('no_assigned_reports');
  String get contactDetails => _getLocalizedValue('contact_details');
  String get noContactDetails => _getLocalizedValue('no_contact_details');
  String get phone => _getLocalizedValue('phone');
  String selectedCount(int count) => _getLocalizedValue('selected_count').replaceAll('{count}', count.toString());

  
  String get adminDashboard => _getLocalizedValue('admin_dashboard');
  String get adminReports => _getLocalizedValue('admin_reports');
  String get whitelistApplications => _getLocalizedValue('whitelist_applications');
  String get noPendingApplications => _getLocalizedValue('no_pending_applications');
  String get approve => _getLocalizedValue('approve');
  String get reject => _getLocalizedValue('reject');
  String get approveThisUserQuestion => _getLocalizedValue('approve_this_user_question');
  String get rejectThisUserQuestion => _getLocalizedValue('reject_this_user_question');
  String get userApproved => _getLocalizedValue('user_approved');
  String get userRejected => _getLocalizedValue('user_rejected');
  String get errorApprovingUser => _getLocalizedValue('error_approving_user');
  String get errorRejectingUser => _getLocalizedValue('error_rejecting_user');
  String requestedAt(String date) =>
      _getLocalizedValue('requested_at').replaceAll('{date}', date);
  String get manageCategories => _getLocalizedValue('manage_categories');
  String get newCategory => _getLocalizedValue('new_category');
  String get addCategory => _getLocalizedValue('add_category');
  String get categoryNameLabel => _getLocalizedValue('category_name_label');
  String get categoryNameCannotBeEmpty => _getLocalizedValue('category_name_cannot_be_empty');
  String categoryAlreadyExists(String name) =>
      _getLocalizedValue('category_already_exists').replaceAll('{name}', name);
  String get categoryAdded => _getLocalizedValue('category_added');
  String get deleteCategoryTitle => _getLocalizedValue('delete_category_title');
  String deleteCategoryConfirm(String name) =>
      _getLocalizedValue('delete_category_confirm').replaceAll('{name}', name);
  String categoryDeleted(String name) =>
      _getLocalizedValue('category_deleted').replaceAll('{name}', name);
  String get selectIcon => _getLocalizedValue('select_icon');
  String get editCategoryTitle => _getLocalizedValue('edit_category_title');
  String get changeIcon => _getLocalizedValue('change_icon');
  String get categoryUpdated => _getLocalizedValue('category_updated');
  String get manageParticipants => _getLocalizedValue('manage_participants');
  String get admins => _getLocalizedValue('admins');
  String get firmOwners => _getLocalizedValue('firm_owners');
  String get firmWorkers => _getLocalizedValue('firm_workers');
  String get users => _getLocalizedValue('users');
  String get banned => _getLocalizedValue('banned');
  String get cannotChangeOwnRole => _getLocalizedValue('cannot_change_own_role');
  String roleUpdatedTo(String role) =>
      _getLocalizedValue('role_updated_to').replaceAll('{role}', role);
  String get cannotBanYourself => _getLocalizedValue('cannot_ban_yourself');
  String get confirmBanTitle => _getLocalizedValue('confirm_ban_title');
  String get confirmUnbanTitle => _getLocalizedValue('confirm_unban_title');
  String banThisUserPrompt(String email) =>
      _getLocalizedValue('ban_this_user_prompt').replaceAll('{email}', email);
  String unbanThisUserPrompt(String email) =>
      _getLocalizedValue('unban_this_user_prompt').replaceAll('{email}', email);
  String get ban => _getLocalizedValue('ban');
  String get unban => _getLocalizedValue('unban');
  String get banUser => _getLocalizedValue('ban_user');
  String get unbanUser => _getLocalizedValue('unban_user');
  String get addAnnouncement => _getLocalizedValue('add_announcement');
  String get publish => _getLocalizedValue('publish');
  String get announcementFormInvalid => _getLocalizedValue('announcement_form_invalid');
  String get announcementPublished => _getLocalizedValue('announcement_published');
  String get titleIsRequired => _getLocalizedValue('title_is_required');
  String get descriptionIsRequired => _getLocalizedValue('description_is_required');
  String get viewAllAnnouncements => _getLocalizedValue('view_all_announcements');
  String get sendToFirms => _getLocalizedValue('send_to_firms');
  String get selectFirm => _getLocalizedValue('select_firm');
  String get statusUpdated => _getLocalizedValue('status_updated');
  String get reportArchived => _getLocalizedValue('report_archived');
  String get firmSelected => _getLocalizedValue('firm_selected');
  String get firm => _getLocalizedValue('firm');
  String get report => _getLocalizedValue('report');
  String get room => _getLocalizedValue('room');
  String get adminActions => _getLocalizedValue('admin_actions');
  String get changeStatus => _getLocalizedValue('change_status');
  String get archiveReport => _getLocalizedValue('archive_report');
  String get firmApplications => _getLocalizedValue('firm_applications');
  String get noApplicationsYet => _getLocalizedValue('no_applications_yet');
  String get unknownFirm => _getLocalizedValue('unknown_firm');
  String get selected => _getLocalizedValue('selected');
  String get categoriesBreakdown => _getLocalizedValue('categories_breakdown');
  String get noReportsInSelectedPeriod => _getLocalizedValue('no_reports_in_selected_period');
  String get noTasksYet => _getLocalizedValue('no_tasks_yet');

  
  String get home => _getLocalizedValue('home');
  String get reports => _getLocalizedValue('reports');
  String get profileNav => _getLocalizedValue('profile_nav');

  
  String get verifyYourEmail => _getLocalizedValue('verify_your_email');
  String get weSentVerificationEmail => _getLocalizedValue('we_sent_verification_email');
  String get resendEmail => _getLocalizedValue('resend_email');
  String get backToLogin => _getLocalizedValue('back_to_login');
  
  
  String get noUserFound => _getLocalizedValue('no_user_found');
  String get seeAll => _getLocalizedValue('see_all');
  String get workerPanel => _getLocalizedValue('worker_panel');
  String get adminTools => _getLocalizedValue('admin_tools');
  String get pleaseFillFullNameAndAlbum => _getLocalizedValue('please_fill_full_name_and_album');
  String get requestSubmitted => _getLocalizedValue('request_submitted');
  String get errorSubmittingRequest => _getLocalizedValue('error_submitting_request');
  String get myFirmPanel => _getLocalizedValue('my_firm_panel');
  String get assignedReportsHome => _getLocalizedValue('assigned_reports_home');
  String get availableReportsHome => _getLocalizedValue('available_reports_home');
  String get firmParticipants => _getLocalizedValue('firm_participants');
  String get reportsHistory => _getLocalizedValue('reports_history');
  String get taskCalendar => _getLocalizedValue('task_calendar');
  String get requestSent => _getLocalizedValue('request_sent');
  String get sending => _getLocalizedValue('sending');
  String get submitRequest => _getLocalizedValue('submit_request');
  String get studentAlbumNumber => _getLocalizedValue('student_album_number');
  String get tapToChangePhoto => _getLocalizedValue('tap_to_change_photo');
  String get yourName => _getLocalizedValue('your_name');
  String get nameCannotExceed20Characters => _getLocalizedValue('name_cannot_exceed_20_characters');
  String get saving => _getLocalizedValue('saving');
  String get verificationEmailSent => _getLocalizedValue('verification_email_sent');
  String get resendVerificationEmail => _getLocalizedValue('resend_verification_email');
  String get iVerifiedContinue => _getLocalizedValue('i_verified_continue');
  String get verificationEmailDescription => _getLocalizedValue('verification_email_description');
  String get testNotificationTitle => _getLocalizedValue('test_notification_title');
  String get testNotificationBody => _getLocalizedValue('test_notification_body');
  String testReportTitle(int index) =>
      _getLocalizedValue('test_report_title').replaceAll('{index}', index.toString());
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pl', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}


const Map<String, String> _enValues = {
  'app_name': 'Akademik App',
  'ok': 'OK',
  'cancel': 'Cancel',
  'save': 'Save',
  'edit': 'Edit',
  'delete': 'Delete',
  'back': 'Back',
  'search': 'Search',
  'details': 'Details',
  'copy_email': 'Copy email',
  'start_date': 'Start',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'yes': 'Yes',
  'no': 'No',
  'close': 'Close',
  'confirm': 'Confirm',
  'auth': 'Auth',
  'all_screens': 'All Screens',
  'role_admin': 'Admin',
  'role_firm_owner': 'Firm owner',
  'role_firm_worker': 'Firm worker',
  'role_user': 'User',
  'role_banned': 'Banned',
  'error_with_details': 'Error:\n{details}',
  'login': 'Login',
  'register': 'Register',
  'email': 'Email',
  'password': 'Password',
  'name': 'Name',
  'please_fill_all_fields': 'Please fill all fields',
  'quick_login': 'Quick Login (dev tools)',
  'invalid_email': 'Invalid email address',
  'weak_password': 'Password is too weak',
  'email_already_in_use': 'Email is already in use',
  'user_not_found': 'User not found',
  'wrong_password': 'Wrong password',
  'welcome_back': 'Welcome Back',
  'create_account': 'Create Account',
  'sign_in_to_continue': 'Sign in to continue',
  'register_to_get_started': 'Register to get started',
  'create_an_account': 'Create an account',
  'already_have_account': 'Already have an account?',
  'authentication_failed': 'Authentication failed',
  'login_failed': 'Login failed for',
  'hello_user': 'Hello, {userName}!',
  'role': 'Role:',
  'firm_panel': 'Firm Panel',
  'create_firm': 'Create Firm',
  'you_have_no_firm_yet': 'You have no registered firm yet.',
  'application_being_reviewed': 'Your application is being reviewed.',
  'account_pending_approval': 'Your account is pending approval.',
  'previous_application_rejected': 'Your previous application was rejected. You can submit a new one.',
  'can_submit_new_one': 'You can submit a new one.',
  'full_name': 'Full name',
  'name_and_surname': 'Name and surname',
  'no_name': 'No Name',
  'album': 'Album',
  'submit_application': 'Submit Application',
  'register_your_firm': 'Register your firm to receive reports.',
  'firm_name_required': 'Enter firm name',
  'select_at_least_one_category': 'Select at least one category',
  'user_not_authenticated': 'User not authenticated',
  'failed_to_register_firm': 'Failed to register firm',
  'settings': 'Settings',
  'appearance': 'Appearance',
  'language': 'Language',
  'support': 'Support',
  'system': 'System',
  'system_theme': 'System Theme',
  'light_theme': 'Light Theme',
  'dark_theme': 'Dark Theme',
  'english': 'English',
  'polish': 'Polski',
  'russian': 'Русский',
  'notifications': 'Notifications',
  'push_notifications': 'Push notifications',
  'news_updates': 'News & updates',
  'report_bug': 'Report Bug',
  'contact_admin': 'Contact Admin',
  'report_bug_title': 'Report a Bug',
  'report_bug_message': 'Found a bug? Send us an email with details:',
  'contact_admin_title': 'Contact Administrator',
  'contact_admin_message': 'Need help? Contact the administrator:',
  'email_copied': 'Email copied to clipboard',
  'profile': 'Profile',
  'edit_profile': 'Edit Profile',
  'change_password': 'Change password',
  'app_settings': 'App Settings',
  'developer_tools': 'Developer Tools',
  'dev_navigation': 'Navigation',
  'dev_data_utils': 'Data Utils',
  'dev_view_all_screens': 'View All Screens',
  'dev_browse_all_screens': 'Browse all application screens',
  'dev_delete_all_reports': 'Delete All Reports',
  'dev_remove_all_reports_subtitle': 'Remove all reports from database',
  'dev_generate_test_reports': 'Generate Test Reports',
  'dev_create_500_test_reports': 'Create 500 test reports',
  'dev_all_screens': 'All Screens',
  'dev_all_reports_deleted': 'All reports deleted',
  'dev_created_test_reports': 'Created {count} test reports',
  'dev_all_reports_sent_to_firms': 'All reports sent to firms',
  'dev_test_push_enqueued': 'Test push enqueued',
  'dev_send_test_push': 'Send Test Push',
  'dev_queue_test_notification': 'Queue a test notification',
  'logout': 'Logout',
  'logout_confirm': 'Logout',
  'are_you_sure_logout': 'Are you sure you want to sign out?',
  'password_reset_sent': 'Password reset link sent to your email.',
  'my_reports': 'My Reports',
  'all': 'All',
  'submitted': 'Submitted',
  'review': 'Review',
  'in_progress': 'In Progress',
  'completed': 'Completed',
  'archived': 'Archived',
  'all_time': 'All',
  'last_7_days': '7 days',
  'last_30_days': '30 days',
  'last_90_days': '90 days',
  'search_by_title_room_category': 'Search by title, room, category',
  'no_reports_found': 'No reports found',
  'status': 'Status:',
  'add_report': 'Add Report',
  'edit_report': 'Edit Report',
  'title': 'Title',
  'description': 'Description',
  'room_number': 'Room Number',
  'category': 'Category',
  'photos': 'Photos',
  'upload_photos': 'Upload photos',
  'take_photo': 'Take photo',
  'choose_from_gallery': 'Choose from gallery',
  'submit_report': 'Submit Report',
  'save_changes': 'Save changes',
  'something_went_wrong': 'Something went wrong. Please check your input.',
  'check_your_input': 'Please check your input.',
  'report_created_successfully': 'Report created successfully!',
  'report_updated_successfully': 'Report updated successfully.',
  'photos_count': 'Photos: {current} / {max}',
  'add_photos_max': 'Add photos (max {max})',
  'announcements': 'Announcements',
  'announcement': 'Announcement',
  'no_announcements': 'No announcements',
  'info': 'Info',
  'important': 'Important',
  'warning': 'Warning',
  'unknown': 'Unknown',
  'untitled': 'Untitled',
  'no_description': 'No description',
  'published_at': 'Published: {date}',
  'author_with_email': 'Author: {email}',
  'register_firm': 'Register Firm',
  'firm_name': 'Firm Name',
  'edit_firm': 'Edit firm',
  'select_categories': 'Select Categories:',
  'categories_label': 'Categories',
  'show_more': 'Show more',
  'show_less': 'Show less',
  'no_categories_available': 'No categories available',
  'proposed_price': 'Proposed Price (USD)',
  'number_of_workers': 'Number of Workers',
  'select_deadline': 'Select Deadline',
  'submitting': 'Submitting...',
  'comment': 'Comment',
  'comment_optional': 'Comment (optional)',
  'preview_application': 'Preview Application',
  'confirm_details_below': 'Please confirm the details below',
  'application_details': 'Application Details',
  'price': 'Price',
  'deadline': 'Deadline',
  'workers': 'Workers',
  'no_comment': 'No comment',
  'available_reports': 'Available Reports',
  'search_reports': 'Search reports...',
  'sort_newest': 'Newest',
  'sort_oldest': 'Oldest',
  'sort_az': 'A → Z',
  'apply': 'Apply',
  'no_available_reports': 'No available reports',
  'firm_statistics': 'Firm Statistics',
  'categories_breakdown': 'Categories breakdown',
  'no_reports_in_selected_period': 'No reports in selected period.',
  'no_tasks_yet': 'No tasks yet.',
  'assigned': 'Assigned',
  'active': 'Active',
  'firm_members': 'Firm Members',
  'add_member': 'Add Member',
  'no_members': 'No members',
  'add_employee': 'Add Employee',
  'employee_email': 'Employee email',
  'add_employee_action': 'Add',
  'no_user_with_this_email_found': 'No user with this email found',
  'firm_member_role_not_allowed': 'Only users with role "user" or "usernau" can be added',
  'user_already_in_firm': 'This user already belongs to a firm',
  'employee_added': 'Employee successfully added',
  'employee_removed': 'Employee removed',
  'error_adding_employee': 'Error adding employee',
  'remove_employee': 'Remove Employee',
  'remove_employee_confirm': 'Remove {email} from your firm?',
  'firm_not_found': 'Firm not found',
  'firm_history': 'Firm History',
  'cancelled': 'Cancelled',
  'no_history_records': 'No history records.',
  'cancel_work': 'Cancel work',
  'cancel_work_confirm': 'Are you sure you want to cancel this job?',
  'mark_as_completed': 'Mark as completed',
  'mark_as_completed_confirm': 'Confirm this job is done?',
  'work_cancelled': 'Work cancelled.',
  'marked_as_completed': 'Marked as completed.',
  'assign_workers': 'Assign Workers',
  'no_workers_found': 'No workers found.',
  'worker_already_assigned': 'Already assigned',
  'worker_will_be_removed': 'Will be removed',
  'assignments_updated': 'Assignments updated.',
  'select_workers': 'Select workers',
  'assigned_reports': 'Assigned Reports',
  'no_assigned_reports': 'You have no assigned reports.',
  'contact_details': 'Contact details',
  'no_contact_details': 'No contact details',
  'phone': 'Phone',
  'selected_count': '{count} selected',
  'admin_dashboard': 'Admin Dashboard',
  'admin_reports': 'Admin Reports',
  'whitelist_applications': 'Whitelist Applications',
  'no_pending_applications': 'No pending applications',
  'approve': 'Approve',
  'reject': 'Reject',
  'approve_this_user_question': 'Approve this user?',
  'reject_this_user_question': 'Reject this user?',
  'user_approved': 'User approved',
  'user_rejected': 'User rejected',
  'error_approving_user': 'Error approving user',
  'error_rejecting_user': 'Error rejecting user',
  'requested_at': 'Requested: {date}',
  'manage_categories': 'Manage Categories',
  'new_category': 'New category',
  'add_category': 'Add Category',
  'category_name_label': 'Category name',
  'category_name_cannot_be_empty': 'Category name cannot be empty',
  'category_already_exists': 'Category "{name}" already exists',
  'category_added': 'Category added',
  'delete_category_title': 'Delete Category',
  'delete_category_confirm': 'Are you sure you want to delete "{name}"?',
  'category_deleted': 'Category "{name}" deleted',
  'select_icon': 'Select Icon',
  'edit_category_title': 'Edit Category',
  'change_icon': 'Change Icon',
  'category_updated': 'Category updated',
  'manage_participants': 'Manage Participants',
  'admins': 'Admins',
  'firm_owners': 'Firm Owners',
  'firm_workers': 'Firm Workers',
  'users': 'Users',
  'banned': 'Banned',
  'cannot_change_own_role': 'You cannot change your own role',
  'role_updated_to': 'Role updated to {role}',
  'cannot_ban_yourself': 'You cannot ban yourself',
  'confirm_ban_title': 'Confirm Ban',
  'confirm_unban_title': 'Confirm Unban',
  'ban_this_user_prompt': 'Ban this user?\n{email}',
  'unban_this_user_prompt': 'Unban this user?\n{email}',
  'ban': 'Ban',
  'unban': 'Unban',
  'ban_user': 'Ban User',
  'unban_user': 'Unban User',
  'add_announcement': 'Add Announcement',
  'publish': 'Publish',
  'announcement_form_invalid': 'Please fill all fields correctly',
  'announcement_published': 'Announcement published!',
  'title_is_required': 'Title is required',
  'description_is_required': 'Description is required',
  'view_all_announcements': 'View all announcements',
  'send_to_firms': 'Send to Firms',
  'select_firm': 'Select Firm',
  'status_updated': 'Status updated successfully',
  'report_archived': 'Report archived successfully',
  'firm_selected': 'Firm selected successfully',
  'firm': 'Firm',
  'report': 'Report',
  'room': 'Room',
  'admin_actions': 'Admin Actions',
  'change_status': 'Change Status',
  'archive_report': 'Archive Report',
  'firm_applications': 'Firm Applications',
  'no_applications_yet': 'No applications yet',
  'unknown_firm': 'Unknown Firm',
  'selected': 'Selected',
  'home': 'Home',
  'reports': 'Reports',
  'profile_nav': 'Profile',
  'verify_your_email': 'Verify your email',
  'we_sent_verification_email': 'We sent a verification email to',
  'resend_email': 'Resend email',
  'back_to_login': 'Back to login',
  'no_user_found': 'No user found',
  'see_all': 'See all',
  'worker_panel': 'Worker Panel',
  'admin_tools': 'Admin Tools',
  'please_fill_full_name_and_album': 'Please fill in your full name and album number.',
  'request_submitted': 'Request submitted',
  'error_submitting_request': 'Error while submitting request',
  'my_firm_panel': 'My Firm Panel',
  'assigned_reports_home': 'Assigned Reports',
  'available_reports_home': 'Available Reports',
  'firm_participants': 'Firm Participants',
  'reports_history': 'Reports History',
  'task_calendar': 'Task Calendar',
  'request_sent': 'Request sent',
  'sending': 'Sending...',
  'submit_request': 'Submit request',
  'student_album_number': 'Student album number',
  'tap_to_change_photo': 'Tap to change photo',
  'your_name': 'Your name',
  'name_cannot_exceed_20_characters': 'Name cannot exceed 20 characters',
  'saving': 'Saving...',
  'verification_email_sent': 'Verification email sent!',
  'resend_verification_email': 'Resend Verification Email',
  'i_verified_continue': 'I verified → Continue',
  'verification_email_description': 'We sent a verification link to your inbox.\nClick the link to activate your account.\n\nThis screen checks automatically.',
  'test_notification_title': 'Test notification',
  'test_notification_body': 'Hello from DebugTools',
  'test_report_title': 'Test Report #{index}',
};


const Map<String, String> _plValues = {
  'app_name': 'Akademik App',
  'ok': 'OK',
  'cancel': 'Anuluj',
  'save': 'Zapisz',
  'edit': 'Edytuj',
  'delete': 'Usuń',
  'back': 'Wstecz',
  'search': 'Szukaj',
  'details': 'Szczegóły',
  'copy_email': 'Kopiuj email',
  'start_date': 'Start',
  'loading': 'Ładowanie...',
  'error': 'Błąd',
  'success': 'Sukces',
  'yes': 'Tak',
  'no': 'Nie',
  'close': 'Zamknij',
  'confirm': 'Potwierdź',
  'auth': 'Auth',
  'all_screens': 'Wszystkie ekrany',
  'role_admin': 'Administrator',
  'role_firm_owner': 'Właściciel firmy',
  'role_firm_worker': 'Pracownik firmy',
  'role_user': 'Użytkownik',
  'role_banned': 'Zbanowany',
  'error_with_details': 'Błąd:\n{details}',
  'login': 'Zaloguj',
  'register': 'Zarejestruj',
  'email': 'Email',
  'password': 'Hasło',
  'name': 'Imię',
  'please_fill_all_fields': 'Proszę wypełnić wszystkie pola',
  'quick_login': 'Szybkie logowanie (narzędzia deweloperskie)',
  'invalid_email': 'Nieprawidłowy adres email',
  'weak_password': 'Hasło jest zbyt słabe',
  'email_already_in_use': 'Email jest już w użyciu',
  'user_not_found': 'Użytkownik nie znaleziony',
  'wrong_password': 'Nieprawidłowe hasło',
  'welcome_back': 'Witaj Z powrotem',
  'create_account': 'Utwórz Konto',
  'sign_in_to_continue': 'Zaloguj się, aby kontynuować',
  'register_to_get_started': 'Zarejestruj się, aby zacząć',
  'create_an_account': 'Utwórz konto',
  'already_have_account': 'Masz już konto?',
  'authentication_failed': 'Uwierzytelnianie nie powiodło się',
  'login_failed': 'Logowanie nie powiodło się dla',
  'hello_user': 'Witaj, {userName}!',
  'role': 'Rola:',
  'firm_panel': 'Panel Firmy',
  'create_firm': 'Utwórz Firmę',
  'you_have_no_firm_yet': 'Nie masz jeszcze zarejestrowanej firmy.',
  'application_being_reviewed': 'Twoja aplikacja jest w trakcie przeglądu.',
  'account_pending_approval': 'Twoje konto oczekuje na zatwierdzenie.',
  'previous_application_rejected': 'Twoja poprzednia aplikacja została odrzucona. Możesz złożyć nową.',
  'can_submit_new_one': 'Możesz złożyć nową.',
  'full_name': 'Pełne imię',
  'name_and_surname': 'Imię i nazwisko',
  'no_name': 'Brak nazwy',
  'album': 'Album',
  'submit_application': 'Złóż Aplikację',
  'register_your_firm': 'Zarejestruj swoją firmę, aby otrzymywać raporty.',
  'firm_name_required': 'Wpisz nazwę firmy',
  'select_at_least_one_category': 'Wybierz co najmniej jedną kategorię',
  'user_not_authenticated': 'Użytkownik nie jest uwierzytelniony',
  'failed_to_register_firm': 'Nie udało się zarejestrować firmy',
  'settings': 'Ustawienia',
  'appearance': 'Wygląd',
  'language': 'Język',
  'support': 'Wsparcie',
  'system': 'System',
  'system_theme': 'Motyw Systemowy',
  'light_theme': 'Jasny Motyw',
  'dark_theme': 'Ciemny Motyw',
  'english': 'Angielski',
  'polish': 'Polski',
  'russian': 'Rosyjski',
  'notifications': 'Powiadomienia',
  'push_notifications': 'Powiadomienia push',
  'news_updates': 'Aktualności i aktualizacje',
  'report_bug': 'Zgłoś Błąd',
  'contact_admin': 'Skontaktuj się z Administratorem',
  'report_bug_title': 'Zgłoś Błąd',
  'report_bug_message': 'Znalazłeś błąd? Wyślij nam email ze szczegółami:',
  'contact_admin_title': 'Skontaktuj się z Administratorem',
  'contact_admin_message': 'Potrzebujesz pomocy? Skontaktuj się z administratorem:',
  'email_copied': 'Email skopiowany do schowka',
  'profile': 'Profil',
  'edit_profile': 'Edytuj Profil',
  'change_password': 'Zmień hasło',
  'app_settings': 'Ustawienia Aplikacji',
  'developer_tools': 'Narzędzia Deweloperskie',
  'dev_navigation': 'Nawigacja',
  'dev_data_utils': 'Narzędzia danych',
  'dev_view_all_screens': 'Zobacz wszystkie ekrany',
  'dev_browse_all_screens': 'Przeglądaj wszystkie ekrany aplikacji',
  'dev_delete_all_reports': 'Usuń wszystkie raporty',
  'dev_remove_all_reports_subtitle': 'Usuń wszystkie raporty z bazy danych',
  'dev_generate_test_reports': 'Generuj raporty testowe',
  'dev_create_500_test_reports': 'Utwórz 500 raportów testowych',
  'dev_all_screens': 'Wszystkie ekrany',
  'dev_all_reports_deleted': 'Wszystkie raporty usunięte',
  'dev_created_test_reports': 'Utworzono {count} raportów testowych',
  'dev_all_reports_sent_to_firms': 'Wszystkie raporty wysłane do firm',
  'dev_test_push_enqueued': 'Testowe powiadomienie dodane do kolejki',
  'dev_send_test_push': 'Wyślij test push',
  'dev_queue_test_notification': 'Dodaj testowe powiadomienie do kolejki',
  'logout': 'Wyloguj',
  'logout_confirm': 'Wyloguj',
  'are_you_sure_logout': 'Czy na pewno chcesz się wylogować?',
  'password_reset_sent': 'Link do resetowania hasła został wysłany na Twój email.',
  'my_reports': 'Moje Raporty',
  'all': 'Wszystkie',
  'submitted': 'Złożone',
  'review': 'W Przeglądzie',
  'in_progress': 'W Trakcie',
  'completed': 'Ukończone',
  'archived': 'Zarchiwizowane',
  'all_time': 'Wszystkie',
  'last_7_days': '7 dni',
  'last_30_days': '30 dni',
  'last_90_days': '90 dni',
  'search_by_title_room_category': 'Szukaj po tytule, pokoju, kategorii',
  'no_reports_found': 'Nie znaleziono raportów',
  'status': 'Status:',
  'add_report': 'Dodaj Raport',
  'edit_report': 'Edytuj Raport',
  'title': 'Tytuł',
  'description': 'Opis',
  'room_number': 'Numer Pokoju',
  'category': 'Kategoria',
  'photos': 'Zdjęcia',
  'upload_photos': 'Prześlij zdjęcia',
  'take_photo': 'Zrób zdjęcie',
  'choose_from_gallery': 'Wybierz z galerii',
  'submit_report': 'Wyślij Raport',
  'save_changes': 'Zapisz zmiany',
  'something_went_wrong': 'Coś poszło nie tak. Proszę sprawdzić swoje dane wejściowe.',
  'check_your_input': 'Proszę sprawdzić swoje dane wejściowe.',
  'report_created_successfully': 'Raport został utworzony pomyślnie!',
  'report_updated_successfully': 'Raport został zaktualizowany pomyślnie.',
  'photos_count': 'Zdjęcia: {current} / {max}',
  'add_photos_max': 'Dodaj zdjęcia (max {max})',
  'announcements': 'Ogłoszenia',
  'announcement': 'Ogłoszenie',
  'no_announcements': 'Brak ogłoszeń',
  'info': 'Informacja',
  'important': 'Ważne',
  'warning': 'Ostrzeżenie',
  'unknown': 'Nieznane',
  'untitled': 'Bez tytułu',
  'no_description': 'Brak opisu',
  'published_at': 'Opublikowano: {date}',
  'author_with_email': 'Autor: {email}',
  'register_firm': 'Zarejestruj Firmę',
  'firm_name': 'Nazwa Firmy',
  'edit_firm': 'Edytuj firmę',
  'select_categories': 'Wybierz Kategorie:',
  'categories_label': 'Kategorie',
  'show_more': 'Pokaż więcej',
  'show_less': 'Pokaż mniej',
  'no_categories_available': 'Brak dostępnych kategorii',
  'proposed_price': 'Proponowana Cena (USD)',
  'number_of_workers': 'Liczba Pracowników',
  'select_deadline': 'Wybierz Termin',
  'submitting': 'Wysyłanie...',
  'comment': 'Komentarz',
  'comment_optional': 'Komentarz (opcjonalnie)',
  'preview_application': 'Podgląd Aplikacji',
  'confirm_details_below': 'Proszę potwierdzić poniższe szczegóły',
  'application_details': 'Szczegóły Aplikacji',
  'price': 'Cena',
  'deadline': 'Termin',
  'workers': 'Pracownicy',
  'no_comment': 'Brak komentarza',
  'available_reports': 'Dostępne Raporty',
  'search_reports': 'Szukaj raportów...',
  'sort_newest': 'Najnowsze',
  'sort_oldest': 'Najstarsze',
  'sort_az': 'A → Z',
  'apply': 'Zastosuj',
  'no_available_reports': 'Brak dostępnych raportów',
  'firm_statistics': 'Statystyki Firmy',
  'categories_breakdown': 'Podział kategorii',
  'no_reports_in_selected_period': 'Brak raportów w wybranym okresie.',
  'no_tasks_yet': 'Brak zadań.',
  'assigned': 'Przypisane',
  'active': 'Aktywne',
  'firm_members': 'Członkowie Firmy',
  'add_member': 'Dodaj Członka',
  'no_members': 'Brak członków',
  'add_employee': 'Dodaj pracownika',
  'employee_email': 'Email pracownika',
  'add_employee_action': 'Dodaj',
  'no_user_with_this_email_found': 'Nie znaleziono użytkownika z takim emailem',
  'firm_member_role_not_allowed': 'Można dodać tylko użytkowników z rolą "user" lub "usernau"',
  'user_already_in_firm': 'Ten użytkownik już należy do firmy',
  'employee_added': 'Pracownik dodany',
  'employee_removed': 'Pracownik usunięty',
  'error_adding_employee': 'Błąd podczas dodawania pracownika',
  'remove_employee': 'Usuń pracownika',
  'remove_employee_confirm': 'Usunąć {email} z Twojej firmy?',
  'firm_not_found': 'Nie znaleziono firmy',
  'firm_history': 'Historia Firmy',
  'cancelled': 'Anulowane',
  'no_history_records': 'Brak historii.',
  'cancel_work': 'Anuluj pracę',
  'cancel_work_confirm': 'Czy na pewno chcesz anulować to zlecenie?',
  'mark_as_completed': 'Oznacz jako ukończone',
  'mark_as_completed_confirm': 'Potwierdzić, że zlecenie jest wykonane?',
  'work_cancelled': 'Praca anulowana.',
  'marked_as_completed': 'Oznaczono jako ukończone.',
  'assign_workers': 'Przypisz Pracowników',
  'no_workers_found': 'Nie znaleziono pracowników.',
  'worker_already_assigned': 'Już przypisany',
  'worker_will_be_removed': 'Zostanie usunięty',
  'assignments_updated': 'Przypisania zaktualizowane.',
  'select_workers': 'Wybierz pracowników',
  'assigned_reports': 'Przypisane Raporty',
  'no_assigned_reports': 'Nie masz przypisanych raportów.',
  'contact_details': 'Dane kontaktowe',
  'no_contact_details': 'Brak danych kontaktowych',
  'phone': 'Telefon',
  'selected_count': 'Wybrano {count}',
  'admin_dashboard': 'Panel Administracyjny',
  'admin_reports': 'Raporty Administratora',
  'whitelist_applications': 'Aplikacje na Whitelist',
  'no_pending_applications': 'Brak oczekujących aplikacji',
  'approve': 'Zatwierdź',
  'reject': 'Odrzuć',
  'approve_this_user_question': 'Zatwierdzić tego użytkownika?',
  'reject_this_user_question': 'Odrzucić tego użytkownika?',
  'user_approved': 'Użytkownik zatwierdzony',
  'user_rejected': 'Użytkownik odrzucony',
  'error_approving_user': 'Błąd podczas zatwierdzania użytkownika',
  'error_rejecting_user': 'Błąd podczas odrzucania użytkownika',
  'requested_at': 'Zgłoszono: {date}',
  'manage_categories': 'Zarządzaj Kategoriami',
  'new_category': 'Nowa kategoria',
  'add_category': 'Dodaj Kategorię',
  'category_name_label': 'Nazwa kategorii',
  'category_name_cannot_be_empty': 'Nazwa kategorii nie może być pusta',
  'category_already_exists': 'Kategoria "{name}" już istnieje',
  'category_added': 'Dodano kategorię',
  'delete_category_title': 'Usuń kategorię',
  'delete_category_confirm': 'Czy na pewno chcesz usunąć "{name}"?',
  'category_deleted': 'Kategoria "{name}" usunięta',
  'select_icon': 'Wybierz ikonę',
  'edit_category_title': 'Edytuj kategorię',
  'change_icon': 'Zmień ikonę',
  'category_updated': 'Zaktualizowano kategorię',
  'manage_participants': 'Zarządzaj Uczestnikami',
  'admins': 'Administratorzy',
  'firm_owners': 'Właściciele Firm',
  'firm_workers': 'Pracownicy firmy',
  'users': 'Użytkownicy',
  'banned': 'Zablokowani',
  'cannot_change_own_role': 'Nie możesz zmienić własnej roli',
  'role_updated_to': 'Rola zmieniona na {role}',
  'cannot_ban_yourself': 'Nie możesz zablokować samego siebie',
  'confirm_ban_title': 'Potwierdź blokadę',
  'confirm_unban_title': 'Potwierdź odblokowanie',
  'ban_this_user_prompt': 'Zablokować tego użytkownika?\n{email}',
  'unban_this_user_prompt': 'Odblokować tego użytkownika?\n{email}',
  'ban': 'Zablokuj',
  'unban': 'Odblokuj',
  'ban_user': 'Zablokuj Użytkownika',
  'unban_user': 'Odblokuj Użytkownika',
  'add_announcement': 'Dodaj Ogłoszenie',
  'publish': 'Opublikuj',
  'announcement_form_invalid': 'Uzupełnij poprawnie wszystkie pola',
  'announcement_published': 'Ogłoszenie opublikowane!',
  'title_is_required': 'Tytuł jest wymagany',
  'description_is_required': 'Opis jest wymagany',
  'view_all_announcements': 'Zobacz wszystkie ogłoszenia',
  'send_to_firms': 'Wyślij do Firm',
  'select_firm': 'Wybierz Firmę',
  'status_updated': 'Status zaktualizowany pomyślnie',
  'report_archived': 'Raport zarchiwizowany pomyślnie',
  'firm_selected': 'Firma wybrana pomyślnie',
  'firm': 'Firma',
  'report': 'Raport',
  'room': 'Pokój',
  'admin_actions': 'Akcje Administratora',
  'change_status': 'Zmień Status',
  'archive_report': 'Zarchiwizuj Raport',
  'firm_applications': 'Aplikacje Firm',
  'no_applications_yet': 'Brak aplikacji',
  'unknown_firm': 'Nieznana Firma',
  'selected': 'Wybrane',
  'home': 'Strona Główna',
  'reports': 'Raporty',
  'profile_nav': 'Profil',
  'verify_your_email': 'Zweryfikuj swój email',
  'we_sent_verification_email': 'Wysłaliśmy email weryfikacyjny na',
  'resend_email': 'Wyślij email ponownie',
  'back_to_login': 'Wróć do logowania',
  'no_user_found': 'Nie znaleziono użytkownika',
  'see_all': 'Zobacz wszystkie',
  'worker_panel': 'Panel Pracownika',
  'admin_tools': 'Narzędzia Administratora',
  'please_fill_full_name_and_album': 'Proszę wypełnić pełne imię i numer albumu.',
  'request_submitted': 'Prośba wysłana',
  'error_submitting_request': 'Błąd podczas wysyłania prośby',
  'my_firm_panel': 'Mój Panel Firmy',
  'assigned_reports_home': 'Przypisane Raporty',
  'available_reports_home': 'Dostępne Raporty',
  'firm_participants': 'Uczestnicy Firmy',
  'reports_history': 'Historia Raportów',
  'task_calendar': 'Kalendarz Zadań',
  'request_sent': 'Prośba wysłana',
  'sending': 'Wysyłanie...',
  'submit_request': 'Wyślij prośbę',
  'student_album_number': 'Numer albumu studenta',
  'tap_to_change_photo': 'Dotknij, aby zmienić zdjęcie',
  'your_name': 'Twoje imię',
  'name_cannot_exceed_20_characters': 'Imię nie może przekraczać 20 znaków',
  'saving': 'Zapisywanie...',
  'verification_email_sent': 'Email weryfikacyjny wysłany!',
  'resend_verification_email': 'Wyślij ponownie email weryfikacyjny',
  'i_verified_continue': 'Zweryfikowałem → Kontynuuj',
  'verification_email_description': 'Wysłaliśmy link weryfikacyjny na Twoją skrzynkę.\nKliknij link, aby aktywować konto.\n\nTen ekran sprawdza automatycznie.',
  'test_notification_title': 'Powiadomienie testowe',
  'test_notification_body': 'Wiadomość z DebugTools',
  'test_report_title': 'Raport testowy #{index}',
};


const Map<String, String> _ruValues = {
  'app_name': 'Академик App',
  'ok': 'ОК',
  'cancel': 'Отмена',
  'save': 'Сохранить',
  'edit': 'Редактировать',
  'delete': 'Удалить',
  'back': 'Назад',
  'search': 'Поиск',
  'details': 'Детали',
  'copy_email': 'Копировать email',
  'start_date': 'Начало',
  'loading': 'Загрузка...',
  'error': 'Ошибка',
  'success': 'Успешно',
  'yes': 'Да',
  'no': 'Нет',
  'close': 'Закрыть',
  'confirm': 'Подтверждение',
  'auth': 'Авторизация',
  'all_screens': 'Все экраны',
  'role_admin': 'Администратор',
  'role_firm_owner': 'Владелец фирмы',
  'role_firm_worker': 'Сотрудник фирмы',
  'role_user': 'Пользователь',
  'role_banned': 'Заблокирован',
  'error_with_details': 'Ошибка:\n{details}',
  'login': 'Войти',
  'register': 'Регистрация',
  'email': 'Email',
  'password': 'Пароль',
  'name': 'Имя',
  'please_fill_all_fields': 'Пожалуйста, заполните все поля',
  'quick_login': 'Быстрый вход (инструменты разработчика)',
  'invalid_email': 'Неверный адрес email',
  'weak_password': 'Пароль слишком слабый',
  'email_already_in_use': 'Email уже используется',
  'user_not_found': 'Пользователь не найден',
  'wrong_password': 'Неверный пароль',
  'welcome_back': 'Добро пожаловать',
  'create_account': 'Создать Аккаунт',
  'sign_in_to_continue': 'Войдите, чтобы продолжить',
  'register_to_get_started': 'Зарегистрируйтесь, чтобы начать',
  'create_an_account': 'Создать аккаунт',
  'already_have_account': 'Уже есть аккаунт?',
  'authentication_failed': 'Ошибка аутентификации',
  'login_failed': 'Ошибка входа для',
  'hello_user': 'Привет, {userName}!',
  'role': 'Роль:',
  'firm_panel': 'Панель Фирмы',
  'create_firm': 'Создать Фирму',
  'you_have_no_firm_yet': 'У вас еще нет зарегистрированной фирмы.',
  'application_being_reviewed': 'Ваша заявка находится на рассмотрении.',
  'account_pending_approval': 'Ваш аккаунт ожидает одобрения.',
  'previous_application_rejected': 'Ваша предыдущая заявка была отклонена. Вы можете подать новую.',
  'can_submit_new_one': 'Вы можете подать новую.',
  'full_name': 'Полное имя',
  'name_and_surname': 'Имя и фамилия',
  'no_name': 'Без имени',
  'album': 'Альбом',
  'submit_application': 'Подать Заявку',
  'register_your_firm': 'Зарегистрируйте свою фирму для получения отчетов.',
  'firm_name_required': 'Введите название фирмы',
  'select_at_least_one_category': 'Выберите хотя бы одну категорию',
  'user_not_authenticated': 'Пользователь не авторизован',
  'failed_to_register_firm': 'Не удалось зарегистрировать фирму',
  'settings': 'Настройки',
  'appearance': 'Внешний вид',
  'language': 'Язык',
  'support': 'Поддержка',
  'system': 'Система',
  'system_theme': 'Системная тема',
  'light_theme': 'Светлая тема',
  'dark_theme': 'Темная тема',
  'english': 'Английский',
  'polish': 'Польский',
  'russian': 'Русский',
  'notifications': 'Уведомления',
  'push_notifications': 'Push-уведомления',
  'news_updates': 'Новости и обновления',
  'report_bug': 'Сообщить об ошибке',
  'contact_admin': 'Связаться с администратором',
  'report_bug_title': 'Сообщить об ошибке',
  'report_bug_message': 'Нашли ошибку? Отправьте нам email с деталями:',
  'contact_admin_title': 'Связаться с администратором',
  'contact_admin_message': 'Нужна помощь? Свяжитесь с администратором:',
  'email_copied': 'Email скопирован в буфер обмена',
  'profile': 'Профиль',
  'edit_profile': 'Редактировать профиль',
  'change_password': 'Изменить пароль',
  'app_settings': 'Настройки приложения',
  'developer_tools': 'Инструменты разработчика',
  'dev_navigation': 'Навигация',
  'dev_data_utils': 'Утилиты данных',
  'dev_view_all_screens': 'Список экранов',
  'dev_browse_all_screens': 'Просмотр всех экранов приложения',
  'dev_delete_all_reports': 'Удалить все отчеты',
  'dev_remove_all_reports_subtitle': 'Удалить все отчеты из базы данных',
  'dev_generate_test_reports': 'Создать тестовые отчеты',
  'dev_create_500_test_reports': 'Создать 500 тестовых отчетов',
  'dev_all_screens': 'Все экраны',
  'dev_all_reports_deleted': 'Все отчеты удалены',
  'dev_created_test_reports': 'Создано тестовых отчетов: {count}',
  'dev_all_reports_sent_to_firms': 'Все отчеты отправлены фирмам',
  'dev_test_push_enqueued': 'Тестовый push добавлен в очередь',
  'dev_send_test_push': 'Отправить тестовый push',
  'dev_queue_test_notification': 'Добавить тестовое уведомление в очередь',
  'logout': 'Выйти',
  'logout_confirm': 'Выйти',
  'are_you_sure_logout': 'Вы уверены, что хотите выйти?',
  'password_reset_sent': 'Ссылка для сброса пароля отправлена на ваш email.',
  'my_reports': 'Мои Отчеты',
  'all': 'Все',
  'submitted': 'Отправлено',
  'review': 'На рассмотрении',
  'in_progress': 'В процессе',
  'completed': 'Завершено',
  'archived': 'Архивировано',
  'all_time': 'Все',
  'last_7_days': '7 дней',
  'last_30_days': '30 дней',
  'last_90_days': '90 дней',
  'search_by_title_room_category': 'Поиск по названию, комнате, категории',
  'no_reports_found': 'Отчеты не найдены',
  'status': 'Статус:',
  'add_report': 'Добавить Отчет',
  'edit_report': 'Редактировать Отчет',
  'title': 'Название',
  'description': 'Описание',
  'room_number': 'Номер комнаты',
  'category': 'Категория',
  'photos': 'Фотографии',
  'upload_photos': 'Загрузить фотографии',
  'take_photo': 'Сделать фото',
  'choose_from_gallery': 'Выбрать из галереи',
  'submit_report': 'Отправить Отчет',
  'save_changes': 'Сохранить изменения',
  'something_went_wrong': 'Что-то пошло не так. Пожалуйста, проверьте введенные данные.',
  'check_your_input': 'Пожалуйста, проверьте введенные данные.',
  'report_created_successfully': 'Отчет успешно создан!',
  'report_updated_successfully': 'Отчет успешно обновлен.',
  'photos_count': 'Фотографии: {current} / {max}',
  'add_photos_max': 'Добавить фото (макс. {max})',
  'announcements': 'Объявления',
  'announcement': 'Объявление',
  'no_announcements': 'Нет объявлений',
  'info': 'Информация',
  'important': 'Важно',
  'warning': 'Предупреждение',
  'unknown': 'Неизвестно',
  'untitled': 'Без названия',
  'no_description': 'Нет описания',
  'published_at': 'Опубликовано: {date}',
  'author_with_email': 'Автор: {email}',
  'register_firm': 'Зарегистрировать Фирму',
  'firm_name': 'Название Фирмы',
  'edit_firm': 'Редактировать фирму',
  'select_categories': 'Выберите Категории:',
  'categories_label': 'Категории',
  'show_more': 'Показать больше',
  'show_less': 'Показать меньше',
  'no_categories_available': 'Нет доступных категорий',
  'proposed_price': 'Предлагаемая Цена (USD)',
  'number_of_workers': 'Количество Рабочих',
  'select_deadline': 'Выберите Срок',
  'submitting': 'Отправка...',
  'comment': 'Комментарий',
  'comment_optional': 'Комментарий (необязательно)',
  'preview_application': 'Предпросмотр Заявки',
  'confirm_details_below': 'Пожалуйста, подтвердите детали ниже',
  'application_details': 'Детали Заявки',
  'price': 'Цена',
  'deadline': 'Срок',
  'workers': 'Рабочие',
  'no_comment': 'Нет комментария',
  'available_reports': 'Доступные Отчеты',
  'search_reports': 'Поиск отчетов...',
  'sort_newest': 'Сначала новые',
  'sort_oldest': 'Сначала старые',
  'sort_az': 'А → Я',
  'apply': 'Применить',
  'no_available_reports': 'Нет доступных отчетов',
  'firm_statistics': 'Статистика Фирмы',
  'categories_breakdown': 'Разбивка по категориям',
  'no_reports_in_selected_period': 'Нет отчётов за выбранный период.',
  'no_tasks_yet': 'Задач пока нет.',
  'assigned': 'Назначено',
  'active': 'Активные',
  'firm_members': 'Участники Фирмы',
  'add_member': 'Добавить Участника',
  'no_members': 'Нет участников',
  'add_employee': 'Добавить сотрудника',
  'employee_email': 'Email сотрудника',
  'add_employee_action': 'Добавить',
  'no_user_with_this_email_found': 'Пользователь с таким email не найден',
  'firm_member_role_not_allowed': 'Можно добавить только пользователей с ролью "user" или "usernau"',
  'user_already_in_firm': 'Этот пользователь уже состоит в фирме',
  'employee_added': 'Сотрудник добавлен',
  'employee_removed': 'Сотрудник удалён',
  'error_adding_employee': 'Ошибка при добавлении сотрудника',
  'remove_employee': 'Удалить сотрудника',
  'remove_employee_confirm': 'Удалить {email} из вашей фирмы?',
  'firm_not_found': 'Фирма не найдена',
  'firm_history': 'История Фирмы',
  'cancelled': 'Отменено',
  'no_history_records': 'История пуста.',
  'cancel_work': 'Отменить работу',
  'cancel_work_confirm': 'Вы уверены, что хотите отменить эту работу?',
  'mark_as_completed': 'Отметить как выполнено',
  'mark_as_completed_confirm': 'Подтвердить, что работа выполнена?',
  'work_cancelled': 'Работа отменена.',
  'marked_as_completed': 'Отмечено как выполнено.',
  'assign_workers': 'Назначить Рабочих',
  'no_workers_found': 'Рабочие не найдены.',
  'worker_already_assigned': 'Уже назначен',
  'worker_will_be_removed': 'Будет удалён',
  'assignments_updated': 'Назначения обновлены.',
  'select_workers': 'Выберите рабочих',
  'assigned_reports': 'Назначенные Отчеты',
  'no_assigned_reports': 'У вас нет назначенных отчётов.',
  'contact_details': 'Контактные данные',
  'no_contact_details': 'Нет контактных данных',
  'phone': 'Телефон',
  'selected_count': 'Выбрано {count}',
  'admin_dashboard': 'Панель Администратора',
  'admin_reports': 'Отчеты Администратора',
  'whitelist_applications': 'Заявки на Whitelist',
  'no_pending_applications': 'Нет ожидающих заявок',
  'approve': 'Одобрить',
  'reject': 'Отклонить',
  'approve_this_user_question': 'Одобрить этого пользователя?',
  'reject_this_user_question': 'Отклонить этого пользователя?',
  'user_approved': 'Пользователь одобрен',
  'user_rejected': 'Пользователь отклонён',
  'error_approving_user': 'Ошибка при одобрении пользователя',
  'error_rejecting_user': 'Ошибка при отклонении пользователя',
  'requested_at': 'Запрошено: {date}',
  'manage_categories': 'Управление Категориями',
  'new_category': 'Новая категория',
  'add_category': 'Добавить Категорию',
  'category_name_label': 'Название категории',
  'category_name_cannot_be_empty': 'Название категории не может быть пустым',
  'category_already_exists': 'Категория "{name}" уже существует',
  'category_added': 'Категория добавлена',
  'delete_category_title': 'Удалить категорию',
  'delete_category_confirm': 'Вы уверены, что хотите удалить "{name}"?',
  'category_deleted': 'Категория "{name}" удалена',
  'select_icon': 'Выберите иконку',
  'edit_category_title': 'Редактировать категорию',
  'change_icon': 'Сменить иконку',
  'category_updated': 'Категория обновлена',
  'manage_participants': 'Управление Участниками',
  'admins': 'Администраторы',
  'firm_owners': 'Владельцы Фирм',
  'firm_workers': 'Сотрудники фирмы',
  'users': 'Пользователи',
  'banned': 'Заблокированные',
  'cannot_change_own_role': 'Вы не можете изменить свою роль',
  'role_updated_to': 'Роль обновлена на {role}',
  'cannot_ban_yourself': 'Вы не можете заблокировать себя',
  'confirm_ban_title': 'Подтвердите блокировку',
  'confirm_unban_title': 'Подтвердите разблокировку',
  'ban_this_user_prompt': 'Заблокировать этого пользователя?\n{email}',
  'unban_this_user_prompt': 'Разблокировать этого пользователя?\n{email}',
  'ban': 'Заблокировать',
  'unban': 'Разблокировать',
  'ban_user': 'Заблокировать Пользователя',
  'unban_user': 'Разблокировать Пользователя',
  'add_announcement': 'Добавить Объявление',
  'publish': 'Опубликовать',
  'announcement_form_invalid': 'Пожалуйста, корректно заполните все поля',
  'announcement_published': 'Объявление опубликовано!',
  'title_is_required': 'Требуется заголовок',
  'description_is_required': 'Требуется описание',
  'view_all_announcements': 'Посмотреть все объявления',
  'send_to_firms': 'Отправить в Фирмы',
  'select_firm': 'Выбрать Фирму',
  'status_updated': 'Статус успешно обновлен',
  'report_archived': 'Отчет успешно архивирован',
  'firm_selected': 'Фирма успешно выбрана',
  'firm': 'Фирма',
  'report': 'Отчет',
  'room': 'Комната',
  'admin_actions': 'Действия Администратора',
  'change_status': 'Изменить Статус',
  'archive_report': 'Архивировать Отчет',
  'firm_applications': 'Заявки Фирм',
  'no_applications_yet': 'Заявок пока нет',
  'unknown_firm': 'Неизвестная Фирма',
  'selected': 'Выбрано',
  'home': 'Главная',
  'reports': 'Отчеты',
  'profile_nav': 'Профиль',
  'verify_your_email': 'Подтвердите ваш email',
  'we_sent_verification_email': 'Мы отправили письмо для подтверждения на',
  'resend_email': 'Отправить письмо повторно',
  'back_to_login': 'Вернуться к входу',
  'no_user_found': 'Пользователь не найден',
  'see_all': 'Смотреть все',
  'worker_panel': 'Панель Рабочего',
  'admin_tools': 'Инструменты Администратора',
  'please_fill_full_name_and_album': 'Пожалуйста, заполните полное имя и номер альбома.',
  'request_submitted': 'Запрос отправлен',
  'error_submitting_request': 'Ошибка при отправке запроса',
  'my_firm_panel': 'Моя Панель Фирмы',
  'assigned_reports_home': 'Назначенные Отчеты',
  'available_reports_home': 'Доступные Отчеты',
  'firm_participants': 'Участники Фирмы',
  'reports_history': 'История Отчетов',
  'task_calendar': 'Календарь Задач',
  'request_sent': 'Запрос отправлен',
  'sending': 'Отправка...',
  'submit_request': 'Отправить запрос',
  'student_album_number': 'Номер альбома студента',
  'tap_to_change_photo': 'Нажмите, чтобы изменить фото',
  'your_name': 'Ваше имя',
  'name_cannot_exceed_20_characters': 'Имя не может превышать 20 символов',
  'saving': 'Сохранение...',
  'verification_email_sent': 'Письмо для подтверждения отправлено!',
  'resend_verification_email': 'Отправить письмо повторно',
  'i_verified_continue': 'Я подтвердил → Продолжить',
  'verification_email_description': 'Мы отправили ссылку для подтверждения на вашу почту.\nНажмите на ссылку, чтобы активировать аккаунт.\n\nЭтот экран проверяет автоматически.',
  'test_notification_title': 'Тестовое уведомление',
  'test_notification_body': 'Привет из DebugTools',
  'test_report_title': 'Тестовый отчет №{index}',
};
