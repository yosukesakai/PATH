#pragma once

#include "ofxiOS.h"
#include "ofxGui.h"
#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxCvHaarFinder.h"



//--------------------------------------------------------


class ofApp : public ofxiOSApp{
  
//oFのデフォルト設定
  
public:
  void setup();
  void update();
  void draw();
  void exit();
  
  void touchDown(ofTouchEventArgs & touch);
  void touchMoved(ofTouchEventArgs & touch);
  void touchUp(ofTouchEventArgs & touch);
  void touchDoubleTap(ofTouchEventArgs & touch);
  void touchCancelled(ofTouchEventArgs & touch);
  
  void lostFocus();
  void gotFocus();
  void gotMemoryWarning();
  
  void deviceOrientationChanged(int newOrientation);
		
  
  //--------------------------------------------------------
  
  //iPhoneGuiExampleより
  
  float lengthRatio;
  int numPoints;
  bool bFill;
  

  //--------------------------------------------------------
  
  
  //guiの設定
  
  bool bHide;
  
  ofxFloatSlider       radius;
  ofxColorSlider       color;
  ofxVec2Slider        center;
  ofxIntSlider         circleResolution;
  ofxToggle            monitor;
  ofxLabel             screenSize;
  ofxPanel             gui;
  ofxIntSlider         interface;//1:rgb_camera、2:kinectをえらぶ "k"をおすとkinect "r"をおすとrgb_camera iOSでは不要
  ofxIntSlider         distanceThreshold1;//遠いほうの閾値
  ofxIntSlider         distanceThreshold2;//近いほうの閾値
  
  
  //--------------------------------------------------------
  
		
//add from original ver ↓
  
  
#define _USE_LIVE_VIDEO
#ifdef _USE_LIVE_VIDEO
  ofVideoGrabber        vidGrabber;//カメラからのキャプチャ
#else
  ofAVFoundationPlayer 	vidPlayer;//カメラを使わないでムービーファイルを使うとき
#endif
  
  
  ofxCvColorImage       colorImg_camera;//カメラからの画像
  ofxCvColorImage       colorImg_camera_small;//カメラからの画像を小さくしたもの???サンプルに有った方法に習う
  ofxCvGrayscaleImage 	grayImg_camera;//カメラからの画像をグレーに
  ofxCvGrayscaleImage 	grayImg_cameraV;//90度回転した画像を納める
  
  ofxCvGrayscaleImage 	grayBg;
  ofxCvGrayscaleImage 	grayDiff;
  
  unsigned char * pixelsH;//画像回転用
  unsigned char *	pixelsV;
  unsigned char *	pixelsV2;
  
  
  ofImage               img;
  ofImage               img2;
  ofImage               imgBlack;
  ofxCvHaarFinder       finder; //haar検出用
  
  //モニター表示用の変数
  ofxIntSlider          xa;//draw用カラムaのxの値
  ofxIntSlider          xb;//draw用カラムbのxの値
  ofxIntSlider          xb2;//draw用カラムb2のxの値
  ofxIntSlider          xc;//draw用カラムcのxの値
  
  //ムービー表示用の変数
  ofxIntSlider          movie_x;//movieのx座標
  ofxIntSlider          movie_y;//movieのy座標
  ofxIntSlider          movie_w;//movieのwidth
  ofxIntSlider          movie_h;//movieのheight
  
  
  int                   framerateA;
  int                   framerateB;
  int                   threshold;
  
  
  int                   eyeWidth;//haar検出したオブジェクトの大きさ
  ofRectangle           rect_haar;//haar検出された対象を示すrect
  int                   nearest_rect_haar_x;//最も近い対象を示すrectのパラメータ
  int                   nearest_rect_haar_y;
  int                   nearest_rect_haar_width;
  int                   nearest_rect_haar_height;
  int                   longestWidth;//最接近した対象を示すrectの大きさ これから距離を推定する
  int                   eyeHeight;//今は使っていない オリジナル版で使っていた目の高さ
  
  //モード移行のためのパラメータ
  float                 first_distance;//各インターフェイスの解析結果から算出した最接近した対象の距離、検出時の値
  float                 final_distance;//スムージングした最接近距離、導かれた描画に直接用いる値
  float                 limit_distance;//描画に影響を及ぼす限界
  
  //モード移行の関数用の係数
  float                 a;//alpha算出用 傾き
  float                 b;//alpha算出用 切片
  
  //CVを使うときに用いる
  int                   eyeWidthThreshold1;//なくす
  int                   eyeWidthThreshold2;
  
  //時間関連
  int                   elapsedTime;//millsecondを取得
  int                   closepositionStayingTime;//ユーザの近接位置滞在時間
  int                   closepositionStayingTimeThreshold;
  int                   noStayingTime;//ユーザの不在時間
  int                   noStayingTimeThreshold;//これを過ぎると遷移
  
  bool                  elapsedTimebool;
  int                   frameCounter;
  int                   frameCounter2;
  
  //モードを扱うための変数
  int                   mode;
  int                   lastmode;
  int                   nextmode;
  int                   gotonextscene;//シーン遷移の条件の一つ 一定時間滞在することで"1"になる
  
  int                   scene;
  int                   scenechange;
  int                   modechange;
  int                   playingmovie;
  int                   closeposition;
  
  int                   presence;//シーン移行判定値 人がいるとその距離に応じて設定され、いなくなると減少する
  
  
  //描画時のアルファ、音量
  int                   blackboardalpha;//黒板のアルファ シーンごとのフェードでも使う
  int                   fadeout;
  
  int                   alpha_sqx01;//sqx01
  int                   prealpha_sqx01;
  int                   alpha_sqx02;//sqx02
  int                   prealpha_sqx02;
  int                   alpha_sqx03;//sqx03
  int                   prealpha_sqx03;
  int                   alpha_sqx04;//sqx04 かつてのfinalmoviealpha
  
  float                 volume_bg;//bgの音量
  float                 volume_sqx01;//sqx01の音量
  float                 volume_sqx02;
  float                 volume_sqx03;
  float                 volume_sqx04;
  
  //add from original ver ↑
  
  ofVideoPlayer         bgmovie; //バックグラウンドムービー
  ofVideoPlayer         sq101; //scene1の１つ目のシーケンス
  ofVideoPlayer         sq102; //
  ofVideoPlayer         sq103; //
  ofVideoPlayer         sq104; //
  
  ofVideoPlayer         sq201; //
  ofVideoPlayer         sq202; //
  ofVideoPlayer         sq203; //
  ofVideoPlayer         sq204; //
  
  ofVideoPlayer         sq301; //
  ofVideoPlayer         sq302; //
  ofVideoPlayer         sq303; //
  ofVideoPlayer         sq304; //
  
  
  /*
   
  //ofxiOSVideoPlayer (ofAVFoundationPlayerから変更)
 
  ofxiOSVideoPlayer 		bgmovie; //バックグラウンドムービー
  ofxiOSVideoPlayer 		sq101; //scene1の１つ目のシーケンス
  ofxiOSVideoPlayer 		sq102; //
  ofxiOSVideoPlayer 		sq103; //
  ofxiOSVideoPlayer 		sq104; //
  
  ofxiOSVideoPlayer 		sq201; //
  ofxiOSVideoPlayer 		sq202; //
  ofxiOSVideoPlayer 		sq203; //
  ofxiOSVideoPlayer 		sq204; //
  
  ofxiOSVideoPlayer 		sq301; //
  ofxiOSVideoPlayer 		sq302; //
  ofxiOSVideoPlayer 		sq303; //
  ofxiOSVideoPlayer 		sq304; //
  
  
  
  //ofAVFoundationPlayer ofavf;//テスト用
  
  ofAVFoundationPlayer 		bgmovie; //バックグラウンドムービー
  ofAVFoundationPlayer 		sq101; //scene1の１つ目のシーケンス
  ofAVFoundationPlayer 		sq102; //
  ofAVFoundationPlayer 		sq103; //
  ofAVFoundationPlayer 		sq104; //
  
  ofAVFoundationPlayer 		sq201; //
  ofAVFoundationPlayer 		sq202; //
  ofAVFoundationPlayer 		sq203; //
  ofAVFoundationPlayer 		sq204; //
  
  ofAVFoundationPlayer 		sq301; //
  ofAVFoundationPlayer 		sq302; //
  ofAVFoundationPlayer 		sq303; //
  ofAVFoundationPlayer 		sq304; //
  
  */
  

  
  //--------------------------------------------------------
  
  //iOS用
  
  //環境光の明度を扱うパラメータ
  float                  brightness;
  ofxIntSlider           brightness_sensitivity;
  
  //環境光の明度をチャートで示す際のパラメータ
  float                  brightnessbarchartlength;
  
  //スクリーンサイズの取得用
  float                  screen_width;
  float                  screen_height;
  
  //シーンの選択用
  ofxPanel               gui_scene_choice;
  ofxButton              Button_scene1;
  ofxButton              Button_scene2;
  ofxButton              Button_scene3;
  int                    to_scene;
  int                    clicked_scene;
  bool                   bHide_gui_scene_choice;//表示の有無を設定
  
  //最初にシーンが選ばれたか否かを判別する
  bool                   scene_loaded;
  
  
  //文字表示用
  ofTrueTypeFont         font;
  
  //タッチを利用する場合に用いる
  float                  touch_x;
  float                  touch_y;
  
  //sceneの文字表示用
  ofTrueTypeFont         scene_text;
  
};





















