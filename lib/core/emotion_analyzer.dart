class EmotionAnalyzer {
  // Danh sách từ khóa và điểm cảm xúc tương ứng
  static const Map<String, int> _emotionWords = {
    // 🎉 Tích cực
    'vui': 2,
    'hạnh phúc': 3,
    'tốt': 1,
    'tuyệt': 3,
    'yêu': 2,
    'cảm ơn': 2,
    'đáng yêu': 2,
    'bình yên': 2,
    'may mắn': 2,

    // 😞 Tiêu cực
    'buồn': -2,
    'mệt': -1,
    'tệ': -3,
    'cô đơn': -2,
    'stress': -3,
    'lo lắng': -2,
    'chán': -2,
    'giận': -1,
    'khóc': -2,
  };

  /// 🔍 Hàm phân tích cảm xúc từ nội dung nhật ký
  static String analyze(String text) {
    int score = 0;
    final lower = text.toLowerCase();

    for (final entry in _emotionWords.entries) {
      if (lower.contains(entry.key)) score += entry.value;
    }

    if (score >= 2) return 'Tích cực 😊';
    if (score <= -2) return 'Tiêu cực 😞';
    return 'Bình thường 😌';
  }
}
