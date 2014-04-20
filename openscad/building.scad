module building(width, depth, height, trans_x, trans_y, trans_z){
  translate([trans_x, trans_y, trans_z]) {
    cube([width, depth, height]);
  };
}
