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
