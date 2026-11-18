import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: Elevator()),
  );
}

class Elevator extends StatefulWidget {
  const Elevator({super.key});

  @override
  State<Elevator> createState() => _ElevatorState();
}

class _ElevatorState extends State<Elevator> {
  int currentFloor = 0;
  String door = 'Open';
  String status = 'Ready';
  bool moving = false;

  // List of requested floors
  List<int> requests = [];

  // Elevator movement
  Future<void> selectFloor(int floor) async {
    if (floor == currentFloor && (!moving || door != 'Closed')) {
      debugPrint('You are already on floor $floor');
      return;
    }

    if (requests.contains(floor)) return;

    setState(() {
      requests.add(floor);
    });

    if (moving) return;

    setState(() {
      moving = true;
    });

    while (requests.isNotEmpty) {
      int targetFloor = requests.first;

      // Close the doors
      if (door != 'Closed') {
        setState(() {
          door = 'Closing';
          status = 'Preparing';
        });

        await Future.delayed(Duration(seconds: 1));
        if (!mounted) return;
      }

      setState(() {
        door = 'Closed';
        status = targetFloor > currentFloor ? 'Moving up' : 'Moving down';
      });

      debugPrint('Going to floor $targetFloor');

      // Move between floors
      while (currentFloor != targetFloor) {
        await Future.delayed(Duration(seconds: 1));
        if (!mounted) return;

        setState(() {
          if (targetFloor > currentFloor) {
            currentFloor++;
          } else {
            currentFloor--;
          }
        });

        debugPrint('Floor $currentFloor');
      }

      // Open the doors
      setState(() {
        status = 'Arrived';
        door = 'Opening';
      });

      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return;

      setState(() {
        door = 'Open';
        requests.removeAt(0);
      });

      // Wait before going to the next floor
      await Future.delayed(Duration(seconds: 2));
      if (!mounted) return;
    }

    setState(() {
      moving = false;
      status = 'Ready';
    });
  }

  // Floor buttons
  Widget floorButton(int floor) {
    return ElevatedButton(
      onPressed: () {
        selectFloor(floor);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: requests.contains(floor)
            ? Colors.lightBlueAccent
            : Color(0xFF334155),
        foregroundColor: requests.contains(floor) ? Colors.black : Colors.white,
        shape: CircleBorder(),
        minimumSize: Size(70, 70),
      ),
      child: Text('$floor', style: TextStyle(fontSize: 25)),
    );
  }

  // Application design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('Elevator Control'),
        centerTitle: true,
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 300,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CURRENT FLOOR',
                        style: TextStyle(color: Colors.white70),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            status == 'Moving up'
                                ? Icons.arrow_upward
                                : status == 'Moving down'
                                ? Icons.arrow_downward
                                : Icons.remove,
                            color: Colors.lightBlueAccent,
                            size: 35,
                          ),
                          SizedBox(width: 15),
                          Text(
                            '$currentFloor',
                            style: TextStyle(
                              fontSize: 65,
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        status,
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Doors: $door',
                        style: TextStyle(color: Colors.white),
                      ),

                      SizedBox(height: 15),
                      Divider(color: Colors.white24),
                      SizedBox(height: 10),

                      Text(
                        'Requested floors',
                        style: TextStyle(color: Colors.white70),
                      ),

                      SizedBox(height: 8),

                      Text(
                        requests.isEmpty ? 'None' : requests.join(' → '),
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    floorButton(4),
                    SizedBox(width: 20),
                    floorButton(5),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    floorButton(2),
                    SizedBox(width: 20),
                    floorButton(3),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    floorButton(0),
                    SizedBox(width: 20),
                    floorButton(1),
                  ],
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (!moving) {
                          setState(() {
                            door = 'Open';
                          });
                        }
                      },
                      child: Text('Open'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (!moving) {
                          setState(() {
                            door = 'Closed';
                          });
                        }
                      },
                      child: Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
