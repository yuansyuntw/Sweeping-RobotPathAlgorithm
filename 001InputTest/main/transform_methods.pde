
int coordinateToImageIndex(PImage _image, int _pointX, int _pointY){
    return _image.width*(_image.height/2-1 + _pointY) + (_image.width/2 + _pointX);
}//end coordinateToImageIndex

// Draw a point 
  /*
  int index = 1024;
  pointX = (index%IMAGE_WIDTH) - IMAGE_WIDTH/2;
  pointY = (index-CENTER_INDEX)/IMAGE_WIDTH;
  */