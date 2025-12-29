import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:permission_handler/permission_handler.dart';
import '../card_editor/write_card_screen.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../theme/app_theme.dart';
import 'contact_detail_screen.dart';
import '../../utils/phone_formatter.dart';
import 'current_contact_provider.dart';
import 'selected_group_provider.dart';
import 'contact_service.dart';
import '../../l10n/app_strings.dart';
import '../../providers/locale_provider.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

// 가족 판별용 키워드 정의 (전역)
const _familySpouseKeywords = ['아내', '남편', '부인', '배우자', '와이프', '신랑', '신부', 'wife', 'husband'];
const _familyChildKeywords = ['아들', '딸', '자녀', '막내', '첫째', '둘째', '셋째', '애기', '아기', '손자', '손녀', 'son', 'daughter'];
const _familyParentKeywords = ['어머니', '아버지', '엄마', '아빠', '모친', '부친', '어무이', '아부지', 'mother', 'father', 'mom', 'dad'];
const _familySiblingKeywords = ['형', '누나', '오빠', '언니', '동생', '형제', '자매', '남동생', '여동생', 'brother', 'sister'];
const _familyMaternalKeywords = ['이모', '외삼촌', '외할머니', '외할아버지', '외숙모', '이모부', '외가'];
const _familyRelativeKeywords = [
  '삼촌', '고모', '숙부', '숙모', '고모부', '조카', '사촌', '친척', 
  '할머니', '할아버지', '장인', '장모', '시아버지', '시어머니',
  '며느리', '사위', '처형', '처제', '매형', '매제', '올케', '형수', '제수',
  '6촌', '8촌', 'uncle', 'aunt', 'grandma', 'grandpa', 'cousin'
];
const _familyPrefixes = ['큰', '작은', '친', '외', '새', '의붓', '계'];

// 가족 연락처인지 판별하는 함수
bool isFamilyContact(Contact c, {String myFamilyName = '함'}) {
  // 1. groupTag에 가족 포함
  if (c.groupTag?.toLowerCase().contains('family') == true ||
      c.groupTag?.contains('가족') == true) {
    return true;
  }
  
  // 2. 이름에 가족 관련 단어가 포함
  final nameLower = c.name.toLowerCase();
  final allKeywords = [
    ..._familySpouseKeywords, ..._familyChildKeywords, ..._familyParentKeywords,
    ..._familySiblingKeywords, ..._familyMaternalKeywords, ..._familyRelativeKeywords
  ];
  
  for (var keyword in allKeywords) {
    if (nameLower.contains(keyword.toLowerCase())) return true;
    // 접두사 조합 체크
    for (var prefix in _familyPrefixes) {
      if (nameLower.contains('$prefix$keyword'.toLowerCase())) return true;
    }
  }
  
  // 3. 성씨가 같으면 가족
  if (c.name.isNotEmpty && c.name[0] == myFamilyName) {
    return true;
  }
  
  return false;
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  int _selectedTabIndex = 0; // 0: My People, 1: Groups, 2: Memory Record
  String _searchQuery = '';
  Contact? _selectedContact; // 현재 선택된 연락처
  String _selectedFilter = '전체'; // 기본은 전체
  bool _isSyncing = false; // 동기화 중 상태
  String? _selectedGroupTag; // 선택된 그룹 태그 (null: 없음)
  List<String>? _cachedGroupTags; // 드래그 순서 유지를 위한 그룹 태그 캐시

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // bg-base
      body: Stack(
        children: [
          // Dot pattern background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(painter: DotPatternPainter()),
            ),
          ),
          
          Column(
            children: [
               // Top Tab Bar
              _buildTopTabBar(),

              // Search Section (Only show for My People tab for now, or both?)
              // The mockup shows search in My People. Let's keep it for both but maybe filter differently.
              _buildSearchSection(),

              Expanded(
                child: _selectedTabIndex == 0 
                  ? _buildMyPeopleList(database)
                  : _selectedTabIndex == 1
                    ? _buildGroupsList(database)
                    : _buildMemoryList(database),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 0),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              text: ref.watch(appStringsProvider).contactsMyPeople,
              iconWidget: Image.asset('assets/icons/heart_icon.png', width: 24, height: 24),
              isActive: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabPill(
              text: ref.watch(appStringsProvider).contactsGroups,
              icon: FontAwesomeIcons.userGroup,
              isActive: _selectedTabIndex == 1,
              onTap: () {
                // 그룹 탭으로 전환 시 currentContactProvider 클리어
                // (FAB가 이전에 선택한 연락처를 사용하지 않도록)
                ref.read(currentContactProvider.notifier).state = null;
                setState(() => _selectedTabIndex = 1);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabPill(
              text: ref.watch(appStringsProvider).contactsMemories,
              icon: FontAwesomeIcons.star,
              isActive: _selectedTabIndex == 2,
              onTap: () => setState(() => _selectedTabIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
           Container(
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(25),
               border: Border.all(color: const Color(0xFF5D4037)),
             ),
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
             child: TextField(
               onChanged: (value) {
                 setState(() {
                   _searchQuery = value;
                   // 검색어 입력 시 자동으로 '전체'로 변경
                   if (value.isNotEmpty && _selectedFilter != '전체') {
                     _selectedFilter = '전체';
                   }
                 });
               },
               decoration: InputDecoration(
                 icon: const Icon(FontAwesomeIcons.magnifyingGlass, color: Color(0xFF795548), size: 18),
                 border: InputBorder.none,
                 hintText: ref.watch(appStringsProvider).contactsSearchPlaceholder,
                 hintStyle: const TextStyle(color: Color(0xFFBCAAA4)),
               ),
             ),
           ),
           const SizedBox(height: 12),
           // Filter chips + Sync button
           Row(
             children: [
               Expanded(
                 child: SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: Row(
                     children: [
                       _FilterChip(
                         label: ref.watch(appStringsProvider).contactsAll,
                         isActive: _selectedFilter == '전체',
                         onTap: () => setState(() => _selectedFilter = '전체'),
                       ),
                       const SizedBox(width: 8),
                       _FilterChip(
                         label: ref.watch(appStringsProvider).contactsFavorites,
                         isActive: _selectedFilter == '즐겨찾기',
                         onTap: () => setState(() => _selectedFilter = '즐겨찾기'),
                       ),
                       const SizedBox(width: 8),
                       _FilterChip(
                         label: ref.watch(appStringsProvider).contactsRecent,
                         isActive: _selectedFilter == '최근 연락',
                         onTap: () => setState(() => _selectedFilter = '최근 연락'),
                       ),
                       const SizedBox(width: 8),
                       _FilterChip(
                         label: ref.watch(appStringsProvider).contactsFamily,
                         isActive: _selectedFilter == '가족',
                         onTap: () => setState(() => _selectedFilter = '가족'),
                       ),
                     ],
                   ),
                 ),
               ),
               // 동기화 버튼
               GestureDetector(
                 onTap: _isSyncing ? null : () async {
                   setState(() => _isSyncing = true);
                   try {
                     await ref.read(contactServiceProvider.notifier).syncContacts();
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("연락처 동기화 완료!")),
                       );
                     }
                   } catch (e) {
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text("동기화 실패: $e")),
                       );
                     }
                   } finally {
                     if (mounted) setState(() => _isSyncing = false);
                   }
                 },
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: _isSyncing ? Colors.grey : const Color(0xFF5D4037),
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: _isSyncing
                       ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                       : const Icon(FontAwesomeIcons.arrowsRotate, color: Colors.white, size: 16),
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildMyPeopleList(AppDatabase database) {
    return StreamBuilder<List<Contact>>(
      stream: database.watchAllContacts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var contacts = snapshot.data!;
        if (contacts.isEmpty) {
          return _buildEmptyState();
        }

        // 내 성씨 추출 (이름이 "함"으로 시작하는 연락처가 많으면 그것이 내 성씨)
        // TODO: 설정에서 사용자 성씨 관리
        String myFamilyName = '함'; // 기본값, 나중에 설정에서 변경 가능
        
        // 1. 검색어 필터링 먼저 적용
        if (_searchQuery.isNotEmpty) {
          contacts = contacts.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery) ||
            (c.groupTag?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
          ).toList();
        }
        
        // 2. 카테고리 필터링 적용
        final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
        
        switch (_selectedFilter) {
          case '즐겨찾기':
            contacts = contacts.where((c) => c.isFavorite).toList();
            break;
          case '최근 연락':
            // 최근 연락: 6개월 이내 연락 기록이 있는 사람만, 날짜 내림차순
            contacts = contacts.where((c) {
              final lastDate = c.lastSentDate ?? c.lastReceivedDate;
              if (lastDate == null) return false;
              return lastDate.isAfter(sixMonthsAgo);
            }).toList();
            contacts.sort((a, b) {
              final aDate = a.lastSentDate ?? a.lastReceivedDate;
              final bDate = b.lastSentDate ?? b.lastReceivedDate;
              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;
              return bDate.compareTo(aDate); // 날짜 내림차순
            });
            break;
          case '가족':
            // 가족 관련 단어 카테고리별 정의
            const spouseKeywords = ['아내', '남편', '부인', '배우자', '와이프', '신랑', '신부', 'wife', 'husband'];
            const childKeywords = ['아들', '딸', '자녀', '막내', '첫째', '둘째', '셋째', '애기', '아기', '손자', '손녀', 'son', 'daughter'];
            const parentKeywords = ['어머니', '아버지', '엄마', '아빠', '모친', '부친', '어무이', '아부지', 'mother', 'father', 'mom', 'dad'];
            const siblingKeywords = ['형', '누나', '오빠', '언니', '동생', '형제', '자매', '남동생', '여동생', 'brother', 'sister'];
            const maternalKeywords = ['이모', '외삼촌', '외할머니', '외할아버지', '외숙모', '이모부', '외가'];
            const relativeKeywords = [
              '삼촌', '고모', '숙부', '숙모', '고모부', '조카', '사촌', '친척', 
              '할머니', '할아버지', '장인', '장모', '시아버지', '시어머니',
              '며느리', '사위', '처형', '처제', '매형', '매제', '올케', '형수', '제수',
              '6촌', '8촌', 'uncle', 'aunt', 'grandma', 'grandpa', 'cousin'
            ];
            
            // 접두사 (큰, 작은, 친, 외 등)
            const prefixes = ['큰', '작은', '친', '외', '새', '의붓', '계'];
            
            // 모든 가족 단어 목록 (접두사 조합 포함)
            List<String> allFamilyKeywords = [];
            for (var keywords in [spouseKeywords, childKeywords, parentKeywords, siblingKeywords, maternalKeywords, relativeKeywords]) {
              for (var keyword in keywords) {
                allFamilyKeywords.add(keyword);
                // 접두사 조합 추가
                for (var prefix in prefixes) {
                  allFamilyKeywords.add('$prefix$keyword');
                }
              }
            }
            
            // 가족 카테고리 판별 함수
            int getFamilyPriority(String name) {
              final nameLower = name.toLowerCase();
              // 1순위: 배우자
              for (var kw in spouseKeywords) {
                if (nameLower.contains(kw)) return 1;
              }
              // 2순위: 자녀
              for (var kw in childKeywords) {
                if (nameLower.contains(kw)) return 2;
              }
              // 3순위: 부모
              for (var kw in parentKeywords) {
                if (nameLower.contains(kw)) return 3;
              }
              // 4순위: 형제
              for (var kw in siblingKeywords) {
                if (nameLower.contains(kw)) return 4;
              }
              // 5순위: 외가
              for (var kw in maternalKeywords) {
                if (nameLower.contains(kw)) return 5;
              }
              // 6순위: 친척
              for (var kw in relativeKeywords) {
                if (nameLower.contains(kw)) return 6;
              }
              // 7순위: 같은 성씨
              return 7;
            }
            
            // 가족 필터링: 가족 관련 단어 + groupTag에 가족 + 같은 성씨
            contacts = contacts.where((c) {
              // 1. groupTag에 가족 포함
              if (c.groupTag?.toLowerCase().contains('family') == true ||
                  c.groupTag?.contains('가족') == true) {
                return true;
              }
              
              // 2. 이름에 가족 관련 단어가 포함
              final nameLower = c.name.toLowerCase();
              for (var keyword in allFamilyKeywords) {
                if (nameLower.contains(keyword.toLowerCase())) {
                  return true;
                }
              }
              
              // 3. 성씨가 같으면 가족
              if (c.name.isNotEmpty && c.name[0] == myFamilyName) {
                return true;
              }
              
              return false;
            }).toList();
            
            // 정렬: 배우자→자녀→부모→형제→외가→친척→같은성씨, 그 안에서 이름순
            contacts.sort((a, b) {
              final aPriority = getFamilyPriority(a.name);
              final bPriority = getFamilyPriority(b.name);
              if (aPriority != bPriority) {
                return aPriority.compareTo(bPriority);
              }
              return a.name.compareTo(b.name);
            });
            break;
          default: // 전체
            // 전체도 즐겨찾기 상위 정렬
            contacts.sort((a, b) {
              if (a.isFavorite && !b.isFavorite) return -1;
              if (!a.isFavorite && b.isFavorite) return 1;
              return a.name.compareTo(b.name);
            });
            break;
        }

        // 필터 결과가 없는 경우
        if (contacts.isEmpty) {
          if (_selectedFilter == '가족') {
            return _buildEmptyFamilyState();
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.filter_list_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text("'$_selectedFilter' 조건에 맞는 연락처가 없습니다."),
              ],
            ),
          );
        }

        // 첫 번째 연락처 자동 선택 (아무것도 선택되지 않은 경우)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedContact == null && contacts.isNotEmpty) {
            setState(() {
              _selectedContact = contacts.first;
            });
            ref.read(currentContactProvider.notifier).state = contacts.first;
          }
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _buildContactCard(contacts[index]);
          },
        );
      },
    );
  }

  // 검색 쿼리를 적용하여 그룹 목록 필터링
  Future<List<String>> _getFilteredGroupTags(AppDatabase database) async {
    final allGroupTags = await database.getDistinctGroupTags();
    
    if (_searchQuery.isEmpty) {
      return allGroupTags;
    }
    
    final searchLower = _searchQuery.toLowerCase();
    List<String> filteredGroupTags = [];
    
    for (var tag in allGroupTags) {
      // 1. 그룹명 검색
      if (tag.toLowerCase().contains(searchLower)) {
        filteredGroupTags.add(tag);
        continue;
      }
      
      // 2. 멤버 이름으로 검색 (가족 그룹은 isFamilyContact 사용)
      List<Contact> tagContacts;
      if (tag == '가족') {
        final allContacts = await database.getAllContacts();
        tagContacts = allContacts.where((c) => isFamilyContact(c)).toList();
      } else {
        tagContacts = await database.getContactsByGroupTag(tag);
      }
      
      if (tagContacts.any((c) => c.name.toLowerCase().contains(searchLower))) {
        filteredGroupTags.add(tag);
      }
    }
    
    return filteredGroupTags;
  }

  Widget _buildGroupsList(AppDatabase database) {
    final strings = ref.watch(appStringsProvider);
    
    // 검색 쿼리를 적용한 그룹 목록 가져오기
    return FutureBuilder<List<String>>(
      future: _getFilteredGroupTags(database),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _cachedGroupTags == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // 캐시가 없거나 검색 중이면 새 데이터 사용
        if (snapshot.hasData && (_cachedGroupTags == null || _searchQuery.isNotEmpty)) {
          _cachedGroupTags = snapshot.data;
        }
        
        final filteredGroupTags = _cachedGroupTags ?? [];
        
        // 가족을 별도로 분리
        final hasFamily = filteredGroupTags.contains('가족');
        final showFamily = hasFamily || _searchQuery.isEmpty;
        final otherGroupTags = filteredGroupTags.where((tag) => tag != '가족').toList();
        
        return Stack(
          children: [
            Column(
              children: [
                // 가족 그룹 (맨 위 고정)
                if (showFamily)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: _buildGroupTagCard('가족', database, isFamily: true),
                  ),
                // 사용자 정의 그룹 목록 (ReorderableListView로 드래그 순서 변경 지원)
                Expanded(
                  child: (otherGroupTags.isEmpty && !showFamily)
                    ? Center(child: Text(strings.contactsNoSearchResult))
                    : otherGroupTags.isEmpty
                        ? const SizedBox()
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            itemCount: otherGroupTags.length,
                            onReorder: (oldIndex, newIndex) {
                              if (newIndex > oldIndex) newIndex--;
                              // 캐시된 리스트에서 순서 변경
                              setState(() {
                                if (_cachedGroupTags != null) {
                                  // 가족을 제외한 인덱스 계산 (가족은 맨 앞)
                                  final familyOffset = _cachedGroupTags!.contains('가족') ? 1 : 0;
                                  final actualOldIndex = oldIndex + familyOffset;
                                  final actualNewIndex = newIndex + familyOffset;
                                  
                                  final item = _cachedGroupTags!.removeAt(actualOldIndex);
                                  _cachedGroupTags!.insert(actualNewIndex, item);
                                }
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                key: ValueKey(otherGroupTags[index]),
                                child: _buildGroupTagCard(otherGroupTags[index], database),
                              );
                            },
                          ),
                ),
              ],
            ),
            // Floating Action Buttons
            Positioned(
              right: 20,
              bottom: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 카드 쓰기 버튼 (그룹 선택시만 표시)
                  if (_selectedGroupTag != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FloatingActionButton(
                        heroTag: 'writeCard',
                        onPressed: () => _navigateToWriteCardWithGroup(database),
                        backgroundColor: const Color(0xFFE65100),
                        child: const Icon(FontAwesomeIcons.pen, color: Colors.white, size: 20),
                      ),
                    ),
                  FloatingActionButton(
                    heroTag: 'addGroup',
                    onPressed: () => _showAddGroupTagDialog(database),
                    backgroundColor: const Color(0xFF5D4037),
                    child: const Icon(FontAwesomeIcons.plus, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 그룹 태그 카드
  Widget _buildGroupTagCard(String groupTag, AppDatabase database, {bool isFamily = false}) {
    final strings = ref.watch(appStringsProvider);
    final isSelected = _selectedGroupTag == groupTag;
    
    // 가족 그룹일 때는 isFamilyContact 함수로 카운트
    final countFuture = isFamily 
        ? database.getAllContacts().then((contacts) => contacts.where((c) => isFamilyContact(c)).length)
        : database.getContactCountByGroupTag(groupTag);
    
    return FutureBuilder<int>(
      future: countFuture,
      builder: (context, countSnapshot) {
        final memberCount = countSnapshot.data ?? 0;
        
        return GestureDetector(
          onTap: () {
            final newSelection = isSelected ? null : groupTag;
            setState(() {
              _selectedGroupTag = newSelection;
            });
            // ScaffoldWithNav의 FAB에서 사용할 수 있도록 provider 업데이트
            ref.read(selectedGroupTagProvider.notifier).state = newSelection;
          },
          onDoubleTap: () => _showGroupTagDetailDialog(groupTag, database, isFamily: isFamily),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFE0B2) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF5D4037) : const Color(0xFF5D4037).withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, 4), blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: isFamily ? const Color(0xFFFFCDD2) : const Color(0xFFFFE0B2),
                    shape: BoxShape.circle,
                    border: Border.all(color: isFamily ? const Color(0xFFE91E63) : const Color(0xFF5D4037)),
                  ),
                  child: Center(
                    child: Icon(
                      isFamily ? FontAwesomeIcons.house : FontAwesomeIcons.userGroup, 
                      color: isFamily ? const Color(0xFFE91E63) : const Color(0xFF5D4037), 
                      size: 20
                    )
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isFamily ? strings.contactsFamily : groupTag, 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF3E2723))),
                      const SizedBox(height: 2),
                      Text(strings.groupMemberCount(memberCount), style: const TextStyle(fontSize: 12, color: Color(0xFF795548))),
                    ],
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(FontAwesomeIcons.check, color: Color(0xFF5D4037), size: 18),
                  ),
                if (!isFamily)
                  PopupMenuButton<String>(
                    icon: const Icon(FontAwesomeIcons.ellipsisVertical, color: Color(0xFF795548), size: 18),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditGroupTagDialog(groupTag, database);
                      } else if (value == 'delete') {
                        _showDeleteGroupTagDialog(groupTag, database);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(strings.groupEdit)),
                      PopupMenuItem(value: 'delete', child: Text(strings.groupDelete, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  // 가족 그룹 상세 다이얼로그
  void _showFamilyDetailDialog(AppDatabase database) {
    final strings = ref.read(appStringsProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFDF5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.house, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(strings.contactsFamily, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.userPlus, color: Colors.white, size: 18),
                    onPressed: () => _showAddFamilyContactDialog(database),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: database.getFamilyContacts(),
                builder: (context, snapshot) {
                  final contacts = snapshot.data ?? [];
                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FontAwesomeIcons.userSlash, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(strings.groupEmpty, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFCDD2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(child: Text("👨‍👩‍👧", style: TextStyle(fontSize: 18))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.xmark, color: Colors.red, size: 16),
                              onPressed: () async {
                                await database.updateContactFamily(contact.id, false);
                                setState(() {});
                                if (mounted) Navigator.pop(context);
                                _showFamilyDetailDialog(database); // Refresh
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 가족 연락처 추가 다이얼로그
  void _showAddFamilyContactDialog(AppDatabase database) async {
    final strings = ref.read(appStringsProvider);
    final allContacts = await database.getAllContacts();
    final familyContacts = await database.getFamilyContacts();
    final familyIds = familyContacts.map((c) => c.id).toSet();
    
    final availableContacts = allContacts.where((c) => !familyIds.contains(c.id)).toList();
    
    if (!mounted) return;
    
    String searchQuery = '';
    Set<int> selectedIds = {};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredContacts = searchQuery.isEmpty
              ? availableContacts
              : availableContacts.where((c) => 
                  c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  c.phone.contains(searchQuery)
                ).toList();
          
          return AlertDialog(
            title: Text(strings.groupAddContact),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setDialogState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
                      hintText: strings.contactsSearchPlaceholder,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => setDialogState(() => selectedIds = filteredContacts.map((c) => c.id).toSet()),
                        icon: const Icon(FontAwesomeIcons.checkDouble, size: 14),
                        label: Text(strings.all, style: const TextStyle(fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () => setDialogState(() => selectedIds.clear()),
                        icon: const Icon(FontAwesomeIcons.xmark, size: 14),
                        label: Text(strings.cancel, style: const TextStyle(fontSize: 12)),
                      ),
                      const Spacer(),
                      Text('${selectedIds.length}${strings.sendPerson}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        return CheckboxListTile(
                          value: selectedIds.contains(contact.id),
                          onChanged: (v) => setDialogState(() => v == true ? selectedIds.add(contact.id) : selectedIds.remove(contact.id)),
                          secondary: const CircleAvatar(child: Text("👩🏻")),
                          title: Text(contact.name, style: const TextStyle(fontSize: 14)),
                          subtitle: Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12)),
                          dense: true,
                          activeColor: const Color(0xFFE91E63),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.close)),
              ElevatedButton.icon(
                onPressed: selectedIds.isEmpty ? null : () async {
                  for (final id in selectedIds) {
                    await database.updateContactFamily(id, true);
                  }
                  if (mounted) Navigator.pop(context);
                  Navigator.pop(context); // Close bottom sheet
                  _showFamilyDetailDialog(database); // Refresh
                },
                icon: const Icon(FontAwesomeIcons.plus, size: 14, color: Colors.white),
                label: Text('${strings.add} (${selectedIds.length})', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: selectedIds.isEmpty ? Colors.grey : const Color(0xFFE91E63)),
              ),
            ],
          );
        },
      ),
    );
  }

  // 선택된 그룹으로 카드 쓰기 화면 이동
  Future<void> _navigateToWriteCardWithGroup(AppDatabase database) async {
    if (_selectedGroupTag == null) return;
    
    // 가족 그룹일 때는 isFamilyContact 함수로 필터링
    List<Contact> groupContacts;
    if (_selectedGroupTag == '가족') {
      final allContacts = await database.getAllContacts();
      groupContacts = allContacts.where((c) => isFamilyContact(c)).toList();
    } else {
      groupContacts = await database.getContactsByGroupTag(_selectedGroupTag!);
    }
    
    if (groupContacts.isEmpty) return;
    
    // recipients 형식으로 변환
    final recipients = groupContacts.map((c) => {'name': c.name, 'phone': c.phone}).toList();
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WriteCardScreen(initialRecipients: recipients),
        ),
      );
    }
  }

  // 그룹 태그 상세 다이얼로그
  void _showGroupTagDetailDialog(String groupTag, AppDatabase database, {bool isFamily = false}) {
    final strings = ref.read(appStringsProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFDF5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isFamily ? const Color(0xFFE91E63) : const Color(0xFF5D4037),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(isFamily ? FontAwesomeIcons.house : FontAwesomeIcons.userGroup, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(isFamily ? strings.contactsFamily : groupTag, 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.userPlus, color: Colors.white, size: 18),
                      onPressed: () => _showAddContactToGroupTagDialog(groupTag, database, setSheetState),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Contact>>(
                  future: isFamily 
                      ? database.getAllContacts().then((contacts) => contacts.where((c) => isFamilyContact(c)).toList())
                      : database.getContactsByGroupTag(groupTag),
                  builder: (context, snapshot) {
                    final contacts = snapshot.data ?? [];
                    if (contacts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FontAwesomeIcons.userSlash, size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(strings.groupEmpty, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: (isFamily ? const Color(0xFFE91E63) : const Color(0xFF5D4037)).withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: isFamily ? const Color(0xFFFFCDD2) : const Color(0xFFFFF59D),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(child: Text(isFamily ? "👨‍👩‍👧" : "👩🏻", style: const TextStyle(fontSize: 18))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(FontAwesomeIcons.xmark, color: Colors.red, size: 16),
                                onPressed: () async {
                                  await database.removeContactFromGroupTag(contact.id);
                                  setSheetState(() {});
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 그룹 태그에 연락처 추가 다이얼로그
  void _showAddContactToGroupTagDialog(String groupTag, AppDatabase database, StateSetter setSheetState) async {
    final strings = ref.read(appStringsProvider);
    final allContacts = await database.getAllContacts();
    final groupContacts = await database.getContactsByGroupTag(groupTag);
    final groupContactIds = groupContacts.map((c) => c.id).toSet();
    
    // 해당 그룹에 이미 추가된 연락처만 제외 (다른 그룹 멤버는 포함)
    final availableContacts = allContacts.where((c) => !groupContactIds.contains(c.id)).toList();
    
    if (!mounted) return;
    
    String searchQuery = '';
    Set<int> selectedIds = {};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredContacts = searchQuery.isEmpty
              ? availableContacts
              : availableContacts.where((c) => 
                  c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  c.phone.contains(searchQuery)
                ).toList();
          
          return AlertDialog(
            title: Text(strings.groupAddContact),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setDialogState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
                      hintText: strings.contactsSearchPlaceholder,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => setDialogState(() => selectedIds = filteredContacts.map((c) => c.id).toSet()),
                        icon: const Icon(FontAwesomeIcons.checkDouble, size: 14),
                        label: Text(strings.all, style: const TextStyle(fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () => setDialogState(() => selectedIds.clear()),
                        icon: const Icon(FontAwesomeIcons.xmark, size: 14),
                        label: Text(strings.cancel, style: const TextStyle(fontSize: 12)),
                      ),
                      const Spacer(),
                      Text('${selectedIds.length}${strings.sendPerson}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: filteredContacts.isEmpty
                        ? Center(child: Text(strings.contactsEmpty))
                        : ListView.builder(
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              return CheckboxListTile(
                                value: selectedIds.contains(contact.id),
                                onChanged: (v) => setDialogState(() => v == true ? selectedIds.add(contact.id) : selectedIds.remove(contact.id)),
                                secondary: const CircleAvatar(child: Text("👩🏻")),
                                title: Text(contact.name, style: const TextStyle(fontSize: 14)),
                                subtitle: Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12)),
                                dense: true,
                                activeColor: const Color(0xFF5D4037),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.close)),
              ElevatedButton.icon(
                onPressed: selectedIds.isEmpty ? null : () async {
                  await database.addContactsToGroupTag(selectedIds.toList(), groupTag);
                  if (mounted) Navigator.pop(context);
                  setSheetState(() {});
                  setState(() {});
                },
                icon: const Icon(FontAwesomeIcons.plus, size: 14, color: Colors.white),
                label: Text('${strings.add} (${selectedIds.length})', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: selectedIds.isEmpty ? Colors.grey : const Color(0xFF5D4037)),
              ),
            ],
          );
        },
      ),
    );
  }

  // 새 그룹 태그 추가 다이얼로그
  void _showAddGroupTagDialog(AppDatabase database) {
    final strings = ref.read(appStringsProvider);
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.groupAdd),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: strings.groupName,
            hintText: strings.groupNameHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.groupNameRequired)),
                );
                return;
              }
              // 새 그룹 태그로 ContactGroups 테이블에도 추가 (호환성)
              await database.insertContactGroup(
                ContactGroupsCompanion.insert(name: controller.text.trim()),
              );
              setState(() {});
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037)),
            child: Text(strings.add, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 그룹 태그 수정 다이얼로그
  void _showEditGroupTagDialog(String groupTag, AppDatabase database) {
    final strings = ref.read(appStringsProvider);
    final controller = TextEditingController(text: groupTag);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.groupEdit),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: strings.groupName,
            hintText: strings.groupNameHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final newTag = controller.text.trim();
              // 기존 그룹의 모든 연락처를 새 태그로 업데이트
              final contacts = await database.getContactsByGroupTag(groupTag);
              for (final c in contacts) {
                await database.updateContactGroupTag(c.id, newTag);
              }
              setState(() {});
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037)),
            child: Text(strings.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 그룹 태그 삭제 다이얼로그
  void _showDeleteGroupTagDialog(String groupTag, AppDatabase database) {
    final strings = ref.read(appStringsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.groupDelete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.groupDeleteConfirm(groupTag)),
            const SizedBox(height: 8),
            Text(strings.groupDeleteDesc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // 해당 그룹의 모든 연락처에서 groupTag 제거
              final contacts = await database.getContactsByGroupTag(groupTag);
              for (final c in contacts) {
                await database.removeContactFromGroupTag(c.id);
              }
              setState(() {
                if (_selectedGroupTag == groupTag) _selectedGroupTag = null;
              });
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(strings.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(ContactGroup group, AppDatabase database) {
    final strings = ref.read(appStringsProvider);
    final controller = TextEditingController(text: group.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.groupEdit),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: strings.groupName,
            hintText: strings.groupNameHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.groupNameRequired)),
                );
                return;
              }
              await database.updateContactGroup(
                group.copyWith(name: controller.text.trim()),
              );
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D4037)),
            child: Text(strings.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(ContactGroup group, AppDatabase database) {
    final strings = ref.read(appStringsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.groupDelete),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.groupDeleteConfirm(group.name)),
            const SizedBox(height: 8),
            Text(strings.groupDeleteDesc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await database.deleteContactGroup(group.id);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(strings.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showGroupDetailDialog(ContactGroup group, AppDatabase database) {
    final strings = ref.read(appStringsProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFDF5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF5D4037),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.userGroup, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(group.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.userPlus, color: Colors.white, size: 18),
                    onPressed: () => _showAddContactToGroupDialog(group, database),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Contact>>(
                stream: database.watchContactsInGroup(group.id),
                builder: (context, snapshot) {
                  final contacts = snapshot.data ?? [];
                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FontAwesomeIcons.userSlash, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(strings.groupEmpty, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF59D),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(child: Text("👩🏻", style: TextStyle(fontSize: 20))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.xmark, color: Colors.red, size: 16),
                              onPressed: () async {
                                await database.removeContactFromGroup(contact.id, group.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactToGroupDialog(ContactGroup group, AppDatabase database) async {
    final strings = ref.read(appStringsProvider);
    final allContacts = await database.getAllContacts();
    final groupContacts = await database.getContactsInGroup(group.id);
    final groupContactIds = groupContacts.map((c) => c.id).toSet();
    
    final availableContacts = allContacts.where((c) => !groupContactIds.contains(c.id)).toList();
    
    if (!mounted) return;
    
    String searchQuery = '';
    Set<int> selectedIds = {};
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredContacts = searchQuery.isEmpty
              ? availableContacts
              : availableContacts.where((c) => 
                  c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  c.phone.contains(searchQuery)
                ).toList();
          
          return AlertDialog(
            title: Text(strings.groupAddContact),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: Column(
                children: [
                  // 검색 창
                  TextField(
                    onChanged: (value) => setDialogState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 16),
                      hintText: strings.contactsSearchPlaceholder,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 모두 선택/취소 버튼
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            selectedIds = filteredContacts.map((c) => c.id).toSet();
                          });
                        },
                        icon: const Icon(FontAwesomeIcons.checkDouble, size: 14),
                        label: Text(strings.all, style: const TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            selectedIds.clear();
                          });
                        },
                        icon: const Icon(FontAwesomeIcons.xmark, size: 14),
                        label: Text(strings.cancel, style: const TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${selectedIds.length}${strings.sendPerson}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF5D4037), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  // 연락처 목록
                  Expanded(
                    child: filteredContacts.isEmpty
                        ? Center(child: Text(strings.contactsEmpty))
                        : ListView.builder(
                            itemCount: filteredContacts.length,
                            itemBuilder: (context, index) {
                              final contact = filteredContacts[index];
                              final isSelected = selectedIds.contains(contact.id);
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      selectedIds.add(contact.id);
                                    } else {
                                      selectedIds.remove(contact.id);
                                    }
                                  });
                                },
                                secondary: const CircleAvatar(child: Text("👩🏻")),
                                title: Text(contact.name, style: const TextStyle(fontSize: 14)),
                                subtitle: Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12)),
                                dense: true,
                                activeColor: const Color(0xFF5D4037),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.close),
              ),
              ElevatedButton.icon(
                onPressed: selectedIds.isEmpty ? null : () async {
                  for (final id in selectedIds) {
                    await database.addContactToGroup(id, group.id);
                  }
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(FontAwesomeIcons.plus, size: 14, color: Colors.white),
                label: Text('${strings.add} (${selectedIds.length})', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedIds.isEmpty ? Colors.grey : const Color(0xFF5D4037),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMemoryList(AppDatabase database) {
    return StreamBuilder<List<RecentContactData>>(
      stream: database.watchRecentContacts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error}"));
        }
        
        var recents = snapshot.data ?? [];
        if (_searchQuery.isNotEmpty) {
           final query = _searchQuery.toLowerCase();
           recents = recents.where((d) => 
             d.contact.name.toLowerCase().contains(query) || 
             (d.lastMessage?.toLowerCase().contains(query) ?? false)
           ).toList();
        }

        if (recents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.clockRotateLeft, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(ref.watch(appStringsProvider).contactsNoMemories),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: recents.length,
          itemBuilder: (context, index) {
            return _buildMemoryCard(recents[index]);
          },
        );
      },
    );
  }

  Widget _buildContactCard(Contact contact) {
    final isSelected = _selectedContact?.id == contact.id;
    
    return GestureDetector(
      onTap: () {
        // 연락처 선택
        setState(() {
          _selectedContact = contact;
        });
        ref.read(currentContactProvider.notifier).state = contact;
      },
      onDoubleTap: () {
        // 더블탭으로 상세화면 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: contact)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF8A65) : const Color(0xFF5D4037).withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(0, 4), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            // 연락처 사진 또는 기본 아이콘
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF59D),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5D4037)),
                image: contact.photoData != null && contact.photoData!.isNotEmpty
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(contact.photoData!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: contact.photoData == null || contact.photoData!.isEmpty
                  ? const Center(child: Text("👩🏻", style: TextStyle(fontSize: 24)))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF3E2723))),
                  const SizedBox(height: 2),
                  Text(formatPhone(contact.phone), style: const TextStyle(fontSize: 12, color: Color(0xFF795548), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            // 가족 필터일 때 가족 삭제 버튼
            if (_selectedFilter == '가족')
              GestureDetector(
                onTap: () async {
                  // 가족에서 제거
                  final db = ref.read(appDatabaseProvider);
                  await db.updateContactFamily(contact.id, false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${contact.name}을(를) 가족에서 제거했습니다.")),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(FontAwesomeIcons.userMinus, color: Colors.red, size: 18),
                ),
              ),
            IconButton(
              icon: Image.asset(
                'assets/icons/heart_icon.png',
                width: 36,
                height: 36,
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (context) => WriteCardScreen(initialContact: contact)),
                );
              },
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyFamilyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.peopleGroup, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("가족으로 등록된 연락처가 없습니다."),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddFamilyDialog,
            icon: const Icon(FontAwesomeIcons.userPlus, size: 16),
            label: const Text("가족 추가"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D4037),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddFamilyDialog() async {
    final db = ref.read(appDatabaseProvider);
    final allContacts = await db.getAllContacts();
    
    // 가족이 아닌 연락처만 필터링
    final nonFamilyContacts = allContacts.where((c) {
      if (c.isFavorite) return false;
      if (c.groupTag?.contains('가족') == true) return false;
      return true;
    }).toList();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("가족 추가"),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: nonFamilyContacts.isEmpty 
              ? const Center(child: Text("추가할 연락처가 없습니다."))
              : ListView.builder(
                  itemCount: nonFamilyContacts.length,
                  itemBuilder: (context, index) {
                    final contact = nonFamilyContacts[index];
                    return ListTile(
                      title: Text(contact.name),
                      subtitle: Text(formatPhone(contact.phone)),
                      trailing: IconButton(
                        icon: const Icon(FontAwesomeIcons.userPlus, color: Color(0xFF5D4037)),
                        onPressed: () async {
                          await db.updateContactFamily(contact.id, true);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${contact.name}을(를) 가족으로 추가했습니다.")),
                            );
                            setState(() {}); // 새로고침
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("닫기"),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(RecentContactData data) {
    final bool isReceived = data.lastType == 'RECEIVED';
    final Color cardColor = isReceived ? const Color(0xFFC8E6C9) : const Color(0xFFFFF9C4); // Mint vs Yellow
    
    // Distinct icons and colors
    final IconData icon = isReceived ? FontAwesomeIcons.envelopeOpenText : FontAwesomeIcons.paperPlane;
    final Color iconColor = isReceived ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00); // Green vs Orange
    
    // Process message for preview (first line only)
    String messagePreview = data.lastMessage ?? (isReceived ? "새 메시지" : "카드 발송");
    if (messagePreview.contains('\n')) {
      messagePreview = messagePreview.split('\n').first;
    }
    // Remove manual length truncation, let Text widget handle it
    
    return GestureDetector(
      onTap: () {
         // Navigate to detail screen just like contact card
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: data.contact)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 2), blurRadius: 8)
          ],
          border: Border.all(color: Colors.black.withOpacity(0.02)),
        ),
        child: IntrinsicHeight( // For vertical divider
          child: Row(
            children: [
              // Left Section: Date & Icon
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: iconColor),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(data.lastDate),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5D4037)),
                    ),
                  ],
                ),
              ),
              
              // Divider
              const VerticalDivider(
                width: 1, 
                thickness: 1, 
                color: Colors.transparent, 
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: CustomPaint(painter: DashedLinePainter()),
              ),

              // Right Section: Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Thumbnail
                      if (data.cardThumbnail != null && File(data.cardThumbnail!).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(data.cardThumbnail!), 
                            width: 48, 
                            height: 48, 
                            fit: BoxFit.cover
                          ),
                        )
                      else
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Text("💐", style: TextStyle(fontSize: 24))),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.contact.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF3E2723)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messagePreview,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037), height: 1.4),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Reply Button for Received messages
                            if (isReceived) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 32,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                         builder: (context) => WriteCardScreen(initialContact: data.contact)
                                       ),
                                     );
                                  },
                                  icon: const Icon(FontAwesomeIcons.pen, size: 12),
                                  label: const Text("카드 쓰기", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF5D4037),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: const Color(0xFF5D4037).withOpacity(0.2)),
                                    ),
                                  ),
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final strings = ref.read(appStringsProvider);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return strings.dateToday;
    }
    
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return strings.dateYesterday;
    }
    
    if (diff.inDays < 7) {
      return strings.daysAgo(diff.inDays);
    }
    
    return DateFormat('MM.dd').format(date);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.solidAddressBook, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("연락처를 동기화해주세요."),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(contactServiceProvider.notifier).syncContacts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("연락처 동기화 완료!")),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("동기화 실패: $e\n설정에서 연락처 권한을 허용해주세요."),
                      action: SnackBarAction(
                        label: "설정",
                        onPressed: () async {
                          // Open app settings
                          await openAppSettings();
                        },
                      ),
                    ),
                  );
                }
              }
            }, 
            child: const Text("동기화 하기"),
          )
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String text;
  final bool isActive;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onTap;

  const _TabPill({required this.text, required this.isActive, this.icon, this.iconWidget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFAB91) : const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(50),
          border: isActive ? Border.all(color: const Color(0xFF5D4037), width: 2) : Border.all(color: const Color(0xFF5D4037).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null) ...[iconWidget!, const SizedBox(width: 6)]
            else if (icon != null) ...[Icon(icon, size: 16, color: const Color(0xFF3E2723)), const SizedBox(width: 6)],
            Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3E2723))),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _FilterChip({required this.label, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3E2723) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF5D4037)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF795548),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += 20) {
      for (double x = 0; x < size.width; x += 20) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF5D4037).withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashHeight = 5, dashSpace = 3, startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
