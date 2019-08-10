import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
String messageText;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = new TextEditingController();
  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                  _auth.signOut();
                  Navigator.pop(context);
//                massagesStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MassagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                        controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      print(DateTime.now().hour);
                      //Implement send functionality.
                        messageTextController.clear();
                      _firestore.collection('massages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time':'${DateTime.now().second} ${DateTime.now().minute} ${DateTime.now().hour}'
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MassagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
      StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('massages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
            }
          final massages = snapshot.data.documents.reversed;
          List<MassageBubble> massagesWidgets = [];
          for (var massage in massages) {
            final massageText = massage.data['text'];
            final massageSender = massage.data['sender'];

            final currentUser=loggedInUser.email;

            final massageWidget =
            MassageBubble(sender: massageSender, text: massageText,isMe: currentUser==massageSender);
            massagesWidgets.add(massageWidget);
            }
          // ignore: missing_return
          return Expanded(
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              padding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: massagesWidgets,
            ),
          );
          },
      );
  }
}
class MassageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;
  MassageBubble({this.sender, this.text,this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: isMe? CrossAxisAlignment.end :CrossAxisAlignment.start,
          children: <Widget>[
        Text(
          sender,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),
        ),
        Material(

          borderRadius:
          isMe? BorderRadius.only(
              topLeft:Radius.circular( 30.0),
              bottomLeft:Radius.circular( 30.0),
              bottomRight:Radius.circular( 30.0))
                  :
          BorderRadius.only(
            topRight:Radius.circular( 30.0),
            bottomLeft:Radius.circular( 30.0),
            bottomRight:Radius.circular( 30.0),

          ),
          elevation: 5.0,
          color: isMe? Colors.lightBlueAccent : Colors.greenAccent,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20.0),
            child: Text(
              '$text',
              style: TextStyle(
                color: isMe? Colors.white :Colors.black,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
