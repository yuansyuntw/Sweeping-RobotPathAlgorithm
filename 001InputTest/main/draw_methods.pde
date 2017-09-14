
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




void drawRegion(PImage _image, int _pointX1, int _pointY1, int _pointX2, int _pointY2, color _color){
  int _width = _pointX2 - _pointX1;
  int _height = _pointY2 - _pointY1;
  
  int selectPointX = _pointX1;
  int selectPointY = _pointY1;
  
  //print("Region = " + _pointX1 + " " + _pointY1 + " " + _pointX2 + " " + _pointY2 + ", ");
  for(int j=0; j<abs(_height); j++){
    for(int i=0; i<abs(_width); i++){
      //print("Point " + selectPointX + " " + selectPointY + ", ");
      _image.pixels[coordinateToImageIndex(_image, selectPointX, selectPointY)] = _color;
      selectPointX += _width/abs(_width);
    }
    selectPointX = _pointX1;
    selectPointY += _height/abs(_height);
  }
  
  _image.updatePixels();
  //image(_image, 0, 0);
}//end drawRegion



void drawCuttingRegionPoint(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, color _color){
  int LRPointX = _cutSize*_cutPointX - _cutSize/2;
  int LRPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
   drawRegion(_image, LRPointX, LRPointY, RDPointX, RDPointY, _color);
}//end drawCuttingPoint



void cutGridShow(PImage _image, int _cutSize, color _color){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  println("Width Index = " + startIndexWidth + " ~ " + endIndexWidth);
  println("Height Index = " + startIndexHeight + " ~ " + endIndexHeight);
  
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