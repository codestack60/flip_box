import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_box/screens/components/song_item.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({Key? key}) : super(key: key);

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // GOOGLE ADS INTEGRATION
  AdRequest? adRequest;
  BannerAd? bannerAd;

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            //BANNER ADS
            Container(color: Color(0xFF302b63), height: 70,width: double.infinity, child: AdWidget(ad: bannerAd!,)),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder<List<SongModel>>(
                future: _audioQuery.querySongs(
                  sortType: SongSortType.DATE_ADDED,
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
                        return SongItem(songModel: item.data![index], currentSongs: item.data!,);
                      }
                  );
                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}
