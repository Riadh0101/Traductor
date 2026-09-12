class PhraseItem {
  final String english;
  final String arabic;

  const PhraseItem({required this.english, required this.arabic});
}

class PhraseCategory {
  final String title;
  final String titleArabic;
  final String emoji;
  final List<PhraseItem> phrases;

  const PhraseCategory({
    required this.title,
    required this.titleArabic,
    required this.emoji,
    required this.phrases,
  });
}

class TravelPhrasesData {
  static const List<PhraseCategory> categories = [
    PhraseCategory(
      title: 'Airport & Transit',
      titleArabic: 'المطار والسفر',
      emoji: '✈️',
      phrases: [
        PhraseItem(
          english: 'Where is the baggage claim area?',
          arabic: 'أين منطقة استلام الأمتعة؟',
        ),
        PhraseItem(
          english: 'Which gate is for my flight?',
          arabic: 'ما هي بوابة رحلتي؟',
        ),
        PhraseItem(
          english: 'Where is passport control and immigration?',
          arabic: 'أين قسم الجوازات والهجرة؟',
        ),
        PhraseItem(
          english: 'I have a connecting flight, where should I go?',
          arabic: 'لدي رحلة ترانزيت، إلى أين يجب أن أتوجه؟',
        ),
      ],
    ),
    PhraseCategory(
      title: 'Hotel & Stay',
      titleArabic: 'الفندق والإقامة',
      emoji: '🏨',
      phrases: [
        PhraseItem(
          english: 'Hello, I have a reservation under my name.',
          arabic: 'مرحباً، لدي حجز مسبق باسمي.',
        ),
        PhraseItem(
          english: 'What time is check-out?',
          arabic: 'ما هو موعد تسجيل المغادرة؟',
        ),
        PhraseItem(
          english: 'Can I store my luggage here for a few hours?',
          arabic: 'هل يمكنني إيداع حقائبي هنا لبضع ساعات؟',
        ),
        PhraseItem(
          english: 'What is the Wi-Fi password, please?',
          arabic: 'ما هي كلمة مرور شبكة الواي فاي من فضلك؟',
        ),
      ],
    ),
    PhraseCategory(
      title: 'Transport & Directions',
      titleArabic: 'المواصلات والاتجاهات',
      emoji: '🚖',
      phrases: [
        PhraseItem(
          english: 'Where is the nearest metro station?',
          arabic: 'أين تقع أقرب محطة مترو؟',
        ),
        PhraseItem(
          english: 'Please take me to this address.',
          arabic: 'من فضلك خذني إلى هذا العنوان.',
        ),
        PhraseItem(
          english: 'How much does the taxi to downtown cost?',
          arabic: 'كم تكلفة سيارة الأجرة إلى وسط المدينة؟',
        ),
        PhraseItem(
          english: 'Which bus goes to the city center?',
          arabic: 'أي حافلة تتجه إلى مركز المدينة؟',
        ),
      ],
    ),
    PhraseCategory(
      title: 'Restaurant & Dining',
      titleArabic: 'المطعم والمأكولات',
      emoji: '🍽️',
      phrases: [
        PhraseItem(
          english: 'Could we see the menu, please?',
          arabic: 'هل يمكننا الاطلاع على قائمة الطعام من فضلك؟',
        ),
        PhraseItem(
          english: 'Is this food halal or vegetarian?',
          arabic: 'هل هذا الطعام حلال أم نباتي؟',
        ),
        PhraseItem(
          english: 'Could we please have the bill?',
          arabic: 'هل يمكننا الحصول على الفاتورة والحساب؟',
        ),
        PhraseItem(
          english: 'Do you accept credit card payments?',
          arabic: 'هل تقبلون الدفع بالبطاقة الائتمانية؟',
        ),
      ],
    ),
    PhraseCategory(
      title: 'Medical & Emergency',
      titleArabic: 'الصحة والطوارئ',
      emoji: '🏥',
      phrases: [
        PhraseItem(
          english: 'I need urgent medical assistance.',
          arabic: 'أحتاج إلى مساعدة طبية عاجلة.',
        ),
        PhraseItem(
          english: 'Where is the nearest 24-hour pharmacy?',
          arabic: 'أين توجد أقرب صيدلية تعمل 24 ساعة؟',
        ),
        PhraseItem(
          english: 'Please call an ambulance immediately!',
          arabic: 'من فضلك اتصل بالإسعاف فوراً!',
        ),
        PhraseItem(
          english: 'I have lost my passport, where is the embassy or police?',
          arabic: 'لقد فقدت جواز سفري، أين قسم الشرطة أو السفارة؟',
        ),
      ],
    ),
    PhraseCategory(
      title: 'Shopping & Bargaining',
      titleArabic: 'التسوق والمشتريات',
      emoji: '🛍️',
      phrases: [
        PhraseItem(
          english: 'How much does this item cost?',
          arabic: 'كم سعر هذه السلعة؟',
        ),
        PhraseItem(
          english: 'Do you have this in another size or color?',
          arabic: 'هل يتوفر هذا بمقاس أو لون آخر؟',
        ),
        PhraseItem(
          english: 'Is there a discount on this?',
          arabic: 'هل يوجد خصم على هذا السعر؟',
        ),
        PhraseItem(
          english: 'Can I please have a receipt?',
          arabic: 'هل يمكنني الحصول على إيصال الشراء؟',
        ),
      ],
    ),
    PhraseCategory(
      title: 'Greetings & Courtesies',
      titleArabic: 'التحيات والمجاملات',
      emoji: '👋',
      phrases: [
        PhraseItem(
          english: 'Hello! Peace be upon you, nice to meet you.',
          arabic: 'مرحباً! السلام عليكم، تشرفت بلقائك.',
        ),
        PhraseItem(
          english: 'Thank you very much for your great kindness.',
          arabic: 'شكراً جزيلاً لك على لطفك ومساعدتك.',
        ),
        PhraseItem(
          english: 'Excuse me, do you speak English?',
          arabic: 'عفواً، هل تتحدث الإنجليزية؟',
        ),
        PhraseItem(
          english: 'Have a wonderful and blessed day!',
          arabic: 'أتمنى لك يوماً جميلاً وسعيداً!',
        ),
      ],
    ),
  ];
}
