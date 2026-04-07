import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController(
    text: 'arnihal@gmail.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '***********',
  );
  final TextEditingController _pincodeController = TextEditingController(
    text: '450116',
  );
  final TextEditingController _addressController = TextEditingController(
    text: "tongir mazar boosti,",
  );
  final TextEditingController _cityController = TextEditingController(
    text: 'sengarchor',
  );
  final TextEditingController _countryController = TextEditingController(
    text: 'bangudesh',
  );
  final TextEditingController _bankAccountController = TextEditingController(
    text: '204356XXXXXXX',
  );
  final TextEditingController _accountHolderController = TextEditingController(
    text: 'Nihall the boss',
  );
  final TextEditingController _ifscController = TextEditingController(
    text: 'SBIN00428',
  );

  final List<String> _stateOptions = [
    'N1 2LL',
    'N2 8AB',
    'EC1A 1BB',
    'W1A 0AX',
  ];

  String _selectedState = 'N1 2LL';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bankAccountController.dispose();
    _accountHolderController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF111111), width: 1.1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF2C2C2C),
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            decoration: _inputDecoration(),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _dropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('State'),
          DropdownButtonFormField<String>(
            value: _selectedState,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 28,
              color: Color(0xFF9A9A9A),
            ),
            decoration: _inputDecoration(),
            dropdownColor: Colors.white,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            items: _stateOptions
                .map(
                  (state) => DropdownMenuItem<String>(
                    value: state,
                    child: Text(
                      state,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedState = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _saveDetails() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),

                const SizedBox(height: 22),

                /// Avatar
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 116,
                        width: 116,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD95F5F),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: 4,
                        child: Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4F8DF7),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _sectionTitle('Personal Details'),
                const SizedBox(height: 18),

                _textField(
                  label: 'Email Address',
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                ),

                _textField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Change Password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF4A68),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFFF4A68),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                const Divider(color: Color(0xFFD8D8D8), height: 1),
                const SizedBox(height: 32),

                _sectionTitle('Business Address Details'),
                const SizedBox(height: 18),

                _textField(
                  label: 'Pincode',
                  controller: _pincodeController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Pincode is required';
                    }
                    return null;
                  },
                ),

                _textField(
                  label: 'Address',
                  controller: _addressController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),

                _textField(
                  label: 'City',
                  controller: _cityController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),

                _dropdownField(),

                _textField(
                  label: 'Country',
                  controller: _countryController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Country is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFFD8D8D8), height: 1),
                const SizedBox(height: 32),

                _sectionTitle('Bank Account Details'),
                const SizedBox(height: 18),

                _textField(
                  label: 'Bank Account Number',
                  controller: _bankAccountController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bank account number is required';
                    }
                    return null;
                  },
                ),

                _textField(
                  label: "Account Holder’s Name",
                  controller: _accountHolderController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Account holder name is required';
                    }
                    return null;
                  },
                ),

                _textField(
                  label: 'IFSC Code',
                  controller: _ifscController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'IFSC code is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B63),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
