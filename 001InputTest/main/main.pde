PImage inputImage;
PImage outputImage;

//String IMAGE_PATH = "data/Test_Image.tif";
String IMAGE_PATH = "data/octree1x1.tif";
//String IMAGE_PATH = "data/octree1x1test.tif";
int IMAGE_WIDTH = 1024, IMAGE_HEIGHT = 1024;

// Robot Size is 30 cm. 
int CUT_SIZE = 6; 

int CENTER_INDEX = IMAGE_WIDTH * ((IMAGE_HEIGHT/2) - 1) + IMAGE_WIDTH/2;
int PATH_COLOR = color(254,254,254);

float EMITY_RATIO = 0.1;
float FULL_RATIO = 0.9;



void setup(){
  size(1024, 1024);
  background(0);
  
  // Open image file.
  inputImage = loadImage(IMAGE_PATH);
  println(inputImage + "\n");
  
  // Protect input image.
  outputImage = inputImage;
  
  // Cut grid image.
  float[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  //cutGridShow(outputImage, CUT_SIZE, color(25));
  
  
  //findVertex(inputImage, CUT_SIZE, gridArray);
  int cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  int cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  println("cutWidth = " + cutWidth + " cutHeight = " + cutHeight + "\n");
  RegionMapInformation _rootQuadtree = quadtreeCutting(outputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth/2, cutHeight/2, cutWidth, cutHeight);
  print("\nQuadtree Cutting End\n");
  
  // Draw region crosss line
  color crossColor = color(200, 200 ,30);
  //drawQuadtreeCuttingCrossLine(outputImage, _rootQuadtree, crossColor);
  
  //print("_rootQuadtree LUPOintX = " + _rootQuadtree.getLUPointX() + " LUPointY = " + _rootQuadtree.getLUPointY());
  //drawCuttingRegionPoint(outputImage, CUT_SIZE, 0, 0, color(255,0,0));
  
  color emityColor = color(10, 100, 30);
  color mixColor = color(200, 150, 20);
  color fullColor = color(128, 128, 128);
  drawQuadtreeState(outputImage, _rootQuadtree, emityColor, mixColor, fullColor);
  
  // Draw a origin points.
  //drawCrossLine(outputImage, 0, 0, color(0,0,255));
  
  
  
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
  
  //outputImage.save(dataPath("quadtree_map_012.png"));
}//end setup



void draw(){
  image(outputImage, 0, 0);
}



RegionMapInformation quadtreeCutting(PImage _image, float[] _mapArray, int _cutSize, int _originalLUPointX, int _originalLUPointY,
                                  int _originalRDPointX, int _originalRDPointY, int _gridWidth, int _gridHeight){
                                    
  RegionMapInformation resultMap;
  boolean DEBUG = false;
  int _regionWidth = abs(_originalRDPointX - _originalLUPointX) + 1 ;
  int _regionHeight = abs(_originalRDPointY - _originalLUPointY) + 1;
  
  //Cutting size is small.
  if((_regionWidth/2 < _cutSize) || (_regionHeight/2 < _cutSize)){
    //println("regionWidth = " + _regionWidth + " _regionHeight = " + _regionHeight);
    
    //return null;
    
    //Move center point to left up.
    int selectPointX = (_originalLUPointX + (_gridWidth/2));
    int selectPointY = (_originalLUPointY + (_gridHeight/2));
    //println("ration = " + _mapArray[selectPointX  + (selectPointY * _gridWidth)]);
    
    if( _mapArray[selectPointX  + (selectPointY * _gridWidth)] <= EMITY_RATIO ){
      //println("Emity region");
          resultMap = new RegionMapInformation (RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalRDPointX, _originalRDPointY);
    }else if( _mapArray[selectPointX  + (selectPointY * _gridWidth)] >= FULL_RATIO ){
      //println("Full region");
          resultMap = new RegionMapInformation (RegionMapInformation.RegionState.FULL_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalRDPointX, _originalRDPointY);
    }else{
      println("Mixed region");
          resultMap = new RegionMapInformation (RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalRDPointX, _originalRDPointY);
    }//end if
    return resultMap;
  }//end if
  
  // Draw center cut line
  /*int centerPointX = _originalPointX + _regionWidth/2;
  int centerPointY = _originalPointY + _regionHeight/2;
  drawCrossLine(_image, centerPointX, centerPointY, color (50));*/
  
  //println("_originalPoint (" + _originalLUPointX + ", " + _originalLUPointY + ") _regionWidth = " + _regionWidth + " _regionHeight = " + _regionHeight);
  
  //Remove odd even conversion
  int halfWidth = _regionWidth/2;
  int halfHeight = _regionHeight/2;
  
  // Explore Left Up Region
  int LURegion_LUPointX = _originalLUPointX;
  int LURegion_LUPointY = _originalLUPointY;
  int LURegion_RDPointX = _originalLUPointX + halfWidth - 1;
  int LURegion_RDPointY = _originalLUPointY + halfHeight - 1;
  RegionMapInformation _LURegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight,  LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  // Explore Right Up Region
  int RURegion_LUPointX = _originalLUPointX + halfWidth;
  int RURegion_LUPointY = _originalLUPointY;
  int RURegion_RDPointX = _originalLUPointX + _regionWidth - 1;
  int RURegion_RDPointY = _originalLUPointY + halfHeight - 1;
  RegionMapInformation _RURegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  // Explore Left Down Region
  int LDRegion_LUPointX = _originalLUPointX;
  int LDRegion_LUPointY = _originalLUPointY + halfHeight;
  int LDRegion_RDPointX = _originalLUPointX + halfWidth - 1;
  int LDRegion_RDPointY = _originalLUPointY + _regionHeight - 1;
  RegionMapInformation _LDRegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  // Explore Right Down Region
  int RDRegion_LUPointX = _originalLUPointX + halfWidth;
  int RDRegion_LUPointY = _originalLUPointY + halfHeight;
  int RDRegion_RDPointX = _originalLUPointX + _regionWidth - 1;
  int RDRegion_RDPointY = _originalLUPointY + _regionHeight - 1;
  RegionMapInformation _RDRegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);

  // Determine whether the sub-region is empty-obstacle
  if(_LURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
        
     resultMap =  new RegionMapInformation (RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    
  }else if (
      // Determine whether the sub-region is full-obstacle
      _LURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE){
    
      resultMap = new RegionMapInformation (RegionMapInformation.RegionState.FULL_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    
  }else{
    resultMap = new RegionMapInformation (RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    resultMap.setLURegion(quadtreeCutting(_image, _mapArray, _cutSize, LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setRURegion(quadtreeCutting(_image, _mapArray, _cutSize, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setLDRegion(quadtreeCutting(_image, _mapArray, _cutSize, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setRDRegion(quadtreeCutting(_image, _mapArray, _cutSize, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY, _gridWidth, _gridHeight));
  }//end if

  return resultMap;
}//end quadtreeCutting



RegionMapInformation getRegionInformation(float[] _mapArray, int _gridWidth, int _gridHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
 
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
    case RegionMapInformation.RegionState.MIXED_OBSTACLE:                  
        // Return mixed obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                        _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);
    default:
        return null;
  }//end switch
}//end checkRegion



int cutRectangleJudgment(float[] _mapArray, int _gridWidth, int _gridHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
  boolean emityResult = false;
  boolean fullResult = false;
  boolean DEBUG = false;
  
  //Check cut rectangle 
  int rectangleWidth = _RDPointX - _LUPointX;
  int rectangleHeight = _RDPointY - _LUPointY;
  int selectPointX = (_LUPointX + (_gridWidth/2));
  int selectPointY = (_LUPointY + (_gridHeight/2));

  
  if(DEBUG) { println("cutRectangleJudgment _LUPoint (" + _LUPointX + ", " + _LUPointY + ") _RDPoint (" + _RDPointX + ", " + _RDPointY + ")"); }
  //println("rectangleWidth = " + (abs(rectangleWidth)+1) + ", rectangleHeight = " + (abs(rectangleHeight)+1));
  
  if(rectangleWidth == 0  || rectangleHeight == 0){
    
    if( _mapArray[selectPointX  + (selectPointY * _gridWidth)] <= EMITY_RATIO ){
          return RegionMapInformation.RegionState.EMITY_OBSTACLE;
    }else if( _mapArray[selectPointX  + (selectPointY * _gridWidth)] >= FULL_RATIO ){
          return RegionMapInformation.RegionState.FULL_OBSTACLE;
    }else{
          return RegionMapInformation.RegionState.MIXED_OBSTACLE;
    }//end if
    
  }else{
    int indexX = rectangleWidth/abs(rectangleWidth);
    int indexY = rectangleHeight/abs(rectangleHeight);
    
    for(int j=0; j<=(abs(rectangleHeight)); j++){
      for(int i=0; i<=(abs(rectangleWidth)); i++){
  
        //println("selectPoint ("+selectPointX+","+selectPointY+") index = " + (selectPointX  + (selectPointY * _gridWidth)));
  
        if( _mapArray[selectPointX  + (selectPointY * _gridWidth)] <= EMITY_RATIO ){
          emityResult = true;
        }else if( _mapArray[selectPointX  + (selectPointY * _gridWidth)] >= FULL_RATIO ){
          fullResult = true;
        }
        selectPointX += indexX;
  
        if(DEBUG){
          if(_mapArray[selectPointX  + (selectPointY * _gridWidth)] <= EMITY_RATIO ){
            print(" ");
          }else{
            print("X");
          }//end if
        }//end if
      }//end if
      if(DEBUG){print("\n");}
      
      selectPointX = (_LUPointX + (_gridWidth/2)) ;
      selectPointY += indexY;
    }//end for
    if(DEBUG){print("\n");}
  }//end if
  
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



void judgmentPointQuadtree(){
  
}//end judgmentPointQuad



void drawQuadtreeState(PImage _image, RegionMapInformation _quadtree, color _emityColor, color _mixColor, color _fullColor){
  
  if(_quadtree != null){
    
    if( (_quadtree.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE) || 
        (_quadtree.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE) ){
          
      drawQuadtreeCuttingArea(_image, _quadtree, _emityColor, _mixColor, _fullColor); 
          
    }else if( (_quadtree.getRegionState() == RegionMapInformation.RegionState.MIXED_OBSTACLE) && _quadtree.isLeaf() ){
      
      drawQuadtreeCuttingArea(_image, _quadtree, _emityColor, _mixColor, _fullColor); 
        
    }else if( (_quadtree.getRegionState() == RegionMapInformation.RegionState.MIXED_OBSTACLE) && !_quadtree.isLeaf() ){
      // Draw child region color
      drawQuadtreeState(_image, _quadtree.getLURegion(), _emityColor, _mixColor, _fullColor);
      drawQuadtreeState(_image, _quadtree.getRURegion(), _emityColor, _mixColor, _fullColor);
      drawQuadtreeState(_image, _quadtree.getLDRegion(), _emityColor, _mixColor, _fullColor);
      drawQuadtreeState(_image, _quadtree.getRDRegion(), _emityColor, _mixColor, _fullColor); 
    }//end if
  }//end if
}//end drawQUadtreeState