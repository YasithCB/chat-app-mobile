import 'package:chat_app/widgets/messsage_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found!'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong..!'),
          );
        }

        final loadedMsgs = snapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMsgs.length,
            itemBuilder: (context, index) {
              final chatMsg = loadedMsgs[index].data();
              final nextChatMsg = index + 1 < loadedMsgs.length
                  ? loadedMsgs[index + 1].data()
                  : null;

              final currentMsgUserId = chatMsg['userId'];
              final nextMsgUserId =
                  nextChatMsg != null ? nextChatMsg['userId'] : null;
              final isNextUserSame = nextMsgUserId == currentMsgUserId;

              if (isNextUserSame) {
                return MessageBubble.next(
                  message: chatMsg['text'],
                  isMe: authenticatedUser.uid == currentMsgUserId,
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMsg['userImage'],
                  username: chatMsg['username'],
                  message: chatMsg['text'],
                  isMe: authenticatedUser.uid == currentMsgUserId,
                );
              }
            });
      },
    );
  }
}
