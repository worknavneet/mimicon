import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui'as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mimiconapp/Infrastructure/Package/flushbar/flushbar.dart';
import 'package:mimiconapp/Infrastructure/commons/constant/image_constants.dart';
import 'package:mimiconapp/UI/common/custom_painter.dart';
import 'package:mimiconapp/UI/common/download_file.dart';
import 'package:mimiconapp/UI/screens/pickedimage_screen.dart';
import 'package:mimiconapp/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;
  int cameraIndex = 1;

  final picker = ImagePicker();
  File? pickedImage;
  FaceLandmark? rightEye;
  FaceLandmark? leftEye;
  FaceLandmark? rightMouth;
  FaceLandmark? leftMouth;
  FaceLandmark? bottomMouth;
  double? circleRadius;
  List<Face>? faces;


  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initCamera() {
    controller = CameraController(cameras[cameraIndex], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  void pickImage() async {
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => pickedImage = File(image.path));
      detectFace(pickedImage!.path);
    }
  }


  void detectFace(String filePath) async{
    final inputImage = InputImage.fromFilePath(filePath);
    final options = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    );
    final faceDetector = FaceDetector(options: options);

    faces = await faceDetector.processImage(inputImage);
    setState(() {});
    print("face length value is here ==> ${faces!.length}");
    if(faces!.length < 2){
      for (Face face in faces!) {
        final Rect boundingBox = face.boundingBox;

        final double? rotX = face.headEulerAngleX; // Head is tilted up and down rotX degrees
        final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
        final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
        // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
        // eyes, cheeks, and nose available):

        rightEye = face.landmarks[FaceLandmarkType.rightEye];
        leftEye = face.landmarks[FaceLandmarkType.leftEye];
        rightMouth = face.landmarks[FaceLandmarkType.rightMouth];
        leftMouth = face.landmarks[FaceLandmarkType.leftMouth];
        bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth];

        if (rightEye != null) {
          final Point<int> rightEyePos = rightEye!.position;
          print("------- rightEyePos -------> ${rightEyePos.x} ${rightEyePos.y}");
        }if (leftEye != null) {
          final Point<int> leftEyePos = leftEye!.position;
          print("------- leftEyePos -------> ${leftEyePos.x} ${leftEyePos.y}");
        }if (rightMouth != null) {
          final Point<int> rightMouthPos = rightMouth!.position;
          print("------- rightMouthPos -------> ${rightMouthPos.x} ${rightMouthPos.y}");
        }if (leftMouth != null) {
          final Point<int> leftMouthPos = leftMouth!.position;
          print("------- leftMouthPos -------> ${leftMouthPos.x} ${leftMouthPos.y}");
        }if (bottomMouth != null) {
          final Point<int> bottomMouthPos = bottomMouth!.position;
          print("------- bottomMouthPos -------> ${bottomMouthPos.x} ${bottomMouthPos.y}");
        }

        setState(() {});

        // If classification was enabled with FaceDetectorOptions:
        if (face.smilingProbability != null) {
          final double? smileProb = face.smilingProbability;
          print("----- smileProb -----> $smileProb");
        }

        // If face tracking was enabled with FaceDetectorOptions:
        if (face.trackingId != null) {
          final int? id = face.trackingId;
        }
      }
    }else{
      Flushbar(
        backgroundColor: Colors.black.withOpacity(0.5),
        message: "2개 이상의 얼굴이 감지되었어요!",
        flushbarPosition: FlushbarPosition.TOP,
        messageSize: 14,
        messageColor: Colors.white,
        duration: const Duration(seconds: 4),
        forwardAnimationCurve: Curves.easeIn,
        borderRadius: BorderRadius.circular(20),
        flushbarStyle: FlushbarStyle.FLOATING,
        margin: const EdgeInsets.all(16),

      ).show(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    print(rightEye?.position);
    if(rightEye != null){
      final leftEyeCenter = (rightEye!.position.x + rightEye!.position.y) / 4;
      print("left eye center value is here ==> $leftEyeCenter");
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            if (pickedImage != null) {
              setState(() {
                pickedImage = null;
              });
            }
          },
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          pickedImage != null
              ? PickedImageScreen(leftEye: leftEye,pickedImage: pickedImage,rightEye: rightEye,rightMouth: rightMouth,onBack: () {
            if (pickedImage != null) {
              setState(() {
                pickedImage = null;
              });
            }
              },)
              : Column(
                children: [
                  SizedBox(
                      height: MediaQuery.sizeOf(context).height * .6,
                      width: double.infinity,
                      child: CameraPreview(controller)),
                  SizedBox(height: MediaQuery.sizeOf(context).height * .04),
                  InkWell(
                      onTap: () async {
                        rightEye = null;
                        leftEye = null;
                        rightMouth = null;
                        leftMouth = null;
                        bottomMouth = null;
                        final image = await controller.takePicture();

                        setState(() => pickedImage = File(image.path));
                        detectFace(pickedImage!.path);
                      },
                      child: SvgPicture.asset(ImageConstant.cameraIcon)),
                  SizedBox(height: MediaQuery.sizeOf(context).height * .08),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            // setState(() => cameraIndex = cameraIndex == 1 ? 0 : 1);
                            // initCamera();
                            pickImage();
                          },
                          child: SvgPicture.asset(ImageConstant.galleryIcon),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() => cameraIndex = cameraIndex == 1 ? 0 : 1);
                            initCamera();
                          },
                          child: SvgPicture.asset(ImageConstant.rotateIcon),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

        ],
      ),
    );
  }
}

