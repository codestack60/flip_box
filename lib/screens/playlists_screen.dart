import 'package:flip_box/notifiers/playlist_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flip_box/screens/components/playlist_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';


class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {

  String newPlayListName = "";

  // GOOGLE ADS INTEGRATION

  AdRequest? adRequest;
  BannerAd? bannerAd;
  //INTERSTITIAL ADS
  InterstitialAd? interstitialAd;
  @override
  void dispose() {
    bannerAd!.dispose();
    super.dispose();
  }
  @override
  void initState() {
    String bannerId= Platform.isAndroid? 'ca-app-pub-9712530003331471/3306780809':'ca-app-pub-9712530003331471/3306780809';
    adRequest= const AdRequest(
      keywords: ['Medical','School','Finance','Banking'],
      nonPersonalizedAds: true,
    );
    BannerAdListener bannerAdListener=BannerAdListener(
        onAdClosed: (ad){
          bannerAd!.load();
        },
        onAdFailedToLoad: (ad,error){
          bannerAd!.load();
        }
    );
    bannerAd=BannerAd(
        size: AdSize.fullBanner,
        adUnitId: bannerId,
        listener: bannerAdListener,
        request: adRequest!
    );
    bannerAd!.load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAlert(context),
            label: Text(AppLocalizations.of(context)!.create_playlist_btn),
            icon: const Icon(Icons.add_rounded),
            backgroundColor: Theme.of(context).primaryColor,
          ),
      body:  SingleChildScrollView(
        child: Column(
          children: [
            //BANNER ADS
            Container(color: Color(0xFF302b63), height: 70,width: double.infinity, child: AdWidget(ad: bannerAd!,)),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: Provider.of<PlaylistNotifier>(context).getPlaylists.length,
                itemBuilder: (context, index) {
                  return PlaylistItem(playlistModel: Provider.of<PlaylistNotifier>(context).getPlaylists[index]);
                },
              ),
            ),

          ],
        ),
      ),
    );
  }


  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.alert_playlist_create_hint_input
                    ),
                    onChanged: (value){
                      setState((){
                        newPlayListName = value;
                      });
                    },
                  ),
                ),
              ),
              title: Text(AppLocalizations.of(context)!.alert_playlist_create_title),
              actions: [
                ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.alert_playlist_create_save_btn),
                    onPressed: (){
                      context.read<PlaylistNotifier>().createPlaylist(newPlayListName);
                      Navigator.of(context).pop();

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
                    },
                ),
                ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.alert_playlist_create_cancel_btn),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                ),
              ],
            ));
  }

}
