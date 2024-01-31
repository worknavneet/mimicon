import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mimiconapp/Infrastructure/Package/flushbar/flushbar.dart';
import 'package:mimiconapp/Infrastructure/commons/constant/image_constants.dart';
import 'package:mimiconapp/UI/common/custom_painter.dart';
import 'package:mimiconapp/UI/common/download_file.dart';

class PickedImageScreen extends StatefulWidget {
  PickedImageScreen({super.key,required this.pickedImage,required this.rightEye,required this.leftEye,required this.rightMouth,required this.onBack});
  File? pickedImage;
  double? circleRadius;
  FaceLandmark? rightEye;
  FaceLandmark? leftEye;
  FaceLandmark? rightMouth;
  void Function() onBack;

  @override
  State<PickedImageScreen> createState() => _PickedImageScreenState();
}

class _PickedImageScreenState extends State<PickedImageScreen> {
  bool showEye = false;
  bool showMouth = false;
  bool isLoading = false;
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return widget.pickedImage != null ? Column(
      children: [
        RepaintBoundary(
          key: globalKey,
          child: Stack(
            children: [
              Image.file(
                widget.pickedImage!,
                fit: BoxFit.fill,
                height: MediaQuery.sizeOf(context).height * .6,
                width: double.infinity,
              ),
              if(widget.rightEye != null && showEye)
                CustomPaint(
                  painter: MyCustomPainter(
                    pointToColor: Point((widget.rightEye!.position.x/4).ceil()+50, (widget.rightEye!.position.y/4).ceil()-5),
                    // pointToColor: rightEye!.position,
                    circleRadius: widget.circleRadius ?? 20,
                    color: Colors.green.withOpacity(0.5),
                  ),
                ),
              if(widget.leftEye != null && showEye)
                CustomPaint(
                  painter: MyCustomPainter(
                    pointToColor: Point((widget.leftEye!.position.x/4).ceil()+30, (widget.leftEye!.position.y/4).ceil()-5),
                    // pointToColor: rightEye!.position,
                    circleRadius: widget.circleRadius ?? 20,

                    color:Colors.green.withOpacity(0.5),
                  ),
                ),
              if(widget.rightMouth != null && showMouth)
                CustomPaint(
                  painter: MouthPainter(
                    pointToColor: Point((widget.rightMouth!.position.x/4).ceil()+10,(widget.rightMouth!.position.y/4).ceil()-20),
                    // pointToColor: rightEye!.position,
                    circleRadius: widget.circleRadius ?? 20,

                    color:Colors.green.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.028,horizontal: 16),
          child: GestureDetector(
            onTap: widget.onBack,
            child: Row(
              children: [
                const SizedBox(width: 5,),
                SvgPicture.asset(ImageConstant.backIcon),
                const SizedBox(width: 5,),
                const Text("다시찍기",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700,color: Colors.white),)
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16,),

          child: Row(
            children: [
              GestureDetector(
                onTap:() {
                  setState(() {
                    showEye = true;
                    showMouth = false;
                  });
                },
                child: Container(
                  height: MediaQuery.of(context).size.height*0.071,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: const Center(child: Text("눈",style: TextStyle(color: Colors.black,fontSize: 12))),
                ),
              ),
              const SizedBox(width: 5,),
              GestureDetector(
                onTap:() {
                  setState(() {
                    showMouth = true;
                    showEye = false;

                  });
                },
                child: Container(
                  height: MediaQuery.of(context).size.height*0.071,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: const Center(child: Text("입",style: TextStyle(color: Colors.black,fontSize: 12))),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: !isLoading ? () async {
            setState(() {
              isLoading = true;
            });
            RenderRepaintBoundary boundary = globalKey.currentContext!
                .findRenderObject() as RenderRepaintBoundary;
            print("print boundary !");
            ui.Image image = await boundary.toImage(pixelRatio: 5.0);

            ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            print("print byteData !");

            var pngBytes = byteData!.buffer.asUint8List();

            var bs64 = base64Encode(pngBytes);
            print("print bs64 !");

            String filePath = await createFileFromString(base64: bs64);
            if(filePath != null && filePath.isNotEmpty){
              setState(() {
                isLoading = false;
              });
              Flushbar(
                backgroundColor: Colors.black.withOpacity(0.5),
                message: "이미지를 저장",
                flushbarPosition: FlushbarPosition.TOP,
                messageSize: 14,
                messageColor: Colors.white,
                duration: const Duration(seconds: 3),
                forwardAnimationCurve: Curves.easeIn,
                borderRadius: BorderRadius.circular(20),
                flushbarStyle: FlushbarStyle.FLOATING,
                margin: const EdgeInsets.all(16),

              ).show(context);
            }
          } :(){},
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.047,
            margin: const EdgeInsets.all(16,),
            decoration: BoxDecoration(
              color: const Color(0xff7B8FF7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: !isLoading ? const Center(child: Text("저장하기",style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w700))) :
            const SizedBox(
                height: 5,
                child: Center(child: CircularProgressIndicator(color: Colors.white,))),
          ),
        )
      ],
    ) :SizedBox();
  }
}
