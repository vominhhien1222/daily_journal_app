class AiResponder {
  static String respond(String mood) {
    switch (mood) {
      case 'Tích cực 😊':
        return "Thật tuyệt! Hãy tiếp tục lan tỏa năng lượng tích cực nhé 🌞";
      case 'Tiêu cực 😞':
        return "Không sao đâu, ngày mai sẽ tốt hơn. Hãy chăm sóc bản thân thật tốt 💖";
      case 'Bình thường 😌':
      default:
        return "Một ngày bình yên cũng là điều đáng quý 🌿";
    }
  }
}
