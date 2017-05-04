#include "ofApp.h"


int main() {
  
    //------------------------------------------------------
    ofiOSWindowSettings settings;
    settings.enableRetina = true; //trueへ変更
    settings.enableDepth = false; .
    settings.enableAntiAliasing = false; //trueにすると一切表示されない
    settings.numOfAntiAliasingSamples = 0; //
    settings.enableHardwareOrientation = false;
    settings.enableHardwareOrientationAnimation = false;
    settings.glesVersion = OFXIOS_RENDERER_ES1;
  
    settings.windowMode = OF_FULLSCREEN;
    ofCreateWindow(settings);
    
	return ofRunApp(new ofApp);
  
}


