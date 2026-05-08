import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_resep_winda/main.dart';

void main() {
  testWidgets('menampilkan halaman login saat belum masuk', (tester) async {
    await tester.pumpWidget(const RecipeApp(isLoggedIn: false));

    expect(find.text('Masuk ke Resep'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
