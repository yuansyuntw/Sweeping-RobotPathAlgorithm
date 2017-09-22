
int coordinateToImageIndex(PImage _image, int _pointX, int _pointY){
    return (_image.width*((_image.height/2 + _pointY - 1) + (_image.width/2 + _pointX - 1)));
}//end coordinateToImageIndex

// Draw a point 
//int index = 1024;
//pointX = (index%IMAGE_WIDTH) - IMAGE_WIDTH/2;
//pointY = (index-CENTER_INDEX)/IMAGE_WIDTH;