/// Cloud services that can recognise speech and/or translate to Arabic.
/// Everything the data layer needs to talk to them lives here, so adding a
/// provider (or fixing a renamed model) is a one-line change.
enum OnlineProvider {
  openai(
    id: 'openai',
    name: 'OpenAI',
    speech: true,
    translation: true,
    keyUrl: 'https://platform.openai.com/api-keys',
    baseUrl: 'https://api.openai.com/v1',
    speechModel: 'whisper-1',
    translationModel: 'gpt-4o-mini',
    jsonMode: true,
    noteAr: 'مدفوع (رصيد على الاستهلاك). جودة ممتازة.',
    noteEn: 'Paid (pay-as-you-go credit). Excellent quality.',
  ),
  groq(
    id: 'groq',
    name: 'Groq',
    speech: true,
    translation: true,
    keyUrl: 'https://console.groq.com/keys',
    baseUrl: 'https://api.groq.com/openai/v1',
    speechModel: 'whisper-large-v3-turbo',
    translationModel: 'llama-3.3-70b-versatile',
    jsonMode: true,
    noteAr:
        'طبقة مجانية بحدود (حوالي ساعتين صوت في الساعة). الأنسب للتجربة المجانية.',
    noteEn:
        'Free tier with limits (about 2 audio hours per hour). Best free option.',
  ),
  gemini(
    id: 'gemini',
    name: 'Google Gemini',
    translation: true,
    keyUrl: 'https://aistudio.google.com/apikey',
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
    translationModel: 'gemini-2.5-flash',
    noteAr: 'ترجمة فقط. طبقة مجانية بحدود تتغير، من Google AI Studio.',
    noteEn:
        'Translation only. Free tier with changing limits, from Google AI Studio.',
  ),
  openrouter(
    id: 'openrouter',
    name: 'OpenRouter',
    translation: true,
    keyUrl: 'https://openrouter.ai/keys',
    baseUrl: 'https://openrouter.ai/api/v1',
    translationModel: 'meta-llama/llama-3.3-70b-instruct:free',
    noteAr:
        'ترجمة فقط. نماذج مجانية (٢٠ طلب/دقيقة، و٥٠ طلب/يوم بدون رصيد). أسماء النماذج المجانية تتغير.',
    noteEn:
        'Translation only. Free models (20 req/min, 50 req/day without credit). Free model names change.',
  ),
  deepgram(
    id: 'deepgram',
    name: 'Deepgram',
    speech: true,
    keyUrl: 'https://console.deepgram.com',
    baseUrl: 'https://api.deepgram.com/v1',
    speechModel: 'nova-3',
    noteAr: 'تحويل الكلام فقط. رصيد تجريبي مجاني عند التسجيل.',
    noteEn: 'Speech only. Free starter credit on sign-up.',
  ),
  deepl(
    id: 'deepl',
    name: 'DeepL',
    translation: true,
    keyUrl: 'https://www.deepl.com/your-account/keys',
    baseUrl: 'https://api-free.deepl.com/v2',
    noteAr:
        'ترجمة فقط، جودة عالية. باقة API Free بحد شهري (تحتاج بطاقة عند التسجيل).',
    noteEn:
        'Translation only, high quality. API Free plan has a monthly cap (needs a card to sign up).',
  ),
  mymemory(
    id: 'mymemory',
    name: 'MyMemory',
    translation: true,
    needsKey: false,
    keyUrl: 'https://mymemory.translated.net',
    baseUrl: 'https://api.mymemory.translated.net',
    noteAr:
        'ترجمة فقط، بدون مفتاح، لكن بحد يومي صغير وجودة أقل. مناسب لسطر أو سطرين.',
    noteEn:
        'Translation only, no key, but a small daily cap and lower quality. Fine for a line or two.',
  )
  ;

  const OnlineProvider({
    required this.id,
    required this.name,
    required this.keyUrl,
    required this.baseUrl,
    required this.noteAr,
    required this.noteEn,
    this.speech = false,
    this.translation = false,
    this.needsKey = true,
    this.speechModel = '',
    this.translationModel = '',
    this.jsonMode = false,
  });

  final String id;
  final String name;
  final bool speech;
  final bool translation;
  final bool needsKey;
  final String keyUrl;
  final String baseUrl;
  final String speechModel;
  final String translationModel;

  /// The chat endpoint accepts `response_format: json_object`.
  final bool jsonMode;
  final String noteAr;
  final String noteEn;

  static List<OnlineProvider> get speechProviders =>
      values.where((p) => p.speech).toList();
  static List<OnlineProvider> get translationProviders =>
      values.where((p) => p.translation).toList();

  static OnlineProvider fromId(String? id, {required bool speech}) {
    final pool = speech ? speechProviders : translationProviders;
    return pool.firstWhere(
      (p) => p.id == id,
      orElse: () => OnlineProvider.groq,
    );
  }
}
