// import 'package:flutter/material.dart';
// import 'chat_page.dart';

// class ChatListPage extends StatelessWidget {
//   ChatListPage({super.key});

//   final List<Map<String, String>> chats = [
//     {"name": "Home Furniture", "type": "Shop", "img": "assets/logo2.jpg"},
//     {"name": "Alaa Ahmed", "type": "Shop", "img": "assets/sample1.png"},
//     {"name": "FRNITURE", "type": "Shop", "img": "assets/logo3.jpg"},
//     {"name": "ArmChair", "type": "Shop", "img": "assets/logo4.jpg"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff6eadf),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const Icon(Icons.arrow_back, color: Colors.brown),
//         title: const Text("Chats", style: TextStyle(color: Colors.brown)),
//         actions: const [
//           Icon(Icons.search, color: Colors.brown),
//           SizedBox(width: 12),
//           Icon(Icons.notifications_none, color: Colors.brown),
//           SizedBox(width: 12),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // filters
//             Row(
//               children: const [
//                 _Chip(text: "All chat"),
//                 SizedBox(width: 8),
//                 _Chip(text: "Shop chat"),
//                 SizedBox(width: 8),
//                 _Chip(text: "Friend chat"),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // chat list
//             Expanded(
//               child: ListView.separated(
//                 itemCount: chats.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final chat = chats[index];
//                   return InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => ChatPage(
//                             name: chat["name"]!,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xffe8cdb8),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             radius: 26,
//                             backgroundImage: AssetImage(chat["img"]!),
//                           ),
//                           const SizedBox(width: 12),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 chat["name"]!,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(chat["type"]!),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // new chat button
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xffe8cdb8),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: const Center(child: Text("New Chat")),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Chip extends StatelessWidget {
//   final String text;
//   const _Chip({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       backgroundColor: const Color(0xffe8cdb8),
//       label: Text(text),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String selectedFilter = "all";

  final List<Map<String, String>> chats = [
    {
      "name": "The Cozy Home",
      "type": "shop",
      "img": "assets/sample1.png"
    },
    {
      "name": "Modern Furniture",
      "type": "shop",
      "img": "assets/sample2.png"
    },
    {
      "name": "Rowan Alaa",
      "type": "friend",
      "img": "assets/sample3.png"
    },
    {
      "name": "Alaa Moustafa",
      "type": "friend",
      "img": "assets/sample1.png"
    },
  ];

  List<Map<String, String>> get filteredChats {
    if (selectedFilter == "all") return chats;
    return chats.where((c) => c["type"] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6eadf),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Chats", style: TextStyle(color: Colors.brown)),
        leading: const Icon(Icons.arrow_back, color: Colors.brown),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// FILTER BUTTONS
            Row(
              children: [
                _filterButton("All chat", "all"),
                const SizedBox(width: 8),
                _filterButton("Shop chat", "shop"),
                const SizedBox(width: 8),
                _filterButton("Friend chat", "friend"),
              ],
            ),

            const SizedBox(height: 20),

            /// CHAT LIST
            Expanded(
              child: ListView.separated(
                itemCount: filteredChats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(name: chat["name"]!),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffe8cdb8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: AssetImage(chat["img"]!),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat["name"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                chat["type"] == "shop"
                                    ? "Shop"
                                    : "Friend",
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FILTER BUTTON WIDGET
  Widget _filterButton(String text, String value) {
    final bool isSelected = selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown : const Color(0xffe8cdb8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
