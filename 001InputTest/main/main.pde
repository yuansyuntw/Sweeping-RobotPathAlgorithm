PImage inputImage;
PImage outputImage;

String IMAGE_PATH = "data/Test_Image.tif";
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
  println(inputImage);
  
  // Protect input image.
  outputImage = inputImage;
  
  // Draw a origin points.
  drawCrossLine(outputImage, 0, 0, color(0,0,255));
  
  // Cut grid image.
  //boolean[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  cutGridShow(outputImage, CUT_SIZE,color(240,240,240,240));
  
  findVertex(inputImage, CUT_SIZE, gridArray);
  
  
  // drawLine(0,0, pointX, pointY);
  //println(ZPath(0, 0, pointX, pointY, 6));
  
  // Draw start point text
  textSize(30);
  fill(0,255,0);
  //text("StartPoint", 0 +(IMAGE_WIDTH/2) , 0 + (IMAGE_HEIGHT/2));
  
  //Draw end point text
  textSize(30);
  fill(0,0,255);
  //text("EndPoint", pointX + (IMAGE_WIDTH/2), pointY + (IMAGE_HEIGHT/2));
  
  outputImage.save(dataPath("area_cleaning2_with_grid.png"));
}//end setup



RegionMapInformation octreeCutting(PImage _image, int _cutSize, int _originalPointX, int _originalPointY, int _width, int _height, color _color){
  
  //Cutting size is small.
  if(_width/2 < _cutSize || _height/2 < _cutSize){
    return null;
  }
  
  
  int LURegion_LUPointX = _originalPointX;
  int LURegion_LUPointY = _originalPointY;
  int LURegion_RDPointX = _originalPointX + _width/2 - 1;
  int LURegion_RDPointY = _originalPointY + _height/2 - 1;
  RegionMapInformation _LURegion = getRegion(_image, LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  int RURegion_LUPointX = _originalPointX + _width/2;
  int RURegion_LUPointY = _originalPointY;
  int RURegion_RDPointX = _originalPointX + _width;
  int RURegion_RDPointY = _originalPointY + _height/2;
  RegionMapInformation _RURegion = getRegion(_image, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  int LDRegion_LUPointX = _originalPointX;
  int LDRegion_LUPointY = _originalPointY + _height/2;
  int LDRegion_RDPointX = _originalPointX + _width/2 - 1;
  int LDRegion_RDPointY = _originalPointY + _height;
  RegionMapInformation _LDRegion = getRegion(_image, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  int RDRegion_LUPointX = _origionalPointX + _width/2;
  int RDRegion_LUPointY = _originalPointY + _height/2;
  int RDRegion_RDPointX = _originalPointX + _width;
  int RDRegion_RDPointY = _originalPointY + _height;
  RegionMapInformation _RDRegion = getRegion(_image, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);
  
  
  
  
  
  RegionMapInformation = new RegionMapinformation ()
  
  return outputRegion
}

RegionMapInformation getRegion(PImage _image, int _LRPointX, int _LRPointY, int _RDPointX, int _RDPointY){
 
  if(rectangleJudgment(_image, _LRPointX, _LRPointY, _RDPointX, _RDPointY)){
    //Return emity region 
    return new RegionMapInformation(0, LURegionLRPointX, LURegionLRPointY, LURegionRDPointX, LURegionRDPointX, LURegionRDPointY);
  }else{
    //Return Mixed region
    return new RegionMapInformation(1, LURegionLRPointX, LURegionLRPointY, LURegionRDPointX, LURegionRDPointX, LURegionRDPointY);
  }
  
}//end checkRegion