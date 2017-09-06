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
  println(inputImage + "\n");
  
  // Protect input image.
  outputImage = inputImage;
  
  // Cut grid image.
  boolean[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  cutGridShow(outputImage, CUT_SIZE, color(25));

   // Draw a origin points.
  drawCrossLine(outputImage, 0, 0, color(0,0,255));
  
  //findVertex(inputImage, CUT_SIZE, gridArray);
  int cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  int cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  println("cutWidth = " + cutWidth + " cutHeight = " + cutHeight + "\n");
  octreeCutting(outputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth, cutHeight);
  int index = 0;
  for(int j=0; j<cutHeight; j++){
    for(int i=0; i<cutWidth; i++){
      if(gridArray[index]){
        print(" ");
      }else{
        print("X");
      }
      index++;
    }
    //index++;
    print("\n");
  }
  
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
  
  outputImage.save(dataPath("octree_map_001.png"));
}//end setup



RegionMapInformation octreeCutting(PImage _image, boolean[] _mapArray, int _cutSize, int _originalPointX, int _originalPointY, int _regionWidth, int _regionHeight){
  RegionMapInformation resultMap;  
  
  //Cutting size is small.
  if(_regionWidth/2 <= _cutSize || _regionHeight/2 <= _cutSize){
    return null;
  }
  
  // Draw center cut line
  int centerPointX = _originalPointX + _regionWidth/2;
  int centerPointY = _originalPointY + _regionHeight/2;
  drawCrossLine(_image, centerPointX, centerPointY, color (50));
  
  // Explore Left Up Region
  int LURegion_LUPointX = _originalPointX;
  int LURegion_LUPointY = _originalPointY;
  drawCuttingRegionPoint(_image, CUT_SIZE, LURegion_LUPointX, LURegion_LUPointY, color(0,255,0));
  int LURegion_RDPointX = _originalPointX + _regionWidth/2 - 1;
  int LURegion_RDPointY = _originalPointY + _regionHeight/2 - 1;
  drawCuttingRegionPoint(_image, CUT_SIZE, LURegion_RDPointX, LURegion_RDPointY, color(0,255,0));
  RegionMapInformation _LURegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight,  LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  // Explore Right Up Region
  int RURegion_LUPointX = _originalPointX + _regionWidth/2;
  int RURegion_LUPointY = _originalPointY;
  drawCuttingRegionPoint(_image, CUT_SIZE, RURegion_LUPointX, RURegion_LUPointY, color(0,255,0));
  int RURegion_RDPointX = _originalPointX + _regionWidth - 1;
  int RURegion_RDPointY = _originalPointY + _regionHeight/2 - 1;
  drawCuttingRegionPoint(_image, CUT_SIZE, RURegion_RDPointX, RURegion_RDPointY, color(0,255,0));
  RegionMapInformation _RURegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  // Explore Left Down Region
  int LDRegion_LUPointX = _originalPointX;
  int LDRegion_LUPointY = _originalPointY + _regionHeight/2;
  drawCuttingRegionPoint(_image, CUT_SIZE, LDRegion_LUPointX, LDRegion_LUPointY, color(0,255,0));
  int LDRegion_RDPointX = _originalPointX + _regionWidth/2 - 1;
  int LDRegion_RDPointY = _originalPointY + _regionHeight - 1;
  drawCuttingRegionPoint(_image, CUT_SIZE, LDRegion_RDPointX, LDRegion_RDPointY, color(0,255,0));
  RegionMapInformation _LDRegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  // Explore Right Down Region
  int RDRegion_LUPointX = _originalPointX + _regionWidth/2;
  int RDRegion_LUPointY = _originalPointY + _regionHeight/2;
  drawCuttingRegionPoint(_image, CUT_SIZE, RDRegion_LUPointX, RDRegion_LUPointY, color(0,255,0));
  int RDRegion_RDPointX = _originalPointX + _regionWidth - 1;
  int RDRegion_RDPointY = _originalPointY + _regionHeight - 1;
  drawCuttingRegionPoint(_image, CUT_SIZE, RDRegion_RDPointX, RDRegion_RDPointY, color(0,255,0));
  RegionMapInformation _RDRegion = getRegionInformation(_mapArray, _regionWidth, _regionHeight, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);
  
  // Determine whether the sub-region is empty-obstacle
  if(_LURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
        
     return new RegionMapInformation (RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                _originalPointX + _regionWidth, _originalPointY + _regionHeight);
    
  }else if (
      // Determine whether the sub-region is full-obstacle
      _LURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
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
 
  switch(cutRectangleJudgment(_mapArray, _regionWidth, _regionHeight,_LUPointX, _LUPointY, _RDPointX, _RDPointY)){
    case RegionMapInformation.RegionState.EMITY_OBSTACLE:
        // Return emity obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                          _LUPointX, _LUPointY,
                                          _RDPointX, _RDPointY);
    case RegionMapInformation.RegionState.FULL_OBSTACLE:
        // Return full obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.FULL_OBSTACLE,
                                         _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);
    default:
        // Return mixed obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                        _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);

  }//end switch
}//end checkRegion

int cutRectangleJudgment(boolean[] _mapArray, int _cutWidth, int _cutHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
  boolean emityResult = true;
  boolean fullResult = true;
  
  println("cutRectangleJudgment _LUPoint (" + _LUPointX + ", " + _LUPointY + ") _RDPoint (" + _RDPointX + ", " + _RDPointY + ")");
  
  //Check cut rectangle 
  int rectangleWidth = _RDPointX - _LUPointX;
  int rectangleHeight = _RDPointY - _LUPointY;
  int selectPointX = (_LUPointX + (_cutWidth/2));
  int selectPointY = (_LUPointY + (_cutHeight/2));

  println("rectangleWidth = " + (abs(rectangleWidth)+1) + ", rectangleHeight = " + (abs(rectangleHeight)+1));

  //print("selectPoint ("+selectPointX+","+selectPointY+") index = " + (selectPointX  + (selectPointY * _cutWidth)));
  
  for(int i=0; i<abs(rectangleWidth) + 1; i++){
    print(i%10);
  }
  print("\n");
  for(int j=0; j<=abs(rectangleHeight) + 1; j++){
    //print(j+" ");
    for(int i=0; i<abs(rectangleWidth) + 1; i++){
      if( !_mapArray[selectPointX  + (selectPointY * _cutWidth)] ){
        emityResult = false;
      }else if( _mapArray[selectPointX  + (selectPointY * _cutWidth)] ){
        fullResult = false;
      }
      if(_mapArray[selectPointX  + (selectPointY * _cutWidth)]){
        print(" ");
      }else{
        print("X");
      }
      selectPointX += rectangleWidth/abs(rectangleWidth);
    }
    print("\n");
    //println(" selectPoint ("+selectPointX+","+selectPointY+") index = " + (selectPointX  + (selectPointY * _cutWidth)));
    selectPointX = (_LUPointX + (_cutWidth/2)) ;
    selectPointY += rectangleHeight/abs(rectangleHeight);
    //print("selectPoint ("+selectPointX+","+selectPointY+") index = " + (selectPointX  + (selectPointY * _cutWidth)));
  }//end for
  print("\n");
  
  int result;
  if(emityResult && !fullResult){
    result = RegionMapInformation.RegionState.EMITY_OBSTACLE;
    println("Result =  Emity Obstacle Region\n");
  }else if (!emityResult && fullResult){
    result = RegionMapInformation.RegionState.FULL_OBSTACLE;
    println("Result =  Full Obstacle Region\n");
  }else{
    result= RegionMapInformation.RegionState.MIXED_OBSTACLE;
    println("Result =  Mixed Obstacle Region\n");
  }
  
  return result;
}