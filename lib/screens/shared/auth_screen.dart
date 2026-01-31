import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    final l10n = AppLocalizations.of(context)!;
    
    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.pleaseFillAllFields)));
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = userCredential.user?.uid;

        if (uid != null) {
          
          await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(uid).set({
            FirestoreUserFields.email: email,
            FirestoreUserFields.name: name,

            
            FirestoreUserFields.role: 'usernau',
            FirestoreUserFields.applicationStatus: 'none',

            
            FirestoreUserFields.fullName: '',
            FirestoreUserFields.album: '',

            FirestoreUserFields.createdAt: FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      final l10n = AppLocalizations.of(context)!;
      String message = l10n.authenticationFailed;
      if (e.code == 'user-not-found') message = l10n.userNotFound;
      if (e.code == 'wrong-password') message = l10n.wrongPassword;
      if (e.code == 'email-already-in-use') message = l10n.emailAlreadyInUse;
      if (e.code == 'weak-password') message = l10n.weakPassword;
      if (e.code == 'invalid-email') message = l10n.invalidEmail;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() => isLoading = false);
  }

  Future<void> _quickLogin(String email, {String password = '1234567'}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.loginFailed} $email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? Colors.white : theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Text(
                  isLogin ? l10n.welcomeBack : l10n.createAccount,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  isLogin ? l10n.signInToContinue : l10n.registerToGetStarted,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (!isLogin)
                        _input(
                          controller: nameController,
                          label: l10n.name,
                          icon: Icons.person,
                        ),
                      const SizedBox(height: 16),

                      _input(
                        controller: emailController,
                        label: l10n.email,
                        icon: Icons.email_rounded,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _input(
                        controller: passwordController,
                        label: l10n.password,
                        icon: Icons.lock_rounded,
                        obscure: true,
                      ),

                      const SizedBox(height: 26),

                      GestureDetector(
                        onTap: isLoading ? null : _submit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : Text(
                              isLogin ? l10n.login : l10n.register,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextButton(
                        onPressed: () =>
                            setState(() => isLogin = !isLogin),
                        child: Text(
                          isLogin
                              ? l10n.createAnAccount
                              : l10n.alreadyHaveAccount,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  l10n.quickLogin,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _quickButton(
                        "user",
                            () => _quickLogin("dm3348412@gmail.com")),
                    _quickButton(
                        "firmowner",
                            () => _quickLogin("dm3348413@gmail.com")),
                    _quickButton(
                        "admin",
                            () => _quickLogin("dm3348411@gmail.com")),
                    _quickButton(
                      "firmworker",
                      () => _quickLogin(
                        "dmytromorozov57@gmail.com",
                        password: "dmytromorozov57@gmail.com",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.black54),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _quickButton(String text, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
