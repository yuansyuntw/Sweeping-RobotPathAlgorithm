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
List<ConnectionInformation> WEIGHTS;

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
  println("Grid Width = " + cutWidth + " Grid Height = " + cutHeight + ", Grid Size = " + (cutWidth + (cutWidth * cutHeight)) + "\n");
  
  //QuadTree cutting
  _rootQuadtree = quadtreeCutting(inputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth/2, cutHeight/2, cutWidth, cutHeight);
  print("Quadtree Cutting End ("+_rootQuadtree+").\n");
  
  
  
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
  
  WEIGHTS = GetPrimSpinningTree(_rootQuadtree, 3, -25);
  
  //cutGridShow(outputImage, CUT_SIZE, color(25));
  //outputImage.save(dataPath("quadtree_map_033.png"));
  
  Draw();
}//end setup

//------------------------------------------------------------------------------------------
void draw(){
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
  
  Draw();
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
List<ConnectionInformation> GetPrimSpinningTree(RegionMapInformation _root, int _rootX, int _rootY){
  
  List<RegionMapInformation> vieweds = new ArrayList<RegionMapInformation>();
  
  List<ConnectionInformation> weights = new ArrayList<ConnectionInformation>();
  
  RegionMapInformation findIt = findRegionPoint(_root, _rootX, _rootY);
  
  while(true){
    if(findIt!=null){
      vieweds.add(findIt);
      //TextQuadtreeArea(findIt, str(vieweds.size()+1), color(255,0,0), 12);
      AddConnectInformations(weights, findIt);
      findIt = GetMinWeightRegion(vieweds, weights);
    }else{
      break;
    }
  }
  
  print("getPrimSpinningTree() is complete. Find " + weights.size() + " paths.\n");

  return weights;
}

//------------------------------------------------------------------------------------------
/*
  Purpose:
    Add connect region to input array.
    
  Parameter:
    _weightsArray = Attached array.
    _index = Attached array index.
    _region = Join the content.
    
  Return:
    New attached array index. 
*/
void AddConnectInformations(List<ConnectionInformation> _weights, RegionMapInformation _region){
  
  //Check input data
  if((_region != null)&&(_region.getConnectionRegions()!=null)&&(_weights!=null)){
    //print("region addres = " + _region+"\n");
    //print("weights address = " + _weights.size()+"\n");
    //print("region connect region = " + _region.getConnectionRegions()+"\n");
    
    ConnectionInformation ci;
    for(int i=0;i<_region.getConnectionRegions().length;i++){
      ci = _region.getConnectionRegions()[i];
      if(ci!=null){
          _weights.add(ci);
      }
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
RegionMapInformation GetMinWeightRegion(List<RegionMapInformation> _vieweds, List<ConnectionInformation> _weights){
  RegionMapInformation result = null;

  if(_weights.size()>0){
    //print("weights size = " + _weights.size() + "\n");
    
    //Find min weights,
    int oldMinWeight = 0;
    int minWeight = _weights.get(0).getWeight();
    int minWeightIndex = 0;
    while(true){
    
      for(int i=0;i<_weights.size();i++){
        //print("_weight["+i+"] = " + _weights.get(i) + "\n");
        if((oldMinWeight < _weights.get(i).getWeight()) && (_weights.get(i).getWeight() < minWeight)){
          minWeightIndex = i;
          minWeight = _weights.get(i).getWeight();
        }
      }//end for
      
      if(minWeight==oldMinWeight){
          break;
      }
      
      //print("find minWeight = " + minWeight);
    
      //Check add it, wether will cause loop.
      if(CheckCycle(_vieweds, _weights.get(minWeightIndex).getConnectRegion())){
        
        //Refind.
        oldMinWeight = minWeight;
        minWeight = 9999;
        //print(" Refind\n");
        
      }else{
        
        //Find it.
        result = _weights.get(minWeightIndex).getConnectRegion();
        break;
        
      }//end if
      
      //print(".");
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
boolean CheckCycle(List<RegionMapInformation> _vieweds, RegionMapInformation _region){
  boolean result = true;
  
  //print(" check region = "+_region+"");
  //print(" in " + _vieweds.indexOf(_region) + "\n");
  if((_region!=null)&&(_vieweds.indexOf(_region)==-1)){
    result = false;
  }
  
  return result;
}

/*------------------------------------------------------------------------------------------
  Purpose:
    Help to debug. Add text to screen.
    
  Parameter:
    _region = draw with region.
    _str = Added string.
    _col = Text color.
    _textSize = Text size. 
    
  Return:
    None.
*/
void TextQuadtreeArea(RegionMapInformation _region, String _str, color _col, int _textSize){
  
  if(_region!=null){
      int x = (_region.getLUPointX()+cutWidth/2)*CUT_SIZE; 
      int y = (_region.getLUPointY()+cutHeight/2)*CUT_SIZE;
      //print("text pos = ("+x+","+y+")\n");
      
      //background(0);
      fill(_col);
      textSize(_textSize);
      text(_str, x, y);
  }
}

/*------------------------------------------------------------------------------------------
  Purpose:
    Help to debug. Draw connectionInformationNumber.
    
  Parameter:
    _weights = draw with region.
    _str = Added string.
    _col = Text color.
    _textSize = Text size. 
    
  Return:
    None.
*/
void DrawConnectionInformation(List<ConnectionInformation> _weights, color _col){
    
  if(_weights!=null){
    color mixColor = color(150);
    color fullColor = color(200);
  
    for(int i=0;i<_weights.size();i++){
      //print("O = " + _weights.get(i).getOriginalRegion() + ", C = " + _weights.get(i).getConnectRegion()+"\n");
      drawQuadtreeCuttingArea(outputImage, _weights.get(i).getConnectRegion(), int(_col-50), mixColor, fullColor);
      drawQuadtreeCuttingArea(outputImage, _weights.get(i).getOriginalRegion(), _col, mixColor, fullColor);
    }
  }
  
}

/*------------------------------------------------------------------------------------------
  Purpose:
    Draw GUI.
    
  Parameter:
    None.
    
  Return:
    None.
*/
void Draw(){
  image(outputImage, 0, 0);
  DrawConnectionInformation(WEIGHTS, color(150));
}