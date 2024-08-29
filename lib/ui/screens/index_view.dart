import 'package:flutter/material.dart';
import 'package:geoblast/ui/screens/screen.dart';

class IndexedView extends StatefulWidget {
  const IndexedView({super.key, this.initialIndex = 0, required this.indexes, this.drawer});
  final int initialIndex;
  final List<Screen> indexes;
  final Widget? drawer;

  @override
  State<StatefulWidget> createState() {
    return _IndexViewState();
  }
}
class _IndexViewState extends State<IndexedView> {

  int currentIndex = 0;

  List<BottomNavigationBarItem> getDestinations() {
    var destinations = <BottomNavigationBarItem>[];
    for (var index in widget.indexes) {
      destinations.add(
        BottomNavigationBarItem(
          icon: Icon(index.icon),
          label: index.title
        )
      );
    }
    return destinations;
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.indexes[currentIndex].title,
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: widget.indexes[currentIndex]
        )
      ),
      drawer: widget.drawer,
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
          selectedItemColor: Theme.of(context).colorScheme.tertiary,
          unselectedItemColor: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          items: getDestinations(),
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        )
      )
    );
  }
}
