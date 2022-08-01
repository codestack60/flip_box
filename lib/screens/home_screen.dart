import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flip_box/screens/components/search_box_modal.dart';
import 'package:flip_box/screens/folders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flip_box/screens/albums_screen.dart';
import 'package:flip_box/screens/all_songs_screen.dart';
import 'package:flip_box/screens/artists_screen.dart';
import 'package:flip_box/screens/components/drawer_menu.dart';
import 'package:flip_box/screens/components/player_box_small.dart';
import 'package:flip_box/screens/playlists_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:new_version/new_version.dart';
import '../utilities/app_router.dart';
import '../widgets/updatedialog.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //INTERSTITIAL ADS
  InterstitialAd? interstitialAd;

  @override
  void initState() {
    Timer(const Duration(milliseconds: 800), () {
      checkNewVersion(newVersion);
    });
    super.initState();
  }
  final newVersion = NewVersion(
    androidId: 'com.samurai.flip_box',
  );
  void checkNewVersion(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if(status != null) {
      if(status.canUpdate) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return UpdateDialog(
              allowDismissal: true,
              description: status.releaseNotes!,
              version: status.storeVersion,
              appLink: status.appStoreLink,
            );
          },
        );
        // newVersion.showUpdateDialog(
        //   context: context,
        //   versionStatus: status,
        //   dialogText: 'New Version is available in the store (${status.storeVersion}), update now!',
        //   dialogTitle: 'Update is Available!',
        // );
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: ()=>  _onBackButtonPressed(context),
      child: DefaultTabController(
        length: 5,
        initialIndex: 0,
        child: SafeArea(
          child: Scaffold(
           // drawer: DrawerMenu(),
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
                return <Widget>[
                  SliverAppBar(

                    pinned: true,
                    floating: true,
                    forceElevated: innerBoxIsScrolled,
                    title: GestureDetector(
                      onTap: (){

                      },
                        child: Text('FlipBox')),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: Icon(Icons.search_rounded),
                          onPressed: (){
                            showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context){
                                  return SearchBoxModal();
                                });
                          },
                        ),
                      ),
                      IconButton(onPressed: (){
                        context.router.pop();
                        context.router.push(const SettingsRoute());
                      }, icon: Icon(Icons.settings))
                    ],
                    bottom: TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(
                          child: Text(AppLocalizations.of(context)!.tab_all_songs),
                          icon: Icon(Icons.my_library_music_rounded),
                        ),
                        Tab(
                          child: Text(AppLocalizations.of(context)!.tab_playlists),
                          icon: Icon(Icons.playlist_add_check_circle_rounded),
                        ),
                        Tab(
                          child: Text(AppLocalizations.of(context)!.tab_artists),
                          icon: Icon(Icons.account_box_rounded),
                        ),
                        Tab(
                          child: Text(AppLocalizations.of(context)!.tab_albums),
                          icon: Icon(Icons.album_rounded),
                        ),
                        Tab(
                          child: Text(AppLocalizations.of(context)!.tab_folders),
                          icon: Icon(Icons.folder_copy_rounded),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  PlayerBoxSmall(),
                  Expanded(

                    child: TabBarView(
                      children: [
                        AllSongsScreen(),
                        PlaylistsScreen(),
                        ArtistsScreen(),
                        AlbumsScreen(),
                        FoldersScreen(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<bool> _onBackButtonPressed(BuildContext context) async{
    bool exitApp = await showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: SizedBox(
              height: 100,width: 100,child: Image.asset('assets/images/logo2.png'),
            ),
            content: Text('Do you want to exit FlipBox ? ',style: TextStyle(color: Color(0xFF302b63),fontSize: 19),),
            actions: <Widget>[
              TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: Text('No')),
              TextButton(onPressed: (){
                Navigator.of(context).pop(true);
                InterstitialAd.load(

                    adUnitId:  Platform.isAndroid?'ca-app-pub-9712530003331471/2361913535':'ca-app-pub-9712530003331471/2361913535',
                    request: AdRequest(
                      keywords: ['Medical','School','Finance','Banking'],
                    ),
                    adLoadCallback: InterstitialAdLoadCallback(
                      onAdLoaded: (ad){
                        interstitialAd=ad;
                        interstitialAd!.show();
                        interstitialAd!.fullScreenContentCallback=FullScreenContentCallback(
                            onAdFailedToShowFullScreenContent: ((ad, error)  {

                              print(error);
                              ad.dispose();
                              interstitialAd!.dispose();

                            }),
                            onAdDismissedFullScreenContent: (ad){
                              ad.dispose();
                              interstitialAd!.dispose();
                              //  Fluttertoast.showToast(msg: 'Moved To tHe Other Action');
                              //Todo:You Can Navigate To Ano Ther Screen If You Wish
                              Navigator.of(context).pop(true);
                            }
                        );
                      },
                      onAdFailedToLoad: (error){
                        print(error);
                      },
                    ));

              }, child: Text('Yes')),

            ],
          );
        }
    );

    return exitApp;
  }
}
