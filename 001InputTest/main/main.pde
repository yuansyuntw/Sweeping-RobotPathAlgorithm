PImage inputImage;
PImage outputImage;

//String IMAGE_PATH = "data/Test_Image.tif";
String IMAGE_PATH = "data/octree1x1.tif";
//String IMAGE_PATH = "data/octree1x1test.tif";
int IMAGE_WIDTH = 1024, IMAGE_HEIGHT = 1024;

// Robot Size is 30 cm. 
int CUT_SIZE = 6; 

int CENTER_INDEX = IMAGE_WIDTH * ((IMAGE_HEIGHT/2) - 1) + IMAGE_WIDTH/2;
int PATH_COLOR = color(254,254,254);

float EMITY_RATIO = 0.05;
float FULL_RATIO = 0.995;



void setup(){
  size(1024, 1024);
  background(0);
  
  // Open image file.
  inputImage = loadImage(IMAGE_PATH);
  println(inputImage + "\n");
  
  // Protect input image.
  outputImage = inputImage;
  //print("output image width = " + outputImage.width + " height = " + outputImage.height + "\n");
  
  // Cut grid image.
  float[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  int cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  int cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  println("cutWidth = " + cutWidth + " cutHeight = " + cutHeight + ", arraySize = " + (cutWidth + (cutWidth * cutHeight)) + "\n");
  
  //QuadTree cutting
  RegionMapInformation _rootQuadtree = quadtreeCutting(outputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth/2, cutHeight/2, cutWidth, cutHeight);
  print("Quadtree Cutting End\n\n");
  
  //cutGridShow(outputImage, CUT_SIZE, color(25));
  
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
  for(int i=0;i < emityRegionsNumber; i++){
    drawQuadtreeCuttingArea(outputImage, emityRegions[i], emityColor, mixColor, fullColor);
    drawQuadtreeCuttingCrossLine(outputImage, emityRegions[i], crossColor, 0.0);
  }//end for
  
  //outputImage.save(dataPath("quadtree_map_021.png"));
}//end setup



void draw(){
  image(outputImage, 0, 0);
}


int getStateRegions(RegionMapInformation _quadtree, RegionMapInformation [] _saveArray, int _state, int _index){
  int nextIndex = _index;
  
  if(_quadtree.isLeaf()){
   if(_quadtree.getRegionState() == _state){
     _saveArray[_index] = _quadtree;
     nextIndex = _index + 1;
   }
  }else{
    //DPS
    nextIndex = getStateRegions(_quadtree.getLURegion(), _saveArray, _state, nextIndex);
    nextIndex = getStateRegions(_quadtree.getRURegion(), _saveArray, _state, nextIndex);
    nextIndex = getStateRegions(_quadtree.getLDRegion(), _saveArray, _state, nextIndex);
    nextIndex = getStateRegions(_quadtree.getRDRegion(), _saveArray, _state, nextIndex);
  }//end if
  
  return nextIndex;
  
}//end getStateRegions



void sortMaxAreaToMinArea(RegionMapInformation[] _saveArray, int maxIndex){
 RegionMapInformation tempRegion; 
 int maxRegionIndex;
 int maxRegionArea;
 
 for(int i=0; i<maxIndex; i++){
   maxRegionIndex = i;
   maxRegionArea = _saveArray[maxRegionIndex].getRegionArea();
   for(int j=i+1; j<maxIndex; j++){
     if(_saveArray[i].getRegionArea() > maxRegionArea ){
       
       //Swap array context
       tempRegion = _saveArray[i];
       _saveArray[i] = _saveArray[j];
       _saveArray[j] = tempRegion;
       tempRegion = null;
       
     }
   }
 }//end for
}//end sortMaxAreaToMinArea