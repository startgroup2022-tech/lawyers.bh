import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // App
  String get appName => _localized('appName');
  String get appNameEn => _localized('appNameEn');

  // Auth
  String get login => _localized('login');
  String get register => _localized('register');
  String get logout => _localized('logout');
  String get email => _localized('email');
  String get phone => _localized('phone');
  String get password => _localized('password');
  String get confirmPassword => _localized('confirmPassword');
  String get forgotPassword => _localized('forgotPassword');
  String get resetPassword => _localized('resetPassword');
  String get otp => _localized('otp');
  String get verifyCode => _localized('verifyCode');
  String get resendCode => _localized('resendCode');
  String get rememberMe => _localized('rememberMe');
  String get orLoginWith => _localized('orLoginWith');
  String get dontHaveAccount => _localized('dontHaveAccount');
  String get alreadyHaveAccount => _localized('alreadyHaveAccount');

  // Onboarding
  String get welcome => _localized('welcome');
  String get welcomeDesc => _localized('welcomeDesc');
  String get quickRegistration => _localized('quickRegistration');
  String get quickRegistrationDesc => _localized('quickRegistrationDesc');
  String get legalAid => _localized('legalAid');
  String get legalAidDesc => _localized('legalAidDesc');
  String get secureContracts => _localized('secureContracts');
  String get secureContractsDesc => _localized('secureContractsDesc');
  String get getStarted => _localized('getStarted');
  String get skip => _localized('skip');
  String get next => _localized('next');

  // Home
  String get home => _localized('home');
  String get searchLawyers => _localized('searchLawyers');
  String get recommendedLawyers => _localized('recommendedLawyers');
  String get viewAll => _localized('viewAll');
  String get browseBySpecialty => _localized('browseBySpecialty');
  String get urgentLegalAid => _localized('urgentLegalAid');
  String get urgentLegalAidDesc => _localized('urgentLegalAidDesc');

  // Lawyers
  String get lawyersDirectory => _localized('lawyersDirectory');
  String get all => _localized('all');
  String get commercial => _localized('commercial');
  String get personalStatus => _localized('personalStatus');
  String get labor => _localized('labor');
  String get criminal => _localized('criminal');
  String get experience => _localized('experience');
  String get years => _localized('years');
  String get consultationFee => _localized('consultationFee');
  String get rating => _localized('rating');
  String get reviews => _localized('reviews');
  String get freeFirstConsultation => _localized('freeFirstConsultation');
  String get acceptedAtCassation => _localized('acceptedAtCassation');
  String get availableToday => _localized('availableToday');
  String get bookConsultation => _localized('bookConsultation');
  String get call => _localized('call');
  String get whatsapp => _localized('whatsapp');
  String get message => _localized('message');
  String get save => _localized('save');

  // Lawyer Profile
  String get specialties => _localized('specialties');
  String get aboutLawyer => _localized('aboutLawyer');
  String get consultationType => _localized('consultationType');
  String get videoCall => _localized('videoCall');
  String get voiceCall => _localized('voiceCall');
  String get inPerson => _localized('inPerson');
  String get back => _localized('back');

  // Contracts & Payments
  String get secureContract => _localized('secureContract');
  String get contractSummary => _localized('contractSummary');
  String get eSignature => _localized('eSignature');
  String get signContract => _localized('signContract');
  String get paymentMethod => _localized('paymentMethod');
  String get benefitPay => _localized('benefitPay');
  String get applePay => _localized('applePay');
  String get legalRepresentation => _localized('legalRepresentation');
  String get feeAgreement => _localized('feeAgreement');
  String get consultationPersonal => _localized('consultationPersonal');
  String get pendingSignature => _localized('pendingSignature');
  String get active => _localized('active');
  String get completed => _localized('completed');

  // Case Tracking
  String get caseTracking => _localized('caseTracking');
  String get requestReceived => _localized('requestReceived');
  String get lawyerMatched => _localized('lawyerMatched');
  String get awaitingContract => _localized('awaitingContract');
  String get caseActive => _localized('caseActive');
  String get representationContract => _localized('representationContract');
  String get uploadedYesterday => _localized('uploadedYesterday');
  String get yourLawyer => _localized('yourLawyer');

  // Lawyer Dashboard
  String get dashboard => _localized('dashboard');
  String get activeCases => _localized('activeCases');
  String get pendingOffers => _localized('pendingOffers');
  String get monthlyFees => _localized('monthlyFees');
  String get newNegotiationRequests => _localized('newNegotiationRequests');
  String get accept => _localized('accept');
  String get reject => _localized('reject');
  String get contractsFiles => _localized('contractsFiles');
  String get notifications => _localized('notifications');
  String get hearingTomorrow => _localized('hearingTomorrow');
  String get paymentReceived => _localized('paymentReceived');
  String get quickFeeCalculator => _localized('quickFeeCalculator');
  String get hours => _localized('hours');
  String get calculateSuggestedFees => _localized('calculateSuggestedFees');

  // Admin
  String get strategicControlRoom => _localized('strategicControlRoom');
  String get transactionsThisMonth => _localized('transactionsThisMonth');
  String get avgResponseTime => _localized('avgResponseTime');
  String get customerSatisfaction => _localized('customerSatisfaction');
  String get activeCasesCount => _localized('activeCasesCount');
  String get disputeResolution => _localized('disputeResolution');
  String get interveneNow => _localized('interveneNow');
  String get documentDelay => _localized('documentDelay');
  String get feeDispute => _localized('feeDispute');
  String get lawyerClient => _localized('lawyerClient');
  String get medium => _localized('medium');
  String get high => _localized('high');
  String get managementStructure => _localized('managementStructure');
  String get platformManager => _localized('platformManager');
  String get disputeSupervisor => _localized('disputeSupervisor');
  String get platformAccountant => _localized('platformAccountant');
  String get fullPermissions => _localized('fullPermissions');
  String get manageDisputes => _localized('manageDisputes');
  String get escrowAccounts => _localized('escrowAccounts');
  String get addNewMember => _localized('addNewMember');

  // Profile & Settings
  String get myProfile => _localized('myProfile');
  String get editProfile => _localized('editProfile');
  String get settings => _localized('settings');
  String get language => _localized('language');
  String get theme => _localized('theme');
  String get notificationsSettings => _localized('notificationsSettings');
  String get security => _localized('security');
  String get biometricLogin => _localized('biometricLogin');
  String get changePassword => _localized('changePassword');
  String get helpSupport => _localized('helpSupport');
  String get aboutApp => _localized('aboutApp');
  String get termsConditions => _localized('termsConditions');
  String get privacyPolicy => _localized('privacyPolicy');
  String get logoutConfirm => _localized('logoutConfirm');
  String get yes => _localized('yes');
  String get no => _localized('no');
  String get cancel => _localized('cancel');
  String get saveChanges => _localized('saveChanges');

  // Messages
  String get messages => _localized('messages');
  String get noMessages => _localized('noMessages');

  // Favorites
  String get favorites => _localized('favorites');
  String get noFavorites => _localized('noFavorites');

  // Common
  String get loading => _localized('loading');
  String get error => _localized('error');
  String get retry => _localized('retry');
  String get ok => _localized('ok');
  String get close => _localized('close');
  String get confirm => _localized('confirm');
  String get delete => _localized('delete');
  String get edit => _localized('edit');
  String get view => _localized('view');
  String get search => _localized('search');
  String get filter => _localized('filter');
  String get sort => _localized('sort');
  String get clear => _localized('clear');
  String get done => _localized('done');
  String get bhd => _localized('bhd');

  // Errors
  String get networkError => _localized('networkError');
  String get serverError => _localized('serverError');
  String get unauthorized => _localized('unauthorized');
  String get sessionExpired => _localized('sessionExpired');
  String get invalidCredentials => _localized('invalidCredentials');
  String get userNotFound => _localized('userNotFound');
  String get emailExists => _localized('emailExists');
  String get phoneExists => _localized('phoneExists');
  String get weakPassword => _localized('weakPassword');
  String get passwordsNotMatch => _localized('passwordsNotMatch');
  String get invalidOtp => _localized('invalidOtp');
  String get otpExpired => _localized('otpExpired');
  String get somethingWentWrong => _localized('somethingWentWrong');

  String _localized(String key) {
    return _localizations[locale.languageCode]?[key] ?? _localizations['ar']?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizations = {
    'ar': {
      'appName': 'محامون البحرين',
      'appNameEn': 'Lawyers.bh',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الهاتف',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'otp': 'رمز التحقق',
      'verifyCode': 'تحقق من الرمز',
      'resendCode': 'إعادة إرسال الرمز',
      'rememberMe': 'تذكرني',
      'orLoginWith': 'أو تسجيل الدخول بـ',
      'dontHaveAccount': 'لا تملك حساباً؟',
      'alreadyHaveAccount': 'تملك حساباً بالفعل؟',
      'welcome': 'مرحباً بك في منصة محامين البحرين',
      'welcomeDesc': 'منصتك القانونية الموثوقة للتواصل مع أفضل المحامين في البحرين',
      'quickRegistration': 'تسجيل سريع',
      'quickRegistrationDesc': 'سجل برقم هاتفك واحصل على تحقق فوري (OTP)',
      'legalAid': 'نجدة قانونية',
      'legalAidDesc': 'اطلب مساعدة قانونية عاجلة بضغطة واحدة',
      'secureContracts': 'عقود آمنة',
      'secureContractsDesc': 'تعاقد وادفع بأمان مع ضمان المنصة',
      'getStarted': 'ابدأ الآن',
      'skip': 'تخطي',
      'next': 'التالي',
      'home': 'الرئيسية',
      'searchLawyers': 'ابحث عن محامٍ',
      'recommendedLawyers': 'محامون موصى بهم',
      'viewAll': 'عرض الكل',
      'browseBySpecialty': 'تصفح حسب التخصص',
      'urgentLegalAid': 'تسجيل سريع ونجدة قانونية',
      'urgentLegalAidDesc': 'أنشئ حسابك برقم هاتفك واحصل على تحقق فوري (OTP)، أو اطلب نجدة قانونية عاجلة بضغطة واحدة.',
      'lawyersDirectory': 'دليل المحامين',
      'all': 'الكل',
      'commercial': 'تجاري',
      'personalStatus': 'أحوال شخصية',
      'labor': 'عمالي',
      'criminal': 'جنائي',
      'experience': 'سنوات خبرة',
      'years': 'سنة',
      'consultationFee': 'رسوم الاستشارة',
      'rating': 'التقييم',
      'reviews': 'تقييم',
      'freeFirstConsultation': 'استشارة أولى مجانية',
      'acceptedAtCassation': 'مقبول أمام التمييز',
      'availableToday': 'متاح اليوم',
      'bookConsultation': 'احجز استشارة',
      'call': 'اتصال',
      'whatsapp': 'واتساب',
      'message': 'مراسلة',
      'save': 'حفظ',
      'specialties': 'التخصصات',
      'aboutLawyer': 'عن المحامي',
      'consultationType': 'نوع الاستشارة',
      'videoCall': 'فيديو',
      'voiceCall': 'صوتي',
      'inPerson': 'حضوري',
      'back': 'رجوع',
      'secureContract': 'التعاقد الآمن والدفع',
      'contractSummary': 'ملخص العقد',
      'eSignature': 'منطقة التوقيع الإلكتروني',
      'signContract': 'توقيع العقد',
      'paymentMethod': 'طريقة الدفع',
      'benefitPay': 'BenefitPay',
      'applePay': 'Apple Pay',
      'legalRepresentation': 'تمثيل قانوني',
      'feeAgreement': 'اتفاقية أتعاب',
      'consultationPersonal': 'استشارة - أحوال شخصية',
      'pendingSignature': 'بانتظار توقيع',
      'active': 'نشط',
      'completed': 'مكتمل',
      'caseTracking': 'لوحة متابعة القضية',
      'requestReceived': 'تم استلام الطلب',
      'lawyerMatched': 'مطابقة محامٍ مختص',
      'awaitingContract': 'بانتظار توقيع العقد',
      'caseActive': 'القضية نشطة ومتابعة',
      'representationContract': 'عقد التمثيل.pdf',
      'uploadedYesterday': 'تم الرفع أمس',
      'yourLawyer': 'محاميك المسؤول عن القضية',
      'dashboard': 'شاشة القيادة',
      'activeCases': 'قضايا نشطة',
      'pendingOffers': 'عروض معلّقة',
      'monthlyFees': 'أتعاب الشهر',
      'newNegotiationRequests': 'طلبات تفاوض جديدة',
      'accept': 'قبول',
      'reject': 'رفض',
      'contractsFiles': 'العقود والملفات',
      'notifications': 'التنبيهات والمواعيد',
      'hearingTomorrow': 'جلسة استماع غداً 10:00 صباحاً',
      'paymentReceived': 'تم استلام دفعة أتعاب',
      'quickFeeCalculator': 'حاسبة الأتعاب السريعة',
      'hours': 'عدد الساعات',
      'calculateSuggestedFees': 'احسب الأتعاب المقترحة',
      'strategicControlRoom': 'غرفة التحكم الاستراتيجية',
      'transactionsThisMonth': 'معاملات هذا الشهر',
      'avgResponseTime': 'متوسط وقت الاستجابة',
      'customerSatisfaction': 'رضا العملاء',
      'activeCasesCount': 'قضايا نشطة حالياً',
      'disputeResolution': 'التدخل وفض النزاعات',
      'interveneNow': 'تدخّل الآن',
      'documentDelay': 'تأخر في تسليم المستندات',
      'feeDispute': 'خلاف حول الأتعاب المتفق عليها',
      'lawyerClient': 'محامٍ ↔ عميل',
      'medium': 'متوسطة',
      'high': 'عالية',
      'managementStructure': 'إدارة الهيكل الإداري',
      'platformManager': 'مدير عام المنصة',
      'disputeSupervisor': 'مشرف فض النزاعات',
      'platformAccountant': 'محاسب المنصة',
      'fullPermissions': 'صلاحيات كاملة على جميع الوحدات',
      'manageDisputes': 'إدارة النزاعات والتدخل المباشر',
      'escrowAccounts': 'حسابات الضمان (Escrow) والأتعاب',
      'addNewMember': 'إضافة عضو جديد',
      'myProfile': 'ملفي الشخصي',
      'editProfile': 'تعديل الملف',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'theme': 'المظهر',
      'notificationsSettings': 'الإشعارات',
      'security': 'الأمان',
      'biometricLogin': 'تسجيل الدخول بالبصمة/الوجه',
      'changePassword': 'تغيير كلمة المرور',
      'helpSupport': 'المساعدة والدعم',
      'aboutApp': 'عن التطبيق',
      'termsConditions': 'الشروط والأحكام',
      'privacyPolicy': 'سياسة الخصوصية',
      'logoutConfirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'yes': 'نعم',
      'no': 'لا',
      'cancel': 'إلغاء',
      'saveChanges': 'حفظ التغييرات',
      'messages': 'الرسائل',
      'noMessages': 'لا توجد رسائل حالياً',
      'favorites': 'المفضلة',
      'noFavorites': 'لا يوجد محامون محفوظون',
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ',
      'retry': 'إعادة المحاولة',
      'ok': 'موافق',
      'close': 'إغلاق',
      'confirm': 'تأكيد',
      'delete': 'حذف',
      'edit': 'تعديل',
      'view': 'عرض',
      'search': 'بحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',
      'clear': 'مسح',
      'done': 'تم',
      'bhd': 'د.ب',
      'networkError': 'خطأ في الاتصال بالشبكة',
      'serverError': 'خطأ في الخادم',
      'unauthorized': 'غير مصرح',
      'sessionExpired': 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى',
      'invalidCredentials': 'بيانات الدخول غير صحيحة',
      'userNotFound': 'المستخدم غير موجود',
      'emailExists': 'البريد الإلكتروني مستخدم بالفعل',
      'phoneExists': 'رقم الهاتف مستخدم بالفعل',
      'weakPassword': 'كلمة المرور ضعيفة',
      'passwordsNotMatch': 'كلمات المرور غير متطابقة',
      'invalidOtp': 'رمز التحقق غير صحيح',
      'otpExpired': 'انتهت صلاحية رمز التحقق',
      'somethingWentWrong': 'حدث خطأ غير متوقع',
    },
    'en': {
      'appName': 'Lawyers Bahrain',
      'appNameEn': 'Lawyers.bh',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'phone': 'Phone',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'resetPassword': 'Reset Password',
      'otp': 'OTP',
      'verifyCode': 'Verify Code',
      'resendCode': 'Resend Code',
      'rememberMe': 'Remember Me',
      'orLoginWith': 'Or login with',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'welcome': 'Welcome to Lawyers Bahrain Platform',
      'welcomeDesc': 'Your trusted legal platform to connect with top lawyers in Bahrain',
      'quickRegistration': 'Quick Registration',
      'quickRegistrationDesc': 'Register with your phone number and get instant OTP verification',
      'legalAid': 'Legal Aid',
      'legalAidDesc': 'Request urgent legal assistance with one tap',
      'secureContracts': 'Secure Contracts',
      'secureContractsDesc': 'Contract and pay safely with platform guarantee',
      'getStarted': 'Get Started',
      'skip': 'Skip',
      'next': 'Next',
      'home': 'Home',
      'searchLawyers': 'Search Lawyers',
      'recommendedLawyers': 'Recommended Lawyers',
      'viewAll': 'View All',
      'browseBySpecialty': 'Browse by Specialty',
      'urgentLegalAid': 'Quick Registration & Legal Aid',
      'urgentLegalAidDesc': 'Create your account with your phone number and get instant OTP verification, or request urgent legal aid with one tap.',
      'lawyersDirectory': 'Lawyers Directory',
      'all': 'All',
      'commercial': 'Commercial',
      'personalStatus': 'Personal Status',
      'labor': 'Labor',
      'criminal': 'Criminal',
      'experience': 'Years Experience',
      'years': 'years',
      'consultationFee': 'Consultation Fee',
      'rating': 'Rating',
      'reviews': 'Reviews',
      'freeFirstConsultation': 'Free First Consultation',
      'acceptedAtCassation': 'Accepted at Cassation',
      'availableToday': 'Available Today',
      'bookConsultation': 'Book Consultation',
      'call': 'Call',
      'whatsapp': 'WhatsApp',
      'message': 'Message',
      'save': 'Save',
      'specialties': 'Specialties',
      'aboutLawyer': 'About Lawyer',
      'consultationType': 'Consultation Type',
      'videoCall': 'Video',
      'voiceCall': 'Voice',
      'inPerson': 'In-Person',
      'back': 'Back',
      'secureContract': 'Secure Contract & Payment',
      'contractSummary': 'Contract Summary',
      'eSignature': 'E-Signature Area',
      'signContract': 'Sign Contract',
      'paymentMethod': 'Payment Method',
      'benefitPay': 'BenefitPay',
      'applePay': 'Apple Pay',
      'legalRepresentation': 'Legal Representation',
      'feeAgreement': 'Fee Agreement',
      'consultationPersonal': 'Consultation - Personal Status',
      'pendingSignature': 'Pending Signature',
      'active': 'Active',
      'completed': 'Completed',
      'caseTracking': 'Case Tracking Dashboard',
      'requestReceived': 'Request Received',
      'lawyerMatched': 'Lawyer Matched',
      'awaitingContract': 'Awaiting Contract Signature',
      'caseActive': 'Case Active & Tracking',
      'representationContract': 'representation_contract.pdf',
      'uploadedYesterday': 'Uploaded Yesterday',
      'yourLawyer': 'Your Assigned Lawyer',
      'dashboard': 'Dashboard',
      'activeCases': 'Active Cases',
      'pendingOffers': 'Pending Offers',
      'monthlyFees': 'Monthly Fees',
      'newNegotiationRequests': 'New Negotiation Requests',
      'accept': 'Accept',
      'reject': 'Reject',
      'contractsFiles': 'Contracts & Files',
      'notifications': 'Notifications & Schedule',
      'hearingTomorrow': 'Hearing Tomorrow 10:00 AM',
      'paymentReceived': 'Payment Received',
      'quickFeeCalculator': 'Quick Fee Calculator',
      'hours': 'Hours',
      'calculateSuggestedFees': 'Calculate Suggested Fees',
      'strategicControlRoom': 'Strategic Control Room',
      'transactionsThisMonth': 'Transactions This Month',
      'avgResponseTime': 'Avg Response Time',
      'customerSatisfaction': 'Customer Satisfaction',
      'activeCasesCount': 'Active Cases Currently',
      'disputeResolution': 'Dispute Resolution',
      'interveneNow': 'Intervene Now',
      'documentDelay': 'Document Delivery Delay',
      'feeDispute': 'Dispute Over Agreed Fees',
      'lawyerClient': 'Lawyer ↔ Client',
      'medium': 'Medium',
      'high': 'High',
      'managementStructure': 'Management Structure',
      'platformManager': 'Platform General Manager',
      'disputeSupervisor': 'Dispute Supervisor',
      'platformAccountant': 'Platform Accountant',
      'fullPermissions': 'Full Permissions on All Modules',
      'manageDisputes': 'Manage Disputes & Direct Intervention',
      'escrowAccounts': 'Escrow Accounts & Fees',
      'addNewMember': 'Add New Member',
      'myProfile': 'My Profile',
      'editProfile': 'Edit Profile',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'notificationsSettings': 'Notifications',
      'security': 'Security',
      'biometricLogin': 'Biometric Login',
      'changePassword': 'Change Password',
      'helpSupport': 'Help & Support',
      'aboutApp': 'About App',
      'termsConditions': 'Terms & Conditions',
      'privacyPolicy': 'Privacy Policy',
      'logoutConfirm': 'Are you sure you want to logout?',
      'yes': 'Yes',
      'no': 'No',
      'cancel': 'Cancel',
      'saveChanges': 'Save Changes',
      'messages': 'Messages',
      'noMessages': 'No messages at the moment',
      'favorites': 'Favorites',
      'noFavorites': 'No saved lawyers',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'ok': 'OK',
      'close': 'Close',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'edit': 'Edit',
      'view': 'View',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'clear': 'Clear',
      'done': 'Done',
      'bhd': 'BHD',
      'networkError': 'Network connection error',
      'serverError': 'Server error',
      'unauthorized': 'Unauthorized',
      'sessionExpired': 'Session expired, please login again',
      'invalidCredentials': 'Invalid credentials',
      'userNotFound': 'User not found',
      'emailExists': 'Email already exists',
      'phoneExists': 'Phone already exists',
      'weakPassword': 'Weak password',
      'passwordsNotMatch': 'Passwords do not match',
      'invalidOtp': 'Invalid OTP code',
      'otpExpired': 'OTP code expired',
      'somethingWentWrong': 'Something went wrong',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}