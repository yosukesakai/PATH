# PATH - ユーザが対象をみるふるまいに応じて異なる映像を呈示するシステム - 
顔・両眼位置、距離、明度などに応じ、撮影位置・撮影速度の異なる映像を提示できます  

Currently Japanese Only  

#### PATH  
###### Interactive System for Displaying Different Videos Depending on User's Behavior to See Objects
Display  Recorded at Different Positions and Speeds Depending on Position of User's Face and Eyes  

概要は下記テキストに掲載されています  

	第 15 回日本バーチャルリアリティ学会大会論文集(2010 年)-ユーザの顔・両眼位置に応じ撮影位置・ 度の異なる 映像を呈示するシステム
 
 distanceThreshold1 シーンを切り替える距離のしきい値(mm)
 distanceThreshold2 シーンを切り替える距離のしきい値(mm)
 limit_distance ユーザの存在を認識する限界値 distanceThreshold1とdistanceThreshold2から算出
 
 シーンのシーケンスのアルファはそれぞれ単純な一次関数で変化する
 それぞれの関数(の傾きや切片)はdistanceThresholdから決める
 
 xa,xb,xb2,xcはウィンドウ上の座標を一括設定するための変数
 
 distanceは連続的に変化させる
 
 使い方
 "k"をおすとkinect "r"をおすとrgb_camera
 
 
 
 シーケンスはバックグラウンドを入れて5段階
 BG>sqx01>sqx02>sqx03>sqx04
 
 鑑賞者の距離はfinal_distanceで表現される(後述)
 
 BG(mode 11):
 何も検出されない場合、limit_distance内に人がいない場合
 検出されない(presence = 0である)時間(noStayingTime)が閾値(noStayingTimeThreshold(= 70))を超えた場合
 
 
 sqx01(mode 21)
 limit_distance内に人がいる場合
 (final_distance < limit_distanceの場合)
 noStayingTime = 0に設定(人がいるから)
 
 sqx02(mode 21)
 distanceThreshold2 内に人がいる場合
 
 sqx03(mode 21)
 distanceThreshold1 内に人がいる場合
 (final_distance < distanceThreshold1の場合)
 closepositionStayingTime を追加 (closepositionStayingTime +2)
 
 sqx04(mode 21)
 distanceThreshold1 内に人が一定時間いる場合
 近接滞在時間(closepositionStayingTime)が閾値(closepositionStayingTimeThreshold (= 200))を超えた場合
 (stayingTimeThresholdより長く滞在していたら)
 gotonextsceneを1にする
 
 
 ムービーは最初に全部読み込む、ループ設定する
 都度読み込んでみたがスムースに進行できない、いちど読み込み画面などを表示してその間に処理すれば良いかもしれない
 
 
 mode
 BG(11)とその他(21)
 
 
 scene
 みっつのsceneがある
 太宰府、宮崎、佐賀祐徳稲荷
 一度人が再近接して一定時間滞在した後に(gotonextscene =1になってから)、noStayingTimeを加算し、人がいなくなると次のsceneへ遷移する
 遷移はトリガー(scenechange = 1)で判断
 
 
 
 距離を検出する処理
 
 kinect>
 そのまんま
 指定した範囲内(w < 640, h < 480)での最近接距離(nearestpoint_distance_kinect)を
 first_distanceに代入
 
 CV>
 検出結果の最大幅(検出した顔の幅、両眼距離)をlongestWidthとしている
 longestWidthから対象の距離を推定している
 first_distanceの設定は以下 (mbp内蔵iSight用の変換式)  (筐体内蔵カメラのパラメータは違った(と思う))
 first_distance = 2440 - longestWidth*24;
 
 final_distanceはfirst_distanceから算出
 差分があればフレームごとに+5or-5で変化する (スムージング)
 
 輝度検出 iOS >
 デフォルト値distanceThreshold1:800 distanceThreshold2:1000 limit_distance:1400を前提として
 
 first_distance = brightness*5000;
 日中の室内: 0.35 >  1750
 暗い室内: 0.00002 > 0.1 (小さすぎる?)
 
 ----
 一定間隔処理
 elapsedTimeboolがtrueなら処理
 closeならelapsedTimeboolはframerateAごとに処理
 closeでないならelapsedTimeboolはframerateBごとに処理
 
 
 音量設定について
 bgmovie -40db highpass 300Hz
 sqx01 -30
 sqx02 -20
 sqx03 -20
 sqx04 -10
 
 FCPムービー書き出し設定
 書き出し>QT変換
 H.264
 480x640
 高品質
 フィルタ:なし (使うなら事前に)
 AAC
 256kbps
 
 
 