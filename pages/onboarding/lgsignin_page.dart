import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/services/auth_service.dart'; // Use AuthService via provider
import 'package:tiiun/utils/error_handler.dart'; // Import ErrorHandler

class LGSigninPage extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const LGSigninPage({super.key});

  @override
  ConsumerState<LGSigninPage> createState() => _LGSigninPageState(); // Changed to ConsumerState
}

class _LGSigninPageState extends ConsumerState<LGSigninPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      String email = _emailController.text.trim();
      if (email.isEmpty) {
        _isEmailValid = false;
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _isEmailValid = false;
        _emailError = '이메일 형식을 확인해주세요';
      } else {
        _isEmailValid = true;
        _emailError = null;
      }

      String password = _passwordController.text;
      if (password.isEmpty) {
        _isPasswordValid = false;
        _passwordError = null;
      } else if (password.length < 8) {
        _isPasswordValid = false;
        _passwordError = '비밀번호는 최소 8자 이상이어야 합니다';
      } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
        _isPasswordValid = false;
        _passwordError = '영문과 숫자를 포함해야 합니다';
      } else {
        _isPasswordValid = true;
        _passwordError = null;
      }
    });
  }

  bool get _isFormValid => _isEmailValid && _isPasswordValid;

  Future<void> _handleSignIn() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider); // Access AuthService via ref
      final userCredential = await authService.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (userCredential.user != null) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.');
        }
      }
    } on FirebaseAuthException catch (e) {
      final appError = ErrorHandler.handleException(e); // Use ErrorHandler
      if (mounted) {
        _showErrorSnackBar(appError.message);
      }
    } on AppError catch (e) { // Catch custom AppError
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('로그인 중 알 수 없는 오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.b2),
        backgroundColor: AppColors.point900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID',
                        style: AppTypography.b2.withColor(AppColors.grey800,),
                      ),
                      const SizedBox(height: 4),
                      _buildTextFormField(
                        controller: _emailController,
                        hintText: '이메일 입력',
                        keyboardType: TextInputType.emailAddress,
                        hasError: _emailError != null,
                        isValid: _isEmailValid,
                      ),
                      if (_emailError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _emailError!,
                          style: AppTypography.c1.withColor(AppColors.point900,),
                        ),
                      ],
                      const SizedBox(height: 29.5),
                      Text(
                        'PASSWORD',
                        style: AppTypography.b2.withColor(AppColors.grey900,),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      if (_passwordError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _passwordError!,
                          style: AppTypography.c1.withColor(AppColors.point900,),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 20,
              color: AppColors.grey700,
            ),
          ),
          Center(
            child: Text(
              'LG 계정 로그인',
              style: AppTypography.b2.withColor(AppColors.grey900,),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool hasError = false,
    bool isValid = false,
  }) {
    Color getBorderColor() {
      if (hasError) return AppColors.point800;
      if (isValid) return AppColors.main700;
      return AppColors.grey300;
    }

    return SizedBox(
      height: 48,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTypography.b1,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.b1.withColor(AppColors.grey400,),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: getBorderColor(),
              width: 1.5,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: getBorderColor(),
              width: 1.5,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: getBorderColor(),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 8),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    Color getBorderColor() {
      if (_passwordError != null) return AppColors.point800;
      if (_isPasswordValid) return AppColors.main700;
      return AppColors.grey300;
    }

    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: AppTypography.b2,
            decoration: InputDecoration(
              hintText: '패스워드 입력',
              hintStyle: AppTypography.b1.withColor(AppColors.grey400,),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: getBorderColor(),
                  width: 1.5,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: getBorderColor(),
                  width: 1.5,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: getBorderColor(),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.only(left: 8),
            ),
          ),
          Positioned(
            right: 0,
            top: 12,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              child: SvgPicture.asset(
                _obscurePassword
                    ? 'assets/icons/functions/icon_dontshow.svg'
                    : 'assets/icons/functions/icon_show.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(AppColors.grey500, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (_isFormValid && !_isLoading) ? _handleSignIn : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid ? AppColors.main700 : AppColors.grey200,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
          '로그인',
          style: AppTypography.largeBtn.withColor(
            _isFormValid ? Colors.white : AppColors.grey400,
          ),
        ),
      ),
    );
  }
}