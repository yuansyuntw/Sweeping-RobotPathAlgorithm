
//------------------------------------------------------------------------------------------
String ZPath(int _startX, int _startY, int _endX, int _endY, int _density){
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

//------------------------------------------------------------------------------------------
int[][] cyclePath(boolean[] _map,int _mapWidth, int _mapHeight, int _startPoint){
  //Copy array.
  boolean[] _pathMap = new boolean[_map.length];
  int[] backPoints = new int[_map.length];
  for(int i=0;i<_pathMap.length;i++){
    _pathMap[i] = _map[i];
    backPoints[i] = 0;
  }
  
  int resultSize = 9999;
  int [][]result = new int[resultSize][2];
  int pathCounter = 1;
  
  int selectPoint = _startPoint;
  backPoints[_startPoint] = -1;
  
  
  //print("_map length = "+_map.length+"\n");
  
  //Save start point.
  _pathMap[selectPoint] = false;
  //Save point x.
  result[pathCounter][0] = selectPoint%_mapWidth - _mapWidth/2;
  //Save point y.
  result[pathCounter][1] = selectPoint/_mapWidth - _mapHeight/2;
  print("["+pathCounter+"] = (" + result[pathCounter][0]+","+result[pathCounter][1]+") start\n");
  pathCounter += 1;
  
  
  
  //This is dfs.
  while(true){
    
    // right, down, left and up is cycle order.
    if(readArray(_pathMap, selectPoint+1)){
      //right
      backPoints[selectPoint+1] = selectPoint;
      selectPoint += 1;
      //backPathCounter = 0;
    }else if(readArray(_pathMap, selectPoint+_mapWidth)){
      //down
      backPoints[selectPoint+_mapWidth] = selectPoint;
      selectPoint += _mapWidth;
      //backPathCounter = 0;
    }else if(readArray(_pathMap, selectPoint-1)){
      //left
      backPoints[selectPoint-1] = selectPoint;
      selectPoint -= 1;
      //backPathCounter = 0;
    }else if(readArray(_pathMap, selectPoint-_mapWidth)){
      //up
      backPoints[selectPoint-_mapWidth] = selectPoint;
      selectPoint -= _mapWidth;
      //backPathCounter = 0;
    }else {
      
      //Back postion
      selectPoint = backPoints[selectPoint]; 
      if(selectPoint==-1) break;//Back to start Point.
      //Save point x.
      result[pathCounter][0] = selectPoint%_mapWidth - _mapWidth/2;
      //Save point y.
      result[pathCounter][1] = selectPoint/_mapWidth - _mapHeight/2;
      print("["+pathCounter+"] = (" + result[pathCounter][0]+","+result[pathCounter][1] + ")\n");
      pathCounter += 1;
      continue;
    }//end if
    
    if(pathCounter >= resultSize) break;
    
    //print("Select point = " + selectPoint + " pathCounter = " + pathCounter + "\n");
    _pathMap[selectPoint] = false;
    //Save point x.
    result[pathCounter][0] = selectPoint%_mapWidth - _mapWidth/2;
    //Save point y.
    result[pathCounter][1] = selectPoint/_mapWidth - _mapHeight/2;
    print("["+pathCounter+"] = (" + result[pathCounter][0]+","+result[pathCounter][1]+") forward \n");
    pathCounter += 1;
    
    if(selectPoint == _startPoint) break;
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