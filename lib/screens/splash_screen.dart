
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flip_box/utilities/app_router.dart';
import 'package:on_audio_query/on_audio_query.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    //loadAudioFiles();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFetch(context));
  }

  _initFetch(BuildContext context) async{

    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
    context.router.replace(const HomeRoute());
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo2.jpg",
              height: 300,
              width: MediaQuery.of(context).size.width ,

            ),
            SizedBox(height: 10,),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(minHeight: 3),
            )
          ],
        ),
      ),
    );
  }
}
