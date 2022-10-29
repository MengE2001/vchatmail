import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:vchatmail/Screens/HomeScreen.dart';
import 'package:vchatmail/group_chats/add_members.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({Key? key, required this.groupId, required this.groupName})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;
  File? imageFile;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      print(membersList);
      isLoading = false;
      setState(() {});
    });
  }

  bool checkAdmin() {
    bool isAdmin = false;

    for (var element in membersList) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'] == true;
      }
    }
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => super.widget));
    });
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: ListTile(
                onTap: () => removeMembers(index),
                title: Text("Remove This Member"),
              ),
            );
          },
        );
      }
    }
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    // _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  // Future uploadImage() async {
  //   String fileName = Uuid().v1();
  //   int status = 1;

  //   await _firestore
  //       .collection('chatroom')
  //       .doc()
  //       .collection('chats')
  //       .doc(fileName)
  //       .set({
  //     "sendby": _auth.currentUser!.displayName,
  //     "message": "",
  //     "type": "img",
  //     "time": FieldValue.serverTimestamp(),
  //   });

  //   var ref = FirebaseStorage.instance
  //       .ref()
  //       .child('profile/$GroupInfo/$fileName.jpg');

  //   var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
  //     await _firestore
  //         .collection('chatroom')
  //         .doc(chatRoomId)
  //         .collection('chats')
  //         .doc(fileName)
  //         .delete();

  //     status = 1;
  //   });

  //   if (status == 1) {
  //     String imageUrl = await uploadTask.ref.getDownloadURL();

  //     await _firestore
  //         .collection('chatroom')
  //         .doc(g)
  //         .collection('chats')
  //         .doc(fileName)
  //         .update({"message": imageUrl});

  //     print(imageUrl);
  //   }
  // }

  void GroupProfile() async {
    await _firestore.collection('groups').doc(widget.groupId).update({});
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    } else {
      //print("ey muy");
      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          // Container(
                          //   height: size.height / 11,
                          //   width: size.height / 11,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     color: Colors.grey,
                          //   ),
                          //   child: Icon(
                          //     Icons.group,
                          //     color: Colors.white,
                          //     size: size.width / 10,
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: _getFromCamera,
                              onLongPress: _getFromGallery,
                              child: Container(
                                width: size.width * 0.22,
                                height: size.height * 0.3,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.cyanAccent,
                                  ),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    'https://media.istockphoto.com/vectors/camera-icon-in-trendy-flat-style-isolated-on-white-background-vector-id1384311753?k=20&m=1384311753&s=612x612&w=0&h=Ed3wBUKWIwxKzD5ODrifUTNXJ0zpkkDeIIgHJ-j5gmg=',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.groupName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size.width / 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //

                    SizedBox(
                      height: size.height / 20,
                    ),

                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${membersList.length} Members",
                        style: TextStyle(
                          fontSize: size.width / 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: size.height / 20,
                    ),

                    // Members Name

                    checkAdmin()
                        ? ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMembersINGroup(
                                  groupChatId: widget.groupId,
                                  name: widget.groupName,
                                  membersList: membersList,
                                ),
                              ),
                            ),
                            leading: Icon(
                              Icons.add,
                            ),
                            title: Text(
                              "Add Members",
                              style: TextStyle(
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : SizedBox(),

                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => showDialogBox(index),
                            leading: Icon(Icons.account_circle),
                            title: Text(
                              membersList[index]['name'],
                              style: TextStyle(
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(membersList[index]['email']),
                            trailing: Text(membersList[index]['isAdmin'] == true
                                ? "Admin"
                                : ""),
                          );
                        },
                      ),
                    ),

                    ListTile(
                      onTap: onLeaveGroup,
                      leading: Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Leave Group",
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
