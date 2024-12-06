import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double get maxHeight => MediaQuery.of(context).size.height;
  double get topbarHeight => maxHeight * 0.2;
  double get bottomCollapsedHeight => maxHeight * 0.4;
  double get bottomExpandedHeight => maxHeight * 0.8;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double lerp(double min, double max) {
    return lerpDouble(min, max, _controller.value)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.amber.shade100,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                // duration: const Duration(milliseconds: 700),
                left: 0,
                right: 0,
                bottom: 0,
                height: lerp(bottomCollapsedHeight, bottomExpandedHeight),
                child: GestureDetector(
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: _buildRecentPlaces(),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                top: lerp(-topbarHeight, 0),
                height: topbarHeight,
                child: _buildSelectDestination(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) {
      return;
    }

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;

    if (flingVelocity < 0.0) {
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    } else if (flingVelocity > 0.0) {
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    } else {
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
    }
  }

  Widget _buildSelectDestination() {
    return Material(
      elevation: 3,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.close),
                  Expanded(
                    child: Center(
                      child: Text('Select destination'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.donut_small_sharp),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (value) {},
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPlaces() {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var p = places[index];
          return ListTile(
            // minVerticalPadding: 0,
            horizontalTitleGap: 0,
            // contentPadding: const EdgeInsets.all(0),
            // dense: true,

            leading: Container(
                height: double.infinity,
                child: Icon(Icons.location_on_outlined)),
            title: Text(
              p.name,
              style: TextStyle(fontWeight: FontWeight.w100),
            ),
            subtitle: Text(
              p.subTitle,
              style: TextStyle(fontWeight: FontWeight.w100, fontSize: 14),
            ),
          );
        },
        itemCount: places.length,
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Divider(
              thickness: 1,
              color: Colors.grey.withOpacity(0.2),
              height: 0,
            ),
          );
        },
      ),
    );
  }
}

class Place {
  final String name;
  final String subTitle;
  Place({
    required this.name,
    required this.subTitle,
  });
}

final places = [
  Place(name: 'Banorama Mall', subTitle: 'Riyadh'),
  Place(name: 'Banorama Mall', subTitle: 'Riyadh'),
  Place(name: 'Banorama Mall', subTitle: 'Riyadh'),
  Place(name: 'Banorama Mall', subTitle: 'Riyadh'),
];
