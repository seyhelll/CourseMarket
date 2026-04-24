import SwiftUI
import SwiftData

struct CartView: View {
    @Environment(\.modelContext) private var modelContext

    
    let currentUser: User
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    @Query private var cart: [Cart]
    @Query private var products: [Product]
    
    @State private var isProcessingPayment = false  // Для отслеживания состояния прогресса
    @State private var isPaymentSuccessful = false  // Для отслеживания успешности оплаты
    
    private var filteredCart: [Cart] {
        cart.filter { $0.user == currentUser.email }
    }
    
    private var filteredProducts: [Product] {
        products.filter { filteredCart.map(\.product).contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(product: product, currentUser: currentUser)) {
                        ProductRow(product: product)
                    }
                }
                
                // Кнопка "Оплатить" внизу списка
                Button(action: {
                    processPayment()
                }) {
                    Text("Оплатить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                .disabled(isProcessingPayment)  // Отключаем кнопку, пока идет оплата
                
                // Показываем индикатор прогресса, если оплата в процессе
                if isProcessingPayment {
                    ProgressView("Оплата...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                
                // Если оплата успешна, показываем уведомление
                if isPaymentSuccessful {
                    Text("Оплата прошла успешно!")
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .navigationTitle("Корзина")
        }
    }
    // Функция для симуляции оплаты
    private func processPayment() {
        // Начинаем процесс оплаты
        isProcessingPayment = true
        isPaymentSuccessful = false
        
        // Симуляция оплаты: через 3 секунды процесс завершится
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let cart = self.cart
            
            for c in cart {
                modelContext.delete(c)
            }
            try! modelContext.save()
            isProcessingPayment = false
            isPaymentSuccessful = true  // Успешная оплата

        }
    }
}
