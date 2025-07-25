import 'package:flutter/material.dart';

class SampleContainer extends StatelessWidget {
  const SampleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 30,
      ),
      alignment: Alignment.center,
      height: 300,
      width: 300,
      decoration: BoxDecoration(
          color: Colors.purple,
          border: Border.all(
            color: Colors.black,  
            width: 2,
          ),
          borderRadius: BorderRadius.circular(30)),
      child: const Text(
        'Latihan Container',
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto',
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.underline,
            decorationColor: Colors.green,
            decorationStyle: TextDecorationStyle.dashed,
            letterSpacing: 10),
      ),
    );
  }
}
// Center(
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         height: 200,
//         width: 200,
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(
//             Radius.circular(100),
//           ),
//           image: DecorationImage(
//             fit: BoxFit.cover,
//             image: AssetImage(
//               'assets/images/avatar.png',
//             ),
//           ),
//         ),
//       ),
//     );






///text
// Text(
//           'Hello Collor',
//           style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               fontFamily: 'Roboto',
//               fontStyle: FontStyle.italic,
//               decoration: TextDecoration.lineThrough,
//               decorationColor: Colors.green,
//               decorationStyle: TextDecorationStyle.dashed,
//               letterSpacing: 10),
//         ),

///alignment: Alignment.bottomCenter,

///transform: Matrix4.translationValues(100,100,0),

/// padding, margin, EdgeInsets
// Container(
      //   padding: const EdgeInsets.all(40),
      //   margin: const EdgeInsets.all(50),
      //   height: 300,
      //   width: 300,
      //   decoration: BoxDecoration(
      //     color: Colors.blue,
      //     border: Border.all(
      //       color: Colors.red,
      //       width: 2,
      //     ),
      //   ),
      //   child: const Text(
      //     'Hello Collor',
      //     style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      //   ),
      // ),

/// decoration, color, border, border color, border width, borderRadius
//      Container(
//         height: 300,
//         width: 300,
//         decoration: BoxDecoration(
//           color: Colors.blue,
//           border: Border.all(
//             color: Colors.red,
//             width: 2,
//           ),
//           borderRadius: const BorderRadius.all(
//             Radius.circular(150),
//           ),
//         ),
//         child: const Center(
//           child: Text(
//             'Hello Collor',
//             style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//           ),
//         ),

      ///child, height, width, color
      //  Container(
      //   height: 300,
      //   width: 300,
      //   color: Colors.yellow,
      //   child: const Center(
      //     child: Text(
      //       'Hello Collor',
      //       style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      //     ),
      //   ),
      // ),