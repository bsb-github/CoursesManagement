import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lms/model/course_model.dart';
import 'package:lms/views/TakeQuiz.dart';
import 'package:nanoid/nanoid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CourseViewer extends StatefulWidget {
  final CourseModel course;
  const CourseViewer({super.key, required this.course});

  @override
  State<CourseViewer> createState() => _CourseViewerState();
}

class _CourseViewerState extends State<CourseViewer> {
  String videoId = "";
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  @override
  void initState() {
    videoId = YoutubePlayer.convertUrlToId(widget.course.courseLink)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId.toString(),
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
    super.initState();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          )),
                      Text(
                        widget.course.name,
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        height: 50,
                      )
                    ],
                  )),
              const SizedBox(
                height: 30,
              ),
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Theme.of(context).primaryColor,
                progressColors: ProgressBarColors(
                  playedColor: Theme.of(context).primaryColor,
                  handleColor: Theme.of(context).primaryColor,
                ),
                onReady: () {
                  _controller.addListener(listener);
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.course.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Description: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.course.courseDescription,
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TakeQuiz(course: widget.course),
                              ));
                        },
                        bgColor: Color(0xff6cd077),
                        buttonText: "Take A Quiz",
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      CustomButton(
                        onTap: () async {
                          var id = nanoid(20);
                          FirebaseFirestore.instance
                              .collection("favourites")
                              .doc("v1")
                              .collection(
                                  FirebaseAuth.instance.currentUser!.uid)
                              .doc(id)
                              .set({"id": id, "courseid": widget.course.id});
                        },
                        bgColor: Theme.of(context).primaryColor,
                        buttonText: "Add to Fav.",
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;
  final Color bgColor;
  const CustomButton({
    super.key,
    required this.onTap,
    required this.buttonText,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 150,
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
