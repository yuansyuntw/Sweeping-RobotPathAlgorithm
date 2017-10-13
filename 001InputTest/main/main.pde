/*
    Purpose: Solve sweeping robot path planning.
    Coder: YuanSyun(yuansyuntw@gmail.com)
    Date: 2017/08
*/

//------------------------------------------------------------------------------------------
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
RegionMapInformation _rootQuadtree;

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
  int cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  int cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  println("cutWidth = " + cutWidth + " cutHeight = " + cutHeight + ", arraySize = " + (cutWidth + (cutWidth * cutHeight)) + "\n");
  
  //QuadTree cutting
  _rootQuadtree = quadtreeCutting(outputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth/2, cutHeight/2, cutWidth, cutHeight);
  print("Quadtree Cutting End\n\n");
  
  cutGridShow(outputImage, CUT_SIZE, color(25));
  
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
    
    //drawQuadtreeCuttingArea(outputImage, emityRegions[i], int(emityColor*colorRatio), int(mixColor*colorRatio), int(fullColor*colorRatio));
    //drawQuadtreeCuttingCrossLine(outputImage, emityRegions[i], crossColor, 0.0);
  }//end for
  
  
  // RegionInformation transform to two-dimension array
  boolean[] map = grabPoints(emityRegions, cutWidth, cutHeight);
  /*
  for(int i=0; i < (cutWidth*cutHeight); i++){
    print(map[i]? "1":"0");
    if(i%cutWidth==0){
      print("\n");
    }
  }//end for
  */
  
  // find path with greed methos
  int startX = 0;
  int startY = 0;
  int[][] cycle_pathing = cyclePath(map, cutWidth, cutHeight, ((startX + cutWidth/2) + (startY + cutHeight/2)*cutWidth));
  print("Cycle path  length = "+cycle_pathing[0][0]+"\n");
  for(int i=1; i<cycle_pathing[0][0]; i++){
    //print("["+i+"] = (" + cycle_pathing[i][0] + "," + cycle_pathing[i][1] + ") \n");
    
    drawCuttingRegionPoint(outputImage, CUT_SIZE, cycle_pathing[i][0], cycle_pathing[i][1], int( color(255, 0, 255) * (i*1.0/cycle_pathing[0][0])));
  }
  print("\n\n");
  
  
  //outputImage.save(dataPath("quadtree_map_023.png"));
}//end setup


//------------------------------------------------------------------------------------------
void draw(){
  image(outputImage, 0, 0);
}

//------------------------------------------------------------------------------------------
void mousePressed(){
  
  int pointX = (mouseX - IMAGE_WIDTH/2)/CUT_SIZE;
  int pointY = (mouseY - IMAGE_HEIGHT/2)/CUT_SIZE;
  
  background(0);
  fill(255,0,0);
  textSize(20);
  text("("+pointX+","+pointY+")", 1024, 1024);
  
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
int[][] cyclePath(boolean[] _map,int _mapWidth, int _mapHeight, int _startPoint){
  //Copy array.
  boolean[] _pathMap = new boolean[_map.length];
  for(int i=0;i<_pathMap.length;i++){
    _pathMap[i] = _map[i];
  }
  
  int resultSize = 9999;
  int [][]result = new int[resultSize][2];
  int pathCounter = 1;
  
  int selectPoint = _startPoint;
  
  int backPathCounter = 0;
  
  //print("_map length = "+_map.length+"\n");
  
  //Save start point.
  _pathMap[selectPoint] = false;
  //Save point x.
  result[pathCounter][0] = selectPoint%_mapWidth - _mapWidth/2;
  //Save point y.
  result[pathCounter][1] = selectPoint/_mapWidth - _mapHeight/2;
  print("["+pathCounter+"] = (" + result[pathCounter][0]+","+result[pathCounter][1]+")\n");
  pathCounter += 1;
  
  while(true){
    
    // right, down, left and up is cycle order.
    if(readArray(_pathMap, selectPoint+1)){
      //right
      selectPoint += 1;
      backPathCounter = 0;
    }else if(readArray(_pathMap, selectPoint+_mapWidth)){
      //down
      selectPoint += _mapWidth;
      backPathCounter = 0;
    }else if(readArray(_pathMap, selectPoint-1)){
      //left
      selectPoint -= 1;
      backPathCounter = 0;
    }else if(readArray(_pathMap, selectPoint-_mapWidth)){
      //up
      selectPoint -= _mapWidth;
      backPathCounter = 0;
    }else {

      if(backPathCounter == 0){
        backPathCounter = 2;
      }else{
        backPathCounter += 2;
        if(pathCounter-backPathCounter<0) break;
      }
      
      //print("Back State = "+ backPathCounter +"\n");

      //Back postion
      selectPoint = ((result[pathCounter-backPathCounter][0] + _mapWidth/2) + ((result[pathCounter-backPathCounter][1] + _mapHeight/2)*_mapWidth)); 
      _pathMap[selectPoint] = false;
      //Save point x.
      result[pathCounter][0] = selectPoint%_mapWidth - _mapWidth/2;
      //Save point y.
      result[pathCounter][1] = selectPoint/_mapWidth - _mapHeight/2;
      print("["+pathCounter+"] = (" + result[pathCounter][0]+","+result[pathCounter][1]+")\n");
      pathCounter += 1;
      
      //Back state.
      if(readArray(_pathMap, selectPoint-1)){
        //left
        selectPoint -= 1;
      }else if(readArray(_pathMap, selectPoint+_mapWidth)){
        //down
        selectPoint += _mapWidth;
      }else if(readArray(_pathMap, selectPoint+1)){
        //right
        selectPoint += 1;
      }else if(readArray(_pathMap, selectPoint-_mapWidth)){
        //up
        selectPoint -= _mapWidth;
      }//end if
    }//end if
    
    if(pathCounter >= resultSize) break;
    
    //print("Select point = " + selectPoint + " pathCounter = " + pathCounter + "\n");
    
    if(_pathMap[selectPoint]){
      _pathMap[selectPoint] = false;
      //Save point x.
      result[pathCounter][0] = selectPoint%_mapWidth - _mapWidth/2;
      //Save point y.
      result[pathCounter][1] = selectPoint/_mapWidth - _mapHeight/2;
      print("["+pathCounter+"] = (" + result[pathCounter][0]+","+result[pathCounter][1]+")\n");
      pathCounter += 1;
    }//end if
  }//end while
  
  //Save path counter.
  result[0][0] = pathCounter;
  
  return result;
}//end cyclePath

//------------------------------------------------------------------------------------------
boolean readArray(boolean[] _array, int _index){
  
  if((_index>=0)&&(_index<_array.length)){
    return _array[_index];
  }
  
  return false;
}//end readAttay