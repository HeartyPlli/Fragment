enum StageView {
  sofa,
  kitchen,
  door,
  computer,
  sofaTop,
  kitchenTop,
  doorTop,
  computerTop,
}

class StageHotspot {
  final String id;
  final String asset;
  final String? altAsset;
  final double left;
  final double top;
  final double width;
  final double shift;
  final bool toggle;
  final double? altLeft;
  final double? altTop;
  final bool instantToggle;

  const StageHotspot({
    required this.id,
    required this.asset,
    required this.left,
    required this.top,
    this.altAsset,
    this.width = 80,
    this.shift = 0,
    this.toggle = false,
    this.altLeft,
    this.altTop,
    this.instantToggle = false,
  });
}

List<StageHotspot> hotspotsForStageView(StageView view) {
  switch (view) {
    case StageView.sofa:
      return const [
        StageHotspot(
          id: 'sofa-table',
          asset: 'assets/images/table.png',
          left: 70,
          top: 170,
          width: 130,
        ),
        StageHotspot(
          id: 'sofa-chair',
          asset: 'assets/images/chair.png',
          left: 199,
          top: 175,
          width: 300,
        ),
        StageHotspot(
          id: 'sofa-frame1',
          asset: 'assets/images/frame01.png',
          left: 250,
          top: 110,
          width: 40,
        ),
        StageHotspot(
          id: 'sofa-frame2',
          asset: 'assets/images/frame02.png',
          left: 325,
          top: 110,
          width: 40,
        ),
        StageHotspot(
          id: 'sofa-frame3',
          asset: 'assets/images/frame3.png',
          left: 400,
          top: 110,
          width: 40,
        ),
      ];
    case StageView.kitchen:
      return const [
        StageHotspot(
          id: 'k-1',
          asset: 'assets/images/1.png',
          left: 120,
          top: 200,
          width: 175,
        ),
        StageHotspot(
          id: 'k-2',
          asset: 'assets/images/2.png',
          left: 115,
          top: 315,
          width: 320,
        ),
        StageHotspot(
          id: 'k-3',
          asset: 'assets/images/3.png',
          left: 108,
          top: 138,
          width: 340,
        ),
        StageHotspot(
          id: 'k-4',
          asset: 'assets/images/4.png',
          left: 280,
          top: 240,
          width: 153,
        ),
        StageHotspot(
          id: 'k-door1',
          asset: 'assets/images/front1.png',
          altAsset: 'assets/images/back1.png',
          left: 131,
          top: 221,
          width: 72,
          toggle: true,
          altLeft: 69,
          altTop: 223,
          instantToggle: true,
        ),
        StageHotspot(
          id: 'k-door2',
          asset: 'assets/images/front2.png',
          altAsset: 'assets/images/back2.png',
          left: 199,
          top: 219,
          width: 75,
          toggle: true,
          altLeft: 265,
          altTop: 220,
          instantToggle: true,
        ),
      ];
    case StageView.door:
      return const [
        StageHotspot(
          id: 'door-clock',
          asset: 'assets/images/clock.png',
          left: 235,
          top: 50,
          width: 90,
        ),
        StageHotspot(
          id: 'door-main',
          asset: 'assets/images/door.png',
          left: 220,
          top: 123,
          width: 115,
        ),
        StageHotspot(
          id: 'door-switch',
          asset: 'assets/images/switch.png',
          left: 350,
          top: 200,
          width: 50,
        ),
      ];
    case StageView.computer:
      return const [
        StageHotspot(
          id: 'c-table',
          asset: 'assets/images/tablecom.png',
          left: 120,
          top: 165,
          width: 230,
        ),
        StageHotspot(
          id: 'c-mirror',
          asset: 'assets/images/mirror.png',
          left: 350,

          top: 100,
          width: 75,
        ),
        StageHotspot(
          id: 'c-hint',
          asset: 'assets/images/hint.png',
          left: 200,
          top: 100,
          width: 100,
        ),
        StageHotspot(
          id: 'c-door1',
          asset: 'assets/images/comfront.png',
          altAsset: 'assets/images/comback.png',
          left: 135,
          top: 240,
          width: 75,
          toggle: true,
          altLeft: 75,
          altTop: 238,
          instantToggle: true,
        ),
      ];
    case StageView.sofaTop:
      return const [
        StageHotspot(
          id: 'sofa-top-btn',
          asset: 'assets/images/topsofa1.png',
          left: 220,
          top: 40,
          width: 120,
        ),
      ];
    case StageView.kitchenTop:
      return const [
        StageHotspot(
          id: 'kitchen-top-btn',
          asset: 'assets/images/topkitchen1.png',
          left: 220,
          top: 40,
          width: 120,
        ),
      ];
    case StageView.doorTop:
      return const [
        StageHotspot(
          id: 'door-top-btn',
          asset: 'assets/images/topdoor1.png',
          left: 220,
          top: 40,
          width: 120,
        ),
      ];
    case StageView.computerTop:
      return const [
        StageHotspot(
          id: 'computer-top-btn',
          asset: 'assets/images/topcomputer1.png',
          left: 220,
          top: 40,
          width: 120,
        ),
      ];
  }
}

String backgroundForStageView(StageView view) {
  switch (view) {
    case StageView.sofa:
      return 'assets/images/sofaBackground.png';
    case StageView.kitchen:
      return 'assets/images/kitchenBackground.png';
    case StageView.door:
      return 'assets/images/doorBackground.png';
    case StageView.computer:
      return 'assets/images/computerBackground.png';
    case StageView.sofaTop:
      return 'assets/images/topsofa2.png';
    case StageView.kitchenTop:
      return 'assets/images/topkitchen2.png';
    case StageView.doorTop:
      return 'assets/images/topdoor2.png';
    case StageView.computerTop:
      return 'assets/images/topcomputer2.png';
  }
}
