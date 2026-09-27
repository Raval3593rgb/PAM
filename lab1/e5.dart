mixin Loggable {
  void log(String msg) {
    print('[$runtimeType] $msg');
  }
}

class CartService with Loggable {
  void addItem(String item) {
    log('товар добавлен: $item');
  }
}

class AuthService with Loggable {
  void login(String username) {
    log('пользователь вошёл: $username');
  }
}

void main() {
  CartService().addItem('Paracetamol');
  AuthService().login('ana.rusu');
}