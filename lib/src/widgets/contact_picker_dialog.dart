import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import '../features/database/app_database.dart';
import '../features/database/database_provider.dart';
import '../utils/phone_formatter.dart';

/// 공통 연락처 선택 다이얼로그
/// 모든 화면에서 동일하게 사용됩니다.
class ContactPickerDialog extends ConsumerStatefulWidget {
  final List<String> initialSelectedPhones;
  final bool multiSelect;
  
  const ContactPickerDialog({
    Key? key,
    this.initialSelectedPhones = const [],
    this.multiSelect = true,
  }) : super(key: key);

  /// 다이얼로그를 표시하고 선택된 연락처 목록을 반환
  static Future<List<Contact>?> show(
    BuildContext context, {
    List<String> initialSelectedPhones = const [],
    bool multiSelect = true,
  }) async {
    return showDialog<List<Contact>>(
      context: context,
      builder: (context) => ContactPickerDialog(
        initialSelectedPhones: initialSelectedPhones,
        multiSelect: multiSelect,
      ),
    );
  }

  @override
  ConsumerState<ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends ConsumerState<ContactPickerDialog> {
  String _searchQuery = "";
  String _selectedFilter = '전체';
  late Set<String> _selectedPhones;
  List<Contact> _contacts = [];

  // 가족 필터용 키워드
  static const _familyKeywords = [
    // 배우자
    '아내', '남편', '부인', '배우자', '와이프', '신랑', '신부', 'wife', 'husband',
    // 자녀
    '아들', '딸', '자녀', '막내', '첫째', '둘째', '셋째', '애기', '아기', '손자', '손녀', 'son', 'daughter',
    // 부모
    '어머니', '아버지', '엄마', '아빠', '모친', '부친', 'mother', 'father', 'mom', 'dad',
    // 형제
    '형', '누나', '오빠', '언니', '동생', '형제', '자매', '남동생', '여동생', 'brother', 'sister',
    // 친척
    '이모', '삼촌', '고모', '숙부', '숙모', '조카', '사촌', '친척',
    '할머니', '할아버지', '장인', '장모', '시아버지', '시어머니',
    '며느리', '사위', 'uncle', 'aunt', 'grandma', 'grandpa', 'cousin'
  ];
  
  // 내 성 (TODO: 설정에서 변경 가능하도록)
  static const _myFamilyName = '함';

  @override
  void initState() {
    super.initState();
    _selectedPhones = Set.from(widget.initialSelectedPhones);
    _loadContacts();
    
    // 다이얼로그 열 때 키보드 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  Future<void> _loadContacts() async {
    final db = ref.read(appDatabaseProvider);
    final contacts = await db.getAllContacts();
    if (mounted) {
      setState(() {
        _contacts = contacts;
      });
    }
  }

  Future<void> _handleAddNew() async {
    final db = ref.read(appDatabaseProvider);
    final result = await _showManualContactDialog(context, db);
    if (result != null) {
      await _loadContacts();
      // 새 연락처 자동 선택
      final newContact = _contacts.firstWhere(
        (c) => c.name == result['name'] && c.phone == result['phone'],
        orElse: () => _contacts.isNotEmpty ? _contacts.last : _contacts.first,
      );
      setState(() {
        _selectedPhones.add(newContact.phone);
      });
    }
  }

  /// 수동 연락처 추가 다이얼로그
  static Future<Map<String, String>?> _showManualContactDialog(
    BuildContext context,
    AppDatabase db,
  ) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("새 연락처 추가"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "이름",
                hintText: "홍길동",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "전화번호",
                hintText: "010-1234-5678",
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.replaceAll(RegExp(r'\D'), '');
              
              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("이름과 전화번호를 입력해주세요.")),
                );
                return;
              }
              
              // DB에 저장
              await db.upsertContact(ContactsCompanion(
                name: Value(name),
                phone: Value(phone),
              ));
              
              Navigator.pop(context, {'name': name, 'phone': phone});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF29D86),
            ),
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }

  bool _isFamily(Contact contact) {
    // 1. groupTag에 가족/family 포함
    final tag = contact.groupTag?.toLowerCase() ?? '';
    if (tag.contains('가족') || tag.contains('family')) {
      return true;
    }
    
    // 2. 이름에 가족 관련 단어 포함
    final nameLower = contact.name.toLowerCase();
    for (var keyword in _familyKeywords) {
      if (nameLower.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    
    // 3. 성씨가 같으면 가족
    if (contact.name.isNotEmpty && contact.name[0] == _myFamilyName) {
      return true;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // 필터링된 연락처 목록
    final filtered = _contacts.where((contact) {
      // 검색어 필터
      final matchesSearch = _searchQuery.isEmpty ||
          contact.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          contact.phone.contains(_searchQuery);
      
      // 카테고리 필터
      bool matchesCategory = true;
      if (_selectedFilter == '즐겨찾기') {
        matchesCategory = contact.isFavorite;
      } else if (_selectedFilter == '가족') {
        matchesCategory = _isFamily(contact);
      }
      
      return matchesSearch && matchesCategory;
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("발송 대상 선택"),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: Column(
          children: [
            // 검색창
            TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: '이름 또는 전화번호 검색',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFF29D86)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF29D86)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF29D86), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 10),
            
            // 필터 버튼들 (좁은 화면에서 아이콘만 표시)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 280;
                return Row(
                  children: [
                    Expanded(child: _buildFilterChip('전체', Icons.people, isNarrow)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildFilterChip('즐겨찾기', Icons.star, isNarrow)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildFilterChip('가족', Icons.family_restroom, isNarrow)),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            
            // 연락처 목록
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty 
                            ? "검색 결과가 없습니다."
                            : "저장된 연락처가 없습니다.",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final contact = filtered[index];
                        final isSelected = _selectedPhones.contains(contact.phone);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Row(
                            children: [
                              Expanded(child: Text(contact.name)),
                              if (contact.isFavorite)
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                              if (_isFamily(contact))
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.family_restroom, color: Colors.brown, size: 16),
                                ),
                            ],
                          ),
                          subtitle: Text(formatPhone(contact.phone)),
                          activeColor: const Color(0xFFF29D86),
                          onChanged: (bool? value) {
                            setState(() {
                              if (widget.multiSelect) {
                                if (value == true) {
                                  _selectedPhones.add(contact.phone);
                                } else {
                                  _selectedPhones.remove(contact.phone);
                                }
                              } else {
                                // 단일 선택 모드
                                _selectedPhones.clear();
                                if (value == true) {
                                  _selectedPhones.add(contact.phone);
                                }
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            
            // 새 연락처 추가 버튼
            OutlinedButton.icon(
              onPressed: _handleAddNew,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text("새 연락처 추가"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF29D86),
                side: const BorderSide(color: Color(0xFFF29D86)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            final selected = _contacts.where((c) => _selectedPhones.contains(c.phone)).toList();
            Navigator.pop(context, selected);
          },
          child: const Text("확인", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF29D86))),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String label, IconData icon, bool isNarrow) {
    final isActive = _selectedFilter == label;
    
    // 좁은 화면에서는 아이콘만 표시 (툴팁으로 라벨 제공)
    if (isNarrow) {
      return Tooltip(
        message: label,
        child: FilterChip(
          label: Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey[700]),
          selected: isActive,
          selectedColor: const Color(0xFFF29D86),
          backgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          onSelected: (selected) {
            setState(() => _selectedFilter = label);
          },
        ),
      );
    }
    
    // 넓은 화면에서는 아이콘 + 텍스트
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[700]),
      selected: isActive,
      selectedColor: const Color(0xFFF29D86),
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.grey[700],
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      onSelected: (selected) {
        setState(() => _selectedFilter = label);
      },
    );
  }
}
