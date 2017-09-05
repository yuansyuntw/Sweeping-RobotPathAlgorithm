
boolean rectangleJudgment(PImage _image, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY, color _color){
  boolean result = true;
  int _width = _RDPointX - _LUPointX;
  int _height = _RDPointY - _LUPointY;
  
  // Check rectangle color
  int selectPointX = _LUPointX;
  int selectPointY = _LUPointY;
  for(int j=0 ; j <abs(_height); j++){
    for(int i=0 ; i < abs(_width) ; i++){
      if(_image.pixels[coordinateToImageIndex(_image,selectPointX,selectPointY)]!=_color){
        //print("Image[" + selectPointX + "," + selectPointY + "]=" +_image.pixels[coordinateToImageIndex(_image,selectPointX,selectPointX)] + " _color = " + _color + " ");
        result = false;
        break;
      }
      selectPointX = _LUPointX;
      selectPointX += _width/abs(_width);
    }
    selectPointY += _height/abs(_height);
  }//end for
  
  return result;
}//end rectangleJudgment

boolean cutRectangleJudgment(boolean[] _mapArray, int _width, int _height, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY, color _color){
  boolean result = true;
  
  //Check cut rectangle 
  int selectPointX = _LUPointX;
  int selectPointY = _LUPointY;
  
  //for(int j=0; j < _width)
  
  
  return result;
  
  
}

boolean cutRegionPointJudgment(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int LRPointX = _cutSize*_cutPointX - _cutSize/2;
  int LRPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
  //drawCrossLine(_image, LRPointX, LRPointY, color(255,0,0));
  //drawCrossLine(_image, RDPointX, RDPointY, color(255,0,0));
  
  return rectangleJudgment(_image, LRPointX, LRPointY, RDPointX, RDPointY, _color);
  
}//end cutRegionJudgment

boolean[] getImageGridArray(PImage _image, int _cutSize,color _color){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  //println("Width Index = " + startIndexWidth + " ~ " + endIndexWidth);
  //println("Height Index = " + startIndexHeight + " ~ " + endIndexHeight);
  
  int gridWidth = endIndexWidth - startIndexWidth;
  int girdHeight = endIndexHeight - startIndexHeight;
  boolean[] gridArray = new boolean[gridWidth * girdHeight];
  
  int gridIndex = 0;
  for(int j=startIndexHeight; j<endIndexHeight; j++){
    for(int i=startIndexWidth; i<endIndexWidth; i++){
      gridArray[gridIndex] = cutRegionPointJudgment(_image, _cutSize, i, j, _color);
      
      //Draw Region Color
      if(gridArray[gridIndex]){
        drawCuttingRegionPoint(_image, _cutSize, i, j, color(255,0,0));
      }
      
      gridIndex += 1;
    }
  }
  return gridArray;
}//end getImageGridArray

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