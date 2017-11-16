/*
    Coder: YuanSyun(yuansyuntw@gmail.com)
    Date: 2017/08
    Purpose: Solve sweeping robot path planning.
    
*/

//------------------------------------------------------------------------------------------
import java.util.*;

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
  RegionMapInformation[] emityRegions = getStateRegions(_rootQuadtree, RegionMapInformation.RegionState.EMITY_OBSTACLE);
  for(int i=0; i<emityRegions.length ; i++){
    //print("(" + i + "," + emityRegions[i].getRegionArea() + ") ");
    //drawQuadtreeCuttingArea(outputImage, emityRegions[i], emityColor, mixColor, fullColor);
    //drawQuadtreeCuttingCrossLine(outputImage, emityRegions[i], crossColor, 0.0);
  }//end for
  
  // Sort Region
  emityRegions = sortMaxAreaToMinArea(emityRegions, emityRegions.length);
  int maxLevel = emityRegions[0].getRegionArea();
  int areaLevel = maxLevel;
  float colorRatio = 1;
  for(int i=0; i<emityRegions.length; i++){
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

  
  // RegionInformation transform to two-dimension array.
  map = grabPoints(emityRegions, cutWidth, cutHeight);
  
  /*
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
  connectRegions(_rootQuadtree, emityRegions);
  
  /*
  color connectRegionColor = color(200, 0, 0);
  color selectRegionColor = color(0, 0, 200);
  drawConnectRegions(emityRegions, selectRegionColor, connectRegionColor);
  */
  
  getPrimSpinningTree(_rootQuadtree, 0, 0);
  
  
  //cutGridShow(outputImage, CUT_SIZE, color(25));
  //outputImage.save(dataPath("quadtree_map_032.png"));
}//end setup


//------------------------------------------------------------------------------------------
void draw(){
  image(outputImage, 0, 0);
  
}

//------------------------------------------------------------------------------------------
void mousePressed(){
  
  /*
  color c;
  c=get(mouseX,mouseY);
  println((c+65536)/100);
  */
  
  int pointX = (int) Math.floor(((mouseX - IMAGE_WIDTH/2)*1.0)/CUT_SIZE);
  int pointY = (int) Math.floor(((mouseY - IMAGE_HEIGHT/2)*1.0)/CUT_SIZE);
  
  background(0);
  fill(255,0,0);
  textSize(20);
  text("(" + mouseX + "," + mouseY+")", 1024, 950);
  text("("+pointX+","+pointY+") = "+ readArray(map, ((pointX + cutWidth/2) + (pointY + cutHeight/2)*cutWidth)), 1024, 1000);
  
  
  //print("mouse point = (" + pointX + "," + pointY + ")\n");
  RegionMapInformation findIt = findRegionPoint( _rootQuadtree, pointX, pointY);
  //print("find region = " + findIt + "\n");
  if(findIt != null){
    color selectColor = color(10, 100, 30);
    color connectColor = color(200, 150, 20);
    drawConnectRegion(findIt, RegionMapInformation.RegionState.EMITY_OBSTACLE, selectColor, connectColor);
  }
  
}

/*------------------------------------------------------------------------------------------
  Purpose: 
    Get a staet point, and return a region map tree. For minimum spanning tree.
    
  Parameter:
    _root = QuadTree map.
    _rootX = Start Point X.
    _rootY = Start Point Y. 
    
  Return:
    void
*/
void getPrimSpinningTree(RegionMapInformation _root, int _rootX, int _rootY){
  
  List<RegionMapInformation> vieweds = new ArrayList<RegionMapInformation>();
  
  List<ConnectionInformation> weights = new ArrayList<ConnectionInformation>();
  
  RegionMapInformation findIt = findRegionPoint(_root, _rootX, _rootY);
  
  while(true){
    if(findIt!=null){
      vieweds.add(findIt);
      AddConnectInformations(weights, findIt);
      findIt = getMinWeightRegion(vieweds, weights);
    }else{
      break;
    }
  }
  
  print("getPrimSpinninggtree() complete.\n");
  for(int i=0;i<weights.size();i++){
    print("O = " + weights.get(i).getOriginalRegion() + ", C = " + weights.get(i).getConnectRegion()+"\n");
  }

  return ;
}

//------------------------------------------------------------------------------------------
/*
  Purpose:
    Add connect region to input array.
    
  Parameter:
    _weightsArray = Attached array.
    _index = Attached array index.
    _region =   Join the content.
    
  Return:
    New attached array index. 
*/
void AddConnectInformations(List<ConnectionInformation> _weights, RegionMapInformation _region){
  
  //Check input data
  if((_region != null)&&(_weights!=null)){
    print("region addres = " + _region+"\n");
    print("weights address = " + _weights.size()+"\n");
    print("region connect region = " + _region.getConnectionRegions()+"\n");
    for(int i=0;i<_region.getConnectionRegions().length;i++){
      _weights.add(_region.getConnectionRegions()[i]);
    }
  }
  
}

/*------------------------------------------------------------------------------------------
  Purpose:
    Return thre area with the least weight and will not create a loop.
    
  Parameter:
    _weights = Weight region array.
    
  Return:
    min region weight.
*/
RegionMapInformation getMinWeightRegion(List<RegionMapInformation> _vieweds, List<ConnectionInformation> _weights){
  RegionMapInformation result = null;

  if(_weights.size()>0){
    
    //Find min weights,
    int minWeight = _weights.get(0).getWeight();
    int minWeightIndex = 0;
    while(true){
    
      for(int i=0;i<_weights.size();i++){
        if(_weights.get(i).getWeight() < minWeight){
          minWeightIndex = i;
          minWeight = _weights.get(i).getWeight();
        }
      }//end for
    
      //Check add it, wether will cause loop.
      if(checkCycle(_vieweds, _weights.get(minWeightIndex).getConnectRegion())){
        
        //Refind.
        minWeight=_weights.get(minWeightIndex).getWeight();
        
      }else{
        
        //Find it.
        result = _weights.get(minWeightIndex).getConnectRegion();
        break;
        
      }//end if
      
    }//end while
  }//end if
  
  return result;
}

/*------------------------------------------------------------------------------------------
  Purpose:
    Check if adding leads to a loop.
    
  Parameter:
    _viewed = Explored area.
    _region = Join the area.
    
  Return:
    Whether to create a loop.
*/
boolean checkCycle(List<RegionMapInformation> _vieweds, RegionMapInformation _region){
  boolean result = true;
  
  if((_region!=null)&&(_vieweds.indexOf(_region)!=-1)){
    
    result = false;
  }
  
  return result;
}