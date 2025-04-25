import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShortViewerPage extends StatefulWidget {
  final int initialIndex;
  final List<QueryDocumentSnapshot> docs;

  const ShortViewerPage({
    super.key,
    required this.initialIndex,
    required this.docs,
  });

  @override
  State<ShortViewerPage> createState() => _ShortViewerPageState();
}

class _ShortViewerPageState extends State<ShortViewerPage> {
  late PageController _pageController;
  final Map<int, VideoPlayerController> _videoControllers = {};
  int _currentIndex = 0;
  bool _showControls = false;
  bool _isSeeking = false;
  double _sliderValue = 0.0;
  Timer? _positionTimer;

  final db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: "cote",
  );

  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _initializeControllerAt(_currentIndex);
    if (_currentIndex > 0) _initializeControllerAt(_currentIndex - 1);
    if (_currentIndex < widget.docs.length - 1) _initializeControllerAt(_currentIndex + 1);
    _startPositionUpdater();
  }

  void _startPositionUpdater() {
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final controller = _videoControllers[_currentIndex];
      if (controller != null && controller.value.isInitialized && !_isSeeking) {
        setState(() {
          _sliderValue = controller.value.position.inMilliseconds.toDouble();
        });
      }
    });
  }

  void _initializeControllerAt(int index) {
    if (index < 0 || index >= widget.docs.length || _videoControllers.containsKey(index)) return;
    final data = widget.docs[index].data() as Map<String, dynamic>;
    final url = data['url'] as String;
    try {
      final controller = VideoPlayerController.network(url, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
      _videoControllers[index] = controller;

      controller.initialize().then((_) {
        if (mounted) {
          setState(() {
            controller.setLooping(true);
            if (index == _currentIndex) {
              controller.play();
            }
          });
        }
      });
    } catch (e) {
      print('Error initializing controller: $e');
    }
  }

  void _disposeControllerAt(int index) {
    _videoControllers[index]?.dispose();
    _videoControllers.remove(index);
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    _positionTimer?.cancel();
    super.dispose();
  }

  void _onPageChanged(int newIndex) {
    if (newIndex == _currentIndex) return;

    _videoControllers[_currentIndex]?.pause();
    setState(() {
      _currentIndex = newIndex;
      _showControls = false;
      _sliderValue = 0.0;
    });
    _initializeControllerAt(newIndex);
    _videoControllers[newIndex]?.play();
    if (newIndex > 0) _initializeControllerAt(newIndex - 1);
    if (newIndex < widget.docs.length - 1) _initializeControllerAt(newIndex + 1);
    for (int i in _videoControllers.keys.toList()) {
      if ((i - newIndex).abs() > 1) {
        _disposeControllerAt(i);
      }
    }
  }

  void _togglePlayPause() {
    final controller = _videoControllers[_currentIndex];
    if (controller == null) return;

    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showControls = false);
        });
      }
    });
  }

  Future<void> _vote(String shortId, String voteType) async {
    final shortRef = db.collection('shorts').doc(shortId);
    final voteRef = shortRef.collection('votes').doc(userId);

    final voteSnap = await voteRef.get();
    final shortSnap = await shortRef.get();
    final shortData = shortSnap.data() as Map<String, dynamic>? ?? {};

    if (voteSnap.exists) {
      final prevVote = voteSnap.data()?['vote'];
      if (prevVote == voteType) return;

      if (prevVote == 'upvote' && (shortData['upvotes'] ?? 0) > 0) {
        await shortRef.update({'upvotes': FieldValue.increment(-1)});
      } else if (prevVote == 'downvote' && (shortData['downvotes'] ?? 0) > 0) {
        await shortRef.update({'downvotes': FieldValue.increment(-1)});
      }
    }

    await voteRef.set({'vote': voteType});
    if (voteType == 'upvote') {
      await shortRef.update({'upvotes': FieldValue.increment(1)});
    } else {
      await shortRef.update({'downvotes': FieldValue.increment(1)});
    }
  }

  Future<void> _toggleBookmark(String userId, String shortId) async {
    final userDocRef = db.collection('users').doc(userId);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      await userDocRef.set({
        'bookmarks': {
          'shorts': [],
          'notes': [],
        }
      });
    }

    final currentBookmarks = (userDoc.data()?['bookmarks']?['shorts'] ?? []) as List<dynamic>;

    if (currentBookmarks.contains(shortId)) {
      await userDocRef.update({
        'bookmarks.shorts': FieldValue.arrayRemove([shortId])
      });
    } else {
      await userDocRef.update({
        'bookmarks.shorts': FieldValue.arrayUnion([shortId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: widget.docs.length,
        itemBuilder: (context, index) {
          final data = widget.docs[index].data() as Map<String, dynamic>;
          final docId = widget.docs[index].id;
          final description = data['description'] ?? '';
          final controller = _videoControllers[index];

          if (controller == null || !controller.value.isInitialized) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final totalDuration = controller.value.duration.inMilliseconds.toDouble();

          return StreamBuilder<DocumentSnapshot>(
            stream: db.collection('shorts').doc(docId).snapshots(),
            builder: (context, snapshot) {
              final snapData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              final upvotes = (snapData['upvotes'] ?? 0) as int;
              final downvotes = (snapData['downvotes'] ?? 0) as int;

              return StreamBuilder<DocumentSnapshot>(
                stream: db.collection('users').doc(userId).snapshots(),
                builder: (context, userSnap) {
                  final bookmarksData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
                  final shortsList = (bookmarksData['bookmarks']?['shorts'] ?? []) as List<dynamic>;
                  final isBookmarked = shortsList.contains(docId);

                  return GestureDetector(
                    onTap: _toggleControls,
                    child: Stack(
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),
                        if (_showControls) ...[
                          Center(
                            child: IconButton(
                              iconSize: 64,
                              icon: Icon(controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white),
                              onPressed: _togglePlayPause,
                            ),
                          ),
                          Positioned(
                            bottom: 100,
                            left: 20,
                            right: 20,
                            child: Column(
                              children: [
                                Slider(
                                  min: 0.0,
                                  max: totalDuration > 0 ? totalDuration : 1.0,
                                  value: (_isSeeking
                                          ? _sliderValue
                                          : controller.value.position.inMilliseconds.toDouble())
                                      .clamp(0.0, totalDuration),
                                  onChangeStart: (val) {
                                    setState(() {
                                      _isSeeking = true;
                                      _sliderValue = val;
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _sliderValue = value;
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    controller.seekTo(Duration(milliseconds: value.toInt()));
                                    setState(() {
                                      _isSeeking = false;
                                    });
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(controller.value.position),
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                    Text(
                                      _formatDuration(controller.value.duration),
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                        Positioned(
                          bottom: 150,
                          right: 20,
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 30),
                                onPressed: () => _vote(docId, 'upvote'),
                              ),
                              Text("$upvotes", style: const TextStyle(color: Colors.white)),
                              const SizedBox(height: 8),
                              IconButton(
                                icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 30),
                                onPressed: () => _vote(docId, 'downvote'),
                              ),
                              Text("$downvotes", style: const TextStyle(color: Colors.white)),
                              const SizedBox(height: 8),
                              IconButton(
                                icon: Icon(
                                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => _toggleBookmark(userId, docId),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Text(description, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
