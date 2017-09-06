import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class main extends PApplet {

PImage inputImage;
PImage outputImage;

//String IMAGE_PATH = "data/Test_Image.tif";
String IMAGE_PATH = "data/octree1x1.tif";
int IMAGE_WIDTH = 1024, IMAGE_HEIGHT = 1024;

// Robot Size is 30 cm. 
int CUT_SIZE = 6; 

int CENTER_INDEX = IMAGE_WIDTH * ((IMAGE_HEIGHT/2) - 1) + IMAGE_WIDTH/2;
int PATH_COLOR = color(254,254,254);

public void setup(){
  
  background(0);
  
  // Open image file.
  inputImage = loadImage(IMAGE_PATH);
  println(inputImage);
  
  // Protect input image.
  outputImage = inputImage;
  
  // Draw a origin points.
  //drawCrossLine(outputImage, 0, 0, color(0,0,255));
  
  // Cut grid image.
  boolean[] gridArray = getImageGridArray(inputImage, CUT_SIZE, PATH_COLOR);
  //cutGridShow(outputImage, CUT_SIZE,color(50));
  
  //findVertex(inputImage, CUT_SIZE, gridArray);
  int cutWidth = getImageGridWidth(inputImage, CUT_SIZE);
  int cutHeight = getImageGridHeight(inputImage, CUT_SIZE);
  octreeCutting(outputImage, gridArray, 1, -cutWidth/2, -cutHeight/2, cutWidth, cutHeight);
  
  
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
  
  //outputImage.save(dataPath("filter_map.png"));
}//end setup



public RegionMapInformation octreeCutting(PImage _image, boolean[] _mapArray, int _cutSize, int _originalPointX, int _originalPointY, int _regionWidth, int _regionHeight){
  RegionMapInformation resultMap;  
  
  //Cutting size is small.
  if(_regionWidth/2 <= _cutSize || _regionHeight/2 <= _cutSize){
    return null;
  }
  
  // Draw center cut line
  int centerPointX = _originalPointX + _regionWidth/2;
  int centerPointY = _originalPointY + _regionHeight/2;
  drawCrossLine(_image, centerPointX, centerPointY, color (50));
  
  // Explore Left Up Region
  int LURegion_LUPointX = _originalPointX;
  int LURegion_LUPointY = _originalPointY;
  int LURegion_RDPointX = _originalPointX + _regionWidth/2 - 1;
  int LURegion_RDPointY = _originalPointY + _regionHeight/2 - 1;
  RegionMapInformation _LURegion = getRegionInformation(resultMap, _mapArray, _regionWidth, _regionHeight,  LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  // Explore Right Up Region
  int RURegion_LUPointX = _originalPointX + _regionWidth/2;
  int RURegion_LUPointY = _originalPointY;
  int RURegion_RDPointX = _originalPointX + _regionWidth;
  int RURegion_RDPointY = _originalPointY + _regionHeight/2;
  RegionMapInformation _RURegion = getRegionInformation(resultMap, _mapArray, _regionWidth, _regionHeight, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  // Explore Left Down Region
  int LDRegion_LUPointX = _originalPointX;
  int LDRegion_LUPointY = _originalPointY + _regionHeight/2;
  int LDRegion_RDPointX = _originalPointX + _regionWidth/2 - 1;
  int LDRegion_RDPointY = _originalPointY + _regionHeight;
  RegionMapInformation _LDRegion = getRegionInformation(resultMap, _mapArray, _regionWidth, _regionHeight, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  // Explore Right Down Region
  int RDRegion_LUPointX = _originalPointX + _regionWidth/2;
  int RDRegion_LUPointY = _originalPointY + _regionHeight/2;
  int RDRegion_RDPointX = _originalPointX + _regionWidth;
  int RDRegion_RDPointY = _originalPointY + _regionHeight;
  RegionMapInformation _RDRegion = getRegionInformation(resultMap, _mapArray, _regionWidth, _regionHeight, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);
  
  // Determine whether the sub-region is empty-obstacle
  if(_LURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
        
     new RegionMapInformation (null, RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                _originalPointX + _regionWidth, _originalPointY + _regionHeight);
    
  }else if (
      // Determine whether the sub-region is full-obstacle
      _LURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE){
    
      return new RegionMapInformation (null, RegionMapInformation.RegionState.FULL_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                _originalPointX + _regionWidth, _originalPointY + _regionHeight);
    
  }else{
    return new RegionMapInformation (null, RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                                _originalPointX, _originalPointY,
                                                _originalPointX + _regionWidth, _originalPointY + _regionHeight);
  }//end if
  
  
}

public RegionMapInformation getRegionInformation(RegionMapInformation _parentRegion, boolean[] _mapArray, int _regionWidth, int _regionHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
 
  switch(cutRectangleJudgment(_mapArray, _regionWidth, _regionHeight,_LUPointX, _LUPointY, _RDPointX, _RDPointY)){
    case RegionMapInformation.RegionState.EMITY_OBSTACLE:
        // Return emity obstacle region information
        return new RegionMapInformation(_parentRegion, RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                          _LUPointX, _LUPointY,
                                          _RDPointX, _RDPointY);
    case RegionMapInformation.RegionState.FULL_OBSTACLE:
        // Return full obstacle region information
        return new RegionMapInformation(_parentRegion, RegionMapInformation.RegionState.FULL_OBSTACLE,
                                         _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);
    default:
        // Return mixed obstacle region information
        return new RegionMapInformation(_parentRegion, RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                        _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);

  }//end switch
}//end checkRegion
public int cutRectangleJudgment(boolean[] _mapArray, int _cutWidth, int _cutHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
  boolean emityResult = true;
  boolean fullResult = true;
  
  println("cutRectangleJudgment _LUPoint (" + _LUPointX + ", " + _LUPointY + ") _RDPoint (" + _RDPointX + ", " + _RDPointY + ")");
  
  //Check cut rectangle 
  int rectangleWidth = _RDPointX - _LUPointX;
  int rectangleHeight = _RDPointY - _LUPointY;
  int selectPointX = _LUPointX + _cutWidth/2;
  int selectPointY = _LUPointY + _cutHeight/2;
  int index = selectPointX + selectPointY*_cutWidth;
  
  for(int j=0; j<abs(rectangleWidth); j++){
     for(int i=0; i<abs(rectangleHeight); i++){
         println("SelectPointX = " + selectPointX + " SelectPointY = " + selectPointY + " index = " + index);
         /*if(!_mapArray[index]){
           emityResult = false;
           println("Result = " + emityResult + "\n");
         }else(_mapArray[index]){
           fullResult = false;
         }*/
         index += rectangleWidth/abs(rectangleWidth);
     }
     index += rectangleHeight/abs(rectangleHeight) * _cutHeight;
  }//end for
  
  int result;
  if(emityResult && !fullResult){
    result = RegionMapInformation.RegionState.EMITY_OBSTACLE;
  }else if (!emityResult && fullResult){
    result = RegionMapInformation.RegionState.FULL_OBSTACLE; 
  }else{
    result= RegionMapInformation.RegionState.MIXED_OBSTACLE;
  }
  println("Result = " + result + "\n");
  return result;
}

class RegionMapInformation{
  
  public class RegionState{
    public final static int EMITY_OBSTACLE = 0;
    public final static int MIXED_OBSTACLE = 1;
    public final static int FULL_OBSTACLE = 2;
  }

  private int LUPointX;
  private int LUPointY;
  private int RDPointX;
  private int RDPointY;
  
  /*
   * 0 = Emity Obstacle
   * 1 = Mixed Obstacle
   * 2 = Full Obstacle
  */
  private int STATE;
  
  // Parent Region
  RegionMapInformation parentRegion;
  
  // Child Map
  private RegionMapInformation LURegion = null;
  private RegionMapInformation RURegion = null;
  private RegionMapInformation LDRegion = null;
  private RegionMapInformation RDRegion = null;
  
  public int getLUPointX(){return LUPointX;}
  public int getLUPointY(){return LUPointY;}
  public int getRDPointX(){return RDPointX;}
  public int getRDPointY(){return RDPointY;}
  
  public int getRegionState(){return STATE;}
  
  public RegionMapInformation getLURegion(){return LURegion;}
  public RegionMapInformation getRURegion(){return RURegion;}
  public RegionMapInformation getLDRegion(){return LDRegion;}
  public RegionMapInformation getRDRegion(){return RDRegion;}
  
  public void setLURegion(RegionMapInformation _region){ LURegion = _region;}
  public void setRURegion(RegionMapInformation _region){ RURegion = _region;}
  public void setLDRegion(RegionMapInformation _region){ LDRegion = _region;}
  public void setRDRegion(RegionMapInformation _region){ RDRegion = _region;}
  
  //Constructor
  RegionMapInformation(RegionMapInformation _parentRegion, int _state, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
    parentRegion = _parentRegion;
    STATE = _state;
    LUPointX = _LUPointX;
    LUPointY = _LUPointY;
    RDPointX = _RDPointX;
    RDPointY = _RDPointY;
  }//end constructor
  
  
  
}//end Class

public boolean rectangleJudgment(PImage _image, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY, int _color){
  boolean result = true;
  int _width = _RDPointX - _LUPointX;
  int _height = _RDPointY - _LUPointY;
  
  // Check rectangle color
  int selectPointX = _LUPointX;
  int selectPointY = _LUPointY;
  for(int j=0 ; j <abs(_height); j++){
    for(int i=0 ; i < abs(_width) ; i++){
      if(_image.pixels[coordinateToImageIndex(_image,selectPointX,selectPointY)]!=_color){
        //print("Image[" + selectPointX + "," + selectPointY + "]=" +_image.pixels[coordinateToImageIndex(_image,selectPointX,selectPointX)] + " _color = " + _color + " ");
        result = false;
        return result;
      }
      selectPointX = _LUPointX;
      selectPointX += _width/abs(_width);
    }
    selectPointY += _height/abs(_height);
  }//end for
  
  return result;
}//end rectangleJudgment



public boolean cutRegionPointJudgment(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, int _color){
  int LRPointX = _cutSize*_cutPointX - _cutSize/2;
  int LRPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
  //drawCrossLine(_image, LRPointX, LRPointY, color(255,0,0));
  //drawCrossLine(_image, RDPointX, RDPointY, color(255,0,0));
  
  return rectangleJudgment(_image, LRPointX, LRPointY, RDPointX, RDPointY, _color);
  
}//end cutRegionJudgment

public boolean[] getImageGridArray(PImage _image, int _cutSize,int _color){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  //println("Width Index = " + startIndexWidth + " ~ " + endIndexWidth);
  //println("Height Index = " + startIndexHeight + " ~ " + endIndexHeight);
  
  int gridWidth = endIndexWidth - startIndexWidth;
  int girdHeight = endIndexHeight - startIndexHeight;
  boolean[] gridArray = new boolean[gridWidth * girdHeight];
  
  int gridIndex = 0;
  for(int j=startIndexHeight; j<endIndexHeight; j++){
    for(int i=startIndexWidth; i<endIndexWidth; i++){
      gridArray[gridIndex] = cutRegionPointJudgment(_image, _cutSize, i, j, _color);
      
      //Draw Region Color
      if(gridArray[gridIndex]){
        drawCuttingRegionPoint(_image, _cutSize, i, j, color(255,0,0));
      }
      
      gridIndex += 1;
    }
  }
  return gridArray;
}//end getImageGridArray

public int getImageGridWidth(PImage _image, int _cutSize){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  
  return (endIndexWidth - startIndexWidth);
}

public int getImageGridHeight(PImage _image, int _cutSize){
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  return (endIndexHeight - startIndexHeight);
}

public void findVertex(PImage _image, int _cutSize, boolean[] _cutMap){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  int gridWidth = endIndexWidth - startIndexWidth;
  int gridHeight = endIndexHeight - startIndexHeight;
  
  int[] vertexArray = new int[10240];
  int index = 0 ;
  
  int mapIndex=0;
  for(int h=0; h< gridHeight; h++){ 
    for(int w=0;w < gridWidth-1; w++){
        if((_cutMap[mapIndex] && !_cutMap[mapIndex+1]) || (!_cutMap[mapIndex] && _cutMap[mapIndex+1])){
          vertexArray[index] = mapIndex;
          index++;
        }
        mapIndex++;
    }
  }//end for
  
  
  print("Vertex = ");
  for(int i=0; i<index; i++){
    if(vertexArray[i]!=-1){
      int cuttingX = ((vertexArray[i]%gridWidth) - (gridWidth/2));
      int cuttingY = ((vertexArray[i]/gridHeight) - (gridHeight/2));
      
      drawCuttingRegionPoint(_image, _cutSize, cuttingX, cuttingY, color(0,255,0));
      
      if(!_cutMap[vertexArray[i]+gridWidth]){
        print(vertexArray[i] + " " + cuttingX + " " + cuttingY + ", ");
        drawCuttingRegionPoint(_image, _cutSize, cuttingX, cuttingY, color(0,0,255));
      }
    }
  }//end for
  
}//end findVertex

public void drawCrossLine(PImage _image, int _pointX, int _pointY, int _color){
  for(int i=0; i < _image.width; i++){
    //Vertical Line
    _image.pixels[(_image.width/2 + _pointX) + i*_image.width] = _color;
    //Horizontal Line
    _image.pixels[_image.width*(_image.height/2 - 1 + _pointY)+i] = _color;
  }
  _image.updatePixels();
  image(_image,0 ,0);

}//end draw Point

public void drawLine(int _pointX1,int _pointY1, int _pointX2, int _pointY2){
  line(_pointX1+(IMAGE_WIDTH/2), _pointY1+(IMAGE_HEIGHT/2), _pointX2+(IMAGE_WIDTH/2), _pointY2+(IMAGE_HEIGHT/2));
}

public void drawRegion(PImage _image, int _pointX1, int _pointY1, int _pointX2, int _pointY2, int _color){
  int _width = _pointX2 - _pointX1;
  int _height = _pointY2 - _pointY1;
  
  int selectPointX = _pointX1;
  int selectPointY = _pointY1;
  
  //print("Region = " + _pointX1 + " " + _pointY1 + " " + _pointX2 + " " + _pointY2 + ", ");
  for(int j=0; j<abs(_height); j++){
    for(int i=0; i<abs(_width); i++){
      //print("Point " + selectPointX + " " + selectPointY + ", ");
      _image.pixels[coordinateToImageIndex(_image, selectPointX, selectPointY)] = _color;
      selectPointX += _width/abs(_width);
    }
    selectPointX = _pointX1;
    selectPointY += _height/abs(_height);
  }
  
  _image.updatePixels();
  image(_image,0 ,0);
}//end drawRegion

public void drawCuttingRegionPoint(PImage _image, int _cutSize, int _cutPointX, int _cutPointY, int _color){
  int LRPointX = _cutSize*_cutPointX - _cutSize/2;
  int LRPointY = _cutSize*_cutPointY - _cutSize/2;
  int RDPointX = _cutSize*_cutPointX + _cutSize/2;
  int RDPointY = _cutSize*_cutPointY + _cutSize/2;
  
   drawRegion(_image, LRPointX, LRPointY, RDPointX, RDPointY, _color);
}//end drawCuttingPoint

public void cutGridShow(PImage _image, int _cutSize, int _color){
  int startIndexWidth = -1 * (((_image.width/2)-(_cutSize/2))/_cutSize);
  int endIndexWidth = (((_image.width/2)-(_cutSize/2))/_cutSize);
  int startIndexHeight = -1 * (((_image.height/2)-(_cutSize/2))/_cutSize);
  int endIndexHeight = (((_image.height/2)-(_cutSize/2))/_cutSize);
  
  println("Width Index = " + startIndexWidth + " ~ " + endIndexWidth);
  println("Height Index = " + startIndexHeight + " ~ " + endIndexHeight);
  
  int LRPointX ;
  int LRPointY ;
  
  for(int j=startIndexHeight; j<endIndexHeight; j++){
    LRPointX = _cutSize*0 - _cutSize/2;
    LRPointY = _cutSize*j - _cutSize/2;
    drawCrossLine(_image, LRPointX, LRPointY, _color);
  }
  for(int i=startIndexWidth; i<endIndexWidth; i++){
    LRPointX = _cutSize*i - _cutSize/2;
    LRPointY = _cutSize*0 - _cutSize/2;
    drawCrossLine(_image, LRPointX, LRPointY, _color);
  }
}//end cutGridShow

public String ZPath(int _startX, int _startY, int _endX, int _endY, int _density){
  int _width = _endX - _startX;
  int _height = _endY - _startY;
  int movePointX = _startX;
  int movePointY = _startY;
  boolean upDownFlag = true;
  String path = "";
  
  //Two points can't decidea a rectangle.
  if(_width == 0 || _height ==0){
    path += Integer.toString(_endX) + " " + Integer.toString(_endY) + " ";
    drawLine(_startX, _startY, _endX, _endY);
    return path;
  }
  
  int i=0;
  while(i<abs(_width)){
    path += Integer.toString(movePointX) + " " + Integer.toString(movePointY) + " ";
    
    //Vertical
    if(upDownFlag){
      drawLine(movePointX, movePointY, movePointX, movePointY + _height);
        movePointY += _height;
    }else{
      drawLine(movePointX, movePointY, movePointX, movePointY - _height);
      movePointY -= _height;
    }
    upDownFlag = !upDownFlag;
    
    path += Integer.toString(movePointX) + " " + Integer.toString(movePointY) + " ";
    
    //Horizontal
    drawLine(movePointX, movePointY, movePointX + (_width/abs(_width)) * _density, movePointY);
    movePointX += _width/abs(_width) * _density;
    i += _density;
  }
  
   if(movePointX!=_endX || movePointY!=_endY){
     drawLine(movePointX, movePointY, _endX, _endY);
     path += Integer.toString(_endX) + " " + Integer.toString(_endY) + " ";
   }
  return path;
}//end ZPath

public int coordinateToImageIndex(PImage _image, int _pointX, int _pointY){
    return _image.width*(_image.height/2-1 + _pointY) + (_image.width/2 + _pointX);
}//end coordinateToImageIndex

// Draw a point 
//int index = 1024;
//pointX = (index%IMAGE_WIDTH) - IMAGE_WIDTH/2;
//pointY = (index-CENTER_INDEX)/IMAGE_WIDTH;
  public void settings() {  size(1024, 1024); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "main" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
