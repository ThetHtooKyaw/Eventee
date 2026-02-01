import 'package:eventee/core/themes/app_color.dart';
import 'package:eventee/core/themes/app_format.dart';
import 'package:eventee/core/widgets/bottom_nav_bar.dart';
import 'package:eventee/src/auth/view_models/params/signup_params.dart';
import 'package:eventee/src/auth/views/login_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventee/src/auth/view_models/signup_view_model.dart';
import 'package:eventee/core/widgets/loading_column.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      // backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppFormat.primaryPadding,
            vertical: AppFormat.secondaryPadding,
          ),
          child: Consumer<SignUpViewModel>(
            builder: (context, vm, _) {
              if (vm.authError != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.authError!.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                  vm.clearAuthError();
                });
              }

              if (vm.loading) {
                return LoadingColumn(message: 'Signing up');
              }

              return Column(
                children: [
                  // Image
                  Image.asset(
                    'assets/images/sign_up.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text("Unlock the Future of", style: t.textTheme.displayLarge),
                  const SizedBox(height: 10),
                  Text(
                    "Event Booking App",
                    style: t.textTheme.displayLarge?.copyWith(
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppFormat.primaryPadding,
                    ),
                    child: Text(
                      "Discover, book, and experience unforgettable moments effortlessly",
                      textAlign: TextAlign.center,
                      style: t.textTheme.titleSmall?.copyWith(
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Text Fields
                  _buildSignUpForm(context),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppFormat.primaryPadding,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await vm.createUser(
                          params: SignUpParams(
                            username: nameController.text.trim(),
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                            phoneNumber: phoneNumberController.text.trim(),
                            address: addressController.text.trim(),
                          ),
                        );

                        await Future.delayed(Duration(milliseconds: 500));

                        if (vm.authError == null && mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavBar(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                      child: Text("Sign up"),
                    ),
                  ),
                  SizedBox(height: 20),

                  Divider(),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppFormat.primaryPadding,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await vm.signUpWithGoogle();

                        await Future.delayed(Duration(milliseconds: 500));

                        if (vm.authError == null && mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BottomNavBar(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 60),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/google.png',
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 20),
                          Text("Sign up with Google"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginView(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: nameController,
            keyboardType: TextInputType.name,
            decoration: InputDecoration(labelText: "Name"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Email"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: phoneNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Phone Number"),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: addressController,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
            decoration: InputDecoration(labelText: "Address"),

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: passwordController,
            keyboardType: TextInputType.text,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              if (value.trim().length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          TextFormField(
            controller: confirmPasswordController,
            keyboardType: TextInputType.text,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your confirm password';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
