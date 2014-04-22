module window(x, y, z, trans_x, trans_y, trans_z){
  translate([trans_x, trans_y, trans_z]) {
    cube([x, y, z], false);
  }
}
