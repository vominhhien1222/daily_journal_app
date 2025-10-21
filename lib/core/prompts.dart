import 'dart:math';

class Prompts {
  static final _rand = Random();

  static const List<String> dailyQuotes = [
    "Hôm nay bạn cảm thấy thế nào? ✍️",
    "Đừng quên ghi lại một khoảnh khắc nhỏ trong ngày 💌",
    "Cảm xúc là cơn mưa, hãy để nó trôi đi nhẹ nhàng 🌧️",
    "Bạn đã làm tốt lắm hôm nay rồi đó 💖",
    "Một ngày bình yên đáng để nhớ lại ☕",
  ];

  static const List<String> happy = [
    "Một ngày tuyệt vời nên được ghi lại ☀️",
    "Niềm vui hôm nay sẽ là ký ức đẹp mai sau 🌼",
  ];
  static const List<String> calm = [
    "Cảm xúc nhẹ như gió... hãy viết lại để nhớ 🌿",
    "Bình yên cũng là cảm xúc đáng lưu lại ☕",
  ];

  static String randomQuote() {
    return dailyQuotes[_rand.nextInt(dailyQuotes.length)];
  }
}
