
//------------------------------------------------------------------------------------------
String ZPath(int _startX, int _startY, int _endX, int _endY, int _density){
  int _width = _endX - _startX;
  int _height = _endY - _startY;
  int movePointX = _startX;
  int movePointY = _startY;
  boolean upDownFlag = true;
  String path = "";
  
  //Two points can't decidea a rectangle.
  if(_width == 0 || _height ==0){
    path += Integer.toString(_endX) + " " + Integer.toString(_endY) + " ";
    drawLine(_startX, _startY, _endX, _endY);
    return path;
  }
  
  int i=0;
  while(i<abs(_width)){
    path += Integer.toString(movePointX) + " " + Integer.toString(movePointY) + " ";
    
    //Vertical
    if(upDownFlag){
      drawLine(movePointX, movePointY, movePointX, movePointY + _height);
        movePointY += _height;
    }else{
      drawLine(movePointX, movePointY, movePointX, movePointY - _height);
      movePointY -= _height;
    }
    upDownFlag = !upDownFlag;
    
    path += Integer.toString(movePointX) + " " + Integer.toString(movePointY) + " ";
    
    //Horizontal
    drawLine(movePointX, movePointY, movePointX + (_width/abs(_width)) * _density, movePointY);
    movePointX += _width/abs(_width) * _density;
    i += _density;
  }
  
   if(movePointX!=_endX || movePointY!=_endY){
     drawLine(movePointX, movePointY, _endX, _endY);
     path += Integer.toString(_endX) + " " + Integer.toString(_endY) + " ";
   }
  return path;
}//end ZPath