
//------------------------------------------------------------------------------------------
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
  private int STATE = RegionState.FULL_OBSTACLE;
  
  // Parent Region
  RegionMapInformation parentRegion;
  
  // COnection Region
  ConnectionInformation[] connectRegions;
  
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
  
  public void setConnectionRegion(ConnectionInformation[] _connectInfos){ connectRegions = _connectInfos; }
  public ConnectionInformation[] getConnectionRegions(){ return connectRegions; }
  
  public int getRegionWidth(){return (abs(RDPointX - LUPointX) + 1);}
  public int getRegionHeight(){return (abs(RDPointY - LUPointY) + 1);}
  public int getRegionArea(){ return(getRegionWidth() * getRegionHeight()); }
  
  public boolean isLeaf(){ return ((LURegion==null)&&(RURegion==null)&&(LDRegion==null)&&(RDRegion==null)); }
  
  //Constructor
  RegionMapInformation(int _state, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
    STATE = _state;
    LUPointX = _LUPointX;
    LUPointY = _LUPointY;
    RDPointX = _RDPointX;
    RDPointY = _RDPointY;
  }//end constructor
  
}//end Class

//------------------------------------------------------------------------------------------
int getStateRegions(RegionMapInformation _quadtree, RegionMapInformation [] _saveArray, int _state, int _index){
  int nextIndex = _index;
  
  if(_quadtree==null) return nextIndex;
  
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

//------------------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------------------
RegionMapInformation quadtreeCutting(PImage _image, float[] _mapArray, int _cutSize, int _originalLUPointX, int _originalLUPointY,
                                  int _originalRDPointX, int _originalRDPointY, int _gridWidth, int _gridHeight){
                                    
  RegionMapInformation resultMap;
  boolean DEBUG = false;
  int _regionWidth = abs(_originalRDPointX - _originalLUPointX) + 1 ;
  int _regionHeight = abs(_originalRDPointY - _originalLUPointY) + 1;
  
  //Cutting size is small.
  if((_regionWidth/2 < _cutSize) || (_regionHeight/2 < _cutSize)){
    //return null;
    resultMap = getRegionInformation(_mapArray, _gridWidth, _gridHeight,  _originalLUPointX,_originalLUPointY,_originalRDPointX,_originalRDPointY);
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
  RegionMapInformation _LURegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight,  LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY); 
  
  // Explore Right Up Region
  int RURegion_LUPointX = _originalLUPointX + halfWidth;
  int RURegion_LUPointY = _originalLUPointY;
  int RURegion_RDPointX = _originalLUPointX + _regionWidth - 1;
  int RURegion_RDPointY = _originalLUPointY + halfHeight - 1;
  RegionMapInformation _RURegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY);
  
  // Explore Left Down Region
  int LDRegion_LUPointX = _originalLUPointX;
  int LDRegion_LUPointY = _originalLUPointY + halfHeight;
  int LDRegion_RDPointX = _originalLUPointX + halfWidth - 1;
  int LDRegion_RDPointY = _originalLUPointY + _regionHeight - 1;
  RegionMapInformation _LDRegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY);
  
  // Explore Right Down Region
  int RDRegion_LUPointX = _originalLUPointX + halfWidth;
  int RDRegion_LUPointY = _originalLUPointY + halfHeight;
  int RDRegion_RDPointX = _originalLUPointX + _regionWidth - 1;
  int RDRegion_RDPointY = _originalLUPointY + _regionHeight - 1;
  RegionMapInformation _RDRegion = getRegionInformation(_mapArray, _gridWidth, _gridHeight, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY);

  // Determine whether the sub-region is empty-obstacle
  if(_LURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RURegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE && 
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.EMITY_OBSTACLE){
        
     resultMap =  new RegionMapInformation (RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    
  }else if (
      // Determine whether the sub-region is full-obstacle
      _LURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RURegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _LDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE &&
      _RDRegion.getRegionState() == RegionMapInformation.RegionState.FULL_OBSTACLE){
    
      resultMap = new RegionMapInformation (RegionMapInformation.RegionState.FULL_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    
  }else{
    resultMap = new RegionMapInformation (RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                                _originalLUPointX, _originalLUPointY,
                                                _originalLUPointX + _regionWidth, _originalLUPointY + _regionHeight);
    resultMap.setLURegion(quadtreeCutting(_image, _mapArray, _cutSize, LURegion_LUPointX, LURegion_LUPointY, LURegion_RDPointX, LURegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setRURegion(quadtreeCutting(_image, _mapArray, _cutSize, RURegion_LUPointX, RURegion_LUPointY, RURegion_RDPointX, RURegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setLDRegion(quadtreeCutting(_image, _mapArray, _cutSize, LDRegion_LUPointX, LDRegion_LUPointY, LDRegion_RDPointX, LDRegion_RDPointY, _gridWidth, _gridHeight));
    resultMap.setRDRegion(quadtreeCutting(_image, _mapArray, _cutSize, RDRegion_LUPointX, RDRegion_LUPointY, RDRegion_RDPointX, RDRegion_RDPointY, _gridWidth, _gridHeight));
  }//end if

  return resultMap;
}//end quadtreeCutting

//------------------------------------------------------------------------------------------
RegionMapInformation getRegionInformation(float[] _mapArray, int _gridWidth, int _gridHeight, int _LUPointX, int _LUPointY, int _RDPointX, int _RDPointY){
 
  switch(cutRectangleJudgment(_mapArray, _gridWidth, _gridHeight,_LUPointX, _LUPointY, _RDPointX, _RDPointY)){
    case RegionMapInformation.RegionState.EMITY_OBSTACLE:
        // Return emity obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.EMITY_OBSTACLE,
                                          _LUPointX, _LUPointY,
                                          _RDPointX, _RDPointY);
    case RegionMapInformation.RegionState.FULL_OBSTACLE:
        // Return full obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.FULL_OBSTACLE,
                                         _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);
    case RegionMapInformation.RegionState.MIXED_OBSTACLE:                  
        // Return mixed obstacle region information
        return new RegionMapInformation(RegionMapInformation.RegionState.MIXED_OBSTACLE,
                                        _LUPointX, _LUPointY,
                                        _RDPointX, _RDPointY);
    default:
        return null;
  }//end switch
}//end checkRegion

//------------------------------------------------------------------------------------------
RegionMapInformation findRegionPoint(RegionMapInformation _quadTree, int _pointX, int _pointY){
  if(_quadTree != null){
    
    if(inRegion(_quadTree, _pointX, _pointY)){
         
         if(_quadTree.isLeaf()){
           return _quadTree;
         }else{
           if(inRegion(_quadTree.getLURegion(), _pointX, _pointY)){
             return findRegionPoint(_quadTree.getLURegion(), _pointX, _pointY);
           }
           
           if(inRegion(_quadTree.getRURegion(), _pointX, _pointY)){
             return findRegionPoint(_quadTree.getRURegion(), _pointX, _pointY);
           }
           
           if(inRegion(_quadTree.getLDRegion(), _pointX, _pointY)){
             return findRegionPoint(_quadTree.getLDRegion(), _pointX, _pointY);
           }
           
           if(inRegion(_quadTree.getRDRegion(), _pointX, _pointY)){
             return findRegionPoint(_quadTree.getRDRegion(), _pointX, _pointY);
           }
           
           return null;
         }
    }//end if
  }//end if
  
  return null;
}//end findRegionPoint

//------------------------------------------------------------------------------------------
boolean inRegion(RegionMapInformation _region, int _pointX, int _pointY){
  if(_pointX >= _region.getLUPointX() && _pointX <= _region.getRDPointX() &&
     _pointY >= _region.getLUPointY() && _pointY <= _region.getRDPointY()){
     return true;  
  }
   
  return false;
}//end inRegion

//------------------------------------------------------------------------------------------
boolean [] grabPoints(RegionMapInformation[] _regions, int _arrayWidth, int _arrayHeight){
  boolean []result = new boolean[_arrayWidth * _arrayHeight];
  
  //Check region is or not is null
  if(_regions.length == 0){
    result = new boolean[1];
    result[0] = false;
    return result;
  }//end if
  
  for(int i=0;i<_regions.length;i++){
    
    if(_regions[i]!=null){
      //print("this is region[" + i +"]\n");
      
      int selectX = _regions[i].LUPointX;
      int selectY = _regions[i].LUPointY;
      
      int originalX = selectX;
      
      int indexX;
      if(_regions[i].LUPointX - _regions[i].RDPointX > 0){
        indexX = -1; //reverse
      }else{
        indexX = 1;
      }
      int indexY;
      if(_regions[i].LUPointY - _regions[i].RDPointY > 0){
        indexY = -1; //reverse
      }else{
        indexY = 1;
      }
      
      //print("test selectX = " + (_arrayWidth/2 - 0) + ", selectY = " + (_arrayHeight/2 - 0) +"\n");

      //result array default value is fasle. This is set to true;
      for(int j=0; j<_regions[i].getRegionHeight(); j++){
        for(int k=0; k<_regions[i].getRegionWidth(); k++){
          result[(_arrayWidth/2 + selectX) +(_arrayHeight/2 + selectY)*_arrayWidth] = true;
          selectX += indexX;
        }
        selectX = originalX;
        selectY += indexY;
      }//end for
    }//end if
  }//end for
  
  return result;
}//end grabPoints

//------------------------------------------------------------------------------------------
void connectRegions(RegionMapInformation _rootRegion, RegionMapInformation[] _regions){
  
  if(_regions.length<=0) return;
  
  //connect same state.
  int State = _regions[0].getRegionState();
  
  print("regions = " + _regions.length+"\n");
  for(int i=0;i<_regions.length;i++){
    //Create path tree
    createConnectRegion(_rootRegion, _regions[i].getLUPointX(), _regions[i].getLUPointY(), State);
  }
}

//------------------------------------------------------------------------------------------
RegionMapInformation[] getStateRegions(RegionMapInformation _rootReegion, int _state){ 
  // Find Emity Region
  RegionMapInformation[] tempRegions = new RegionMapInformation[1024];
  int regionsNumber = getStateRegions(_rootReegion, tempRegions, _state, 0);
  
  RegionMapInformation[] resultRegions = new RegionMapInformation[regionsNumber];
  for(int i=0;i<regionsNumber;i++){
    resultRegions[i] = tempRegions[i];
  }
  
  return resultRegions;
}