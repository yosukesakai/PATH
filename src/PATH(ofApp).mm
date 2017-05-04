/*
Copyright 2017 SAKAI Yosuke

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


#include "ofApp.h"
//#import "AVFoundationVideoPlayer.h" //現在は使っていない 必要に応じて導入



//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
void ofApp::setup(){
  
  
  //ios用
  
  /*タッチ操作が必要なら導入する
  // タッチイベントの登録
  ofRegisterTouchEvents(this);
  */
  
  //orientationをきめる
  ofSetOrientation(OF_ORIENTATION_DEFAULT);//たて位置
  
  
  //--------------------------------------------------------------
  
  //映像表示位置、大きさなどの設定
  
  screen_width	= ofGetWidth();
  screen_height	= ofGetHeight();
  
  float screen_retio;
  screen_retio =screen_height/screen_width;
  
  
  //高さはインターフェイス(sensitivity)の高さを引いた長さ
  movie_h=screen_height-70;
  
  //幅はスクリーンの端あわせ
  movie_w=(screen_height-70)*3/4;
  
  //表示位置を設定する、xの原点はムービーがセンターに来るように、yの原点は端あわせ
  movie_x=(screen_width-movie_w)/2;
  movie_y=0;
  
  
  
  //--------------------------------------------------------------
  
  //Sensitivtyのスライドバーの設定 (ofxGui) iOS用
  
  //同期をとる
  ofSetVerticalSync(true);
  
  //セットアップ なおfontの指定(ofxGuiSetFont)はdrawの直前に置く
  gui.setup();
  
  //表示位置の設定、ムービーの下に置く、大きさはムービーの下のスペースいっぱいにする
  gui.setPosition(0, movie_h);
  gui.setSize(screen_width, screen_height);//窓の高さ
  gui.setWidthElements(screen_width);//窓の幅

  //スライダーの幅、高さを設定
  gui.setDefaultWidth(screen_width);
  gui.setDefaultHeight(50);
  
  //Sensitivityの値の初期設定
  gui.add(brightness_sensitivity.setup(" SENSITIVITY 0 - 10000", 5000, 000, 10000));
  
  //表示を消したいときはtrueに
  bHide = false;
  
  //monitor = true ;//各種値をモニター表示したいときなどに用いる
  
  
  
  
  //--------------------------------------------------------------
  
  //Scene Choiceのボタンの設定 (ofxGui) iOS用
  
  //同期をとる
  ofSetVerticalSync(true);
  
  //fontの指定(ofxGuiSetFont)はdrawの直前に置く
  
  //セットアップ なおfontの指定(ofxGuiSetFont)はdrawの直前に置く
  gui_scene_choice.setup("SCENE?");
  
  //表示位置の設定
  gui_scene_choice.setPosition(0, -49);
  gui_scene_choice.setSize(screen_width-1, screen_height);//窓の高さ
  gui_scene_choice.setWidthElements(screen_width);//窓の幅
  
  
  //ボタンの高さを設定
  gui_scene_choice.setDefaultHeight(100);
  
  //gui_scene_choiceの値の初期設定
  gui_scene_choice.add(Button_scene1.setup(" scene 1  Saitobaru Goryobo", false));
  gui_scene_choice.add(Button_scene2.setup(" scene 2  Yutoku Inari Shrine", false));
  gui_scene_choice.add(Button_scene3.setup(" scene 3  Dazaifu", false));
  
  //表示を消したいときはtrueに
  bHide_gui_scene_choice = false;
  
  
  
  
  //--------------------------------------------------------------
  
  
  //シーンを切り替える距離のしきい値(mm)の設定
  distanceThreshold1 = 800;
  distanceThreshold2 = 1000;
  
  //それぞれの閾値から限界距離を導く
  limit_distance = (distanceThreshold2*255.00/(distanceThreshold1-distanceThreshold2)-510 ) * (distanceThreshold1-distanceThreshold2)/255;
  
  //遠いところから始まるよう初期設定
  first_distance = limit_distance;

  //blackboardの準備
  imgBlack.load("blackboard.jpg");
  
  
  //--------------------------------------------------------
  
  /*
  //検出、計測処理をするタイミング 下記レートごとに検出処理を行う 毎フレームに処理をしても問題ないなら不要
  framerateA = 4;//default:4
  framerateB = 40;//default:40
  */
  
  
  //全体のフレームレートの設定
  ofSetFrameRate(30);//デフォルト30
  
  
  //--------------------------------------------------------
  //もろもろの変数の初期設定
  
  /*
  //自動遷移を実装する場合に用いる
  noStayingTime = 0;
  noStayingTimeThreshold = 70;
  */
  
  //最後のモードに移行するために用いる
  closeposition = 0;
  closepositionStayingTime = 0;
  closepositionStayingTimeThreshold = 200;
  
  //一定のタイミングが来たときに行う処理を、初めに行う
  elapsedTimebool = true;
  
  
  mode = 11;
  lastmode = 11;
  nextmode = 11;
  frameCounter = 0;
  
  scene = 0;
  scenechange = 1;
  modechange = 1;
  
  presence = 0;
  blackboardalpha = 255;
  alpha_sqx04 = 0;


  
  //--------------------------------------------------------
  
  
  //バックグラウンドムービーの準備
  
  bgmovie.load("movies/bgmovie.mov");
  bgmovie.setLoopState(OF_LOOP_NORMAL);
  bgmovie.play();
  
  //scene_textの設定
  scene_text.loadFont("mono.ttf", 15, true, false, 0);
  
  
}


//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
void ofApp::update(){
  
  
  //まず画面をリセット これがないとうまくいかない
  ofBackground(0,0,0);//背景色

  //--------------------------------------------------------
  
  //シーンが選択されたときに、そのシーンのムービーファイルを1度だけ読み込む (scene_loadedで読み込み済みか確認する)
  
  if(Button_scene1 == true and scene_loaded == false){
    sq101.load("movies/sq0101.mov");
    sq102.load("movies/sq0102.mov");
    sq103.load("movies/sq0103.mov");
    sq104.load("movies/sq0104.mov");
    sq101.setLoopState(OF_LOOP_NORMAL);
    sq102.setLoopState(OF_LOOP_NORMAL);
    sq103.setLoopState(OF_LOOP_NORMAL);
    sq104.setLoopState(OF_LOOP_NORMAL);
    sq101.play();
    sq102.play();
    sq103.play();
    sq104.play();
    scene_loaded = true;
    scene = 1;
  }
  
  
  if(Button_scene2 == true and scene_loaded == false){
    sq201.load("movies/sq0201.mov");
    sq202.load("movies/sq0202.mov");
    sq203.load("movies/sq0203.mov");
    sq204.load("movies/sq0204.mov");
    sq201.setLoopState(OF_LOOP_NORMAL);
    sq202.setLoopState(OF_LOOP_NORMAL);
    sq203.setLoopState(OF_LOOP_NORMAL);
    sq204.setLoopState(OF_LOOP_NORMAL);
    sq201.play();
    sq202.play();
    sq203.play();
    sq204.play();
    scene_loaded = true;
    scene = 2;
  }
  
  
  if(Button_scene3 == true and scene_loaded == false){
    sq301.load("movies/sq0301.mov");
    sq302.load("movies/sq0302.mov");
    sq303.load("movies/sq0303.mov");
    sq304.load("movies/sq0304.mov");
    sq301.setLoopState(OF_LOOP_NORMAL);
    sq302.setLoopState(OF_LOOP_NORMAL);
    sq303.setLoopState(OF_LOOP_NORMAL);
    sq304.setLoopState(OF_LOOP_NORMAL);
    sq301.play();
    sq302.play();
    sq303.play();
    sq304.play();
    scene_loaded = true;
    scene = 3;
  }
  
  
  /*
  //haar検出用の前処理 画像処理する場合は用いる
  
  bool bNewFrame = false;//初期化(サンプルにあったもの)
  vidGrabber.update();
  bNewFrame = vidGrabber.isFrameNew();
  
  if (bNewFrame){
    colorImg_camera.setFromPixels(vidGrabber.getPixels());//サンプルの値(640,480)を削除 エラーが出る
   
   //haarの処理対象はofxCvGrayscaleImage　認識用のグレイイメージを作る
    colorImg_camera_small.scaleIntoMe(colorImg_camera, CV_INTER_NN);//カメラからの画像を小さくしたもの(サンプルに習う)
    grayImg_camera = colorImg_camera;//カメラからの画像を小さくしたもの(サンプルに習う)
    
  }
  */
  
  
  //検出処理のタイミングの処理 一定のフレーム間隔ごとにelapsedtimebool=trueにする
  
  
  //closeposition == 0 のとき、つまり近くにいないときは、一定の(framerateA)ごとに、elapsedtimebool=trueにして、認識処理する
  if( closeposition == 0){
    
    if( frameCounter < framerateA){
      
      frameCounter ++;
      elapsedTimebool = false;
      
    }
    
    else{
      
      frameCounter = 0;
      elapsedTimebool = true;
    }
    
  }
  
  
  //closeposition == 1 のとき、つまり近くにいるときは、一定の(framerateB)フレームごとに、elapsedtimebool=trueにして、認識処理する
  if( closeposition == 1){
    
    if( frameCounter < framerateB){
      
      frameCounter ++;
      elapsedTimebool = false;
      
    }
    
    else{
      
      frameCounter = 0;
      elapsedTimebool = true;
    }
    
    
  }
  
  
  
  //スクリーン輝度(環境光の明るさ)を取得し、first_distanceを設定する iOS用
    
    brightness = [UIScreen mainScreen].brightness;
    
    first_distance = brightness*brightness_sensitivity;//brightnessとbrightness_sensitivityからfirstdistanceを求める
  
  
  
  
  //--------------------------------------------------------
  
  
  if(final_distance < first_distance){
    final_distance = final_distance +20;//オリジナルは+5
  }
  else if(final_distance > first_distance ){
    final_distance = final_distance -20;//オリジナルは-5
  }
  
  
  //--------------------------------------------------------
  
  //alpha_sqx04の処理 closepositionにいれば増加する
  
  if( closeposition == 1 ){
    
    alpha_sqx04 = alpha_sqx04 + 1;
    
    if(255 < alpha_sqx04 ){
      
      alpha_sqx04 = 255;
      
    }
    
  }
  
  if(closeposition == 0 ){
    
    alpha_sqx04 = alpha_sqx04 - 3;
    
    if( alpha_sqx04  < 0 ){
      
      alpha_sqx04 = 0;
      
    }
    
  }
  
  
  
  //presence(ユーザの存在感,scene移行判定値)の値をlongestWidthから設定 検出されないときは減少させる (各sceneの最後のシーケンスでpresenceがなくなれば次のsceneへ移行)
  //要改修!!!
  
  
  if(0 < longestWidth){
    presence = longestWidth * 4;
  }
  
  else{
    if(0 < presence)
      presence = presence - 5;
  }
  
  if(255 < presence){
    presence =255;
  }
  
  
  
  //closepositionの振り分け distanceThreshold2より近くなればclosepositionにいたことにする
  
  if(final_distance < distanceThreshold1){
    
    closeposition = 1;
    
  }
  
  else{
    
    closeposition = 0;
    
  }
  
  
  //--------------------------------------------------------
  
  
  
  //modeの振り分け設定 すべてのシーンで適用、modeがかわる際にfadeを使う
  //mode11 - no eye, 21 - ユーザがいる
  
  //mode21 ユーザがいる
  
  //ユーザが存在していたら
  
  if(final_distance < limit_distance){
    noStayingTime = 0;
    nextmode = 21;//eye far
    
  }
  
  
  //distanceThreshold1より近かったら
  
  if(final_distance < distanceThreshold1){
    closepositionStayingTime = closepositionStayingTime +2;
    
  }
  
  
  //stayingTimeThresholdより長く滞在していたら
  
  if(closepositionStayingTimeThreshold < closepositionStayingTime){
    gotonextscene =1;
    
  }
  
  
  /*
  //シーン遷移を実装するときは用いる
  //もし何も検出されない時間があれば
  //noStayingTimeのカウント gotonextscene =1になってから 人がいない状態ならnoStayingTimeを加算
  
  if(final_distance > limit_distance*0.9){//これで良いか確認!!!!! kinectでも?
    
    noStayingTime ++;
    if(gotonextscene == 1 and 0 < closepositionStayingTime){
      closepositionStayingTime --;
    };
    
  }
  */
  
  //誰もいない状態 ポジション0 ユーザがいなくなってしばらく経ったらフェードを始める
  
  if(noStayingTime > noStayingTimeThreshold){
    
    closepositionStayingTime = 0;
    nextmode = 11;//
    
  }
  
  
  
  //--------------------------------------------------------
  
  
  //フェードアウト blackboardalphaを上げることでフェードアウトする
  
  if(mode != nextmode){
    fadeout = 1;
    blackboardalpha = blackboardalpha + 20;
    if( 300 < blackboardalpha ){//本来は255だが、ディレイが出るので、余裕を持つ
      mode = nextmode;
      noStayingTime = 0;
      fadeout = 0;
    }
    
  }
  
  
  
  //--------------------------------------------------------
  
  //フェードイン blackboardalphaを下げることでフェードインする
  //modeがかわれば実行
  
  if(mode != lastmode){
    modechange = 1;
  }
  
  if(modechange ==1 ){//本来は255だが、ディレイが出るので、余裕を持つ
    blackboardalpha = 350;
    
  }
  lastmode =  mode;
  
  
  if(-100 < blackboardalpha and nextmode == mode){////本来は255だが、ディレイが出るので、余裕を持つ
    blackboardalpha = blackboardalpha - 5;
  }
  
  
  //--------------------------------------------------------
  

  //シーンがかわるとそのシーンのファイルを再生する bgmovieはそのまま再生し続ける
  
  
  if(scenechange == 1){
    
    
    
    if(scene == 1){
      
      sq101.play();
      sq102.play();
      sq103.play();
      sq104.play();
      
      sq201.stop();
      sq202.stop();
      sq203.stop();
      sq204.stop();
      
      sq301.stop();
      sq302.stop();
      sq303.stop();
      sq304.stop();
      
    }
    
    if(scene == 2){
      
      sq101.stop();
      sq102.stop();
      sq103.stop();
      sq104.stop();
      
      sq201.play();
      sq202.play();
      sq203.play();
      sq204.play();
      
      sq301.stop();
      sq302.stop();
      sq303.stop();
      sq304.stop();
    }
    
    if(scene == 3){
      
      sq101.stop();
      sq102.stop();
      sq103.stop();
      sq104.stop();
      
      sq201.stop();
      sq202.stop();
      sq203.stop();
      sq204.stop();
      
      sq301.play();
      sq302.play();
      sq303.play();
      sq304.play();
      
    }
    
    
  }
  
  
  //--------------------------------------------------------
  
  
  //ムービーのアップデート シーン毎に切り替え
  
  bgmovie.update();
  
  if(scene == 1){
    
    sq101.update();
    sq102.update();
    sq103.update();
    sq104.update();
    
  }
  
  if(scene == 2){
    
    sq201.update();
    sq202.update();
    sq203.update();
    sq204.update();
    
  }
  
  if(scene == 3){
    
    sq301.update();
    sq302.update();
    sq303.update();
    sq304.update();
    
  }
  
  
  
}


//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------
//--------------------------------------------------------------

void ofApp::draw(){
  
  
    
    //ムービー描画 各シーケンスの描画 オーバラップ版
    

    //1. まずprealphaの設定
    
    if(elapsedTimebool == true){
      
      

      a = (255.00)/(distanceThreshold1-distanceThreshold2);
      b =  (-1)*distanceThreshold2*255.00/(distanceThreshold1-distanceThreshold2) +255 +255;
      prealpha_sqx01 = final_distance*a + b;
      
      limit_distance = (distanceThreshold2*255.00/(distanceThreshold1-distanceThreshold2)-510 ) * (distanceThreshold1-distanceThreshold2)/255;
      
      if(255<prealpha_sqx01){
        prealpha_sqx01=255;
      }
      if(prealpha_sqx01<0){
        prealpha_sqx01=0;
        
      }
      

      
      a = (255.00)/(distanceThreshold1-distanceThreshold2);
      b =  (-1)*distanceThreshold2*255.00/(distanceThreshold1-distanceThreshold2) +255;
      prealpha_sqx02 = final_distance*a + b;
      
      if(255<prealpha_sqx02){
        prealpha_sqx02=255;
      }
      if(prealpha_sqx02<0){
        prealpha_sqx02=0;
        
      }
      

      
      a = (255.00)/(distanceThreshold1-distanceThreshold2);
      b =  (-1)*distanceThreshold2*255.00/(distanceThreshold1-distanceThreshold2);
      prealpha_sqx03 = final_distance*a + b;
      
      
      if(255<prealpha_sqx03){
        prealpha_sqx03=255;
      }
      if(prealpha_sqx03<0){
        prealpha_sqx03=0;
      }
      
    }
    

    
    //2. prealphaからalphaを導く
    
    
    //prealpha_sqx01からalpha_sqx01を
    if(prealpha_sqx01 < alpha_sqx01){
      alpha_sqx01 = alpha_sqx01 -3;
    }
    else if(prealpha_sqx01 == alpha_sqx01){
      alpha_sqx01 = prealpha_sqx01;
    }
    else if(alpha_sqx01 < prealpha_sqx01){
      alpha_sqx01 = alpha_sqx01 +3;
    }
    
    
    
    //prealpha_sqx02からalpha_sqx02を
    if(prealpha_sqx02 < alpha_sqx02){
      alpha_sqx02 = alpha_sqx02 -3;
    }
    else if(prealpha_sqx02 == alpha_sqx02){
      alpha_sqx02 = prealpha_sqx02;
    }
    else if(alpha_sqx02 < prealpha_sqx02){
      alpha_sqx02 = alpha_sqx02 +3;
    }
    
    
    
    //prealpha_sqx03からalpha_sqx03を
    if(prealpha_sqx03 < alpha_sqx03){
      alpha_sqx03 = alpha_sqx03 -3;
    }
    else if(prealpha_sqx03 == alpha_sqx03){
      alpha_sqx03 = prealpha_sqx03;
    }
    else if(alpha_sqx03 < prealpha_sqx03){
      alpha_sqx03 = alpha_sqx03 +3;
    }
    
    
    

    //3. それからモード毎の描画
  
    
    //3.1 さいしょにBGの描画 シーンに関係なくずっと描画する
    
    if(mode == 11);{
      
      //ofEnableAlphaBlending();//最も下のレイヤーで描画し続けるので、アルファの設定は不要
      //ofSetColor(255, 255, 255, 100);
      
      volume_bg = (255.0 -alpha_sqx01 -alpha_sqx04 )/255.0;
      if(volume_bg<0){
        volume_bg=0;
      }
      bgmovie.setVolume(volume_bg);//alpha_sqx04に変更
      bgmovie.draw(movie_x,movie_y,movie_w,movie_h);
      
    }
    
    
    //3.2 各モードの描画
    
    if(mode == 21 or mode == 22 or mode == 31 or mode == 32 ){
      
      
      
      //各シーケンスの描画
      
      //準備
      ofEnableAlphaBlending();
      
      
      //原因不明の残像対策のため黒板表示 後ろへ移動
      ofSetColor(255, 255, 255);
      imgBlack.draw(xa,20);
      ofSetColor(0xffffff);
      
      
      //1つ目のシーケンスの描画 scene毎に
      
      ofSetColor(255, 255, 255, alpha_sqx01);//アルファはシーンごとに共通
      volume_sqx01 = (alpha_sqx01 -alpha_sqx02 -alpha_sqx04)/255.0;
      if(volume_sqx01<0){
        volume_sqx01=0;
      }
      
      if(scene == 1){
        sq101.setVolume(volume_sqx01); //音量は、アルファと同じ
        sq101.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 2){
        sq201.setVolume(volume_sqx01);
        sq201.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 3){
        sq301.setVolume(volume_sqx01);
        sq301.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      
      //2つ目のシーケンスの描画 scene毎に
      
      ofSetColor(255, 255, 255, alpha_sqx02);//アルファはシーンごとに共通
      volume_sqx02 = (alpha_sqx02 - alpha_sqx03 - alpha_sqx04)/255.0;//音量は、最後のムービーが現れるにつれて小さくなる
      if(volume_sqx02<0){
        volume_sqx02=0;
      }
      
      if(scene == 1){
        sq102.setVolume(volume_sqx02);
        sq102.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 2){
        sq202.setVolume(volume_sqx02);
        sq202.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 3){
        sq302.setVolume(volume_sqx02);
        sq302.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      
      //3つ目のシーケンスの描画 scene毎に
      
      ofSetColor(255, 255, 255, alpha_sqx03);
      volume_sqx03 = (alpha_sqx03 - alpha_sqx04)/255.0;//音量は、最後のムービーが現れるにつれて小さくなる
      if(volume_sqx03<0){
        volume_sqx03=0;
      }
      
      
      if(scene == 1){
        sq103.setVolume(volume_sqx03);
        sq103.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 2){
        sq203.setVolume(volume_sqx03);
        sq203.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 3){
        sq303.setVolume(volume_sqx03);
        sq303.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      
      //4つ目のシーケンスの描画 scene毎に
      
      ofSetColor(255, 255, 255, alpha_sqx04);
      volume_sqx04 = alpha_sqx04 / 255.0;//音量は、アルファと比例
      if(volume_sqx04<0){
        volume_sqx04=0;
      }
      
      if(scene == 1){
        sq104.setVolume(volume_sqx04);
        sq104.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 2){
        sq204.setVolume(volume_sqx04);
        sq204.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      if(scene == 3){
        sq304.setVolume(volume_sqx04);
        sq304.draw(movie_x,movie_y,movie_w,movie_h);
      }
      
      
      ofDisableAlphaBlending();
      
    }
    
    
    
    
    //--------------------------------------------------------
    
    //4. ムービー描画に関する条件を示す変数のリセット
    scenechange = 0;
    modechange = 0;
    
    
    
    //--------------------------------------------------------
    
    //5. シーンを示すテキストの表示
    
    //sceneの表示 フォントサイズをアレンジするためtrue typeを用いる
    
    ofSetColor(200);//文字の色
    
    if(scene == 1){
      ofSetColor(200);
      scene_text.drawString("Saitobaru Goryobo", 10, movie_y+movie_h-15);
    }
    
    if(scene == 2){
      ofSetColor(200);
      scene_text.drawString("Yutoku Inari Shrine", 10, movie_y+movie_h-15);
    }
    
    if(scene == 3){
      ofSetColor(200);
      scene_text.drawString("Dazaifu", 10, movie_y+movie_h-15);
    }
    
    //最後にblackboard描画 これがないとうまく動かない
    
    ofEnableAlphaBlending();
    ofSetColor(255, 255, 255, blackboardalpha);
    imgBlack.draw(movie_x,movie_y,movie_w,movie_h);//逆にiOSではこれがあると絵が出ないことがある
    ofDisableAlphaBlending();
    ofSetColor(0xffffff);
  
    
    
    
    //--------------------------------------------------------
    
    //6. ofxGuiの描画
    
    //sensitivityを描画する
    if(!bHide){
      gui.setPosition(0, movie_h);//ポジションがずれないように元の場所を指定
      ofxGuiSetFont("mono.ttf", 15, true, false, 0);//fontの指定(ofxGuiSetFont)はdrawの直前に置く
      gui.draw();
    }

    //scene choiseを描画する
    if(scene_loaded != true){
      gui_scene_choice.setPosition(0, -49);
      ofxGuiSetFont("mono.ttf", 20, true, false, 0);//fontの指定(ofxGuiSetFont)はdrawの直前に置く
      gui_scene_choice.draw();
    }
  
  
    
    //----------
    
    //7. 明るさをバーで表示
    
    ofColor(255, 255);
    
    brightnessbarchartlength = screen_width*brightness;
    ofRect(0, screen_height-4, brightnessbarchartlength, 4);
    
    
    /*
     //明るさの数値での確認
     ofSetColor(255, 255, 255);//文字の色 グレー
     char reportStr2[1024];
     sprintf(reportStr2, "brightness %f ", brightness);
     ofDrawBitmapString(reportStr2, 50, screen_height-50);
     
     sprintf(reportStr2, "brightnessbarchartlength %f ", brightnessbarchartlength);
     ofDrawBitmapString(reportStr2, 200, screen_height-50);
     */
    
    /*
     //タッチした座標の数値での確認
     ofSetColor(255, 255, 255);//文字の色 グレー
     char reportStr2[1024];
     sprintf(reportStr2, "touch.x %f ", touch_x);
     ofDrawBitmapString(reportStr2, 50, screen_height-50);
    */
  
  

  //--------------------------------------------------------------
  //--------------------------------------------------------------
  //--------------------------------------------------------------
  //--------------------------------------------------------------
  //--------------------------------------------------------------
  
  
  
  
}

//--------------------------------------------------------------
void ofApp::exit(){
  
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
  
  /*
  //タッチがあればその座標を取得する 必要に応じて用いる
  touch_x = touch.x;
  touch_y = touch.y;
  */
  
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
  
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
  
  /*
  //画面から指が離れたら、位置を画面外に 必要に応じて用いる
  touch.x = -100;
  touch.y = -100;
  touch_x = touch.x;
  touch_y = touch.y;
  */
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
  
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
  
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
  
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
  
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
  
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
  
}


