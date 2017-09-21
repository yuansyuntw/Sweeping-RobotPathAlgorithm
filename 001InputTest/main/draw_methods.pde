
void drawCrossLine(PImage _image, int _pointX, int _pointY, color _color){
  for(int i=0; i < _image.width; i++){
    //Vertical Line
    _image.pixels[(_image.width/2 + _pointX) + i*_image.width] = _color;
    //Horizontal Line
    _image.pixels[_image.width*(_image.height/2 - 1 + _pointY)+i] = _color;
  }
  _image.updatePixels();
  //image(_image,0 ,0);

}//end draw Point




void drawLine(int _pointX1,int _pointY1, int _pointX2, int _pointY2){
  line(_pointX1+(IMAGE_WIDTH/2), _pointY1+(IMAGE_HEIGHT/2), _pointX2+(IMAGE_WIDTH/2), _pointY2+(IMAGE_HEIGHT/2));
}




void drawRegion(PImage _image, int _point1X, int _point1Y, int _point2X, int _point2Y, color _color){
  int _width = _point2X - _point1X;
  int _height = _point2Y - _point1Y;
  
  int selectPointX = _point1X;
  int selectPointY = _point1Y;
  
  int indexX;
  if(_width==0){
    indexX = 1;
  }else{
    indexX = _width/abs(_width);
  }
  
  int indexY;
  if(_height==0){
    indexY = 1;
  }else{
    indexY = _height/abs(_height);
  }
  
  if(_height==0){
    
    for(int i=0; i<(abs(_width)); i++){
      //print("Point " + selectPointX + " " + selectPointY + ", ");
      _image.pixels[coordinateToImageIndex(_image, selectPointX, selectPointY)] = _color;
      selectPointX += indexX;
    }//end for
    
  }else{
    
    for(int j=0; j<(abs(_height)); j++){
      if(_width==0){
        
        _image.pixels[coordinateToImageIndex(_image, selectPointX, selectPointY)] = _color;
        
      }else{
        
        for(int i=0; i<(abs(_width)); i++){
          //print("Point " + selectPointX + " " + selectPointY + ", ");
          _image.pixels[coordinateToImageIndex(_image, selectPointX, selectPointY)] = _color;
          selectPointX += indexX;
        }//end for
        
      }//end if
      
      selectPointX = _point1X;
      selectPointY += indexY;
    }//end for
    
  }//end if
  
  _image.updatePixels();
  //image(_image, 0, 0);
}//end drawRegion



void drawCuttingRegionPoint(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int LUPointX = _cutSize*_cutPointX - _cutSize/2;
  int LUPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
   drawRegion(_image, LUPointX, LUPointY, RDPointX, RDPointY, _color);
}//end drawCuttingPoint



void drawCuttingRegionPointRight(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int RUPointX = _cutSize*_cutPointX + _cutSize/2;
  int RUPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
  drawRegion(_image, RUPointX, RUPointY, RDPointX, RDPointY, _color);
}//end drawCuttingRegionPointRight



void drawCuttingRegionPointDown(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int LDPointX = _cutSize*_cutPointX - _cutSize/2;
  int LDPointY = _cutSize*_cutPointY + _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
  drawRegion(_image, LDPointX, LDPointY, RDPointX, RDPointY, _color);
}//end drawCuttingRegionPointDown



void drawCuttingRegionPointCenterVertical(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int LDPointX = _cutSize*_cutPointX;
  int LDPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
  drawRegion(_image, LDPointX, LDPointY, RDPointX, RDPointY, _color);
}//end drawCuttingRegionPointCenterVertical



void drawCuttingRegionPointCenterHorizontal(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int LDPointX = _cutSize*_cutPointX - _cutSize/2;
  int LDPointY = _cutSize*_cutPointY;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY;
  
  drawRegion(_image, LDPointX, LDPointY, RDPointX, RDPointY, _color);
}//end drawCuttingRegionPointCenterHorizontal



void cutGridShow(PImage _image, int _cutSize, color _color){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  //println("Width Index = " + startIndexWidth + " ~ " + endIndexWidth);
  //println("Height Index = " + startIndexHeight + " ~ " + endIndexHeight);
  
  int LUPointX ;
  int LUPointY ;
  int RDPointX ;
  int RDPointY;
  
  for(int j=startIndexHeight; j<=endIndexHeight; j++){
    LUPointX = _cutSize*0 - _cutSize/2;
    LUPointY = _cutSize*j - _cutSize/2;
    drawCrossLine(_image, LUPointX, LUPointY, _color);

    // Ｔhe most end.
    if(j==endIndexHeight){
      RDPointX = LUPointX + _cutSize;
      RDPointY = LUPointY + _cutSize; 
      drawCrossLine(_image, RDPointX, RDPointY, _color);
    }
  }
  for(int i=startIndexWidth; i<=endIndexWidth; i++){
    LUPointX = _cutSize*i - _cutSize/2;
    LUPointY = _cutSize*0 - _cutSize/2;
    drawCrossLine(_image, LUPointX, LUPointY, _color);

    // The most end.
    if(i==endIndexHeight){
      RDPointX = LUPointX + _cutSize;
      RDPointY = LUPointY + _cutSize; 
      drawCrossLine(_image, RDPointX, RDPointY, _color);
    }
  }
}//end cutGridShow



void drawQuadtreeCuttingArea(PImage _image, RegionMapInformation _region, color _emityColor, color _mixColor, color _fullColor){

  color _decisionColor;

  if(_region.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
    _decisionColor = _emityColor;
  }else if(_region.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE){
    _decisionColor = _fullColor;
  }else if(_region.getRegionState() == RegionMapInformation.RegionState.MIXED_OBSTACLE){
    _decisionColor = _mixColor;
  }else{
    _decisionColor = color(255,0,0);
  }
  
  /*
  print("drawCuttingRegionPoint LUPoint = (" + _region.getLUPointX() + ", " + _region.getLUPointY() + ") RDPoint = (" + _region.getRDPointX() + ", " + _region.getRDPointY() + ")\n");
  drawCuttingRegionPoint(_image, _cutSize, _region.getLUPointX(), _region.getLUPointY(), _decisionColor);
  drawCuttingRegionPoint(_image, _cutSize, _region.getRDPointX(), _region.getRDPointY(), _decisionColor);
  */
  
  int _width = _region.getRDPointX() - _region.getLUPointX();
  int _height = _region.getRDPointY() - _region.getLUPointY();

  int selectPointX = _region.getLUPointX();
  int selectPointY = _region.getLUPointY();
  
  if(_width == 0 || _height == 0){
    
    //Leaf Node
    drawCuttingRegionPoint(_image, CUT_SIZE, selectPointX, selectPointY, _decisionColor);
    
  }else{
    
    int indexX = _width/abs(_width);
    int indexY = _height/abs(_height);

    for(int j=0; j < abs(_width); j++){
      for(int i=0; i < abs(_height); i++){
        drawCuttingRegionPoint(_image, CUT_SIZE, selectPointX, selectPointY, _decisionColor);
        selectPointX += indexX;
      }
      selectPointX = _region.getLUPointX();
      selectPointY += indexY;
    }//end for
    
  }//end if
}//end drawIctreeCuttingArea



void drawQuadtreeCuttingCrossLine(PImage _image, RegionMapInformation _region, color _color){
  
  if(_region!=null){
    if(_region.getRegionState() == RegionMapInformation.RegionState.MIXED_OBSTACLE){
      
      if(_region.getLURegion()!=null)  drawQuadtreeCuttingCrossLine(_image, _region.getLURegion(), _color);
      if(_region.getRURegion()!=null)  drawQuadtreeCuttingCrossLine(_image, _region.getRURegion(), _color);
      if(_region.getLDRegion()!=null)  drawQuadtreeCuttingCrossLine(_image, _region.getLDRegion(), _color);
      if(_region.getRDRegion()!=null)  drawQuadtreeCuttingCrossLine(_image, _region.getRDRegion(), _color);
      
    }else{
      
      int _width = _region.getRDPointX() - _region.getLUPointX();
      int _height = _region.getRDPointY() - _region.getLUPointY();

      int selectPointX = _region.getLUPointX();
      int selectPointY = _region.getLUPointY();
      
      if(_width == 0 || _height == 0){
        drawCuttingRegionPointCenterHorizontal(_image, CUT_SIZE, selectPointX, selectPointY, _color);
        drawCuttingRegionPointCenterVertical(_image, CUT_SIZE, selectPointX, selectPointY, _color);
        return ;
      }else{
        int indexX = _width/abs(_width);
        int indexY = _height/abs(_height);
        
        //Horizontal Line
        selectPointX = _region.getLUPointX();
        selectPointY = _region.getLUPointY() + _height/2;
        
        if(abs(_height) % 2 == 1){
          
          //Odd
          for(int i=0; i<abs(_width); i++){
            drawCuttingRegionPointCenterHorizontal(_image, CUT_SIZE, selectPointX, selectPointY, _color);
            selectPointX += indexX;
          }//end for
          
        }else{
          
          //Even
          for(int i=0; i<abs(_width); i++){
            drawCuttingRegionPointDown(_image, CUT_SIZE, selectPointX, selectPointY-1, _color);
            selectPointX += indexX;
          }//end for
          
        }//end if
        
        //Vertical Line
        selectPointX = _region.getLUPointX() + _width/2;
        selectPointY = _region.getLUPointY();
        
        if(abs(_width) % 2 == 1){
          
          //Odd
          for(int j=0; j<abs(_height); j++){
            drawCuttingRegionPointCenterVertical(_image, CUT_SIZE, selectPointX, selectPointY, _color);
            selectPointY += indexY;
          }//end for
          
        }else{
          
          //Even
          for(int j=0; j<abs(_height); j++){
            drawCuttingRegionPointRight(_image, CUT_SIZE, selectPointX-1, selectPointY, _color);
            selectPointY += indexY;
          }//end for
        
        }//end if
      }//end if
    }//end if
  }//edn if
  
}//end frawQtreeCuttinCrossLine