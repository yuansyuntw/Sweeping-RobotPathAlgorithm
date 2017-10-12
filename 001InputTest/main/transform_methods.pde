
//------------------------------------------------------------------------------------------
int coordinateToImageIndex(PImage _image, int _pointX, int _pointY){
  //print("point = (" + _pointX + "," + _pointY + ") ");
  return ( _image.width*(_pointY + _image.height/2 ) + (_pointX + _image.width/2 ));
}//end coordinateToImageIndex

// Draw a point 
//int index = 1024;
//pointX = (index%IMAGE_WIDTH) - IMAGE_WIDTH/2;
//pointY = (index-CENTER_INDEX)/IMAGE_WIDTH;