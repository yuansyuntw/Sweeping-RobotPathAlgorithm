PImage inputImage;
PImage outputImage;

//String IMAGE_PATH = "data/Test_Image.tif";
String IMAGE_PATH = "data/octree1x1.tif";
int IMAGE_WIDTH = 1024, IMAGE_HEIGHT = 1024;

// Robot Size is 30 cm. 
int CUT_SIZE = 6; 

int CENTER_INDEX = IMAGE_WIDTH * ((IMAGE_HEIGHT/2) - 1) + IMAGE_WIDTH/2;
int PATH_COLOR = color(254,254,254);

void setup(){
  size(1024, 1024);
  background(0);
  
  // Open image file.
  inputImage = loadImage(IMAGE_PATH);
  println(inputImage);
  
  // Protect input image.
  outputImage = inputImage;
  
  // Draw a origin points.
  drawCrossLine(outputImage, 0, 0, color(0,0,255));
  
  // Cut grid image.
  boolean[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  //cutGridShow(outputImage, CUT_SIZE,color(50));
  
  //findVertex(inputImage, CUT_SIZE, gridArray);
  int cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  int cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  octreeCutting(gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth, cutHeight);
  
  
  // drawLine(0,0, pointX, pointY);
  //println(ZPath(0, 0, pointX, pointY, 6));
  
  // Draw start point text
  textSize(30);
  fill(0,255,0);
  //text("StartPoint", 0 +(IMAGE_WIDTH/2) , 0 + (IMAGE_HEIGHT/2));
  
  //Draw end point text
  textSize(30);
  fill(0,0,255);
  //text("EndPoint", pointX + (IMAGE_WIDTH/2), pointY + (IMAGE_HEIGHT/2));
  
  //outputImage.save(dataPath("filter_map.png"));
}//end setup



RegionMapInformation octreeCutting(boolean[] _mapArray, int _cutSize, int _originalPointX, int _originalPointY, int _regionWidth, int _regionHeight){
  
  //Cutting size is small.
  if(_regionWidth/2 <= _cutSize || _regionHeight/2 <= _cutSize){
    return null;
  }
  
  int LURegion_LUPointX = _originalPointX;
  int LURegion_LUPointY = _originalPointY;
  int LURegion_RDPointX = _originalPointX + _regionWidth/2 - 1;
  int LURegion_RDPointY = _originalPointY + _regionHeight/2 - 1;
  RegionMapInformation _LURegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight,  LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  int RURegion_LUPointX = _originalPointX + _regionWidth/2;
  int RURegion_LUPointY = _originalPointY;
  int RURegion_RDPointX = _originalPointX + _regionWidth;
  int RURegion_RDPointY = _originalPointY + _regionHeight/2;
  RegionMapInformation _RURegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  int LDRegion_LUPointX = _originalPointX;
  int LDRegion_LUPointY = _originalPointY + _regionHeight/2;
  int LDRegion_RDPointX = _originalPointX + _regionWidth/2 - 1;
  int LDRegion_RDPointY = _originalPointY + _regionHeight;
  RegionMapInformation _LDRegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  int RDRegion_LUPointX = _originalPointX + _regionWidth/2;
  int RDRegion_LUPointY = _originalPointY + _regionHeight/2;
  int RDRegion_RDPointX = _originalPointX + _regionWidth;
  int RDRegion_RDPointY = _originalPointY + _regionHeight;
  RegionMapInformation _RDRegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);
  
  
  if(_LURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
        
    return new RegionMapInformation (RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                 _originalPointX + _regionWidth, _originalPointY + _regionHeight);
    
  }else if (_LURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE){
    
      return new RegionMapInformation (RegionMapInformation.RegionState.FULL_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                 _originalPointX + _regionWidth, _originalPointY + _regionHeight);
    
  }else{
    return new RegionMapInformation (RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                 _originalPointX + _regionWidth, _originalPointY + _regionHeight);
  }//end if
  
  
}

RegionMapInformation getRegionInformation(boolean[] _mapArray, int _regionWidth, int _regionHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
 
  if(cutRectangleJudgment(_mapArray, _regionWidth, _regionHeight,_LUPointX, _LUPointY, _RDPointX, _RDPointY)){
    //Return emity region 
    return new RegionMapInformation(RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                      _LUPointX, _LUPointY,
                                      _RDPointX, _RDPointY);
  }else{
    //Return Mixed region
    return new RegionMapInformation(RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                      _LUPointX, _LUPointY,
                                      _RDPointX, _RDPointY);
  }
  
}//end checkRegion

boolean cutRectangleJudgment(boolean[] _mapArray, int _cutWidth, int _cutHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
  boolean result = true;
  
  //Check cut rectangle 
  int rectangleWidth = _RDPointX - _LUPointX;
  int rectangleHeight = _RDPointY - _LUPointY;
  int selectPointX = _LUPointX + _cutWidth/2;
  int selectPointY = _LUPointY + _cutHeight/2;
  int index = selectPointX + selectPointY*_cutWidth;
  
  for(int j=0; j<abs(rectangleWidth); j++){
     for(int i=0; i<abs(rectangleHeight); i++){
         println("SelectPointX = " + selectPointX + " SelectPointY = " + selectPointY + " index = " + index);
         if(!_mapArray[index]){
           result = false;
           return result;
         }
         index += rectangleWidth/abs(rectangleWidth);
     }
     index += rectangleHeight/abs(rectangleHeight) * _cutHeight;
  }//end for
  
  return result;
}