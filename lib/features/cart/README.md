# Cart Feature – Flutter Clean Architecture

## 📁 Folder Structure
```
cart_feature/
├── domain/
│   ├── entities/
│   │   ├── cart_item.dart
│   │   └── cart_summary.dart
│   ├── repositories/
│   │   └── cart_repository.dart        ← abstract interface
│   └── usecases/
│       └── cart_usecases.dart
├── data/
│   ├── models/
│   │   └── cart_item_model.dart
│   ├── datasources/
│   │   └── cart_local_datasource.dart
│   └── repositories/
│       └── cart_repository_impl.dart
├── presentation/
│   ├── bloc/
│   │   ├── cart_bloc.dart
│   │   ├── cart_event.dart
│   │   └── cart_state.dart
│   ├── pages/
│   │   └── cart_page.dart
│   └── widgets/
│       ├── cart_item_card.dart
│       ├── cart_summary_card.dart
│       └── share_cart_overlay.dart
└── injection_container.dart
```

## 📦 Required Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter_bloc: ^8.1.6
  get_it: ^7.7.0
  equatable: ^2.0.5
```

## 🚀 Setup

### 1. Register dependencies in main.dart
```dart
import 'cart_feature/injection_container.dart';

void main() {
  initCartDependencies();
  runApp(const MyApp());
}
```

### 2. Navigate to CartPage
```dart
BlocProvider(
  create: (_) => sl<CartBloc>(),
  child: const CartPage(),
)
```

## ✨ Features Implemented
- ✅ Cart items list with images, name, price, quantity
- ✅ Increment / Decrement quantity
- ✅ Swipe-to-delete with trash icon reveal (Dismissible)
- ✅ Promo code input + apply (try code: `SAVE50`)
- ✅ Cart summary: subtotal, delivery, discount, total
- ✅ Share cart overlay with contacts + social icons
- ✅ BLoC state management
- ✅ Clean Architecture (Domain / Data / Presentation)
- ✅ Dependency Injection with get_it

## 🎨 Design
- Background: warm linen `#F7F2ED`
- Primary brown: `#7A5C3E`
- Share button accent: `#F0A830`
- Cards: pure white with soft shadow
- Quantity buttons: rounded square style matching the design
