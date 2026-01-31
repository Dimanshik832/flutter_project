import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  bool _emailSent = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    
    _sendVerificationEmail();

    
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerification();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  
  
  
  Future<void> _checkVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload(); 
    if (user.emailVerified) {
      _timer?.cancel();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, "/"); 
    }
  }

  
  
  
  Future<void> _sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified) return;

    setState(() {
      _sending = true;
      _emailSent = false;
    });

    try {
      await user.sendEmailVerification();
      setState(() => _emailSent = true);
    } catch (e, stack) {
      debugPrint('VerifyEmailScreen: failed to send verification: $e');
      debugPrintStack(stackTrace: stack);
    }

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() {
        _sending = false;
      });
    }
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.verifyYourEmail,
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService.logout();
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.18),
                        Colors.blue.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Colors.blue,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.verifyYourEmail,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  l10n.verificationEmailDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[400] : Colors.black54),
                ),

                const SizedBox(height: 26),

                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _sendVerificationEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _sending
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      l10n.resendVerificationEmail,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                
                AnimatedOpacity(
                  opacity: _emailSent ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    l10n.verificationEmailSent,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _checkVerification,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blue, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      l10n.iVerifiedContinue,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
