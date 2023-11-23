import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF232B55),
          ),
        ),
        cardColor: const Color(0xFFF4EDDB),
        canvasColor: const Color(0xFFe64d3d),
      ),
      home: const HomeScreen(),
    );
  }
}

class TimeCard extends StatelessWidget {
  final String text;

  const TimeCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          width: 1,
          color: Theme.of(context).cardColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).canvasColor,
          fontSize: 70,
          fontWeight: FontWeight.w600,
          backgroundColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final int text;
  final bool isActive;

  const DayCard({
    super.key,
    required this.text,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).cardColor
            : Theme.of(context).canvasColor.withOpacity(0.5),
        border: Border.all(
          width: 1,
          color: isActive
              ? Theme.of(context).canvasColor
              : Theme.of(context).cardColor.withOpacity(0.5),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        '$text',
        style: TextStyle(
          color: isActive
              ? Theme.of(context).canvasColor
              : Theme.of(context).cardColor.withOpacity(0.5),
          fontSize: 30,
          fontWeight: FontWeight.w600,
          backgroundColor: isActive
              ? Theme.of(context).cardColor
              : Theme.of(context).canvasColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

class CountStatus extends StatelessWidget {
  final int total;
  final int done;
  final String text;

  const CountStatus({
    super.key,
    required this.total,
    required this.done,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$done/$total',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).cardColor.withOpacity(0.5),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).cardColor,
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const isTest = true;
  static const List<int> runTime =
      isTest ? [1, 3, 5, 7, 9] : [15, 20, 25, 30, 35];
  static const intervalSeconds = isTest ? 5 : 25 * 60;
  static const freetimeSeconds = isTest ? 10 : 5 * 60;
  static const roundCount = 4;
  static const goalCount = 12;

  List<bool> tapped = [false, false, true, false, false];
  bool isStarted = false;
  bool isRunning = false;
  bool isWorking = true;
  int lastSelected = 2;
  int totalSeconds = isTest ? 5 : 25 * 60;
  int totalCycles = 0;
  int totalRounds = 0;
  String warningMsg = isTest ? "> Test Mode Unit : Seconds" : "";
  late Timer timer;

  void activateCycle(idx, val) {
    setState(() {
      for (var i = 0; i < tapped.length; i++) {
        if (i == idx) {
          lastSelected = i;
          tapped[i] = true;
          totalSeconds = isTest ? val : val * 60;
          warningMsg = isTest ? "> Test Mode Unit : Seconds" : "";
        } else {
          tapped[i] = false;
        }
      }
    });
  }

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      timer.cancel();

      setState(() {
        if (isWorking) {
          totalCycles = totalCycles + 1;
        } else {
          totalCycles = 0;
          isWorking = true;
          activateCycle(lastSelected, runTime[lastSelected]);
        }
        totalSeconds = runTime[lastSelected];
        isRunning = false;
      });

      if (totalCycles == roundCount) {
        setState(() {
          totalRounds = totalRounds + 1;
          totalSeconds = freetimeSeconds;
          isRunning = true;
          isWorking = false;
          warningMsg = "Please, take a break for a while!";
        });
        timer = Timer.periodic(
          const Duration(seconds: 1),
          onTick,
        );
      }
    } else {
      setState(() {
        totalSeconds = totalSeconds - 1;
      });
    }
  }

  void onStartPressed() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
    setState(() {
      isStarted = true;
      isRunning = true;
      isWorking = true;
      warningMsg = "";
    });
  }

  void onPausePressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void onResetPressed() {
    timer.cancel();
    setState(() {
      totalRounds = 0;
      totalCycles = 0;
      isStarted = false;
      isRunning = false;
      isWorking = true;
      activateCycle(2, runTime[2]);
    });
  }

  List<String> showRemains(int seconds) {
    var duration = Duration(seconds: seconds);
    return duration.toString().split(".").first.split(":");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POMOTIMER',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    warningMsg,
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TimeCard(text: showRemains(totalSeconds)[1]),
                  Text(
                    ":",
                    style: TextStyle(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      fontSize: 70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TimeCard(text: showRemains(totalSeconds)[2]),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: isRunning || !isWorking
                        ? null
                        : () => activateCycle(0, runTime[0]),
                    child: DayCard(text: runTime[0], isActive: tapped[0]),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: isRunning || !isWorking
                        ? null
                        : () => activateCycle(1, runTime[1]),
                    child: DayCard(text: runTime[1], isActive: tapped[1]),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: isRunning || !isWorking
                        ? null
                        : () => activateCycle(2, runTime[2]),
                    child: DayCard(text: runTime[2], isActive: tapped[2]),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: isRunning || !isWorking
                        ? null
                        : () => activateCycle(3, runTime[3]),
                    child: DayCard(text: runTime[3], isActive: tapped[3]),
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: isRunning || !isWorking
                        ? null
                        : () => activateCycle(4, runTime[4]),
                    child: DayCard(text: runTime[4], isActive: tapped[4]),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    iconSize: 100,
                    color: isWorking || !isRunning
                        ? Theme.of(context).cardColor
                        : Theme.of(context).cardColor.withOpacity(0.5),
                    onPressed: !isWorking
                        ? null
                        : isRunning
                            ? onPausePressed
                            : onStartPressed,
                    icon: Icon(isRunning
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "RESET",
                        style: TextStyle(
                          color: isStarted
                              ? Theme.of(context).cardColor.withOpacity(0.8)
                              : Theme.of(context).cardColor.withOpacity(0.5),
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        iconSize: 25,
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                        hoverColor: Theme.of(context).cardColor,
                        mouseCursor: SystemMouseCursors.grab,
                        onPressed: isStarted ? onResetPressed : null,
                        icon: const Icon(Icons.restore),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CountStatus(
                            total: roundCount,
                            done: totalCycles,
                            text: 'ROUND'),
                        CountStatus(
                            total: goalCount, done: totalRounds, text: 'GOAL'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
