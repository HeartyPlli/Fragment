import 'package:flutter/material.dart';

class SubScene {
  final String id;
  final String background;
  final List<SubHotspot> overlays;
  final double width;
  final double height;
  const SubScene({
    required this.id,
    required this.background,
    required this.overlays,
    this.width = 550,
    this.height = 350,
  });
}

class SubHotspot {
  final String id;
  final String asset;
  final String? altAsset;
  final Offset offset;
  final double width;
  final bool toggleShift;
  final double shiftAmount;
  final bool toggleAsset;
  final bool draggable;
  final double? altLeft;
  final double? altTop;
  final bool instantToggle;

  const SubHotspot({
    required this.id,
    required this.asset,
    required this.offset,
    this.width = 0,
    this.altAsset,
    this.toggleShift = false,
    this.shiftAmount = 6,
    this.toggleAsset = false,
    this.draggable = false,
    this.altLeft,
    this.altTop,
    this.instantToggle = false,
  });
}

/// Library of sub-scenes mapped from hotspot ids.
/// Every hotspot below has an explicit `offset` and `width` so you can tweak placement/size easily.
const Map<String, SubScene> subScenes = {
  // Sofa
  'sofa-chair': SubScene(
    id: 'sofa-chair',
    background: 'assets/images/chair/chair_closeup.png',
    overlays: [
      SubHotspot(
        id: 'pillow',
        asset: 'assets/images/chair/pillow.png',
        offset: Offset(60, 100),
        width: 260,
        toggleShift: true,
        shiftAmount: -150,
      ),
    ],
  ),
  'sofa-table': SubScene(
    id: 'sofa-table',
    background: 'assets/images/Stage2/backgroundtable0.png',
    overlays: [
      SubHotspot(
        id: 't0',
        asset: 'assets/images/table/table0.png',
        offset: Offset(139, 170),
        width: 225,
      ),
      SubHotspot(
        id: 't1',
        asset: 'assets/images/table/table1.png',
        offset: Offset(138, 260),
        width: 230,
      ),
      SubHotspot(
        id: 't2',
        asset: 'assets/images/table/table2.png',
        offset: Offset(138, 127),
        width: 230,
        toggleShift: true,
        shiftAmount: 80,
      ),
      SubHotspot(
        id: 't3',
        asset: 'assets/images/table/table3.png',
        offset: Offset(138, 230),
        width: 230,
      ),
      SubHotspot(
        id: 't4',
        asset: 'assets/images/table/table4.png',
        offset: Offset(138, 98),
        width: 230,
        toggleShift: true,
        shiftAmount: 80,
      ),
      SubHotspot(
        id: 't5',
        asset: 'assets/images/table/table5.png',
        offset: Offset(138, 200),
        width: 230,
      ),
      SubHotspot(
        id: 't6',
        asset: 'assets/images/table/table6.png',
        offset: Offset(138, 68),
        width: 230,
        toggleShift: true,
        shiftAmount: 80,
      ),
      SubHotspot(
        id: 't7',
        asset: 'assets/images/table/table7.png',
        offset: Offset(108, 45),
        width: 278,
      ),
      SubHotspot(
        id: 'vase',
        asset: 'assets/images/table/vase1.png',
        offset: Offset(270, 23),
        width: 80,
      ),
    ],
  ),

  'sofa-frame1': SubScene(
    id: 'sofa-frame1',
    background: 'assets/images/frame_close.png',
    overlays: [
      SubHotspot(
        id: 'frame1-front',
        asset: 'assets/images/frame01.png',
        offset: Offset(180, 80),
        width: 200,
      ),
  
        
    ],
  ),
  'sofa-frame2': SubScene(
    id: 'sofa-frame2',
    background: 'assets/images/frame_close.png',
    overlays: [
      SubHotspot(
        id: 'frame2-front',
        asset: 'assets/images/frame2.png',
        offset: Offset(180, 80),
        width: 200,
      ),
      SubHotspot(
        id: 'frame2-02-1',
        asset: 'assets/images/Frames/02.1.png',
        offset: Offset(208, 114),
        width: 73,
      ),
      SubHotspot(
        id: 'frame2-02-2',
        asset: 'assets/images/Frames/02.2.png',
        offset: Offset(280, 114),
        width: 73,
      ),
      SubHotspot(
        id: 'frame2-02-3',
        asset: 'assets/images/Frames/02.3.png',
        offset: Offset(208, 202),
        width: 73,
      ),
      SubHotspot(
        id: 'frame2-02-4',
        asset: 'assets/images/Frames/02.4.png',
        offset: Offset(280, 202),
        width: 73,
      ),
    ],
  ),
  'sofa-frame3': SubScene(
    id: 'sofa-frame3',
    background: 'assets/images/frame_close.png',
    overlays: [
      SubHotspot(
        id: 'frame3-front',
        asset: 'assets/images/frame3.png',
        offset: Offset(180, 80),
        width: 200,
      ),
      SubHotspot(
        id: 'frame3-03-1',
        asset: 'assets/images/Frames/03.1.png',
        offset: Offset(207, 114),
        width: 73,
      ),
      SubHotspot(
        id: 'frame3-03-2',
        asset: 'assets/images/Frames/03.2.png',
        offset: Offset(280, 114),
        width: 73,
      ),
      SubHotspot(
        id: 'frame3-03-3',
        asset: 'assets/images/Frames/03.3.png',
        offset: Offset(207, 201),
        width: 73,
      ),
      SubHotspot(
        id: 'frame3-03-4',
        asset: 'assets/images/Frames/03.4.png',
        offset: Offset(280, 201),
        width: 73,
      ),
    ],
  ),
  /* 'sofa-frame1': SubScene(
    id: 'sofa-frame1',
    background: 'assets/images/frame_close.png',
    overlays: [
       SubHotspot(
        id: 'sofa-frame1',
        asset: 'assets/images/frame1.png',
        offset: Offset(139, 170),
        width: 225,
      ),
    ],
  ),
   'sofa-frame2': SubScene(
    id: 'sofa-frame2',
    background: 'assets/images/frame_close.png',
    overlays: [
       SubHotspot(
        id: 'sofa-frame2',
        asset: 'assets/images/frame2.png',
        offset: Offset(139, 170),
        width: 225,
      ),
    ],
  ),
   'sofa-frame3': SubScene(
    id: 'sofa-frame3',
    background: 'assets/images/frame_close.png',
    overlays: [
       SubHotspot(
        id: 'sofa-frame3',
        asset: 'assets/images/frame3.png',
        offset: Offset(139, 170),
        width: 225,
      ),
    ],
  ),
*/
  // Kitchen

  'k-3': SubScene(
    id: 'k-3',
    background: 'assets/images/faucet/ft.png',
    overlays: [
      SubHotspot(
        id: 'ft2',
        asset: 'assets/images/faucet/ft2.png',
        offset: Offset(140, 146),
        width: 80,
      ),
      SubHotspot(
        id: 'ft3',
        asset: 'assets/images/faucet/ft3.png',
        offset: Offset(293, 245),
        width: 216,
      ),
      SubHotspot(
        id: 'ft4',
        asset: 'assets/images/faucet/ft4.png',
        offset: Offset(305, 285),
        width: 70,
      ),
      SubHotspot(
        id: 'ft5',
        asset: 'assets/images/faucet/ft5.png',
        offset: Offset(420, 285),
        width: 70,
      ),
    ],
  ),
  'k-4': SubScene(
    id: 'k-4',
    background: 'assets/images/oven/oven_close.png',
    overlays: [
      SubHotspot(
        id: 'o1',
        asset: 'assets/images/oven/oven1.png',
        offset: Offset(5, 10),
        width: 470,
      ),
      SubHotspot(
        id: 'o2',
        asset: 'assets/images/oven/oven2.png',
        altAsset: 'assets/images/oven/oven3.png',
        offset: Offset(95, 99),
        width: 310,
        toggleAsset: true,
        altLeft: 95,
        altTop: 195,
        instantToggle: true,
      ),
    ],
  ),

  // Door
  'door-clock': SubScene(
    id: 'door-clock',
    background: 'assets/images/clockcloseup.png',
    overlays: [
      /*SubHotspot(
        id: 'door-clock',
        asset: 'assets/images/arrow.png',
        offset: Offset(120, 120),
        width: 120,
        toggleAsset: true,
        toggleShift: true,
        shiftAmount: 5,
      ),*/
    ],
  ),
  'door-main': SubScene(
    id: 'door-main',
    background: 'assets/images/doorcloseup.png',
    overlays: [],
  ),

  // Computer
  'c-table': SubScene(
    id: 'c-table',
    background: 'assets/images/laptop/tablebackground.png',
    overlays: [
      SubHotspot(
        id: 'lamp',
        asset: 'assets/images/laptop/lamp.png',
        offset: Offset(320, 40),
        width: 200,
      ),
      SubHotspot(
        id: 'laptop',
        asset: 'assets/images/laptop/laptop.png',
        offset: Offset(30, 70),
        width: 200,
      ),
    ],
  ),
  'laptop-screen': SubScene(
    id: 'laptop-screen',
    background: 'assets/images/laptop/screen.png',
    overlays: [],
  ),

  'c-mirror': SubScene(
    id: 'c-mirror',
    background: 'assets/images/mirror/mirrorBackground.png',
    overlays: [
      SubHotspot(
        id: 'mirror',
        asset: 'assets/images/mirror/mirror_near.png',
        offset: Offset(50, 0),
        width: 500,
      ),
      SubHotspot(
        id: 'mepic',
        asset: 'assets/images/mirror/mepic.png',
        offset: Offset(220, 116),
        width: 150,
      ),
    ],
  ),
  'c-hint': SubScene(
    id: 'c-hint',
    background: 'assets/images/hint/hint.png',
    overlays: [
      SubHotspot(
        id: 'h2',
        asset: 'assets/images/hint/me.png',
        offset: Offset(120, 100),
        width: 120,
        draggable: true,
      ),
      SubHotspot(
        id: 'h3',
        asset: 'assets/images/Stage2/hintstage2.png',
        offset: Offset(90, 180),
        width: 180,
        draggable: true,
      ),
    
    ],
  ),
};
