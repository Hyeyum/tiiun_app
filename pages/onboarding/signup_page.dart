import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:tiiun/design_system/colors.dart';
import 'package:tiiun/design_system/typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tiiun/services/auth_service.dart'; // Use AuthService via provider
import 'package:tiiun/utils/error_handler.dart'; // Import ErrorHandler

class SignupPage extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState(); // Changed to ConsumerState
}

class _SignupPageState extends ConsumerState<SignupPage> {
  int _currentStep = 1;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordConfirmValid = false;
  bool _isNicknameValid = false;
  String? _emailError;
  String? _passwordError;
  String? _passwordConfirmError;
  String? _nicknameError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _passwordConfirmController.addListener(_validateForm);
    _nicknameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
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

      String passwordConfirm = _passwordConfirmController.text;
      if (passwordConfirm.isEmpty) {
        _isPasswordConfirmValid = false;
        _passwordConfirmError = null;
      } else if (passwordConfirm != password) {
        _isPasswordConfirmValid = false;
        _passwordConfirmError = '비밀번호가 일치하지 않습니다';
      } else {
        _isPasswordConfirmValid = true;
        _passwordConfirmError = null;
      }

      String nickname = _nicknameController.text.trim();
      if (nickname.isEmpty) {
        _isNicknameValid = false;
        _nicknameError = null;
      } else if (nickname.length < 2) {
        _isNicknameValid = false;
        _nicknameError = '닉네임은 최소 2자 이상이어야 합니다';
      } else {
        _isNicknameValid = true;
        _nicknameError = null;
      }
    });
  }

  bool get _isFormValid => _isEmailValid && _isPasswordValid && _isPasswordConfirmValid && _isNicknameValid;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider); // Access AuthService via ref
      final userModel = await authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nicknameController.text.trim(),
      );

      if (userModel != null) {
        if (mounted) {
          _nextStep();
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('회원가입에 실패했습니다. 다시 시도해주세요.');
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
        _showErrorSnackBar('회원가입 중 알 수 없는 오류가 발생했습니다: ${e.toString()}');
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

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWithTitle(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Adjusted for better centering
                    Text(
                      '이메일',
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
                    const SizedBox(height: 28),
                    Text(
                      '비밀번호',
                      style: AppTypography.b2.withColor(AppColors.grey900,),
                    ),
                    const SizedBox(height: 4),
                    _buildPasswordField(),
                    if (_passwordError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _passwordError!,
                        style: AppTypography.c1.withColor(AppColors.point900,),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      '비밀번호 확인',
                      style: AppTypography.b2.withColor(AppColors.grey900,),
                    ),
                    const SizedBox(height: 4),
                    _buildPasswordConfirmField(),
                    if (_passwordConfirmError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _passwordConfirmError!,
                        style: AppTypography.c1.withColor(AppColors.point900,),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      '닉네임',
                      style: AppTypography.b2.withColor(AppColors.grey900,),
                    ),
                    const SizedBox(height: 4),
                    _buildTextFormField(
                      controller: _nicknameController,
                      hintText: '닉네임 입력 (한글, 영문, 숫자)',
                      hasError: _nicknameError != null,
                      isValid: _isNicknameValid,
                    ),
                    if (_nicknameError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _nicknameError!,
                        style: AppTypography.c1.withColor(AppColors.point900,),
                      ),
                    ],
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Adjusted for better centering
                  ],
                ),
              ),
            ),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: 20,
          child: Text(
            "환영해요!\n틔운버디와 추억을 만들어요",
            style: AppTypography.h4.copyWith(
              color: AppColors.grey900,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              Center(
                child: Image.asset(
                  'assets/images/illust_welcome.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()),
              _buildStartButton(),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderWithTitle() {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back_ios),
              iconSize: 20,
              color: AppColors.grey700,
            ),
          ),
          Center(
            child: Text(
              '회원가입',
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

    return TextFormField(
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
              hintText: '비밀번호 입력 (숫자, 영문 포함 8자 이상)',
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
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(AppColors.grey500, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordConfirmField() {
    Color getBorderColor() {
      if (_passwordConfirmError != null) return AppColors.point800;
      if (_isPasswordConfirmValid) return AppColors.main700;
      return AppColors.grey300;
    }

    return SizedBox(
      height: 48,
      child: Stack(
        children: [
          TextFormField(
            controller: _passwordConfirmController,
            obscureText: _obscurePasswordConfirm,
            style: AppTypography.b2,
            decoration: InputDecoration(
              hintText: '동일한 비밀번호 입력',
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
                  _obscurePasswordConfirm = !_obscurePasswordConfirm;
                });
              },
              child: SvgPicture.asset(
                _obscurePasswordConfirm
                    ? 'assets/icons/functions/icon_dontshow.svg'
                    : 'assets/icons/functions/icon_show.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(AppColors.grey500, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (_isFormValid && !_isLoading) ? _handleSignUp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid ? AppColors.main700 : AppColors.grey400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(
          '가입하기',
          style: AppTypography.largeBtn.withColor(
            _isFormValid ? Colors.white : AppColors.grey500,
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _navigateToHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.main700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '시작하기',
          style: AppTypography.largeBtn.withColor(Colors.white,),
        ),
      ),
    );
  }
}