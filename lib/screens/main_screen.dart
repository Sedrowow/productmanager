import 'package:flutter/material.dart';
import '../controllers/main_controller.dart';
import 'dart:async';
import 'dart:math';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final MainController _controller = MainController();
  final String targetText = "Product Manager by MIT";
  String currentText = "";
  bool showSubtitle = false;
  double subtitleOffset = 100.0;
  double subtitleOpacity = 0.0;
  late AnimationController _rainbowController;
  late AnimationController _greyOutController;
  Timer? _timer;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _greyOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2250),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _rainbowController.stop();
        }
      });

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _slideAnimation = Tween<double>(
      begin: 200.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _greyOutController.forward();
        }
      });

    _startAnimation();
  }

  void _startAnimation() {
    final random = Random();
    final List<String> chars = List.filled(targetText.length, '');
    final List<bool> fixed = List.filled(targetText.length, false);
    int fixedCount = 0;

    // Initialize with random characters
    for (int i = 0; i < targetText.length; i++) {
      chars[i] = String.fromCharCode(random.nextInt(26) + 65);
    }

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // Fix one character every 200ms
      if (timer.tick % 2 == 0 && fixedCount < targetText.length) {
        int nextToFix = fixedCount;
        fixed[nextToFix] = true;
        chars[nextToFix] = targetText[nextToFix];
        fixedCount++;
      }

      setState(() {
        for (int i = 0; i < chars.length; i++) {
          if (!fixed[i]) {
            chars[i] = String.fromCharCode(random.nextInt(26) + 65);
          }
        }
        currentText = chars.join();
      });

      // Only cancel timer after the state is updated with all fixed characters
      if (fixedCount == targetText.length && currentText == targetText) {
        timer.cancel();
        // Start subtitle animation after text is complete
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            showSubtitle = true;
          });
          // Start both animations together
          _slideController.forward();
          _rainbowController.repeat();
        });
      }
    });
  }

  @override
  void dispose() {
    _rainbowController.dispose();
    _greyOutController.dispose();
    _slideController.dispose();
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Manager')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Forms', style: TextStyle(color: Colors.white)),
            ),
            for (final model in ['users', 'products', 'orders'])
              ListTile(
                title: Text(model.toUpperCase()),
                onTap: () => _controller.openModelForm(context, model),
              ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentText,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: showSubtitle ? 1.0 : 0.0,
                    child: showSubtitle
                        ? RainbowText(
                            text: "Select a form from the menu",
                            rainbowAnimation: _rainbowController,
                            greyOutAnimation: _greyOutController,
                          )
                        : const SizedBox(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: _controller.debugModeStream,
        builder: (context, snapshot) {
          final isDebug = snapshot.data ?? false;
          return FloatingActionButton(
            onPressed: () => _controller.showDebugMenu(context),
            child: Icon(isDebug ? Icons.bug_report : Icons.bug_report_outlined),
          );
        },
      ),
    );
  }
}

class RainbowText extends StatelessWidget {
  final String text;
  final AnimationController rainbowAnimation;
  final AnimationController greyOutAnimation;

  const RainbowText({
    super.key,
    required this.text,
    required this.rainbowAnimation,
    required this.greyOutAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([rainbowAnimation, greyOutAnimation]),
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            text.length,
            (index) {
              final double hue =
                  (index / text.length * 360 + (rainbowAnimation.value * 360)) %
                      360;
              final color = HSVColor.fromAHSV(
                1.0,
                hue,
                1.0,
                1.0,
              ).toColor();

              final Color finalColor = Color.lerp(
                color,
                Colors.grey,
                greyOutAnimation.value,
              )!;

              return Text(
                text[index],
                style: TextStyle(
                  color: finalColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
