use <../../4_openscad/area.scad>;
use <../../4_openscad/layer.scad>;
use <../../4_openscad/layer_divider.scad>;
use <../../4_openscad/window.scad>;

area(56, 50);
translate([5, 0, 0]) {
  union() {
    difference(){
      union(){
        layer(20, 20, 3, 0, 0, 0);
        window(4, 4, 2, 8.0, 15, 2);
        window(4, 4, 2, 13.0, 15, 2);
      }
      window(4, 4, 2, 3.0, 15, 2);
      window(4, 4, 2, 3.0, 10, 2);
      window(4, 4, 2, 8.0, 10, 2);
      window(4, 4, 2, 13.0, 10, 2);
      window(4, 4, 2, 3.0, 5, 2);
      window(4, 4, 2, 8.0, 5, 2);
      window(4, 4, 2, 13.0, 5, 2);
    }
    difference(){
      union(){
        layer(20, 20, 3, 0, 20, 0);
        window(4, 4, 2, 3.0, 35, 2);
        window(4, 4, 2, 8.0, 35, 2);
        window(4, 4, 2, 3.0, 30, 2);
        window(4, 4, 2, 8.0, 30, 2);
      }
      window(4, 4, 2, 13.0, 35, 2);
      window(4, 4, 2, 13.0, 30, 2);
      window(4, 4, 2, 3.0, 25, 2);
      window(4, 4, 2, 8.0, 25, 2);
      window(4, 4, 2, 13.0, 25, 2);
    }
  }
}
translate([30, 0, 0]) {
  union() {
    difference(){
      union(){
        layer(21, 21, 6, 0, 0, 0);
        window(4, 4, 2, 1.0, 11, 5);
        window(4, 4, 2, 16.0, 11, 5);
        window(4, 4, 2, 1.0, 6, 5);
        window(4, 4, 2, 11.0, 6, 5);
        window(4, 4, 2, 16.0, 6, 5);
      }
      window(4, 4, 2, 1.0, 16, 5);
      window(4, 4, 2, 6.0, 16, 5);
      window(4, 4, 2, 11.0, 16, 5);
      window(4, 4, 2, 16.0, 16, 5);
      window(4, 4, 2, 6.0, 11, 5);
      window(4, 4, 2, 11.0, 11, 5);
      window(4, 4, 2, 6.0, 6, 5);
    }
    difference(){
      union(){
        layer(21, 21, 6, 0, 21, 0);
        window(4, 4, 2, 6.0, 37, 5);
        window(4, 4, 2, 1.0, 32, 5);
        window(4, 4, 2, 6.0, 32, 5);
        window(4, 4, 2, 11.0, 32, 5);
        window(4, 4, 2, 1.0, 27, 5);
      }
      window(4, 4, 2, 1.0, 37, 5);
      window(4, 4, 2, 11.0, 37, 5);
      window(4, 4, 2, 16.0, 37, 5);
      window(4, 4, 2, 16.0, 32, 5);
      window(4, 4, 2, 6.0, 27, 5);
      window(4, 4, 2, 11.0, 27, 5);
      window(4, 4, 2, 16.0, 27, 5);
    }
  }
}
