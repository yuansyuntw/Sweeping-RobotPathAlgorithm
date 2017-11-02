/*
    Purpose: Solve sweeping robot path planning.
    Coder: YuanSyun(yuansyuntw@gmail.com)
    Date: 2017/08
*/

//------------------------------------------------------------------------------------------
PImage inputImage;
PImage outputImage;
//String IMAGE_PATH = "data/Test_Image.tif";
String IMAGE_PATH = "data/octree1x1_fix_blob_v1.bmp";
//String IMAGE_PATH = "data/octree1x1test.tif";
int IMAGE_WIDTH = 1024, IMAGE_HEIGHT = 1024;
// Robot Size is 30 cm. 
int CUT_SIZE = 6; 
int CENTER_INDEX = IMAGE_WIDTH * ((IMAGE_HEIGHT/2) - 1) + IMAGE_WIDTH/2;
int PATH_COLOR = color(254,254,254);
float EMITY_RATIO = 0.05;
float FULL_RATIO = 0.995;
RegionMapInformation _rootQuadtree;
boolean[] map;
int cutWidth;
int cutHeight;

//------------------------------------------------------------------------------------------
void setup(){
  size(1200, 1024);
  background(0);
  
  // Open image file.
  inputImage = loadImage(IMAGE_PATH);
  println(inputImage + "\n");
  
  // Protect input image.
  outputImage = inputImage;
  //print("output image width = " + outputImage.width + " height = " + outputImage.height + "\n");
  
  // Cut grid image.
  float[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  println("cutWidth = " + cutWidth + " cutHeight = " + cutHeight + ", arraySize = " + (cutWidth + (cutWidth * cutHeight)) + "\n");
  
  //QuadTree cutting
  _rootQuadtree = quadtreeCutting(inputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth/2, cutHeight/2, cutWidth, cutHeight);
  print("Quadtree Cutting End\n\n");
  
  
  
  // Draw image ranger.
  drawCrossLine(outputImage, -512, -512, color(255,0,0));
  drawCrossLine(outputImage, 0, 0, color(255,0,0));
  drawCrossLine(outputImage, 511, 511, color(255,0,0));
  
  //Draw region ranger
  drawCuttingRegionPoint(outputImage, CUT_SIZE, -84, -84, color(255,0,0));
  drawCuttingRegionPoint(outputImage, CUT_SIZE, 84, 84, color(255,0,0));
  
  color emityColor = color(10, 100, 30);
  color mixColor = color(200, 150, 20);
  color fullColor = color(128, 128, 128);
  //drawQuadtreeState(outputImage, _rootQuadtree, emityColor, mixColor, fullColor);
  
  // Draw region crosss line
  color crossColor = color(50);
  //drawQuadtreeCuttingCrossLine(outputImage, _rootQuadtree, crossColor, 0.9);
  
  // Find Emity Region
  RegionMapInformation[] emityRegions = new RegionMapInformation[1024];
  int emityRegionsNumber = getStateRegions(_rootQuadtree, emityRegions, RegionMapInformation.RegionState.EMITY_OBSTACLE, 0);
  println("Save Index = " + emityRegionsNumber);
  for(int i=0; i<emityRegionsNumber ; i++){
    //print("(" + i + "," + emityRegions[i].getRegionArea() + ") ");
    //drawQuadtreeCuttingArea(outputImage, emityRegions[i], emityColor, mixColor, fullColor);
    //drawQuadtreeCuttingCrossLine(outputImage, emityRegions[i], crossColor, 0.0);
  }//end for
  
  // Sort Region
  emityRegions = sortMaxAreaToMinArea(emityRegions, emityRegionsNumber);
  int maxLevel = emityRegions[0].getRegionArea();
  int areaLevel = maxLevel;
  float colorRatio = 1;
  for(int i=0; i<emityRegionsNumber ; i++){
    //print("(" + i + "," + emityRegions[i].getRegionArea() + ") ");
    if(emityRegions[i].getRegionArea() < areaLevel){
      //print("have min region\n");
      areaLevel =  emityRegions[i].getRegionArea();
      colorRatio = float(areaLevel)/maxLevel;
      //print("Color Ratio = " + colorRatio +"\n");
    }
    
    drawQuadtreeCuttingArea(outputImage, emityRegions[i], int(emityColor*colorRatio), int(mixColor*colorRatio), int(fullColor*colorRatio));
    //drawQuadtreeCuttingCrossLine(outputImage, emityRegions[i], crossColor, 0.0);
  }//end for

  /*
  // RegionInformation transform to two-dimension array.
  map = grabPoints(emityRegions, cutWidth, cutHeight);
  
  // find path with greed methos
  int startX = 0;
  int startY = 0;
  int[][] cycle_pathing = cyclePath(map, cutWidth, cutHeight, ((startX + cutWidth/2) + (startY + cutHeight/2)*cutWidth));
  print("Cycle path  length = "+cycle_pathing[0][0]+"\n");
  for(int i=1; i<cycle_pathing[0][0]; i++){
    //print("["+i+"] = (" + cycle_pathing[i][0] + "," + cycle_pathing[i][1] + ") \n");
    //drawCuttingRegionPoint(outputImage, CUT_SIZE, cycle_pathing[i][0], cycle_pathing[i][1], int( color(255, 255, 0) * (i*1.0/cycle_pathing[0][0])));
    drawCuttingRegionPoint(outputImage, CUT_SIZE, cycle_pathing[i][0], cycle_pathing[i][1], color(-65536-(i*100)));
  }
  print("\n\n");
  */
  
  //Create path tree
  
  
  
  
  //cutGridShow(outputImage, CUT_SIZE, color(25));
  //outputImage.save(dataPath("quadtree_map_027.png"));
}//end setup


//------------------------------------------------------------------------------------------
void draw(){
  image(outputImage, 0, 0);
  
}

//------------------------------------------------------------------------------------------
void mousePressed(){
  color c;
  c=get(mouseX,mouseY);
  println((c+65536)/100);
  int pointX = (int) Math.floor(((mouseX - IMAGE_WIDTH/2)*1.0)/CUT_SIZE);
  int pointY = (int) Math.floor(((mouseY - IMAGE_HEIGHT/2)*1.0)/CUT_SIZE);
  
  background(0);
  fill(255,0,0);
  textSize(20);
  text("(" + mouseX + "," + mouseY+")", 1024, 950);
  text("("+pointX+","+pointY+") = "+ readArray(map, ((pointX + cutWidth/2) + (pointY + cutHeight/2)*cutWidth)), 1024, 1000);
  
  /*
  print("mouse point = (" + pointX + "," + pointY + ")\n");
  RegionMapInformation findIt = findRegionPoint( _rootQuadtree, pointX, pointY);
  print("find region = " + findIt + "\n");
  if(findIt != null){
    color emityColor = color(10, 100, 30);
    color mixColor = color(200, 150, 20);
    color fullColor = color(128, 128, 128);
    drawQuadtreeCuttingArea(outputImage, findIt, emityColor, mixColor, fullColor);
  }
  */
}

//------------------------------------------------------------------------------------------
void createConnectTree(RegionMapInformation _map, int _startX, int _startY){
  RegionMapInformation selectRegion = findRegionPoint( _map, _startX, _startY);
  
  //Start Point is not region area.
  if( selectRegion == null) return;
  
  //Explore the top.
  
  for(int i=0;i<selectRegion.getRegionWidth();i++){
    
  }
}