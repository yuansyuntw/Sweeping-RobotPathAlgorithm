class ConnectionInformation{
  
  private RegionMapInformation originalRegion;
  private RegionMapInformation connectRegion;
  private int weight;
  private int connectX;
  private int connectY;
  
  ConnectionInformation(RegionMapInformation _oriReg, RegionMapInformation _connReg, int _weight, int _x, int _y){
    originalRegion = _oriReg;
    connectRegion = _connReg;
    weight = _weight;
    connectX = _x;
    connectY = _y;
  }//end constructor
  
  public RegionMapInformation getOriginalRegion(){return originalRegion;}
  public RegionMapInformation getConnectRegion() {return connectRegion;}
  public int getWeight()  {return weight;}
  public int getConnectX() {return connectX;}
  public int getConnectY() {return connectY;}
  
}//end ConnectInformation

//------------------------------------------------------------------------------------------
RegionMapInformation createConnectRegion(RegionMapInformation _map, int _startX, int _startY, int _state){
  RegionMapInformation selectRegion = findRegionPoint( _map, _startX, _startY);
  
  //Start Point is not region area.
  if(selectRegion == null) return null;
  
  if(selectRegion.getRegionState() != _state) return selectRegion;
  
  ConnectionInformation[] connectArray = new ConnectionInformation[selectRegion.getRegionWidth()*2 + selectRegion.getRegionHeight()*2];
  int connectIndex = 0;
  
  int selectX;
  int selectY;
  RegionMapInformation findRightRegion, findTopRegion, findDownRegion, findLeftRegion;
  
  //Explore the top and down.
  selectX = selectRegion.getLUPointX();
  selectY = selectRegion.getLUPointY();
  //print("select point = ("+selectX+","+selectY+")\n");
  for(int i=0;i<selectRegion.getRegionWidth();i++){
    findTopRegion = findRegionPoint(_map, selectX+i,selectY-1);
    //print("find point = ("+(selectX+i)+","+(selectY-1)+") = "+ findTopRegion+"\n");
    findDownRegion = findRegionPoint(_map, selectX+i, selectY + selectRegion.getRegionHeight());
    //print("find point = ("+(selectX+i)+","+(selectY + selectRegion.getRegionHeight()+1)+") = "+ findDownRegion+"\n");
    
    if((findTopRegion != null)&&(findTopRegion.getRegionState() == _state)){
      connectArray[connectIndex] = new ConnectionInformation(selectRegion, findTopRegion, findTopRegion.getRegionArea(), selectX+i, selectY);
      connectIndex += 1;
    }//end if
    if((findDownRegion != null&&(findDownRegion.getRegionState() == _state))){
      connectArray[connectIndex] = new ConnectionInformation(selectRegion, findDownRegion, findDownRegion.getRegionArea(), selectX+i, selectY + selectRegion.getRegionHeight());
      connectIndex += 1;
    }//end if
  }//end for
  
  //Explore the left and right.
  selectX = selectRegion.getLUPointX();
  selectY = selectRegion.getLUPointY();
  for(int i=0;i<selectRegion.getRegionHeight();i++){
    findLeftRegion = findRegionPoint(_map, selectX-1,selectY+i);
    //print("find point = ("+(selectX-1)+","+(selectY+i)+") = "+ findLeftRegion+"\n");
    findRightRegion = findRegionPoint(_map, selectX+selectRegion.getRegionWidth()+1, selectY+i);
    //print("find point = ("+(selectX+selectRegion.getRegionWidth()+1)+","+(selectY+i)+") = "+ findRightRegion+"\n");
    
    if((findLeftRegion != null)&&(findLeftRegion.getRegionState() == _state)){
      connectArray[connectIndex] = new ConnectionInformation(selectRegion, findLeftRegion, findLeftRegion.getRegionArea(), selectX, selectY+i);
      connectIndex += 1;
    }//end if
    if((findRightRegion != null)&&(findRightRegion.getRegionState() == _state)){
      connectArray[connectIndex] = new ConnectionInformation(selectRegion, findRightRegion, findRightRegion.getRegionArea(), selectX+selectRegion.getRegionWidth(), selectY+i);
      connectIndex += 1;
    }//end if
  }//end for
  
  selectRegion.setConnectionRegion(connectArray);
  return selectRegion;
}