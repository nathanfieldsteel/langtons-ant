open Camlimages
open Random
open Png

let rule = Sys.argv.(0)

let color_list =
  let open Random in
  Random.self_init ();
  let open Color in
  let rec random_colors n =
    match n with
    | 1 -> [{r=0;g=0;b=0}]
    | n -> {r = int 256;g=int 256;b=int 256} :: (random_colors (n-1)) in
  rule
  |> String.length
  |> random_colors
  |> List.rev
  |> Array.of_list

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

let rotate t a =
  let (u,v) = a.direction in
  match t with
  | Left -> a.direction <- (v, -u)
  | UTurn -> a.direction <- (-u, -v)
  | Right -> a.direction <- (-v, u)
  | Straight -> a.direction <- (u, v)

let move a =
  let (i,j) = a.position in
  let (u,v) = a.direction in
  a.position <- (i + u, j + v)

let in_img i j s =
  let gw = s.grid_width in
  let gh = s.grid_height in
  let iw = s.img_width in
  let ih = s.img_height in
  
  (gw - iw) / 2 <= i
  && i < iw + (gw - iw)/2
  && (gh - ih) / 2 <= j
  && j < ih + (gh - ih) / 2

let img_coords i j s =
  let gw = s.grid_width in
  let gh = s.grid_height in
  let iw = s.img_width in
  let ih = s.img_height in
  (i - ((gw - iw)/2),
   j - ((gh - ih)/2))

let change_color s =
  let (i,j) = s.ant.position in
  let color = s.grid.(i).(j) in
  let next_color = if color = (s.colors - 1)
                   then 0
                   else color + 1 in
  s.grid.(i).(j) <- next_color;
  if in_img i j s
  then (let (p,q) = img_coords i j s in
        Rgb24.set s.img p q color_list.(next_color))
  else ()

let step s =

  let (i,j) = s.ant.position in

  let gw = s.grid_width in
  let gh = s.grid_height in
  
  if (0 <= i && i < gw && 0 <= j && j < gh)
  then (let c = s.grid.(i).(j) in
        let t = s.ant.rule.(c) in

        rotate t s.ant;

        change_color s;

        move s.ant)
  else ()
