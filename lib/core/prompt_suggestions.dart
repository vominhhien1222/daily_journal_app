// 'dart:math';

class PromptSuggestions {
  ///
  static const Map<String, List<String>> _moodPrompts = {
    'Tích cực 😊': [
      'Hôm nay điều gì khiến bạn cảm thấy biết ơn nhất?',
      'Bạn đã đạt được điều gì khiến mình tự hào?',
      'Khoảnh khắc vui nhất trong ngày là gì?',
    ],
    'Tiêu cực 😞': [
      'Chuyện gì khiến bạn buồn hôm nay?',
      'Bạn có thể học được điều gì từ cảm xúc này?',
      'Điều gì sẽ giúp bạn cảm thấy khá hơn vào ngày mai?',
    ],
    'Bình thường 😌': [
      'Ngày hôm nay trôi qua thế nào?',
      'Có điều gì nhỏ bé khiến bạn mỉm cười không?',
      'Nếu chấm điểm ngày hôm nay, bạn sẽ cho bao nhiêu điểm?',
    ],
    'Bực 😠': [
      'Điều gì khiến bạn bực mình hôm nay?',
      'Cảm xúc này đến từ đâu, bạn có thể kiểm soát nó không?',
      'Lần tới nếu gặp lại tình huống này, bạn sẽ phản ứng khác đi chứ?',
    ],
  };

  /// 🔁 Trả về danh sách gợi ý tương ứng với cảm xúc (hoặc mặc định nếu chưa chọn)
  static List<String> getSuggestions(String? mood) {
    if (mood != null && _moodPrompts.containsKey(mood)) {
      return _moodPrompts[mood]!;
    }
    // Nếu chưa chọn cảm xúc → mặc định là "Bình thường"
    return _moodPrompts['Bình thường 😌']!;
  }
}
