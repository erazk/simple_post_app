import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; //import insert post


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp1());
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News Feed',
      home: ViewPostsPage(),
    );
  }
}
class ViewPostsPage extends StatelessWidget {
  ViewPostsPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "News Feed",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),

        body: Center(
          child: Column(
            children: [
              SizedBox(height: 30),

              // What's on your mind container (clickable direct to insert post)
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 10),

                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Post(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          alignment: Alignment.centerLeft,
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          "What's on your mind?",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('tbl_post')
                      .orderBy('date_posted', descending: true)
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (snapshots.hasError) {
                      return Center(
                        child: Text("Error: ${snapshots.error}"),
                      );
                    }
                    if (!snapshots.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    var post = snapshots.data!.docs;

                    if (post.isEmpty) {
                      return const Center(
                        child: Text("No posts available."),
                      );
                    }

                    return ListView.builder(
                          itemCount: post.length,
                          itemBuilder: (context, index){
                            var perpost = post[index];

                            return Container(
                              margin: EdgeInsets.only(bottom:12),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        child: Icon(Icons.person, color: Colors.white),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                perpost['user_id'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                  (perpost['date_posted'] != null)
                                                      ? perpost['date_posted'].toDate().toString()
                                                      : "Posting...",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:  Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    perpost['post'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.thumb_up_alt_outlined, color: Colors.green),
                                          SizedBox(width: 5),
                                          Text(perpost['likes'].toString()),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.comment, color: Colors.red),
                                          SizedBox(width: 5),
                                          Text(perpost['share'].toString()),
                                        ],
                                      ),
                                    ]
                                  ),
                                ]
                              )
                            );
                          }



                      );
                    }
                  ),
              ),
            ],
          ),
        )
    );
  }
}