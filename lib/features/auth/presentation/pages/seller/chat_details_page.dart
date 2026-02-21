// import 'package:flutter/material.dart';

// class ChatDetailsPage extends StatefulWidget {
//   const ChatDetailsPage({super.key});

//   @override
//   State<ChatDetailsPage> createState() => _ChatDetailsPageState();
// }

// class _ChatDetailsPageState extends State<ChatDetailsPage> {
//   final List<Map<String, dynamic>> messages = [
//     {"fromMe": false, "text": "Hello, is this available?"},
//     {"fromMe": true, "text": "Yes, it's available."},
//     {"fromMe": false, "text": "Can I change the color?"},
//   ];
//   final TextEditingController _msgCtrl = TextEditingController();

//   void _send() {
//     final txt = _msgCtrl.text.trim();
//     if (txt.isEmpty) return;
//     setState(() {
//       messages.add({"fromMe": true, "text": txt});
//       _msgCtrl.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Rowan Alaa", style: TextStyle(color: Colors.brown)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.brown), onPressed: () => Navigator.pop(context)),
//       ),
//       backgroundColor: const Color(0xfff6eadf),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: messages.length,
//               itemBuilder: (context, i) {
//                 final m = messages[i];
//                 return Align(
//                   alignment: m["fromMe"] ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: m["fromMe"] ? Colors.brown : Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       m["text"],
//                       style: TextStyle(color: m["fromMe"] ? Colors.white : Colors.black87),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // input
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             color: Colors.transparent,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _msgCtrl,
//                     decoration: InputDecoration(
//                       hintText: "Type a message",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 FloatingActionButton(
//                   backgroundColor: Colors.brown,
//                   onPressed: _send,
//                   mini: true,
//                   child: const Icon(Icons.send),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
