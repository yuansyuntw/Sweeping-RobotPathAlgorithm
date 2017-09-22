
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