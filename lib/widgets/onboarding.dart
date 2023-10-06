import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:university_app/utils/constants.dart';
import 'package:university_app/widgets/subjects.dart';

class OnBoardingBody extends StatelessWidget {
  OnBoardingBody(
      {Key? key,
      required this.text,
      required this.imagePath,
      required this.isPortrait,
      this.svgImage = true})
      : super(key: key);
  final String text;
  final String imagePath;
  final bool svgImage;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    Widget image = svgImage
            ? SvgPicture.asset(
                imagePath,
                fit: BoxFit.cover,
                height: isPortrait ? 0.39.sh : 0.39.sw,
                width: isPortrait ? 0.39.sh : 0.39.sw,
              )
            : SizedBox(
                height: isPortrait ? 0.39.sh : 0.39.sw,
                width: isPortrait ? 0.39.sh : 0.39.sw,
                child: SubjectsWidget(
                    title: 'الكتب والمراجع', imagepath: imagePath),
              ) /*Container(

            height: isPortrait ? 0.39.sh : 0.39.sw,
            width: isPortrait ? 0.39.sh : 0.39.sw,
            child: Column(
              children: [
                Image.asset(
                  imagePath,
                  // fit: BoxFit.cover,
                  height: isPortrait ? 0.25.sh : 0.25.sw,
                  width: isPortrait ? 0.25.sh : 0.25.sw,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: double.infinity,
                  // height: 45.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(AppUtils.blueColor),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    alignment: Alignment.center,
                    child: Text(
                      'الكتب والمراجع',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.spMin,
                        fontFamily: 'Droid',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )*/
        ;
    Widget sizeBox = SizedBox(
      height: isPortrait ? 0.075.sh : 0.075.sw,
    );
    Widget textWidget = Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isPortrait ? 30 : 0, vertical: isPortrait ? 0 : 30),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontFamily: 'Droid',
            fontSize: 16.spMin,
            color: const Color(0xff2C3E50)),
      ),
    );
    return SingleChildScrollView(
        child: isPortrait
            ? Column(
                children: [
                  image,
                  sizeBox,
                  textWidget,
                ],
              )
            : Row(
                children: [image, sizeBox, Expanded(child: textWidget)],
              ));
  }
}
