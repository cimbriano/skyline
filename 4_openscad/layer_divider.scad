module layer_divider(x, y, z, trans_z){
  translate([0, 0, trans_z]){
    cube([x, y, z]);
  }
}
