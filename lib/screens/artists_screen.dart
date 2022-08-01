import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flip_box/screens/components/artist_item.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({Key? key}) : super(key: key);

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  //INTERSTITIAL ADS
  InterstitialAd? interstitialAd;
  @override
  void initState() {
    Timer(const Duration(seconds: 5), () {
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
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<ArtistModel>>(
        future: _audioQuery.queryArtists(
          sortType: ArtistSortType.ARTIST,
          orderType: null,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item){

          if (item.data == null) return const Center(child: CircularProgressIndicator(),);

          // When you try "query" without asking for [READ] or [Library] permission
          // the plugin will return a [Empty] list.
          if (item.data!.isEmpty) return const Text("Nothing found!");

          return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: item.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return ArtistItem(artistModel: item.data![index],);
              }
          );
        },

      ),
    );
  }
}
