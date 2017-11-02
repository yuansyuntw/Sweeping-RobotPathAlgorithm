class ConnectionInformation{
  
  private RegionMapInformation connectRegion;
  private int weight;
  private int connectX;
  private int connectY;
  
  ConnectionInformation(RegionMapInformation _connReg, int _weight, int _x, int _y){
    connectRegion = _connReg;
    weight = _weight;
    connectX = _x;
    connectY = _y;
  }//end constructor
  
  public RegionMapInformation getConnectRegion() {return connectRegion;}
  public int getWeight()  {return weight;}
  public int getConnectX() {return connectX;}
  public int getConnectY() {return connectY;}
  
}//end ConnectInformation