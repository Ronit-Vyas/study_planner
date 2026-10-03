import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
<<<<<<< HEAD
=======
import '../../theme/app_text_styles.dart';
import '../../utils/constants.dart';
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
import '../home/home_screen.dart';

import '../../utils/constants.dart';
import '../../widgets/common/grouped_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      await AuthService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidLength = passwordController.text.length >= 6;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
<<<<<<< HEAD
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Start planning your studies.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GroupedCard(
                      children: [
                        GroupedRow(
                          label: 'Name',
                          child: TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Your name',
                              hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              isDense: true,
                              filled: false,
                            ),
                            validator: (value) => value == null || value.trim().isEmpty
                                ? 'Enter your name'
                                : null,
                          ),
                        ),
                        GroupedRow(
                          label: 'Email',
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'you@example.com',
                              hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              isDense: true,
                              filled: false,
                            ),
                            validator: (value) => value == null || !value.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ),
                        ),
                        GroupedRow(
                          label: 'Password',
                          trailing: IconButton(
                            iconSize: 20,
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.mutedText,
                            ),
                          ),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: obscure,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'At least 6 characters',
                              hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              isDense: true,
                              filled: false,
                            ),
                            validator: (value) => value == null || value.length < 6
                                ? 'Use at least 6 characters'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: hasValidLength ? AppColors.primary : AppColors.mutedText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Password must be at least 6 characters',
                          style: TextStyle(
                            color: hasValidLength ? AppColors.text : AppColors.mutedText,
                            fontSize: 12.5,
                            fontWeight: hasValidLength ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF081C10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: loading ? null : register,
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF081C10),
                                ),
                              )
                            : const Text('Create account'),
                      ),
=======
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 20,
                      offset: Offset(0, 8),
>>>>>>> 788069d ([fix] UI theme & [imp] Exam Management & Streak Tracking)
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Create Account', style: AppTextStyles.hero),
                      const SizedBox(height: 4),
                      const Text(
                        'Set up your study profile and start planning courses.',
                        style: AppTextStyles.muted,
                      ),
                      const SizedBox(height: 24),

                      _inputLabel('FULL NAME'),
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Ronit Vyas',
                          prefixIcon: Icon(Icons.person_outline, color: AppColors.mutedText, size: 20),
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      _inputLabel('EMAIL ADDRESS'),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.mutedText, size: 20),
                        ),
                        validator: (value) => value == null || !value.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      _inputLabel('PASSWORD'),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: 'At least 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedText, size: 20),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.mutedText,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 6
                            ? 'Password must have at least 6 characters'
                            : null,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : register,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?', style: AppTextStyles.muted),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.label.copyWith(fontSize: 11)),
    );
  }
}
