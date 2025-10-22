import 'dart:math';

class PromptSuggestions {
  static final List<String> _prompts = [
    "Điều gì khiến bạn mỉm cười hôm nay? 😊",
    "Ai là người khiến bạn thấy biết ơn nhất hiện tại?",
    "Một điều nhỏ khiến bạn hạnh phúc hôm nay là gì?",
    "Nếu được quay lại hôm nay, bạn muốn làm điều gì khác?",
    "Bạn học được gì từ một khó khăn gần đây?",
    "Hôm nay bạn dành thời gian cho bản thân như thế nào?",
    "Khoảnh khắc đáng nhớ nhất trong ngày là gì?",
    "Nếu mô tả hôm nay bằng 3 từ, đó sẽ là gì?",
  ];

  /// 🔀 Lấy ngẫu nhiên [count] gợi ý
  static List<String> randomSuggestions([int count = 3]) {
    _prompts.shuffle(Random());
    return _prompts.take(count).toList();
  }
}
