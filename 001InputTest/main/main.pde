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
  

  
  
  //findVertex(inputImage, CUT_SIZE, gridArray);
  int cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  int cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  println("cutWidth = " + cutWidth + " cutHeight = " + cutHeight + "\n");
  octreeCutting(outputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth, cutHeight, cutWidth, cutHeight);
  print("\n Octree Cutting End\n");
  
  
  cutGridShow(outputImage, CUT_SIZE, color(25));
  
  // Draw a origin points.
  drawCrossLine(outputImage, 0, 0, color(0,0,255));
  
  
  
  // drawLine(0,0, pointX, pointY);
  //println(ZPath(0, 0, pointX, pointY, 6));
  
  // Draw start point text
  textSize(30);
  fill(0, 255, 0);
  //text("StartPoint", 0 +(IMAGE_WIDTH/2) , 0 + (IMAGE_HEIGHT/2));
  
  //Draw end point text
  textSize(30);
  fill(0, 0, 255);
  //text("EndPoint", pointX + (IMAGE_WIDTH/2), pointY + (IMAGE_HEIGHT/2));
  
  //outputImage.save(dataPath("octree_map_004.png"));
}//end setup



void draw(){
  image(outputImage, 0, 0);
}



RegionMapInformation octreeCutting(PImage _image, boolean[] _mapArray, int _cutSize, int _originalPointX, int _originalPointY, int _regionWidth, int _regionHeight, int _gridWidth, int _gridHeight){
  RegionMapInformation resultMap;
  boolean DEBUG = false;
  
  //Cutting size is small.
  if(_regionWidth/2 <= _cutSize || _regionHeight/2 <= _cutSize){
    return null;
  }
  
  // Draw center cut line
  /*int centerPointX = _originalPointX + _regionWidth/2;
  int centerPointY = _originalPointY + _regionHeight/2;
  drawCrossLine(_image, centerPointX, centerPointY, color (50));*/
  
  println("_originalPoint (" + _originalPointX + ", " + _originalPointY + ") _regionWidth = " + _regionWidth + " _regionHeight = " + _regionHeight);
  
  // Explore Left Up Region
  int transformWidth = (_regionWidth/2)*2;
  int transformHeight = (_regionHeight/2)*2;
  int LURegion_LUPointX = _originalPointX;
  int LURegion_LUPointY = _originalPointY;
  int LURegion_RDPointX = _originalPointX + transformWidth/2 - 1;
  int LURegion_RDPointY = _originalPointY + transformHeight/2 - 1;
  RegionMapInformation _LURegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight,  LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  // Explore Right Up Region
  int RURegion_LUPointX = _originalPointX + transformWidth/2;
  int RURegion_LUPointY = _originalPointY;
  int RURegion_RDPointX = _originalPointX + transformWidth;
  int RURegion_RDPointY = _originalPointY + transformHeight/2 - 1;
  RegionMapInformation _RURegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  // Explore Left Down Region
  int LDRegion_LUPointX = _originalPointX;
  int LDRegion_LUPointY = _originalPointY + transformHeight/2;
  int LDRegion_RDPointX = _originalPointX + transformWidth/2;
  int LDRegion_RDPointY = _originalPointY + transformHeight - 1;
  RegionMapInformation _LDRegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  // Explore Right Down Region
  int RDRegion_LUPointX = _originalPointX + transformWidth/2;
  int RDRegion_LUPointY = _originalPointY + transformHeight/2;
  int RDRegion_RDPointX = _originalPointX + transformWidth;
  int RDRegion_RDPointY = _originalPointY + transformHeight;
  RegionMapInformation _RDRegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);

  // Draw child region color
  color emityColor = color(10, 100, 30);
  color mixColor = color(255, 255, 0);
  color fullColor = color(128, 128, 128);
  drawOctreeCuttingArea(_image, _LURegion, emityColor, mixColor, fullColor);
  drawOctreeCuttingArea(_image, _RURegion, emityColor, mixColor, fullColor);
  drawOctreeCuttingArea(_image, _LDRegion, emityColor, mixColor, fullColor);
  drawOctreeCuttingArea(_image, _RDRegion, emityColor, mixColor, fullColor);

  // Determine whether the sub-region is empty-obstacle
  if(_LURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
        
     resultMap =  new RegionMapInformation (RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                _originalPointX + _regionWidth, _originalPointY + _regionHeight);
    
  }else if (
      // Determine whether the sub-region is full-obstacle
      _LURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE){
    
      resultMap = new RegionMapInformation (RegionMapInformation.RegionState.FULL_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                _originalPointX + _regionWidth, _originalPointY + _regionHeight);
    
  }else{
    resultMap = new RegionMapInformation (RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                _originalPointX + _regionWidth, _originalPointY + _regionHeight);
  }//end if

  resultMap.setLURegion(octreeCutting(_image, _mapArray, _cutSize, LURegion_LUPointX, LURegion_LUPointY, _regionWidth/2, _regionHeight/2, _gridWidth, _gridHeight));
  resultMap.setRURegion(octreeCutting(_image, _mapArray, _cutSize, RURegion_LUPointX, RURegion_LUPointY, _regionWidth/2, _regionHeight/2, _gridWidth, _gridHeight));
  resultMap.setLDRegion(octreeCutting(_image, _mapArray, _cutSize, LDRegion_LUPointX, LDRegion_LUPointY, _regionWidth/2, _regionHeight/2, _gridWidth, _gridHeight));
  resultMap.setRDRegion(octreeCutting(_image, _mapArray, _cutSize, RDRegion_LUPointX, RDRegion_LUPointY, _regionWidth/2, _regionHeight/2, _gridWidth, _gridHeight));
  
  return resultMap;
}//end octreeCutting



RegionMapInformation getRegionInformation(boolean[] _mapArray, int _gridWidth, int _gridHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
 
  switch(cutRectangleJudgment(_mapArray, _gridWidth, _gridHeight,_LUPointX, _LUPointY, _RDPointX, _RDPointY)){
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



int cutRectangleJudgment(boolean[] _mapArray, int _gridWidth, int _gridHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
  boolean emityResult = true;
  boolean fullResult = true;
  boolean DEBUG = false;
  
  //Check cut rectangle 
  int rectangleWidth = _RDPointX - _LUPointX;
  int rectangleHeight = _RDPointY - _LUPointY;
  int selectPointX = (_LUPointX + (_gridWidth/2));
  int selectPointY = (_LUPointY + (_gridHeight/2));

  
  println("cutRectangleJudgment _LUPoint (" + _LUPointX + ", " + _LUPointY + ") _RDPoint (" + _RDPointX + ", " + _RDPointY + ")");
  //println("rectangleWidth = " + (abs(rectangleWidth)+1) + ", rectangleHeight = " + (abs(rectangleHeight)+1));
  

  if(DEBUG){
    
    for(int i=0; i<abs(rectangleWidth) + 1; i++){
      print(i%10);
    }
    print("\n");
  }
  
  int indexX = rectangleWidth/abs(rectangleWidth);
  int indexY = rectangleHeight/abs(rectangleHeight);
  
  for(int j=0; j<=abs(rectangleHeight) + 1; j++){
    for(int i=0; i<abs(rectangleWidth) + 1; i++){

      //println("selectPoint ("+selectPointX+","+selectPointY+") index = " + (selectPointX  + (selectPointY * _gridWidth)));

      if( !_mapArray[selectPointX  + (selectPointY * _gridWidth)] ){
        emityResult = false;
      }else if( _mapArray[selectPointX  + (selectPointY * _gridWidth) - 1] ){
        fullResult = false;
      }
      selectPointX += indexX;

      if(DEBUG){
        if(_mapArray[selectPointX  + (selectPointY * _gridWidth)]){
          print(" ");
        }else{
          print("X");
        }
      }
    }
    if(DEBUG){print("\n");}
    
    selectPointX = (_LUPointX + (_gridWidth/2)) ;
    selectPointY += indexY;
  }//end for
  if(DEBUG){print("\n");}
  
  int result;
  if(emityResult && !fullResult){
    result = RegionMapInformation.RegionState.EMITY_OBSTACLE;
    //println("Result =  Emity Obstacle Region\n");
  }else if (!emityResult && fullResult){
    result = RegionMapInformation.RegionState.FULL_OBSTACLE;
    //println("Result =  Full Obstacle Region\n");
  }else{
    result = RegionMapInformation.RegionState.MIXED_OBSTACLE;
    //println("Result =  Mixed Obstacle Region\n");
  }
  
  return result;
}//end cutRectangleJudgment



void drawOctreeCuttingArea(PImage _image, RegionMapInformation _region, color _emityColor, color _mixColor, color _fullColor){

  color _decisionColor;

  if(_region.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
    _decisionColor = _emityColor;
  }else if(_region.getRegionState() == RegionMapInformation.RegionState.MIXED_OBSTACLE){
    _decisionColor = _mixColor;
    return;
  }else{
    _decisionColor = _fullColor;
  }
  
  /*
  print("drawCuttingRegionPoint LUPoint = (" + _region.getLUPointX() + ", " + _region.getLUPointY() + ") RDPoint = (" + _region.getRDPointX() + ", " + _region.getRDPointY() + ")\n");
  drawCuttingRegionPoint(_image, _cutSize, _region.getLUPointX(), _region.getLUPointY(), _decisionColor);
  drawCuttingRegionPoint(_image, _cutSize, _region.getRDPointX(), _region.getRDPointY(), _decisionColor);
  */

  
  int width = _region.getRDPointX() - _region.getLUPointX();
  int height = _region.getRDPointY() - _region.getLUPointY();

  int selectPointX = _region.getLUPointX();
  int selectPointY = _region.getLUPointY();

  int indexX = width/abs(width);
  int indexY = height/abs(height);

  for(int j=0; j < abs(height); j++){
    for(int i=0; i < abs(width); i++){
      drawCuttingRegionPoint(_image, CUT_SIZE, selectPointX, selectPointY, _decisionColor);
      selectPointX += indexX;
    }
    selectPointX = _region.getLUPointX();
    selectPointY += indexY;
  }//end for
  

}//end drawIctreeCuttingArea