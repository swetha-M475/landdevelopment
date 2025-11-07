import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../widgets/feature_selection_card.dart';
import '../widgets/image_picker_widget.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form Controllers - Page 1: Location Details
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _nearbyTownController = TextEditingController();
  final TextEditingController _talukController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _mapLocationController = TextEditingController();

  // Date and Status
  DateTime? _selectedDate;
  String? _selectedStatus;
  final List<String> _statusOptions = [
    'Planning',
    'In Progress',
    'Completed',
    'On Hold'
  ];

  // Page 2: Feature Selection
  String? _selectedFeature; // lingam, avudai, nandhi
  
  // Lingam Details
  String? _lingamType; // old or new
  String? _lingamDimension;
  final TextEditingController _customDimensionController = TextEditingController();
  final TextEditingController _lingamAmountController = TextEditingController();

  final List<Map<String, dynamic>> _predefinedDimensions = [
    {'name': '2 feet', 'amount': 50000},
    {'name': '3 feet', 'amount': 75000},
    {'name': '4 feet', 'amount': 100000},
  ];

  // Page 3: Contact & Images
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _estimatedAmountController = TextEditingController();
  
  List<String> _selectedImages = []; // Will store image paths

  bool _isLoading = false;

  @override
  void dispose() {
    _placeController.dispose();
    _nearbyTownController.dispose();
    _talukController.dispose();
    _districtController.dispose();
    _mapLocationController.dispose();
    _customDimensionController.dispose();
    _lingamAmountController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _estimatedAmountController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _placeController.text.isNotEmpty &&
            _nearbyTownController.text.isNotEmpty &&
            _talukController.text.isNotEmpty &&
            _districtController.text.isNotEmpty &&
            _mapLocationController.text.isNotEmpty &&
            _selectedDate != null &&
            _selectedStatus != null;
      case 1:
        if (_selectedFeature == null) return false;
        if (_selectedFeature == 'lingam') {
          if (_lingamType == null) return false;
          if (_lingamType == 'new') {
            return _lingamDimension != null && _lingamAmountController.text.isNotEmpty;
          }
        }
        return true;
      case 2:
        return _contactNameController.text.isNotEmpty &&
            _contactPhoneController.text.isNotEmpty &&
            _estimatedAmountController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createProject() async {
    if (!_validateCurrentPage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Add Firebase logic here
    // For now, just simulate a delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Project created successfully! (Frontend only)'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Project',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.secondary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.7),
              AppColors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildLocationPage(),
                  _buildFeaturePage(),
                  _buildContactPage(),
                ],
              ),
            ),

            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildProgressStep(0, 'Location'),
          _buildProgressLine(0),
          _buildProgressStep(1, 'Feature'),
          _buildProgressLine(1),
          _buildProgressStep(2, 'Details'),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    final isActive = _currentPage >= step;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondary : AppColors.greyLight.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: GoogleFonts.poppins(
                color: isActive ? AppColors.white : AppColors.greyDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isActive ? AppColors.secondary : AppColors.greyDark,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int step) {
    final isActive = _currentPage > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? AppColors.secondary : AppColors.greyLight.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Details',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the project location information',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.greyDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: _placeController,
            label: 'Place',
            icon: Icons.location_on_outlined,
            hint: 'Enter place name',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _nearbyTownController,
            label: 'Nearby Town',
            icon: Icons.location_city_outlined,
            hint: 'Enter nearby town',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _talukController,
            label: 'Taluk',
            icon: Icons.map_outlined,
            hint: 'Enter taluk',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _districtController,
            label: 'District',
            icon: Icons.domain_outlined,
            hint: 'Enter district',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _mapLocationController,
            label: 'Map Location',
            icon: Icons.pin_drop_outlined,
            hint: 'Enter coordinates or Google Maps link',
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Date Picker
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.greyLight.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.greyDark.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date of Visit',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.greyDark.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          _selectedDate == null
                              ? 'Select date'
                              : DateFormat('dd MMM yyyy').format(_selectedDate!),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Status Dropdown
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(
                Icons.flag_outlined,
                color: AppColors.greyDark.withOpacity(0.6),
              ),
            ),
            items: _statusOptions.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Feature',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the main feature for this project',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.greyDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Feature Cards
          Row(
            children: [
              Expanded(
                child: FeatureSelectionCard(
                  title: 'Lingam',
                  icon: Icons.account_balance,
                  isSelected: _selectedFeature == 'lingam',
                  onTap: () {
                    setState(() {
                      _selectedFeature = 'lingam';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FeatureSelectionCard(
                  title: 'Avudai',
                  icon: Icons.architecture,
                  isSelected: _selectedFeature == 'avudai',
                  onTap: () {
                    setState(() {
                      _selectedFeature = 'avudai';
                      _lingamType = null;
                      _lingamDimension = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FeatureSelectionCard(
            title: 'Nandhi',
            icon: Icons.pets,
            isSelected: _selectedFeature == 'nandhi',
            onTap: () {
              setState(() {
                _selectedFeature = 'nandhi';
                _lingamType = null;
                _lingamDimension = null;
              });
            },
          ),

          // Lingam Details (shown only when Lingam is selected)
          if (_selectedFeature == 'lingam') ...[
            const SizedBox(height: 32),
            Text(
              'Lingam Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),

            // Old or New
            Text(
              'Type',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.greyDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRadioOption('Old', 'old'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRadioOption('New', 'new'),
                ),
              ],
            ),

            // Show dimension options only for New
            if (_lingamType == 'new') ...[
              const SizedBox(height: 24),
              Text(
                'Dimensions',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Predefined dimensions
              ...(_predefinedDimensions.map((dim) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildDimensionOption(
                    dim['name'],
                    '₹${dim['amount']}',
                    dim['name'],
                  ),
                );
              })),

              // Custom dimension
              _buildDimensionOption('Others', 'Custom', 'custom'),

              if (_lingamDimension == 'custom') ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _customDimensionController,
                  label: 'Custom Dimension',
                  icon: Icons.straighten,
                  hint: 'e.g., 5 feet x 3 feet',
                ),
              ],

              const SizedBox(height: 16),
              _buildTextField(
                controller: _lingamAmountController,
                label: 'Amount Needed',
                icon: Icons.currency_rupee,
                hint: 'Enter amount',
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact & Details',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add local contact and project images',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.greyDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Local Contact Person',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _contactNameController,
            label: 'Contact Name',
            icon: Icons.person_outline,
            hint: 'Enter contact person name',
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _contactPhoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          Text(
            'Project Images',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload up to 5 images',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.greyDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),

          ImagePickerWidget(
            maxImages: 5,
            onImagesSelected: (images) {
              setState(() {
                _selectedImages = images;
              });
            },
          ),

          const SizedBox(height: 24),

          _buildTextField(
            controller: _estimatedAmountController,
            label: 'Estimated Total Amount',
            icon: Icons.account_balance_wallet_outlined,
            hint: 'Enter total estimated amount',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: AppColors.greyDark.withOpacity(0.6),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  Widget _buildRadioOption(String title, String value) {
    final isSelected = _lingamType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _lingamType = value;
          _lingamDimension = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.1)
              : AppColors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.greyLight.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.secondary : AppColors.greyDark,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.secondary : AppColors.greyDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionOption(String title, String subtitle, String value) {
    final isSelected = _lingamDimension == value;
    return InkWell(
      onTap: () {
        setState(() {
          _lingamDimension = value;
          if (value != 'custom') {
            final dim = _predefinedDimensions.firstWhere(
              (d) => d['name'] == value,
              orElse: () => {'amount': 0},
            );
            _lingamAmountController.text = dim['amount'].toString();
          } else {
            _lingamAmountController.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.1)
              : AppColors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.greyLight.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.secondary : AppColors.greyDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.secondary : AppColors.greyDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.greyDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.greyLight),
                ),
                child: Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: () {
                if (!_validateCurrentPage()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please fill all required fields'),
                      backgroundColor: AppColors.warning,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }

                if (_currentPage < 2) {
                  _nextPage();
                } else {
                  _createProject();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentPage < 2 ? 'Next' : 'Create Project',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}