
//------------------------------------------------------------------------------------------
float rectangleJudgment(PImage _image, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY, color _color){
  int obstacleNumber = 0;
  int _width = _RDPointX - _LUPointX;
  int _height = _RDPointY - _LUPointY;
  
  int indexX = _width/abs(_width);
  int indexY = _height/abs(_height);
  
  // Check rectangle color
  int selectPointX = _LUPointX;
  int selectPointY = _LUPointY;
  for(int j=0 ; j < abs(_height) ; j++){
    for(int i=0 ; i < abs(_width) ; i++){
      if(_image.pixels[coordinateToImageIndex(_image,selectPointX,selectPointY)] != _color){
        //print("Image[" + selectPointX + "," + selectPointY + "]=" +_image.pixels[coordinateToImageIndex(_image,selectPointX,selectPointX)] + " _color = " + _color + " ");
        obstacleNumber ++;
      }
      selectPointX += indexX;
    }
    selectPointX = _LUPointX;
    selectPointY += indexY;
  }//end for
  
  return ( float(obstacleNumber) / (abs(_height)*abs(_width)) );
}//end rectangleJudgment

//------------------------------------------------------------------------------------------
float cutRegionPointJudgment(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int LRPointX = _cutSize*_cutPointX - _cutSize/2;
  int LRPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
  //drawCrossLine(_image, LRPointX, LRPointY, color(255,0,0));
  //drawCrossLine(_image, RDPointX, RDPointY, color(255,0,0));
  
  return rectangleJudgment(_image, LRPointX, LRPointY, RDPointX, RDPointY, _color);
  
}//end cutRegionJudgment

//------------------------------------------------------------------------------------------
float[] getImageGridArray(PImage _image, int _cutSize,color _color){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  //println("Width Index = " + startIndexWidth + " ~ " + endIndexWidth);
  //println("Height Index = " + startIndexHeight + " ~ " + endIndexHeight);
  
  int gridWidth = endIndexWidth - startIndexWidth + 1;
  int gridHeight = endIndexHeight - startIndexHeight + 1;
  float[] gridArray = new float[gridWidth + (gridWidth * gridHeight)];
  
  int gridIndex = 0;
  for(int j=startIndexHeight; j<=endIndexHeight; j++){
    for(int i=startIndexWidth; i<=endIndexWidth; i++){
      gridArray[gridIndex] = cutRegionPointJudgment(_image, _cutSize, i, j, _color);
      
      //Draw Region Color
      if(gridArray[gridIndex] == 0.0){
        //drawCuttingRegionPoint(_image, _cutSize, i, j, color(255,255,255));
      }
      
      gridIndex += 1;
    }
  }
  
  return gridArray;
}//end getImageGridArray

//------------------------------------------------------------------------------------------
int getImageGridWidth(PImage _image, int _cutSize){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  
  return (endIndexWidth - startIndexWidth + 1);
}

//------------------------------------------------------------------------------------------
int getImageGridHeight(PImage _image, int _cutSize){
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  return (endIndexHeight - startIndexHeight + 1);
}

//------------------------------------------------------------------------------------------
void findVertex(PImage _image, int _cutSize, boolean[] _cutMap){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  int gridWidth = endIndexWidth - startIndexWidth;
  int gridHeight = endIndexHeight - startIndexHeight;
  
  int[] vertexArray = new int[10240];
  int index = 0 ;
  
  int mapIndex=0;
  for(int h=0; h< gridHeight; h++){ 
    for(int w=0;w < gridWidth-1; w++){
        if((_cutMap[mapIndex] && !_cutMap[mapIndex+1]) || (!_cutMap[mapIndex] && _cutMap[mapIndex+1])){
          vertexArray[index] = mapIndex;
          index++;
        }
        mapIndex++;
    }
  }//end for
  
  
  print("Vertex = ");
  for(int i=0; i<index; i++){
    if(vertexArray[i]!=-1){
      int cuttingX = ((vertexArray[i]%gridWidth) - (gridWidth/2));
      int cuttingY = ((vertexArray[i]/gridHeight) - (gridHeight/2));
      
      drawCuttingRegionPoint(_image, _cutSize, cuttingX, cuttingY, color(0,255,0));
      
      if(!_cutMap[vertexArray[i]+gridWidth]){
        print(vertexArray[i] + " " + cuttingX + " " + cuttingY + ", ");
        drawCuttingRegionPoint(_image, _cutSize, cuttingX, cuttingY, color(0,0,255));
      }
    }
  }//end for
  
}//end findVertex

//------------------------------------------------------------------------------------------
int cutRectangleJudgment(float[] _mapArray, int _gridWidth, int _gridHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
  boolean DEBUG = false;
  
  //Check cut rectangle 
  int rectangleWidth = _RDPointX - _LUPointX;
  int rectangleHeight = _RDPointY - _LUPointY;
  int selectPointX = (_LUPointX + (_gridWidth/2));
  int selectPointY = (_LUPointY + (_gridHeight/2));

  
  if(DEBUG) { println("cutRectangleJudgment _LUPoint (" + _LUPointX + ", " + _LUPointY + ") _RDPoint (" + _RDPointX + ", " + _RDPointY + ")"); }
  //println("rectangleWidth = " + (abs(rectangleWidth)+1) + ", rectangleHeight = " + (abs(rectangleHeight)+1));
  
  int indexX;
  if(rectangleWidth == 0){
    indexX = 1;
  }else{
    indexX = rectangleWidth/abs(rectangleWidth);
  }//end if
  
  int indexY;
  if(rectangleHeight == 0){
    indexY = 1;
  }else{
    indexY = rectangleHeight/abs(rectangleHeight);
  }//end if
  
  //Average obstacle
  float averageObstacleRatio = 0.0f;
  for(int j=0; j<=(abs(rectangleHeight)); j++){
    for(int i=0; i<=(abs(rectangleWidth)); i++){
      //println("selectPoint ("+selectPointX+","+selectPointY+") index = " + (selectPointX  + (selectPointY * _gridWidth)));
      averageObstacleRatio += _mapArray[selectPointX  + (selectPointY * _gridWidth)];
      selectPointX += indexX;
    }//end for
    selectPointX = (_LUPointX + (_gridWidth/2)) ;
    selectPointY += indexY;
  }//end for
  
  int result;
  averageObstacleRatio = (averageObstacleRatio / ((abs(rectangleHeight)+1) * (abs(rectangleWidth)+1)));
  if( averageObstacleRatio <= EMITY_RATIO ){
    result = RegionMapInformation.RegionState.EMITY_OBSTACLE;
  }else if ( (averageObstacleRatio/(indexX * indexY)) >= FULL_RATIO ){
    result = RegionMapInformation.RegionState.FULL_OBSTACLE;
  }else{
    //print("Obstacle Ratio = " + averageObstacleRatio + " ");
    result = RegionMapInformation.RegionState.MIXED_OBSTACLE;
  }
  
  return result;
}//end cutRectangleJudgment