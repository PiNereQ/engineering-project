import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proj_inz/bloc/coupon_add/coupon_add_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/text_formatters.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/bloc/shop/shop_bloc.dart';
import 'package:proj_inz/data/models/shop_model.dart';
import 'package:proj_inz/data/repositories/shop_repository.dart';
import 'package:proj_inz/presentation/screens/legal_document_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/help/help_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_icon_button.dart';
import 'package:proj_inz/presentation/screens/coupon_image_scan_screen.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/search_button.dart';
import 'package:proj_inz/presentation/widgets/input/custom_date_picker_dialog.dart';
import '../widgets/input/text_fields/labeled_text_field.dart';
import '../widgets/input/text_fields/search_bar.dart';
import '../widgets/input/buttons/checkbox.dart';
import '../widgets/input/buttons/radio_button.dart';
import '../widgets/input/buttons/custom_text_button.dart';

enum CouponType { percent, fixed }

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

const double _dialogWidth = 360;
const double _dialogMinHeight = 80;

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  // Controllers for text fields
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _reductionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _expiryDate;
  Shop? _selectedShop;
  String? _shopSearchQuery;
  CouponType _selectedType = CouponType.percent;
  bool _hasExpiryDate = true;
  bool _inPhysicalStores = false;
  bool _inOnlineStore = false;
  bool _hasRestrictions = false; // null = brak wyboru, true = tak, false = nie
  bool _isMultipleUse = false;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _couponImage;

  bool _userMadeInput = false;
  bool _showMissingValuesTip = false;
  bool _showUsageLocationTip = false;
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _couponImage = image;
          _userMadeInput = true;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Image pick failed: $e');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: CustomTextButton(
                  width: 300,
                  icon: const Icon(Icons.photo_camera),
                  label: 'Zrób zdjęcie',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.camera);
                  },
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: CustomTextButton(
                  width: 300,
                  icon: const Icon(Icons.photo_library),
                  label: 'Wybierz z galerii',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _priceController.dispose();
    _expiryDateController.dispose();
    _codeController.dispose();
    _reductionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> showShopSearchDialog(BuildContext parentContext) async {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          String? localQuery = _shopSearchQuery;
          return BlocProvider(
            create: (context) => ShopBloc(context.read<ShopRepository>()),
            child: AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(width: 2, color: AppColors.textPrimary),
              ),
              title: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      'Wyszukaj sklep',
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  CustomIconButton.small(
                    icon: Icon(Icons.close),
                    onTap: () {
                      setState(() {
                        _shopSearchQuery = null;
                      });
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ]
              ),
              content: SizedBox(
                width: 400,
                child: BlocBuilder<ShopBloc, ShopState>(
                  builder: (blocContext, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        SearchBarWide(
                          hintText: 'Wyszukaj sklep...',
                          controller: TextEditingController(text: localQuery),
                          onSubmitted: (query) {
                            blocContext.read<ShopBloc>().add(
                              SearchShopsByName(query),
                            );
                            setState(() {
                              _shopSearchQuery = query;
                            });
                          },
                        ),
                        if (state is ShopLoading &&
                            _shopSearchQuery != null &&
                            _shopSearchQuery!.isNotEmpty)
                          Center(
                            child: const CircularProgressIndicator(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (state is ShopLoaded) Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (state is ShopLoaded)
                          if (state.shops.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  'Nie znaleziono sklepów.',
                                  style: TextStyle(
                                    fontFamily: 'Itim',
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            SingleChildScrollView(
                              child: Column(
                                spacing: 8,
                                children: [
                                  ...[
                                    ...state.shops.map(
                                      (shop) => Container(
                                        decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        border: Border.all(
                                          color:
                                              _selectedShop?.id != shop.id
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                _selectedShop?.id != shop.id
                                                    ? AppColors.textPrimary
                                                    : AppColors.textSecondary,
                                            offset: const Offset(2, 2),
                                            blurRadius: 0,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          shop.name,
                                          style: TextStyle(
                                            fontFamily: 'Itim',
                                            fontSize: 18,
                                            color:
                                                _selectedShop?.id != shop.id
                                                    ? AppColors.textPrimary
                                                    : AppColors.textSecondary,
                                          ),
                                        ),
                                        trailing: Icon(
                                          _selectedShop?.id == shop.id
                                              ? Icons.check_circle_outline
                                              : Icons.arrow_forward_outlined,
                                          color:
                                              _selectedShop?.id != shop.id
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                        ),
                                        onTap: () {
                                          if (_selectedShop?.id != shop.id) {
                                            setState(() {
                                              _shopSearchQuery = null;
                                              _selectedShop = shop;
                                              _userMadeInput = true;
                                            });
                                            Navigator.of(dialogContext).pop();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                              if (state is ShopError)
                                const Text("Błąd podczas ładowania sklepów."),
                                                        ],
                                                      ),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    backDialog() {
      return showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(width: 2, color: AppColors.textPrimary),
              ),
              title: const Text(
                'Potwierdzenie',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              content: const Text(
                'Czy na pewno chcesz opuścić ekran dodawania kuponu? Wprowadzone dane zostaną utracone.',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                CustomTextButton.small(
                  label: 'Anuluj',
                  width: 100,
                  onTap: () => Navigator.of(context).pop(),
                ),
                CustomTextButton.primarySmall(
                  label: 'Tak',
                  width: 100,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    }

    return BlocListener<CouponAddBloc, CouponAddState>(
      listener: (context, state) {
        if (state is CouponAddSuccess) {
          showDialog(
            context: context,
            builder: (_) => appDialog(
              title: 'Sukces',
              content: 'Kupon został dodany.',
              actions: [
                CustomTextButton.primarySmall(
                  label: 'OK',
                  width: 100,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        } else if (state is CouponAddFailure) {
          _focusScopeNode.unfocus();
          showCustomSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth =
                  constraints.maxWidth < 800 ? constraints.maxWidth : 800;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomIconButton(
                              icon: SvgPicture.asset('assets/icons/back.svg'),
                              onTap: () {
                                if (_userMadeInput) {
                                  backDialog();
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                            HelpButton(
                              title: "Pomoc - Dodawanie kuponu",
                              body: _HelpBody(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: maxWidth,
                        decoration: ShapeDecoration(
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 2,
                              color: AppColors.textPrimary,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: AppColors.textPrimary,
                              blurRadius: 0,
                              offset: Offset(4, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: FocusScope(
                          node: _focusScopeNode,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Tytul
                                      const SizedBox(
                                        width: 332,
                                        child: Text(
                                          'Dodaj kupon',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 24,
                                            fontFamily: 'Itim',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      SearchButtonWide(
                                        label:
                                            _selectedShop == null
                                                ? 'Wyszukaj sklep...'
                                                : 'Zmień sklep',
                                        onTap:
                                            () => showShopSearchDialog(
                                              context,
                                            ),
                                      ),
                                        if (_selectedShop != null) ...[
                                        const SizedBox(height: 12),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Wybrany sklep: ',
                                              style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18,
                                                color: AppColors.textPrimary,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: _selectedShop!.name,
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontFamily: 'Itim',
                                                    fontSize: 18,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 18),
                                      // Cena i Data waznosci
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          LabeledTextField(
                                            label: 'Cena',
                                            placeholder: 'Wpisz cenę',
                                            width: LabeledTextFieldWidth.half,
                                            iconOnLeft: true,
                                            controller: _priceController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [PriceFormatter()],
                                            suffix: Text('zł'),
                                            validator: (val) {
                                              if (val == null || val.isEmpty) {
                                                return 'Wymagane';
                                              }

                                              final normalized = val.replaceAll(
                                                ',',
                                                '.',
                                              );

                                              if (double.tryParse(normalized) ==
                                                  null) {
                                                return 'Niepoprawna liczba';
                                              }
                                              // Check for at most 2 decimal places (grosze)
                                              final parts = normalized.split(
                                                '.',
                                              );
                                              if (parts.length > 1 &&
                                                  parts[1].length > 2) {
                                                return 'Cena może mieć maksymalnie 2 miejsca po przecinku';
                                              }
                                              if (double.tryParse(
                                                    normalized,
                                                  )! <=
                                                  2) {
                                                return 'Wpisz więcej niż 2';
                                              }
                                              return null;
                                            },
                                            onChanged: (val) {
                                              setState(() {
                                                _userMadeInput = true;
                                              });
                                            },
                                          ),
                                          GestureDetector(
                                            onTap: !_hasExpiryDate
                                                ? null
                                                : () async {
                                                    DateTime now = DateTime.now();
                                                    DateTime today = DateTime(
                                                      now.year,
                                                      now.month,
                                                      now.day,
                                                    );

                                                    final DateTime initialDate =
                                                        _expiryDateController.text.isNotEmpty
                                                            ? _expiryDate
                                                            : today;

                                                    final DateTime? pickedDate =
                                                        await showDialog<DateTime>(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (context) {
                                                        return CustomCalendarDatePickerDialog(
                                                          initialDate: initialDate,
                                                          firstDate: today,
                                                          lastDate: DateTime(2100),
                                                        );
                                                      },
                                                    );

                                                    if (pickedDate != null) {
                                                      setState(() {
                                                        _expiryDateController.text =
                                                            "${pickedDate.day.toString().padLeft(2, '0')}-"
                                                            "${pickedDate.month.toString().padLeft(2, '0')}-"
                                                            "${pickedDate.year}";
                                                        _expiryDate = pickedDate;
                                                        _userMadeInput = true;
                                                      });
                                                    }
                                                  },
                                            child: AbsorbPointer(
                                              child: LabeledTextField(
                                                label: 'Data ważności',
                                                placeholder: 'DD-MM-RRRR',
                                                enabled: _hasExpiryDate,
                                                width: LabeledTextFieldWidth.half,
                                                iconOnLeft: false,
                                                controller: _expiryDateController,
                                                keyboardType: TextInputType.datetime,
                                                validator: (val) {
                                                  if ((val == null || val.isEmpty) && _hasExpiryDate) {
                                                    return 'Wymagane';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      CustomCheckbox(
                                        label: 'Kupon nie ma daty ważności',
                                        selected: !_hasExpiryDate,
                                        onTap: () {
                                          setState(() {
                                            _hasExpiryDate = !_hasExpiryDate;

                                            if (!_hasExpiryDate) {
                                              _expiryDateController.clear();
                                            }

                                            _userMadeInput = true;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 18),

                                      // Kod kuponu
                                      LabeledTextField(
                                        label: 'Kod kuponu',
                                        placeholder: 'Wpisz kod kuponu',
                                        width: LabeledTextFieldWidth.full,
                                        iconOnLeft: true,
                                        controller: _codeController,
                                        maxLength: 50,
                                        onChanged: (val) {
                                          setState(() {
                                            _userMadeInput = true;
                                          });
                                        },
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Wymagane';
                                          }
                                          if (val.length > 50) {
                                            return 'Kod może mieć maksymalnie 50 znaków';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),

                                      // Info i przycisk "Dodaj zdjecie"
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.priority_high_rounded,
                                            size: 24,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Możesz dodać zdjęcie, aby zeskanować z niego kod kuponu (w formie tekstu, kodu kreskowego lub kodu QR).',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14,
                                                fontFamily: 'Itim',
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LayoutBuilder(
                                        builder: (context, c) {
                                          final w = c.maxWidth;

                                          final twoButtons =
                                              _couponImage != null;

                                          final outerExtra =
                                              twoButtons ? 8.0 : 4.0;

                                          final spacing = 10.0;

                                          final buttonWidth =
                                              twoButtons
                                                  ? (w - spacing - outerExtra) /
                                                      2
                                                  : 160.0;

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CustomTextButton.primary(
                                                height: 52,
                                                width: buttonWidth,
                                                label:
                                                    _couponImage == null
                                                        ? 'Dodaj zdjęcie'
                                                        : 'Zmień zdjęcie',
                                                onTap:
                                                    _showImageSourceActionSheet,
                                              ),
                                              if (twoButtons) ...[
                                                SizedBox(width: spacing),
                                                CustomTextButton(
                                                  height: 52,
                                                  width: buttonWidth,
                                                  label: 'Usuń zdjęcie',
                                                  onTap:
                                                      () => setState(() {
                                                        _couponImage = null;
                                                      }),
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      if (_couponImage != null)
                                        Center(
                                          child: GestureDetector(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColors.textPrimary,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        AppColors.textPrimary,
                                                    offset: const Offset(4, 4),
                                                    blurRadius: 0,
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    Image.file(
                                                      File(_couponImage!.path),
                                                      height: 120,
                                                      width: 120,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
                                                      child: DecoratedIcon(
                                                        decoration:
                                                            IconDecoration(
                                                              border: IconBorder(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                width: 3,
                                                              ),
                                                            ),
                                                        icon: Icon(
                                                          Icons.qr_code_scanner,
                                                          color: Colors.white,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              if (_couponImage == null) {
                                                return;
                                              }

                                              final scannedValue =
                                                  await Navigator.of(
                                                    context,
                                                  ).push<String>(
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              CouponImageScanScreen(
                                                                imagePath:
                                                                    _couponImage!
                                                                        .path,
                                                              ),
                                                    ),
                                                  );

                                              if (scannedValue != null &&
                                                  scannedValue
                                                      .trim()
                                                      .isNotEmpty) {
                                                final trimmed =
                                                    scannedValue.trim();

                                                setState(() {
                                                  _codeController.text =
                                                      trimmed.length > 50
                                                          ? trimmed.substring(
                                                            0,
                                                            50,
                                                          )
                                                          : trimmed;
                                                  _userMadeInput = true;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      const SizedBox(height: 18),

                                      // Typ kuponu (radiobuttony) - stan zmienia textfield, TODO: bloc event
                                      const Text(
                                        'Typ kuponu',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomRadioButton(
                                                  label: 'rabat -%',
                                                  selected:
                                                      _selectedType ==
                                                      CouponType.percent,
                                                  onTap: () {
                                                    setState(() {
                                                      _reductionController
                                                          .text = '';
                                                      _selectedType =
                                                          CouponType.percent;
                                                      _userMadeInput = true;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 12),
                                                CustomRadioButton(
                                                  label: 'rabat -zł',
                                                  selected:
                                                      _selectedType ==
                                                      CouponType.fixed,
                                                  onTap: () {
                                                    setState(() {
                                                      _reductionController
                                                          .text = '';
                                                      _selectedType =
                                                          CouponType.fixed;
                                                      _userMadeInput = true;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            flex: 1,
                                            child:
                                                _selectedType ==
                                                        CouponType.percent
                                                    ? LabeledTextField(
                                                      label: 'Procent rabatu',
                                                      width:
                                                          LabeledTextFieldWidth
                                                              .full,
                                                      textAlign:
                                                          TextAlign.right,
                                                      controller:
                                                          _reductionController,
                                                      inputFormatters: [
                                                        PercentFormatter(),
                                                      ],
                                                      suffix: Text('%'),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          _userMadeInput = true;
                                                        });
                                                      },
                                                      validator: (val) {
                                                        if (val == null ||
                                                            val.isEmpty) {
                                                          return 'Wymagane';
                                                        }

                                                        final normalized = val
                                                            .replaceAll(
                                                              ',',
                                                              '.',
                                                            );

                                                        if (double.tryParse(
                                                              normalized,
                                                            ) ==
                                                            null) {
                                                          return 'Niepoprawna liczba';
                                                        }
                                                        if (double.tryParse(
                                                              normalized,
                                                            )! <=
                                                            0) {
                                                          return 'Wpisz więcej niż 0';
                                                        }
                                                        if (double.tryParse(
                                                              normalized,
                                                            )! >
                                                            100) {
                                                          return 'Wpisz conajwyżej 100';
                                                        }
                                                        return null;
                                                      },
                                                    )
                                                    : LabeledTextField(
                                                      label: 'Kwota rabatu',
                                                      width:
                                                          LabeledTextFieldWidth
                                                              .full,
                                                      textAlign:
                                                          TextAlign.right,
                                                      controller:
                                                          _reductionController,
                                                      inputFormatters: [
                                                        PriceFormatter(),
                                                      ],
                                                      suffix: Text('zł'),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          _userMadeInput = true;
                                                        });
                                                      },
                                                      validator: (val) {
                                                        if (val == null ||
                                                            val.isEmpty) {
                                                          return 'Wymagane';
                                                        }

                                                        final normalized = val
                                                            .replaceAll(
                                                              ',',
                                                              '.',
                                                            );

                                                        if (double.tryParse(
                                                              normalized,
                                                            ) ==
                                                            null) {
                                                          return 'Niepoprawna liczba';
                                                        }
                                                        if (double.tryParse(
                                                              normalized,
                                                            )! <=
                                                            0) {
                                                          return 'Wpisz więcej niż 0';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                          ),
                                        ],
                                      ),
                                      // Czy wielokrotnego uzytku
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Czy kupon jest wielokrotnego użytku?',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 20,
                                        children: [
                                          CustomRadioButton(
                                            label: 'tak',
                                            selected: _isMultipleUse == true,
                                            onTap: () {
                                              setState(() {
                                                _isMultipleUse = true;
                                                _userMadeInput = true;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 4),
                                          CustomRadioButton(
                                            label: 'nie',
                                            selected: _isMultipleUse == false,
                                            onTap: () {
                                              setState(() {
                                                _isMultipleUse = false;
                                                _userMadeInput = true;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.priority_high_rounded,
                                            size: 24,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Zaznacz "tak" tylko wtedy, gdy masz pewność, że kupon może być użyty wielokrotnie. Spowoduje to, że będzie mógł być kupiony wielokrotnie przez różnych użytkowników.',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14,
                                                fontFamily: 'Itim',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Do wykorzystania w... (checkboxy)
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Do wykorzystania w:',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomCheckbox(
                                            label: 'w sklepach stacjonarnych',
                                            selected: _inPhysicalStores,
                                            onTap: () {
                                              setState(() {
                                                _inPhysicalStores =
                                                    !_inPhysicalStores;
                                                _userMadeInput = true;
                                              });
                                              setState(() {
                                                _showUsageLocationTip =
                                                    _inPhysicalStores ==
                                                        false &&
                                                    _inOnlineStore == false;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          CustomCheckbox(
                                            label: 'w sklepie internetowym',
                                            selected: _inOnlineStore,
                                            onTap: () {
                                              setState(() {
                                                _inOnlineStore =
                                                    !_inOnlineStore;
                                                _userMadeInput = true;
                                              });
                                              setState(() {
                                                _showUsageLocationTip =
                                                    _inPhysicalStores ==
                                                        false &&
                                                    _inOnlineStore == false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),

                                      if (_showUsageLocationTip)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            'Zaznacz przynajmniej jedną opcję.',
                                            style: TextStyle(
                                              color: AppColors.alertText,
                                              fontSize: 14,
                                              fontFamily: 'Itim',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(height: 24),

                                      // 8. Czy kupon ma ograniczenia (radiobuttony)
                                      const Text(
                                        'Czy Twój kupon ma ograniczenia?',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 18,
                                          fontFamily: 'Itim',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 20,
                                        children: [
                                          CustomRadioButton(
                                            label: 'tak',
                                            selected: _hasRestrictions == true,
                                            onTap: () {
                                              setState(() {
                                                _hasRestrictions = true;
                                                _userMadeInput = true;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          CustomRadioButton(
                                            label: 'nie',
                                            selected: _hasRestrictions == false,
                                            onTap: () {
                                              setState(() {
                                                _hasRestrictions = false;
                                                _userMadeInput = true;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.priority_high_rounded,
                                            size: 24,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              'Jeśli Twój kupon posiada ograniczenia tj. wyłączone produkty/kategorie z promocji - wypisz je w opisie!',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 14,
                                                fontFamily: 'Itim',
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),

                                      // 9. opis
                                      LabeledTextField(
                                        label: 'Opis',
                                        placeholder:
                                            'Np. kupon nie obejmuje produktów z kategorii Elektronika...',
                                        width: LabeledTextFieldWidth.full,
                                        maxLines: 6,
                                        maxLength: 255,
                                        textAlign: TextAlign.left,
                                        controller: _descriptionController,
                                        onChanged: (val) {
                                          setState(() {
                                            _userMadeInput = true;
                                          });
                                        },
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty &&
                                                  _hasRestrictions) {
                                            return 'Wpisz opis ograniczeń';
                                          }
                                          if (val.length > 255) {
                                            return 'Opis może mieć maksymalnie 255 znaków';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // separator
                                DashedSeparator(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 18.0,
                                    left: 24.0,
                                    right: 24.0,
                                    bottom: 24.0,
                                  ),
                                  child: Column(
                                    children: [
                                      if (_showMissingValuesTip) ...[
                                        const Text(
                                          'Uzupełnij brakujące pola, aby móc dodać kupon.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.alertText,
                                            fontSize: 16,
                                            fontFamily: 'Itim',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Prowizja serwisu wynosi 5% wartości sprzedanego kuponu. '
                                              'Kwota prowizji zostanie automatycznie potrącona przy sprzedaży.',
                                              textAlign: TextAlign.justify,
                                              style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 11. Przycisk dodaj
                                      const SizedBox(height: 12),
                                      CustomTextButton.primary(
                                        height: 56,
                                        width: double.infinity,
                                        label: 'Dodaj',
                                        onTap: () async {
                                          FocusScope.of(context).unfocus();

                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            if (!_inPhysicalStores &&
                                                !_inOnlineStore) {
                                              setState(() {
                                                _showUsageLocationTip = true;
                                              });
                                              return;
                                            }
                                            // Get current user ID
                                            final firebaseUser =
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser;
                                            if (firebaseUser == null) {
                                              setState(() {
                                                _showMissingValuesTip = true;
                                              });
                                              return;
                                            }

                                            // Ensure user exists in API database
                                            final userRepo =
                                                context.read<UserRepository>();
                                            try {
                                              await userRepo
                                                  .ensureUserExistsInApi(
                                                    firebaseUser.uid,
                                                    firebaseUser.email ?? '',
                                                    firebaseUser.displayName ??
                                                        'User',
                                                  );
                                            } catch (e) {
                                              if (mounted) {
                                                showCustomSnackBar(
                                                  context,
                                                  'Błąd synchronizacji użytkownika: $e',
                                                );
                                              }
                                              return;
                                            }

                                            // Format expiry date as YYYY-MM-DD or null
                                            String? expiryDateStr;
                                            if (_hasExpiryDate &&
                                                _expiryDateController
                                                    .text
                                                    .isNotEmpty) {
                                              expiryDateStr =
                                                  "${_expiryDate.year}-${_expiryDate.month.toString().padLeft(2, '0')}-${_expiryDate.day.toString().padLeft(2, '0')}";
                                            }

                                            final normalizedPrice =
                                                _priceController.text
                                                    .replaceAll(',', '.');

                                            double priceDouble =
                                                double.tryParse(
                                                  normalizedPrice,
                                                ) ??
                                                0;
                                            int priceInSmallestUnit =
                                                (priceDouble * 100).toInt();

                                            final normalizedDiscount =
                                                _reductionController.text
                                                    .replaceAll(',', '.');

                                            final offer = CouponOffer(
                                              description:
                                                  _descriptionController.text
                                                      .trim(),
                                              discount:
                                                  double.tryParse(
                                                    normalizedDiscount,
                                                  ) ??
                                                  0,
                                              isDiscountPercentage:
                                                  _selectedType ==
                                                  CouponType.percent,
                                              price: priceInSmallestUnit,
                                              code: _codeController.text,
                                              hasLimits: _hasRestrictions,
                                              worksOnline: _inOnlineStore,
                                              worksInStore: _inPhysicalStores,
                                              expiryDate: expiryDateStr,
                                              shopId:
                                                  int.tryParse(
                                                    _selectedShop?.id ?? '0',
                                                  ) ??
                                                  0,
                                              ownerId: firebaseUser.uid,
                                              isActive: true,
                                              isMultipleUse: _isMultipleUse,
                                            );

                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => appDialog(
                                                title: 'Potwierdzenie',
                                                content: 'Czy na pewno chcesz dodać ten kupon?',
                                                actions: [
                                                  CustomTextButton.small(
                                                    label: 'Anuluj',
                                                    width: 100,
                                                    onTap: () => Navigator.of(context).pop(false),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  CustomTextButton.primarySmall(
                                                    label: 'Dodaj',
                                                    width: 100,
                                                    onTap: () => Navigator.of(context).pop(true),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirmed == true) {
                                              context.read<CouponAddBloc>().add(
                                                AddCouponOffer(offer),
                                              );
                                            }
                                          } else {
                                            setState(() {
                                              _showMissingValuesTip = true;
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 4,
                                        runSpacing: 2,
                                        children: [
                                          const Text(
                                            'Dodając kupon, akceptujesz',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontFamily: 'Itim',
                                            ),
                                          ),
                                          _FooterLink(
                                            label: 'regulamin',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const LegalDocumentScreen(
                                                    title: 'Regulamin',
                                                    assetPath: 'assets/legal/regulamin.md',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const Text(
                                            'oraz',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontFamily: 'Itim',
                                            ),
                                          ),
                                          _FooterLink(
                                            label: 'politykę prywatności.',
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const LegalDocumentScreen(
                                                    title: 'Polityka prywatności',
                                                    assetPath: 'assets/legal/polityka_prywatnosci.md',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HelpBody extends StatelessWidget {
  const _HelpBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        '''1. Upewnij się, że kupon, który chcesz dodać nie jest przypisany do Twojego emaila/konta w danym sklepie i inny użytkownik może z niego skorzystać.\n
2. Wybierz sklep, w którym chcesz dodać kupon.\n
3. Wpisz cenę, za którą chcesz wystawić kupon na sprzedaż.\n
4. Jeżeli kupon ma datę wygaśnięcia - wpisz ją. Niektóre kupony są bezterminowe - jeżeli Twój kupon taki jest, zaznacz "Kupon nie ma daty ważności".\n
5. Wpisz kod kuponu dokładnie tak, jak jest on podany na Twoim kuponie (uwzględniając wielkość liter). Możesz zeskanować kod, dodając jego zdjęcie. Zweryfikuj poprawność dodanego kodu.\n
6. Wybierz typ kuponu - czy jest to rabat procentowy czy na stałą kwotę, a następnie wpisz wartość rabatu.\n
7. Zaznacz, gdzie można wykorzystać kupon - w sklepach stacjonarnych, w sklepie internetowym lub w obu miejscach.\n
8. Określ, czy kupon ma jakieś ograniczenia (np. wyłączone produkty lub kategorie). Jeśli tak, wymień je w polu "Opis".\n
9. Po uzupełnieniu wszystkich wymaganych pól, kliknij przycisk "Dodaj", aby dodać kupon do systemu.''',
        style: TextStyle(fontFamily: 'Itim', fontSize: 18),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontFamily: 'Itim',
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

Widget appDialog({
  required String title,
  required String content,
  required List<Widget> actions,
}) {
  return Dialog(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(width: 2, color: AppColors.textPrimary),
    ),
    child: SizedBox(
      width: _dialogWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: _dialogMinHeight,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    ),
  );
}