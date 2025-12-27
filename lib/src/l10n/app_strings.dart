import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heart_connect/src/providers/locale_provider.dart';

/// 앱 전역 다국어 문자열 클래스
class AppStrings {
  final String languageCode;
  
  AppStrings(this.languageCode);
  
  // ========== 공통 ==========
  String get appName => _get({'ko': '마음이음', 'en': 'Heart-Connect', 'ja': 'ハートコネクト', 'zh': '心连心'});
  String get ok => _get({'ko': '확인', 'en': 'OK', 'ja': 'OK', 'zh': '确认'});
  String get cancel => _get({'ko': '취소', 'en': 'Cancel', 'ja': 'キャンセル', 'zh': '取消'});
  String get close => _get({'ko': '닫기', 'en': 'Close', 'ja': '閉じる', 'zh': '关闭'});
  String get save => _get({'ko': '저장', 'en': 'Save', 'ja': '保存', 'zh': '保存'});
  String get delete => _get({'ko': '삭제', 'en': 'Delete', 'ja': '削除', 'zh': '删除'});
  String get edit => _get({'ko': '편집', 'en': 'Edit', 'ja': '編集', 'zh': '编辑'});
  String get add => _get({'ko': '추가', 'en': 'Add', 'ja': '追加', 'zh': '添加'});
  String get search => _get({'ko': '검색', 'en': 'Search', 'ja': '検索', 'zh': '搜索'});
  String get loading => _get({'ko': '로딩 중...', 'en': 'Loading...', 'ja': '読み込み中...', 'zh': '加载中...'});
  String get error => _get({'ko': '오류', 'en': 'Error', 'ja': 'エラー', 'zh': '错误'});
  String get success => _get({'ko': '성공', 'en': 'Success', 'ja': '成功', 'zh': '成功'});
  String get warning => _get({'ko': '경고', 'en': 'Warning', 'ja': '警告', 'zh': '警告'});
  String get retry => _get({'ko': '다시 시도', 'en': 'Retry', 'ja': '再試行', 'zh': '重试'});
  String get next => _get({'ko': '다음', 'en': 'Next', 'ja': '次へ', 'zh': '下一步'});
  String get previous => _get({'ko': '이전', 'en': 'Previous', 'ja': '前へ', 'zh': '上一步'});
  String get done => _get({'ko': '완료', 'en': 'Done', 'ja': '完了', 'zh': '完成'});
  String get all => _get({'ko': '전체', 'en': 'All', 'ja': 'すべて', 'zh': '全部'});
  String get today => _get({'ko': '오늘', 'en': 'Today', 'ja': '今日', 'zh': '今天'});
  String get yesterday => _get({'ko': '어제', 'en': 'Yesterday', 'ja': '昨日', 'zh': '昨天'});
  String get tomorrow => _get({'ko': '내일', 'en': 'Tomorrow', 'ja': '明日', 'zh': '明天'});
  
  // ========== 온보딩 ==========
  String get onboardingStart => _get({'ko': '시작하기', 'en': 'Get Started', 'ja': '始める', 'zh': '开始'});
  String get onboardingWelcome => _get({'ko': '기쁨과 감사의 마음을\n주변 사람들과 나누세요', 'en': 'Share joy and gratitude\nwith people around you', 'ja': '喜びと感謝の気持ちを\n周りの人と分かち合いましょう', 'zh': '与周围的人分享\n喜悦和感恩'});
  String get onboardingDesc1 => _get({'ko': '마음이음은', 'en': 'Heart-Connect is', 'ja': 'ハートコネクトは', 'zh': '心连心是'});
  String get onboardingDesc2 => _get({'ko': '소중한 사람들에게', 'en': 'an app that lets you send', 'ja': '大切な人に', 'zh': '一款可以向'});
  String get onboardingDesc3 => _get({'ko': '따뜻한 카드와 메시지를', 'en': 'warm cards and messages', 'ja': '温かいカードとメッセージを', 'zh': '珍贵的人发送'});
  String get onboardingDesc4 => _get({'ko': '보낼 수 있는 앱입니다.', 'en': 'to your precious ones.', 'ja': '送れるアプリです。', 'zh': '温暖卡片和消息的应用。'});
  String get onboardingDesc5 => _get({'ko': '생일, 기념일, 특별한 날에', 'en': 'On birthdays, anniversaries,', 'ja': '誕生日、記念日、特別な日に', 'zh': '在生日、纪念日、特别的日子'});
  String get onboardingDesc6 => _get({'ko': '진심을 담은 마음을', 'en': 'and special days,', 'ja': '真心を込めた気持ちを', 'zh': '传递真心的'});
  String get onboardingDesc7 => _get({'ko': '전해보세요.', 'en': 'share your heartfelt feelings.', 'ja': '伝えてみてください。', 'zh': '心意吧。'});
  
  // ========== 권한 요청 ==========
  String get permissionContacts => _get({'ko': '연락처 접근 권한', 'en': 'Contacts Permission', 'ja': '連絡先へのアクセス権限', 'zh': '通讯录访问权限'});
  String get permissionCalendar => _get({'ko': '캘린더 접근 권한', 'en': 'Calendar Permission', 'ja': 'カレンダーへのアクセス権限', 'zh': '日历访问权限'});
  String get permissionWhyNeeded => _get({'ko': '왜 필요한가요?', 'en': 'Why is this needed?', 'ja': 'なぜ必要ですか？', 'zh': '为什么需要？'});
  String get permissionContactsDesc => _get({'ko': '연락처 정보는 가족, 친구들에게 카드를 보내기 위해 필요합니다.\n\n저장된 연락처에서 수신자를 쉽게 선택할 수 있어요.', 'en': 'Contact information is needed to send cards to family and friends.\n\nYou can easily select recipients from your saved contacts.', 'ja': '連絡先情報は家族や友人にカードを送るために必要です。\n\n保存した連絡先から受信者を簡単に選択できます。', 'zh': '通讯录信息用于向家人和朋友发送卡片。\n\n您可以轻松从保存的联系人中选择收件人。'});
  String get permissionCalendarDesc => _get({'ko': '캘린더 정보는 가족과 친구의 생일, 기념일, 이벤트 정보를 가져오기 위해 필요합니다.\n\n중요한 날을 놓치지 않고 미리 알림을 받을 수 있어요!', 'en': 'Calendar information is needed to get birthdays, anniversaries, and events of your family and friends.\n\nYou can receive reminders so you never miss important days!', 'ja': 'カレンダー情報は家族や友人の誕生日、記念日、イベント情報を取得するために必要です。\n\n大切な日を見逃さずにリマインダーを受け取れます！', 'zh': '日历信息用于获取家人和朋友的生日、纪念日和活动信息。\n\n这样您就不会错过重要的日子！'});
  String get permissionPrivacy => _get({'ko': '🔒 개인정보 보호 안내\n\n수집되는 정보는 사용자님의 핸드폰 안에서만 사용되며, 핸드폰 밖으로 반출되지 않습니다.', 'en': '🔒 Privacy Notice\n\nCollected information is only used within your phone and is never exported outside.', 'ja': '🔒 プライバシーに関するお知らせ\n\n収集された情報はお使いの端末内でのみ使用され、外部に送信されることはありません。', 'zh': '🔒 隐私保护说明\n\n收集的信息仅在您的手机中使用，不会导出到手机外。'});
  String get permissionAllow => _get({'ko': '접근 허용', 'en': 'Allow Access', 'ja': 'アクセスを許可', 'zh': '允许访问'});
  String get permissionAllowContacts => _get({'ko': '연락처 접근 허용', 'en': 'Allow Contacts Access', 'ja': '連絡先へのアクセスを許可', 'zh': '允许访问通讯录'});
  String get permissionAllowCalendar => _get({'ko': '캘린더 접근 허용', 'en': 'Allow Calendar Access', 'ja': 'カレンダーへのアクセスを許可', 'zh': '允许访问日历'});
  String get permissionSkip => _get({'ko': '나중에 설정하기', 'en': 'Set up later', 'ja': '後で設定する', 'zh': '稍后设置'});
  String get permissionSkipContacts => _get({'ko': '권한을 허용하지 않으시면 수동으로 연락처를 입력해야 합니다.', 'en': 'If you don\'t allow permission, you\'ll need to enter contacts manually.', 'ja': '権限を許可しない場合は、連絡先を手動で入力する必要があります。', 'zh': '如果不允许权限，您需要手动输入联系人。'});
  String get permissionSkipCalendar => _get({'ko': '권한을 허용하지 않으시면 수동으로 일정을 입력해야 합니다.', 'en': 'If you don\'t allow permission, you\'ll need to enter events manually.', 'ja': '権限を許可しない場合は、スケジュールを手動で入力する必要があります。', 'zh': '如果不允许权限，您需要手动输入日程。'});
  String get permissionSms => _get({'ko': 'SMS 접근 권한', 'en': 'SMS Permission', 'ja': 'SMSへのアクセス権限', 'zh': '短信访问权限'});
  String get permissionSmsDesc => _get({'ko': 'SMS 정보는 연락처와 주고받은 문자 메시지 내역을 확인하기 위해 필요합니다.\n\n카드를 보낸 후 문자로 안부를 주고받은 기록을 볼 수 있어요!', 'en': 'SMS permission is needed to view message history with your contacts.\n\nYou can see your text conversations after sending cards!', 'ja': 'SMS権限は連絡先とのメッセージ履歴を確認するために必要です。\n\nカード送信後のやり取りを確認できます！', 'zh': '短信权限用于查看与联系人的短信记录。\n\n发送卡片后可以查看短信往来记录！'});
  String get permissionAllowSms => _get({'ko': 'SMS 접근 허용', 'en': 'Allow SMS Access', 'ja': 'SMSへのアクセスを許可', 'zh': '允许访问短信'});
  String get permissionSkipSms => _get({'ko': '권한을 허용하지 않으시면 문자 메시지 내역을 볼 수 없습니다.', 'en': 'If you don\'t allow permission, you won\'t be able to see message history.', 'ja': '権限を許可しない場合は、メッセージ履歴を表示できません。', 'zh': '如果不允许权限，您将无法查看短信记录。'});
  
  // 사용자 이름 입력 (온보딩)
  String get onboardingEnterName => _get({'ko': '사용하실 이름을 입력하세요', 'en': 'Enter your name', 'ja': 'お名前を入力してください', 'zh': '请输入您的名字'});
  String get onboardingNameHint => _get({'ko': '이름 또는 별명', 'en': 'Name or nickname', 'ja': '名前またはニックネーム', 'zh': '姓名或昵称'});
  String get onboardingNameDesc => _get({'ko': '이 이름은 카드의 서명(Footer)에 표시됩니다.\n설정에서 언제든지 변경할 수 있습니다.', 'en': 'This name will appear as your signature on cards.\nYou can change it anytime in Settings.', 'ja': 'この名前はカードの署名として表示されます。\n設定でいつでも変更できます。', 'zh': '此名称将显示为卡片上的签名。\n您可以随时在设置中更改。'});
  String get onboardingNameRequired => _get({'ko': '이름을 입력해주세요', 'en': 'Please enter your name', 'ja': '名前を入力してください', 'zh': '请输入您的名字'});
  String get onboardingContinue => _get({'ko': '계속하기', 'en': 'Continue', 'ja': '続ける', 'zh': '继续'});
  
  // SMS 발송 권한
  String get permissionSendSms => _get({'ko': 'SMS 발송 권한', 'en': 'SMS Sending Permission', 'ja': 'SMS送信権限', 'zh': '短信发送权限'});
  String get permissionSendSmsDesc => _get({'ko': '카드를 문자로 직접 발송하려면 SMS 발송 권한이 필요합니다.\n\n이 권한이 없으면 문자 앱을 통해서만 발송할 수 있습니다.', 'en': 'SMS sending permission is required to send cards directly via text message.\n\nWithout this permission, you can only send via the messaging app.', 'ja': 'カードを直接SMSで送信するには、SMS送信権限が必要です。\n\nこの権限がないと、メッセージアプリ経由でのみ送信できます。', 'zh': '需要短信发送权限才能直接通过短信发送卡片。\n\n没有此权限，您只能通过短信应用发送。'});
  String get permissionAllowSendSms => _get({'ko': 'SMS 발송 허용', 'en': 'Allow SMS Sending', 'ja': 'SMS送信を許可', 'zh': '允许发送短信'});
  
  // ========== 네비게이션 ==========
  String get navHome => _get({'ko': '홈', 'en': 'Home', 'ja': 'ホーム', 'zh': '首页'});
  String get navContacts => _get({'ko': '연락처', 'en': 'Contacts', 'ja': '連絡先', 'zh': '通讯录'});
  String get navGallery => _get({'ko': '갤러리', 'en': 'Gallery', 'ja': 'ギャラリー', 'zh': '图库'});
  String get navMessages => _get({'ko': '메시지', 'en': 'Messages', 'ja': 'メッセージ', 'zh': '消息'});
  String get navSettings => _get({'ko': '설정', 'en': 'Settings', 'ja': '設定', 'zh': '设置'});
  
  // ========== 홈 화면 ==========
  String get homeUpcoming => _get({'ko': '다가오는 일정', 'en': 'Upcoming Events', 'ja': '予定されているイベント', 'zh': '即将到来的日程'});
  String get homeNoEvents => _get({'ko': '예정된 일정이 없습니다', 'en': 'No scheduled events', 'ja': '予定されているイベントはありません', 'zh': '没有预定的日程'});
  String get homeQuickSend => _get({'ko': '빠른 발송', 'en': 'Quick Send', 'ja': 'クイック送信', 'zh': '快速发送'});
  String get homeRecentCards => _get({'ko': '최근 보낸 카드', 'en': 'Recent Cards', 'ja': '最近送ったカード', 'zh': '最近发送的卡片'});
  String get homeWriteCard => _get({'ko': '카드 작성', 'en': 'Write Card', 'ja': 'カードを作成', 'zh': '写卡片'});
  String get homeDaysLeft => _get({'ko': '일 남음', 'en': 'days left', 'ja': '日後', 'zh': '天后'});
  String get homeDDay => _get({'ko': 'D-Day', 'en': 'D-Day', 'ja': '当日', 'zh': '当天'});
  
  // ========== 연락처 ==========
  String get contactsTitle => _get({'ko': '연락처', 'en': 'Contacts', 'ja': '連絡先', 'zh': '通讯录'});
  String get contactsAll => _get({'ko': '전체', 'en': 'All', 'ja': 'すべて', 'zh': '全部'});
  String get contactsFamily => _get({'ko': '가족', 'en': 'Family', 'ja': '家族', 'zh': '家人'});
  String get contactsFriends => _get({'ko': '친구', 'en': 'Friends', 'ja': '友人', 'zh': '朋友'});
  String get contactsWork => _get({'ko': '직장', 'en': 'Work', 'ja': '仕事', 'zh': '工作'});
  String get contactsOthers => _get({'ko': '기타', 'en': 'Others', 'ja': 'その他', 'zh': '其他'});
  String get contactsFavorites => _get({'ko': '즐겨찾기', 'en': 'Favorites', 'ja': 'お気に入り', 'zh': '收藏'});
  String get contactsEmpty => _get({'ko': '연락처가 없습니다', 'en': 'No contacts', 'ja': '連絡先がありません', 'zh': '没有联系人'});
  String get contactsSearchHint => _get({'ko': '이름 또는 전화번호 검색', 'en': 'Search name or phone number', 'ja': '名前または電話番号で検索', 'zh': '搜索姓名或电话号码'});
  String get contactsMyPeople => _get({'ko': '내 사람들', 'en': 'My People', 'ja': 'マイピープル', 'zh': '我的人脉'});
  String get contactsMemories => _get({'ko': '추억 기록', 'en': 'Memories', 'ja': '思い出', 'zh': '回忆记录'});
  String get contactsRecent => _get({'ko': '최근 연락', 'en': 'Recent', 'ja': '最近', 'zh': '最近联系'});
  String get contactsSearchPlaceholder => _get({'ko': '이름, 태그 검색', 'en': 'Search name, tag', 'ja': '名前、タグで検索', 'zh': '搜索姓名、标签'});
  String get contactsNoMemories => _get({'ko': '아직 추억 기록이 없습니다.', 'en': 'No memories yet.', 'ja': 'まだ思い出がありません。', 'zh': '还没有回忆记录。'});
  
  // ========== 공유하기 ==========
  String get shareTitle => _get({'ko': '공유하기', 'en': 'Share', 'ja': '共有する', 'zh': '分享'});
  String get shareOtherApps => _get({'ko': '기타 앱으로 공유', 'en': 'Share to other apps', 'ja': '他のアプリで共有', 'zh': '分享到其他应用'});
  String get shareKakaoTalk => _get({'ko': '카카오톡', 'en': 'KakaoTalk', 'ja': 'カカオトーク', 'zh': 'KakaoTalk'});
  String get shareInstagram => _get({'ko': '인스타그램', 'en': 'Instagram', 'ja': 'Instagram', 'zh': 'Instagram'});
  String get shareFacebook => _get({'ko': '페이스북', 'en': 'Facebook', 'ja': 'Facebook', 'zh': 'Facebook'});
  String get shareTwitter => _get({'ko': 'X (트위터)', 'en': 'X (Twitter)', 'ja': 'X (Twitter)', 'zh': 'X (Twitter)'});
  String get shareWhatsApp => _get({'ko': 'WhatsApp', 'en': 'WhatsApp', 'ja': 'WhatsApp', 'zh': 'WhatsApp'});
  String get shareTelegram => _get({'ko': '텔레그램', 'en': 'Telegram', 'ja': 'Telegram', 'zh': 'Telegram'});
  String get contactsSendCard => _get({'ko': '카드 보내기', 'en': 'Send Card', 'ja': 'カードを送る', 'zh': '发送卡片'});
  String get contactsCall => _get({'ko': '전화', 'en': 'Call', 'ja': '電話', 'zh': '打电话'});
  String get contactsMessage => _get({'ko': '문자', 'en': 'Message', 'ja': 'メッセージ', 'zh': '短信'});
  String get contactsBirthday => _get({'ko': '생일', 'en': 'Birthday', 'ja': '誕生日', 'zh': '生日'});
  String get contactsAnniversary => _get({'ko': '기념일', 'en': 'Anniversary', 'ja': '記念日', 'zh': '纪念日'});
  String get contactsNoHistory => _get({'ko': '주고받은 내역이 없습니다.', 'en': 'No message history.', 'ja': 'やり取りした履歴がありません。', 'zh': '没有消息记录。'});
  String get contactsSearchContent => _get({'ko': '내용 검색', 'en': 'Search content', 'ja': '内容を検索', 'zh': '搜索内容'});
  String get contactsNoSearchResult => _get({'ko': '검색 결과가 없습니다.', 'en': 'No search results.', 'ja': '検索結果がありません。', 'zh': '没有搜索结果。'});
  String get contactsMessageSent => _get({'ko': '보냄', 'en': 'Sent', 'ja': '送信', 'zh': '已发送'});
  String get contactsMessageReceived => _get({'ko': '받음', 'en': 'Received', 'ja': '受信', 'zh': '已接收'});
  
  // ========== 갤러리/카드 선택 ==========
  String get galleryTitle => _get({'ko': '카드 갤러리', 'en': 'Card Gallery', 'ja': 'カードギャラリー', 'zh': '卡片库'});
  String get galleryBirthday => _get({'ko': '생일', 'en': 'Birthday', 'ja': '誕生日', 'zh': '生日'});
  String get galleryChristmas => _get({'ko': '크리스마스', 'en': 'Christmas', 'ja': 'クリスマス', 'zh': '圣诞节'});
  String get galleryNewYear => _get({'ko': '새해', 'en': 'New Year', 'ja': '新年', 'zh': '新年'});
  String get galleryThanks => _get({'ko': '감사', 'en': 'Thanks', 'ja': '感謝', 'zh': '感谢'});
  String get galleryMothersDay => _get({'ko': '어버이날', 'en': "Parents' Day", 'ja': '父母の日', 'zh': '父母节'});
  String get galleryTeachersDay => _get({'ko': '스승의 날', 'en': "Teachers' Day", 'ja': '先生の日', 'zh': '教师节'});
  String get galleryHalloween => _get({'ko': '할로윈', 'en': 'Halloween', 'ja': 'ハロウィン', 'zh': '万圣节'});
  String get galleryThanksgiving => _get({'ko': '추수감사절', 'en': 'Thanksgiving', 'ja': '感謝祭', 'zh': '感恩节'});
  String get galleryTravel => _get({'ko': '여행', 'en': 'Travel', 'ja': '旅行', 'zh': '旅行'});
  String get galleryLetters => _get({'ko': '편지', 'en': 'Letters', 'ja': '手紙', 'zh': '信件'});
  String get galleryMyPhotos => _get({'ko': '내 사진', 'en': 'My Photos', 'ja': 'マイフォト', 'zh': '我的照片'});
  String get gallerySelectImage => _get({'ko': '이미지 선택', 'en': 'Select Image', 'ja': '画像を選択', 'zh': '选择图片'});
  
  // ========== 카드 편집 ==========
  String get cardEditorTitle => _get({'ko': '카드 편집', 'en': 'Edit Card', 'ja': 'カード編集', 'zh': '编辑卡片'});
  String get cardEditorAddText => _get({'ko': '텍스트 추가', 'en': 'Add Text', 'ja': 'テキストを追加', 'zh': '添加文字'});
  String get cardEditorAddSticker => _get({'ko': '스티커 추가', 'en': 'Add Sticker', 'ja': 'ステッカーを追加', 'zh': '添加贴纸'});
  String get cardEditorAddImage => _get({'ko': '이미지 추가', 'en': 'Add Image', 'ja': '画像を追加', 'zh': '添加图片'});
  String get cardEditorBackground => _get({'ko': '배경', 'en': 'Background', 'ja': '背景', 'zh': '背景'});
  String get cardEditorFont => _get({'ko': '폰트', 'en': 'Font', 'ja': 'フォント', 'zh': '字体'});
  String get cardEditorColor => _get({'ko': '색상', 'en': 'Color', 'ja': '色', 'zh': '颜色'});
  String get cardEditorSize => _get({'ko': '크기', 'en': 'Size', 'ja': 'サイズ', 'zh': '大小'});
  String get cardEditorPreview => _get({'ko': '미리보기', 'en': 'Preview', 'ja': 'プレビュー', 'zh': '预览'});
  String get cardEditorSend => _get({'ko': '발송', 'en': 'Send', 'ja': '送信', 'zh': '发送'});
  String get cardEditorSave => _get({'ko': '저장', 'en': 'Save', 'ja': '保存', 'zh': '保存'});
  String get cardEditorShare => _get({'ko': '공유', 'en': 'Share', 'ja': '共有', 'zh': '分享'});
  String get cardEditorEnterMessage => _get({'ko': '메시지를 입력하세요', 'en': 'Enter your message', 'ja': 'メッセージを入力してください', 'zh': '请输入消息'});
  String get cardEditorGenerateAI => _get({'ko': 'AI 메시지 생성', 'en': 'Generate AI Message', 'ja': 'AIメッセージを生成', 'zh': 'AI生成消息'});
  String get cardEditorTextBox => _get({'ko': '글상자', 'en': 'Text Box', 'ja': 'テキストボックス', 'zh': '文本框'});
  String get cardEditorZoomHint => _get({'ko': '클탭하시면 줌 모드로 전환됩니다', 'en': 'Tap to enter zoom mode', 'ja': 'タップでズームモードに切替', 'zh': '点击进入缩放模式'});
  String get cardEditorRecipient => _get({'ko': '발송대상', 'en': 'Recipient', 'ja': '送信先', 'zh': '收件人'});
  String get cardEditorAddRecipient => _get({'ko': '대상 추가', 'en': 'Add', 'ja': '追加', 'zh': '添加'});
  
  // ========== 발송 대상 선택 다이얼로그 ==========
  String get recipientSelectTitle => _get({'ko': '발송 대상 선택', 'en': 'Select Recipients', 'ja': '送信先を選択', 'zh': '选择收件人'});
  String get recipientSearchHint => _get({'ko': '이름 또는 전화번호...', 'en': 'Name or phone number...', 'ja': '名前または電話番号...', 'zh': '姓名或电话号码...'});
  String get recipientAddNew => _get({'ko': '새 연락처 추가', 'en': 'Add New Contact', 'ja': '新しい連絡先を追加', 'zh': '添加新联系人'});
  String get recipientName => _get({'ko': '이름', 'en': 'Name', 'ja': '名前', 'zh': '姓名'});
  String get recipientPhone => _get({'ko': '전화번호', 'en': 'Phone Number', 'ja': '電話番号', 'zh': '电话号码'});
  String get recipientAdd => _get({'ko': '추가', 'en': 'Add', 'ja': '追加', 'zh': '添加'});
  
  // ========== 카드 이미지 확인 다이얼로그 ==========
  String get cardPreviewTitle => _get({'ko': '카드 이미지 확인', 'en': 'Preview Card Image', 'ja': 'カード画像の確認', 'zh': '确认卡片图片'});
  String get cardPreviewDesc => _get({'ko': '수신자들에게 발송될 최종 이미지입니다.', 'en': 'This is the final image to be sent.', 'ja': '受信者に送信される最終画像です。', 'zh': '这是将要发送给收件人的最终图片。'});
  String get cardPreviewZoomHint => _get({'ko': '더블탭으로 확대/축소, 드래그로 이동이 가능합니다.', 'en': 'Double-tap to zoom, drag to move.', 'ja': 'ダブルタップで拡大/縮小、ドラッグで移動。', 'zh': '双击缩放，拖动移动。'});
  String get cardPreviewCheckHint => _get({'ko': '발송 전 이미지 결과물을 확인해 주세요.', 'en': 'Please check the image before sending.', 'ja': '送信前に画像を確認してください。', 'zh': '发送前请确认图片。'});
  String get cardPreviewConfirm => _get({'ko': '확인 (다음 단계)', 'en': 'Confirm (Next)', 'ja': '確認（次へ）', 'zh': '确认（下一步）'});
  
  // ========== 발송 ==========
  String get sendTitle => _get({'ko': '발송 관리', 'en': 'Send Manager', 'ja': '送信管理', 'zh': '发送管理'});
  String get sendRecipients => _get({'ko': '수신자', 'en': 'Recipients', 'ja': '受信者', 'zh': '收件人'});
  String get sendAddRecipient => _get({'ko': '수신자 추가', 'en': 'Add Recipient', 'ja': '受信者を追加', 'zh': '添加收件人'});
  String get sendStart => _get({'ko': '발송 시작', 'en': 'Start Sending', 'ja': '送信開始', 'zh': '开始发送'});
  String get sendStop => _get({'ko': '발송 중지', 'en': 'Stop Sending', 'ja': '送信停止', 'zh': '停止发送'});
  String get sendContinue => _get({'ko': '계속 발송', 'en': 'Continue Sending', 'ja': '送信を続ける', 'zh': '继续发送'});
  String get sendProgress => _get({'ko': '발송 진행 중', 'en': 'Sending in progress', 'ja': '送信中', 'zh': '正在发送'});
  String get sendComplete => _get({'ko': '발송 완료', 'en': 'Sending complete', 'ja': '送信完了', 'zh': '发送完成'});
  String get sendFailed => _get({'ko': '발송 실패', 'en': 'Sending failed', 'ja': '送信失敗', 'zh': '发送失败'});
  String get sendPending => _get({'ko': '대기 중', 'en': 'Pending', 'ja': '待機中', 'zh': '等待中'});
  String get sendTotalRecipients => _get({'ko': '총 수신자', 'en': 'Total recipients', 'ja': '受信者合計', 'zh': '总收件人'});
  String get sendAutoResume => _get({'ko': '5건 발송 후 자동 계속', 'en': 'Auto-continue after 5', 'ja': '5件送信後に自動続行', 'zh': '发送5条后自动继续'});
  String get sendManagerTitle => _get({'ko': '발송 대상 관리', 'en': 'Recipient Manager', 'ja': '送信先管理', 'zh': '收件人管理'});
  String get sendTotal => _get({'ko': '총', 'en': 'Total', 'ja': '合計', 'zh': '总计'});
  String get sendPerson => _get({'ko': '명', 'en': '', 'ja': '人', 'zh': '人'});
  String get sendSpamWarning => _get({'ko': '단시간 다량 발송은 스팸 정책에 의해 제한될 수 있습니다.\n안전을 위해 자동 계속 해제를 권장합니다.', 'en': 'Bulk sending may be limited by spam policies.\nDisabling auto-continue is recommended.', 'ja': '短時間での大量送信はスパムポリシーにより制限される場合があります。\n自動続行の無効化をお勧めします。', 'zh': '短时间内大量发送可能受到限制。\n建议关闭自动继续。'});
  
  // ========== 메시지/기록 ==========
  String get messageHistory => _get({'ko': '발송 기록', 'en': 'Send History', 'ja': '送信履歴', 'zh': '发送记录'});
  String get messageNoHistory => _get({'ko': '발송 기록이 없습니다', 'en': 'No send history', 'ja': '送信履歴がありません', 'zh': '没有发送记录'});
  String get messageSent => _get({'ko': '발송 완료', 'en': 'Sent', 'ja': '送信済み', 'zh': '已发送'});
  String get messageViewed => _get({'ko': '확인함', 'en': 'Viewed', 'ja': '確認済み', 'zh': '已查看'});
  
  // ========== 설정 ==========
  String get settingsTitle => _get({'ko': '설정', 'en': 'Settings', 'ja': '設定', 'zh': '设置'});
  String get settingsProfile => _get({'ko': '프로필', 'en': 'Profile', 'ja': 'プロフィール', 'zh': '个人资料'});
  String get settingsName => _get({'ko': '이름', 'en': 'Name', 'ja': '名前', 'zh': '姓名'});
  String get settingsLanguage => _get({'ko': '언어', 'en': 'Language', 'ja': '言語', 'zh': '语言'});
  String get settingsNotifications => _get({'ko': '알림', 'en': 'Alerts', 'ja': '通知', 'zh': '通知'});
  String get settingsNotificationTime => _get({'ko': '알림 시간', 'en': 'Alert Time', 'ja': '通知時刻', 'zh': '通知时间'});
  String get settingsReceiveAlerts => _get({'ko': '알림 받기', 'en': 'Receive Alerts', 'ja': 'アラートを受け取る', 'zh': '接收提醒'});
  String get settingsSetTime => _get({'ko': '시간 설정', 'en': 'Set Time', 'ja': '時間設定', 'zh': '设置时间'});
  String get settingsDesignSending => _get({'ko': '디자인/발송', 'en': 'Design', 'ja': 'デザイン', 'zh': '设计'});
  String get settingsCardBranding => _get({'ko': '카드 하단 브랜딩', 'en': 'Card Branding', 'ja': 'カードブランディング', 'zh': '卡片品牌'});
  String get settingsDataManage => _get({'ko': '데이터 관리', 'en': 'Data', 'ja': 'データ', 'zh': '数据'});
  String get settingsBranding => _get({'ko': '브랜딩 표시', 'en': 'Show Branding', 'ja': 'ブランディング表示', 'zh': '显示品牌'});
  String get settingsSync => _get({'ko': '동기화', 'en': 'Sync', 'ja': '同期', 'zh': '同步'});
  String get settingsSyncContacts => _get({'ko': '연락처 동기화', 'en': 'Sync Contacts', 'ja': '連絡先を同期', 'zh': '同步通讯录'});
  String get settingsSyncCalendar => _get({'ko': '캘린더 동기화', 'en': 'Sync Calendar', 'ja': 'カレンダーを同期', 'zh': '同步日历'});
  String get settingsBackup => _get({'ko': '백업', 'en': 'Backup', 'ja': 'バックアップ', 'zh': '备份'});
  String get settingsRestore => _get({'ko': '복원', 'en': 'Restore', 'ja': '復元', 'zh': '恢复'});
  String get settingsExport => _get({'ko': '내보내기', 'en': 'Export', 'ja': 'エクスポート', 'zh': '导出'});
  String get settingsImport => _get({'ko': '가져오기', 'en': 'Import', 'ja': 'インポート', 'zh': '导入'});
  String get settingsCalendarSync => _get({'ko': '캘린더 연동', 'en': 'Calendar', 'ja': 'カレンダー', 'zh': '日历'});
  String get settingsOpenCalendar => _get({'ko': '캘린더 열기', 'en': 'Open Calendar', 'ja': 'カレンダーを開く', 'zh': '打开日历'});
  String get settingsCalendarGuide => _get({'ko': '지원 캘린더 안내', 'en': 'Calendar Guide', 'ja': 'カレンダーガイド', 'zh': '日历指南'});
  String get settingsAppInfo => _get({'ko': '앱 정보', 'en': 'App Info', 'ja': 'アプリ情報', 'zh': '应用信息'});
  String get settingsContactUs => _get({'ko': '문의하기', 'en': 'Contact', 'ja': 'お問合せ', 'zh': '联系我们'});
  String get settingsAccount => _get({'ko': '계정', 'en': 'Account', 'ja': 'アカウント', 'zh': '账户'});
  String get settingsExit => _get({'ko': '나가기', 'en': 'Exit', 'ja': '終了', 'zh': '退出'});
  String get settingsMyName => _get({'ko': '내 이름/별명', 'en': 'My Name', 'ja': '名前/ニックネーム', 'zh': '我的名字'});
  String get settingsNameOrNickname => _get({'ko': '이름 또는 별명', 'en': 'Name or nickname', 'ja': '名前またはニックネーム', 'zh': '姓名或昵称'});
  String get settingsNameHint => _get({'ko': '카드에 표시될 이름', 'en': 'Name shown on cards', 'ja': 'カードに表示される名前', 'zh': '卡片上显示的名字'});
  String get settingsNameUsageInfo => _get({'ko': '이 이름은 카드 쓰기 화면의 Footer(서명)에 사용됩니다.', 'en': 'This name is used as the footer signature on cards.', 'ja': 'この名前はカードのフッター署名に使用されます。', 'zh': '此名称将用于卡片的页脚签名。'});
  String get settingsAbout => _get({'ko': '앱 정보', 'en': 'About', 'ja': 'アプリ情報', 'zh': '关于应用'});
  String get settingsVersion => _get({'ko': '버전', 'en': 'Version', 'ja': 'バージョン', 'zh': '版本'});
  String get settingsPrivacy => _get({'ko': '개인정보 처리방침', 'en': 'Privacy Policy', 'ja': 'プライバシーポリシー', 'zh': '隐私政策'});
  String get settingsTerms => _get({'ko': '이용약관', 'en': 'Terms of Service', 'ja': '利用規約', 'zh': '使用条款'});
  String get settingsHelp => _get({'ko': '도움말', 'en': 'Help', 'ja': 'ヘルプ', 'zh': '帮助'});
  
  // ========== 스플래시/로딩 ==========
  String get splashPreparing => _get({'ko': '준비 중...', 'en': 'Preparing...', 'ja': '準備中...', 'zh': '准备中...'});
  String get splashLoadingData => _get({'ko': '데이터를 불러오는 중...', 'en': 'Loading data...', 'ja': 'データを読み込み中...', 'zh': '正在加载数据...'});
  String get splashSyncingContacts => _get({'ko': '연락처를 동기화하는 중...', 'en': 'Syncing contacts...', 'ja': '連絡先を同期中...', 'zh': '正在同步通讯录...'});
  String get splashSyncingCalendar => _get({'ko': '캘린더를 동기화하는 중...', 'en': 'Syncing calendar...', 'ja': 'カレンダーを同期中...', 'zh': '正在同步日历...'});
  String get splashGeneratingSchedules => _get({'ko': '일정을 생성하는 중...', 'en': 'Generating schedules...', 'ja': 'スケジュールを作成中...', 'zh': '正在生成日程...'});
  String get splashPreparingScreen => _get({'ko': '화면을 준비하는 중...', 'en': 'Preparing screen...', 'ja': '画面を準備中...', 'zh': '正在准备屏幕...'});
  String get splashReady => _get({'ko': '준비 완료!', 'en': 'Ready!', 'ja': '準備完了！', 'zh': '准备完成！'});
  String helloUser(String name) => _get({'ko': '안녕하세요, $name 님! 👋', 'en': 'Hello, $name! 👋', 'ja': 'こんにちは、$name さん！👋', 'zh': '你好，$name！👋'});
  
  // ========== 에러 메시지 ==========
  String get errorNetwork => _get({'ko': '네트워크 오류가 발생했습니다', 'en': 'Network error occurred', 'ja': 'ネットワークエラーが発生しました', 'zh': '网络错误'});
  String get errorUnknown => _get({'ko': '알 수 없는 오류가 발생했습니다', 'en': 'Unknown error occurred', 'ja': '不明なエラーが発生しました', 'zh': '发生未知错误'});
  String get errorPermission => _get({'ko': '권한이 필요합니다', 'en': 'Permission required', 'ja': '権限が必要です', 'zh': '需要权限'});
  String get errorLoadFailed => _get({'ko': '데이터를 불러오지 못했습니다', 'en': 'Failed to load data', 'ja': 'データの読み込みに失敗しました', 'zh': '加载数据失败'});
  String get errorSaveFailed => _get({'ko': '저장에 실패했습니다', 'en': 'Failed to save', 'ja': '保存に失敗しました', 'zh': '保存失败'});
  String get errorSendFailed => _get({'ko': '발송에 실패했습니다', 'en': 'Failed to send', 'ja': '送信に失敗しました', 'zh': '发送失败'});
  String get errorImageFailed => _get({'ko': '이미지 처리에 실패했습니다', 'en': 'Failed to process image', 'ja': '画像の処理に失敗しました', 'zh': '图片处理失败'});
  
  // ========== 확인 다이얼로그 ==========
  String get confirmDelete => _get({'ko': '정말 삭제하시겠습니까?', 'en': 'Are you sure you want to delete?', 'ja': '本当に削除しますか？', 'zh': '确定要删除吗？'});
  String get confirmExit => _get({'ko': '변경사항을 저장하지 않고 나가시겠습니까?', 'en': 'Exit without saving changes?', 'ja': '変更を保存せずに終了しますか？', 'zh': '不保存更改就退出吗？'});
  String get confirmSend => _get({'ko': '발송하시겠습니까?', 'en': 'Do you want to send?', 'ja': '送信しますか？', 'zh': '确定要发送吗？'});
  
  // ========== 날짜/시간 ==========
  String get dateToday => _get({'ko': '오늘', 'en': 'Today', 'ja': '今日', 'zh': '今天'});
  String get dateTomorrow => _get({'ko': '내일', 'en': 'Tomorrow', 'ja': '明日', 'zh': '明天'});
  String get dateYesterday => _get({'ko': '어제', 'en': 'Yesterday', 'ja': '昨日', 'zh': '昨天'});
  String get dateThisWeek => _get({'ko': '이번 주', 'en': 'This week', 'ja': '今週', 'zh': '本周'});
  String get dateNextWeek => _get({'ko': '다음 주', 'en': 'Next week', 'ja': '来週', 'zh': '下周'});
  String get dateThisMonth => _get({'ko': '이번 달', 'en': 'This month', 'ja': '今月', 'zh': '本月'});
  String daysRemaining(int days) => _get({'ko': '$days일 남음', 'en': '$days days left', 'ja': 'あと$days日', 'zh': '还剩$days天'});
  
  // ========== 이벤트 종류 ==========
  String get eventBirthday => _get({'ko': '생일', 'en': 'Birthday', 'ja': '誕生日', 'zh': '生日'});
  String get eventAnniversary => _get({'ko': '기념일', 'en': 'Anniversary', 'ja': '記念日', 'zh': '纪念日'});
  String get eventHoliday => _get({'ko': '공휴일', 'en': 'Holiday', 'ja': '祝日', 'zh': '节日'});
  String get eventMeeting => _get({'ko': '모임', 'en': 'Meeting', 'ja': '集まり', 'zh': '聚会'});
  String get eventOther => _get({'ko': '기타', 'en': 'Other', 'ja': 'その他', 'zh': '其他'});
  
  // ========== 일정 관리 다이얼로그 ==========
  String get scheduleEdit => _get({'ko': '일정 수정', 'en': 'Edit', 'ja': '編集', 'zh': '编辑'});
  String get scheduleAdd => _get({'ko': '일정 추가', 'en': 'Add', 'ja': '追加', 'zh': '添加'});
  String get scheduleAddNew => _get({'ko': '새 일정', 'en': 'New', 'ja': '新規', 'zh': '新建'});
  String get scheduleTitle => _get({'ko': '제목', 'en': 'Title', 'ja': 'タイトル', 'zh': '标题'});
  String get scheduleRecipients => _get({'ko': '수신자', 'en': 'To', 'ja': '宛先', 'zh': '收件人'});
  String get scheduleDate => _get({'ko': '날짜', 'en': 'Date', 'ja': '日付', 'zh': '日期'});
  String get scheduleIconType => _get({'ko': '아이콘', 'en': 'Icon', 'ja': 'アイコン', 'zh': '图标'});
  String get scheduleAddToCalendar => _get({'ko': '캘린더에 추가', 'en': 'Add to Calendar', 'ja': 'カレンダーに追加', 'zh': '添加到日历'});
  String get scheduleAddedSuccess => _get({'ko': '일정이 추가되었습니다!', 'en': 'Schedule added!', 'ja': 'スケジュール追加！', 'zh': '日程已添加！'});
  
  // ========== 일정 옵션 메뉴 ==========
  String get planEdit => _get({'ko': '수정', 'en': 'Edit', 'ja': '編集', 'zh': '编辑'});
  String get planDelete => _get({'ko': '삭제', 'en': 'Delete', 'ja': '削除', 'zh': '删除'});
  String get planMoveToEnd => _get({'ko': '끝으로 이동', 'en': 'Move to End', 'ja': '最後に移動', 'zh': '移到末尾'});
  String get planReschedule => _get({'ko': '날짜 변경', 'en': 'Reschedule', 'ja': '日程変更', 'zh': '改期'});
  String get planChangeIcon => _get({'ko': '아이콘 변경', 'en': 'Change Icon', 'ja': 'アイコン変更', 'zh': '更改图标'});
  String get planSelectIcon => _get({'ko': '아이콘 선택', 'en': 'Select Icon', 'ja': 'アイコン選択', 'zh': '选择图标'});
  String planDeleteConfirm(String title) => _get({'ko': '"$title"을(를) 삭제하시겠습니까?', 'en': 'Delete "$title"?', 'ja': '「$title」を削除しますか？', 'zh': '删除"$title"？'});
  
  // ========== 아이콘 타입 (짧은 버전) ==========
  String get iconNormal => _get({'ko': '일반', 'en': 'Normal', 'ja': '通常', 'zh': '普通'});
  String get iconHoliday => _get({'ko': '휴일', 'en': 'Holiday', 'ja': '祝日', 'zh': '节日'});
  String get iconBirthday => _get({'ko': '생일', 'en': 'Birthday', 'ja': '誕生日', 'zh': '生日'});
  String get iconAnniversary => _get({'ko': '기념일', 'en': 'Anniv.', 'ja': '記念日', 'zh': '纪念'});
  String get iconWork => _get({'ko': '업무', 'en': 'Work', 'ja': '仕事', 'zh': '工作'});
  String get iconPersonal => _get({'ko': '개인', 'en': 'Personal', 'ja': '個人', 'zh': '个人'});
  String get iconImportant => _get({'ko': '중요', 'en': 'Important', 'ja': '重要', 'zh': '重要'});
  
  // ========== 카드 ==========
  String get cardWrite => _get({'ko': '작성', 'en': 'Write', 'ja': '作成', 'zh': '写'});
  
  // ========== 언어 선택 ==========
  String get languageSelection => _get({'ko': '언어 선택', 'en': 'Select Language', 'ja': '言語選択', 'zh': '选择语言'});
  String get previousLanguage => _get({'ko': '이전 언어', 'en': 'Previous Language', 'ja': '前の言語', 'zh': '上一语言'});
  String get nextLanguage => _get({'ko': '다음 언어', 'en': 'Next Language', 'ja': '次の言語', 'zh': '下一语言'});
  
  // ========== 미리보기 ==========
  String get previewTitle => _get({'ko': '미리보기', 'en': 'Preview', 'ja': 'プレビュー', 'zh': '预览'});
  String get previewConfirm => _get({'ko': '이 이미지로 발송하시겠습니까?', 'en': 'Send with this image?', 'ja': 'この画像で送信しますか？', 'zh': '使用此图片发送？'});
  
  // Helper method
  String _get(Map<String, String> translations) {
    return translations[languageCode] ?? translations['ko'] ?? translations['en'] ?? '';
  }
}

/// AppStrings Provider
final appStringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(localeProvider);
  return AppStrings(locale.languageCode);
});

/// Context extension for easy access
extension AppStringsExtension on BuildContext {
  AppStrings get strings => ProviderScope.containerOf(this).read(appStringsProvider);
}
