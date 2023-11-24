import 'dart:io';
import 'dart:math';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const HanoiTower());
  doWhenWindowReady(
    () {
      appWindow.show();
    },
  );
}

class HanoiTower extends StatelessWidget {
  const HanoiTower({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  List<Widget> t1Disks = [], t2Disks = [], t3Disks = [];
  TextEditingController hanoiController = TextEditingController(text: "");
  late Map<int, List<Widget>> mapper;
  List<List<List<Widget>>> tracker = <List<List<Widget>>>[];
  bool disabled = false;

  @override
  void initState() {
    mapper = <int, List<Widget>>{1: t1Disks, 2: t2Disks, 3: t3Disks};
    super.initState();
  }

  @override
  void dispose() {
    hanoiController.dispose();
    t1Disks.clear();
    t2Disks.clear();
    t3Disks.clear();
    tracker.clear();
    mapper.clear();
    super.dispose();
  }

  Widget createTower(List<Widget> children) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Container(
          height: 200,
          width: 20,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        )
      ],
    );
  }

  Widget createDisk(double width, Color color) {
    return Container(
      height: 15,
      width: width,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
    );
  }

  void hanoi(int n, int start, int end) {
    if (n == 1) {
      loader(start, end);
    } else {
      int middle = 6 - (start + end);
      hanoi(n - 1, start, middle);
      loader(start, end);
      hanoi(n - 1, middle, end);
    }
  }

  void loader(int start, int end) {
    if (mapper[start]!.isNotEmpty) {
      mapper[end]!.insert(0, mapper[start]!.removeAt(0));
      tracker.add(
        [
          [...t1Disks],
          [...t2Disks],
          [...t3Disks],
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: const Color.fromARGB(255, 0, 28, 52),
      body: SafeArea(
        child: Column(
          children: [
            if (Platform.isWindows)
              WindowTitleBarBox(
                child: Row(
                  children: [
                    Expanded(
                      child: MoveWindow(),
                    ),
                    MinimizeWindowButton(
                        animate: true,
                        // onPressed: () {},
                        colors: WindowButtonColors(iconNormal: Colors.white)),
                    MaximizeWindowButton(
                        animate: true,
                        //onPressed: () {},
                        colors: WindowButtonColors(iconNormal: Colors.white)),
                    CloseWindowButton(
                        animate: true,
                        // onPressed: () {},
                        colors: WindowButtonColors(
                            normal: Colors.pink, iconNormal: Colors.white))
                  ],
                ),
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
            ),
            Center(
              child: RichText(
                text: TextSpan(
                  children: List.generate(
                    "Hanoi's Tower".length,
                    (index) => TextSpan(
                      text: "Hanoi's Tower"[index],
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 50,
                  child: TextFormField(
                    controller: hanoiController,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"^[1-9]+$"),
                        replacementString: "",
                      ),
                      LengthLimitingTextInputFormatter(1),
                    ],
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: const TextStyle(color: Colors.lightGreenAccent),
                    decoration: InputDecoration(
                      enabled: !disabled,
                      border: const UnderlineInputBorder(),
                      labelText: "Disk's Number",
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (hanoiController.text.isNotEmpty)
                  const SizedBox(
                    width: 50,
                  ),
                if (hanoiController.text.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${pow(2, hanoiController.text.isEmpty ? 1 : (int.parse(hanoiController.text))) - 1}",
                          style: const TextStyle(
                            color: Colors.lightGreenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: " Optimal\nMoves",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
            if (hanoiController.text.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              ),
            if (hanoiController.text.isNotEmpty)
              Center(
                child: IconButton(
                  onPressed: disabled
                      ? null
                      : () async {
                          t1Disks.clear();
                          t2Disks.clear();
                          t3Disks.clear();
                          tracker.clear();
                          mapper = <int, List<Widget>>{
                            1: t1Disks,
                            2: t2Disks,
                            3: t3Disks
                          };
                          for (int index = 1;
                              index <=
                                  (hanoiController.text.isNotEmpty
                                      ? int.parse(hanoiController.text)
                                      : 0);
                              index++) {
                            t1Disks.add(
                              createDisk(
                                MediaQuery.of(context).size.width / 3 -
                                    MediaQuery.of(context).size.width * .3 +
                                    index * 20 -
                                    (hanoiController.text.isEmpty
                                        ? 0
                                        : double.parse(
                                            hanoiController.text,
                                          )),
                                Colors
                                    .primaries[index % Colors.primaries.length],
                              ),
                            );
                          }

                          setState(() {
                            disabled = true;
                          });

                          await Future.delayed(
                            const Duration(seconds: 1),
                          );
                          hanoi(int.parse(hanoiController.text), 1, 3);
                          for (List<List<Widget>> item in tracker) {
                            setState(
                              () {
                                t1Disks = item[0];
                                t2Disks = item[1];
                                t3Disks = item[2];
                              },
                            );
                            await Future.delayed(
                              const Duration(seconds: 1),
                            );
                          }
                          setState(() {
                            disabled = false;
                          });
                        },
                  icon: Icon(
                    Icons.play_circle,
                    color: disabled
                        ? Colors.grey.shade600
                        : Colors.lightGreenAccent,
                    size: 25,
                  ),
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                //t1Disks
                createTower(
                  t1Disks,
                ),
                createTower(
                  t2Disks,
                ),

                createTower(
                  t3Disks,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
