


class RegionMapInformation{
  
  public class Direction{
    public final static int LEFT = 0;
    public final static int RIGHT = 1;
    public final static int UP = 2;
    public final static int DOWN = 3;
  }
  
  public class RegionPosition{
    public final static int ROOT = -1;
    public final static int LEFT_UP = 0;
    public final static int RIGHT_UP = 1;
    public final static int LEFT_DOWN = 2;
    public final static int RIGHT_DOWN = 3;
    public final static int ENTIRE = 4;
  }
  
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
  private int STATE = RegionState.FULL_OBSTACLE;
  
  // Parent Region
  private RegionMapInformation parentRegion;
  
  // 
  private int regionPosition = RegionPosition.ROOT;
  
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

  public void setParentRegion(RegionMapInformation _region){ parentRegion = _region; }
  public RegionMapInformation getParentRegion(){ return parentRegion; }
  
  public int getRegionPosition(){ return regionPosition; }
  
  public int getRegionWidth(){return (abs(RDPointX - LUPointX) + 1);}
  public int getRegionHeight(){return (abs(RDPointY - LUPointY) + 1);}
  public int getRegionArea(){ return(getRegionWidth() * getRegionHeight()); }
  
  public boolean isLeaf(){ return ((LURegion==null)&&(RURegion==null)&&(LDRegion==null)&&(RDRegion==null)); }
  
  //Constructor
  RegionMapInformation(int _state, int _position , int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
    STATE = _state;
    regionPosition = _position;
    LUPointX = _LUPointX;
    LUPointY = _LUPointY;
    RDPointX = _RDPointX;
    RDPointY = _RDPointY;
  }//end constructor
}//end Class



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



RegionMapInformation[] sortMaxAreaToMinArea(RegionMapInformation[] _saveArray, int maxIndex){
 RegionMapInformation tempRegion; 
 int maxRegionIndex;
 int maxRegionArea;
 
 for(int i=0; i<maxIndex; i++){
   maxRegionIndex = i;
   maxRegionArea = _saveArray[maxRegionIndex].getRegionArea();
   for(int j=i+1; j<maxIndex; j++){
     if(_saveArray[j].getRegionArea() > maxRegionArea ){
       
       maxRegionIndex = j;
       maxRegionArea = _saveArray[j].getRegionArea();
       
       //Swap array context
       tempRegion = _saveArray[i];
       _saveArray[i] = _saveArray[j];
       _saveArray[j] = tempRegion;
       tempRegion = null;
     }//end 
   }//end for
 }//end for
 
 return _saveArray;
}//end sortMaxAreaToMinArea



RegionMapInformation quadtreeCutting(PImage _image, float[] _mapArray, int _cutSize, RegionMapInformation _parentRegion, int _regionPosition,  
                                  int _originalLUPointX, int _originalLUPointY,
                                  int _originalRDPointX, int _originalRDPointY,
                                  int _gridWidth, int _gridHeight){
                                    
  RegionMapInformation resultMap;
  boolean DEBUG = false;
  int _regionWidth = abs(_originalRDPointX - _originalLUPointX) + 1 ;
  int _regionHeight = abs(_originalRDPointY - _originalLUPointY) + 1;
  
  //Cutting size is small.
  if((_regionWidth/2 < _cutSize) || (_regionHeight/2 < _cutSize)){
    //return null;
    resultMap = getRegionInformation(_mapArray,
                                     _gridWidth, _gridHeight,
                                     RegionMapInformation.RegionPosition.ENTIRE,
                                     _originalLUPointX,_originalLUPointY,_originalRDPointX,_originalRDPointY);
    return resultMap;
  }//end if
  
  // Draw center cut line
  /*int centerPointX = _originalPointX + _regionWidth/2;
  int centerPointY = _originalPointY + _regionHeight/2;
  drawCrossLine(_image, centerPointX, centerPointY, color (50));*/
  
  //println("_originalPoint (" + _originalLUPointX + ", " + _originalLUPointY + ") _regionWidth = " + _regionWidth + " _regionHeight = " + _regionHeight);
  
  //Remove odd even conversion
  int halfWidth = _regionWidth/2;
  int halfHeight = _regionHeight/2;
  
  // Explore Left Up Region
  int LURegion_LUPointX = _originalLUPointX;
  int LURegion_LUPointY = _originalLUPointY;
  int LURegion_RDPointX = _originalLUPointX + halfWidth - 1;
  int LURegion_RDPointY = _originalLUPointY + halfHeight - 1;
  RegionMapInformation _LURegion = getRegionInformation(_mapArray,
                                                         _gridWidth, _gridHeight,
                                                         RegionMapInformation.RegionPosition.LEFT_UP,
                                                         LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  // Explore Right Up Region
  int RURegion_LUPointX = _originalLUPointX + halfWidth;
  int RURegion_LUPointY = _originalLUPointY;
  int RURegion_RDPointX = _originalLUPointX + _regionWidth - 1;
  int RURegion_RDPointY = _originalLUPointY + halfHeight - 1;
  RegionMapInformation _RURegion = getRegionInformation(_mapArray, 
                                                        _gridWidth, _gridHeight,
                                                        RegionMapInformation.RegionPosition.RIGHT_UP,
                                                        RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  // Explore Left Down Region
  int LDRegion_LUPointX = _originalLUPointX;
  int LDRegion_LUPointY = _originalLUPointY + halfHeight;
  int LDRegion_RDPointX = _originalLUPointX + halfWidth - 1;
  int LDRegion_RDPointY = _originalLUPointY + _regionHeight - 1;
  RegionMapInformation _LDRegion = getRegionInformation(_mapArray, 
                                                        _gridWidth, _gridHeight, 
                                                        RegionMapInformation.RegionPosition.LEFT_DOWN,
                                                        LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  // Explore Right Down Region
  int RDRegion_LUPointX = _originalLUPointX + halfWidth;
  int RDRegion_LUPointY = _originalLUPointY + halfHeight;
  int RDRegion_RDPointX = _originalLUPointX + _regionWidth - 1;
  int RDRegion_RDPointY = _originalLUPointY + _regionHeight - 1;
  RegionMapInformation _RDRegion = getRegionInformation(_mapArray, 
                                                        _gridWidth, _gridHeight, 
                                                        RegionMapInformation.RegionPosition.RIGHT_DOWN,
                                                        RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);

  // Determine whether the sub-region is empty-obstacle
  if(_LURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
        
     resultMap =  new RegionMapInformation (RegionMapInformation.RegionState.EMITY_OBSTACLE, _regionPosition,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    
  }else if (
      // Determine whether the sub-region is full-obstacle
      _LURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE){
    
      resultMap = new RegionMapInformation (RegionMapInformation.RegionState.FULL_OBSTACLE, _regionPosition,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    
  }else{
    resultMap = new RegionMapInformation (RegionMapInformation.RegionState.MIXED_OBSTACLE, _regionPosition,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    resultMap.setLURegion(quadtreeCutting(_image, _mapArray, _cutSize, resultMap, RegionMapInformation.RegionPosition.LEFT_UP, LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setRURegion(quadtreeCutting(_image, _mapArray, _cutSize, resultMap, RegionMapInformation.RegionPosition.RIGHT_UP, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setLDRegion(quadtreeCutting(_image, _mapArray, _cutSize, resultMap, RegionMapInformation.RegionPosition.LEFT_DOWN, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setRDRegion(quadtreeCutting(_image, _mapArray, _cutSize, resultMap, RegionMapInformation.RegionPosition.RIGHT_DOWN, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY, _gridWidth, _gridHeight));
  }//end if
  
  resultMap.setParentRegion(_parentRegion);

  return resultMap;
}//end quadtreeCutting



RegionMapInformation getRegionInformation(float[] _mapArray, int _gridWidth, int _gridHeight, int _position,
                                          int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
 
  switch(cutRectangleJudgment(_mapArray, _gridWidth, _gridHeight,_LUPointX, _LUPointY, _RDPointX, _RDPointY)){
    case RegionMapInformation.RegionState.EMITY_OBSTACLE:
        // Return emity obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.EMITY_OBSTACLE, 
                                          _position,
                                          _LUPointX, _LUPointY,
                                          _RDPointX, _RDPointY);
    case RegionMapInformation.RegionState.FULL_OBSTACLE:
        // Return full obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.FULL_OBSTACLE,
                                         _position,
                                         _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);
    case RegionMapInformation.RegionState.MIXED_OBSTACLE:                  
        // Return mixed obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                        _position,
                                        _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);
    default:
        return null;
  }//end switch
}//end checkRegion