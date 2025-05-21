import 'package:flutter/material.dart';
import 'product_home.dart';

class PaymentPage extends StatelessWidget {
  final String method;
  final double amount;

  const PaymentPage({
    super.key,
    required this.method,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    Widget paymentContent;

    if (method == "QPay") {
      paymentContent = Column(
        children: [
          const Text(
            "Төлбөрийн QPay код",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/QR_code_for_mobile_English_Wikipedia.svg/1024px-QR_code_for_mobile_English_Wikipedia.svg.png',
              height: 200,
            ),
          ),
        ],
      );
    } else if (method == "Данс") {
      paymentContent = Column(
        children: const [
          Text(
            "Төлбөрийн дансны мэдээлэл",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            "Хүлээн авагч: С.Алтанцэцэг \nДанс: 5235053040\nБанк: Хаан банк",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ],
      );
    } else {
      paymentContent = const Text(
        "Энэ төлбөрийн аргыг бараагаа авахдаа хийнэ үү.",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFFFCC80)], // цагаан → улбар шар өнгө
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Төлбөрийн дэлгэрэнгүй"),
          backgroundColor: const Color(0xFFFF9800),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              paymentContent,
              const SizedBox(height: 30),
              Text(
                "Төлбөрийн арга: $method",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "Нийт дүн: ₮${amount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Төлбөр баталгаажуулах"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Амжилттай"),
                      content: const Text("Таны төлбөр амжилттай хийгдлээ."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductHomePage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
