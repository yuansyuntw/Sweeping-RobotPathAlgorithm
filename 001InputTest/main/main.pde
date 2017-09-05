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
  boolean[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  //cutGridShow(outputImage, CUT_SIZE,color(240,240,240,240));
  
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



RegionMapInformation OctreeCutting(PImage _image, int _cutSize){
  
  
  
  return outputRegion
}