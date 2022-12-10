type position = int * int

type direction = int * int

type turn =
  | Left
  | UTurn
  | Right
  | Straight

type rule = turn array

type ant = {
    rule : rule;
    mutable position : position;
    mutable direction : direction;
  }

type grid = int array array

type state = {

    colors : int;
    
    grid_width : int;
    grid_height : int;
    grid : grid;

    ant : ant;
    
    img_width : int;
    img_height : int;
    img: Rgb24.t
  }

let initialize_state ?(gw=1000) ?(gh=1000) ?(iw=1000) ?(ih=1000) rule_str =
  let colors = String.length rule_str in
  
  let rule = Array.make colors Left in
  let read_char i c =
    rule.(i) <- match c with
                | 'L' -> Left
                | 'U' -> UTurn
                | 'R' -> Right
                | 'S' -> Straight
                | _ -> Left in
  String.iteri read_char rule_str;
  
  let grid_width = max gw iw in
  let grid_height = max gh ih in
  
  let grid = Array.make_matrix gw gh 0 in
  
  let i = grid_width / 2 in
  let j = grid_height / 2 in
  let position = (i,j) in
  let direction = (1,0) in

  let ant = {rule; position; direction} in
  
  let img_width = iw in
  let img_height = ih in
  let c = color_list.(0) in
  let img = Rgb24.make img_width img_height c in

  {colors; grid_width; grid_height; grid; ant; img_width; img_height; img}
