import 'dart:core';

class GridPos {
  int x, y;

  GridPos(this.x, this.y);
}

class ProbabilityGrid {
  List<double> cells;
  int csize;
  int width, height;


  ProbabilityGrid(this.csize, this.width, this.height) {
    var numberofcells = width*height;
    cells = new List(numberofcells);
    for(int i = 0; i < numberofcells; i++) {
      var x = (i%width)*csize/2;
      var y = (i/width).toInt()*csize/2;
      var p = 1.0/numberofcells;

      cells[i] = p;
    }
  }

  GridPos getPosFromIndex(int i) {
    var x = i%width;
    var y = (i/width).toInt();

    return GridPos(x, y);
  }

  GridPos getHighestProbPos() {
    var h = cells[0];
    var index = 0;
    for(int i = 0; i < width*height; i++) {
      if(cells[i] > h) {
        h = cells[i];
        index = i;
      }
    }

    return getPosFromIndex(index);
  }

  void setCircleProbabilty(double x, double y, double radius, double callback(double x, double y)) {

  }
}
