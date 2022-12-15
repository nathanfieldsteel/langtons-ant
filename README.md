# langtons-ant

This is the repo for the code I used to make [this video](https://www.youtube.com/watch?v=_77IJkAHhaE).

Be aware that I didn't really write this code with anyone but myself in mind. So it's not particularly user-friendly.

## Setting things up

To compile, you'll need [OCaml](https://ocaml.org/) of course, and you'll need to have the [CamlImages](https://opam.ocaml.org/packages/camlimages/) package installed. Compile with:

`ocamlfind ocamlopt -o ant -linkpkg -package camlimages.core -package camlimages.png ant.ml`

This code makes a system call to `ffmpeg`, so to use this code as-is you will need to have `ffmpeg` installed too. However, it's fairly easy to excise that system call from the source code and recompile, and the resulting binary will only produce the animation frames. Then you can use the frames however you want.

## Usage

The resulting binary takes three arguments:

+ the rule, a string consisting of the characters `R`, `L`, `U` and `S` (Right, Left, U-Turn and Straight)
+ the number of frames to be generated
+ the number of steps for the ant to take

As written, it produces a 60FPS video. So if you want your video to be `n` seconds long, you will need to generate `60 * n` frames.

The number of steps to take to produce a nice visualization of a given rule varies wildly and can really only be found through experimentation. For the clips in the video linked above, the number of steps ranged from around `100_000_000` to around `10_000_000_000`.

### Example

To make a 10-second video showing an ant with rule `RLLLR` taking `100_000_000` steps, you would use:

`./ant RLLLR 600 100_000_000`

Be prepared to wait. The actual Langton's ant code is fairly high-performance, so the bulk of the time is spent writing images and calling `ffmpeg`. For example, on my system (an M1 MacBook Air) this example took about `11.5` minutes.

Just running the ant for `100_000_000` steps but producing no images or video takes `8.31` seconds. So it seems to be the bottleneck is in writing the frames and in the `ffmpeg` call at the end. An example with around `10_000_000_000` steps and `600` frames took about `37` minutes. Be prepared to wait a bit. You can watch as the files are written to the directory to get an idea of how much progress it's made.

## Notes

The last line of the source code is

`animation_frames 20000 20000 (2*3840) (2*2160);;`

This means that by default, the ant runs on a `20_000 x 20_000` grid, the central `(2*3840) x (2*2160)` entries of which are used to generate the resulting frames. These values can be changed and the code recompiled, if needed:

### Image dimensions

`(2*3840) x (2*2160)` is twice the resolution of standard 4K video, so there's some loss of fidelity when `ffmpeg` stitches the frames into a video with resolution `3840 x 2160`.

If you instead want a video where each pixel corresponds to a square in the ant's grid, you'd want only the central `3840 x 2160` pixels to be used when generating frames. However, since some compression and artifacting is inevitable, the final video still won't have pixel-perfect fidelity to the ant's behavior, and in practice I find such videos are "too zoomed in" to show many interesting features of the ant's path and the patterns it generates. But if this is what you want, you could change the last line to

`animation_frames 20000 20000 3840 2160;;`

and recompile.

It is also possible to use the central `(4*3840)x(4*2160)` entries of the grid to generate the frames, resulting in a "more zoomed out" video showing even more large-scale structures, at the cost of slightly more loss when the images are processed into a 4K video. This will also make the code run much slower, as it takes roughly 4x longer to write such images. In any case, this change can be accomplished by editing the last line like so

`animation_frames 20000 20000 (4*3840) (4*2160);;`

and recompiling. All of the clips in the video linked above were made using a factor of `2` or `4` in the image dimensions. You can use any dimensions you want when generating frames, but you may run into trouble using `ffmpeg` when using frames of arbitrary sizes.

### Grid sizes

If the ant leaves the `20_000 x 20_000` grid, the simulation will stop. All frames generated from that point onwards will be identical, and the resulting animation will appear to freeze. If this becomes an issue, you can increase the size of the grid. Be warned that this can quickly eat up a lot of memory. Even as written, the binary uses over 3GB of RAM while running. Changing the grid size to `40_000 x 40_000` pushes ram usage up to around 12GB. Take care.

### Colors

The colors are randomly generated, though the first color (the color the image is initialized to and which corresponds to the first instruction in the ant's rule string) is always `#000000`.

If you would like to use a custom color scheme, replace the definition of `color_list` with an explicit definition, such as

`let color_list = [|"#000000"; "#ff0000"; "#00ff00"; "#1144ff"|] |> Array.map Color.color_parse`

and recompile.

### Image file sizes

When producing an animation where the frames have resolution `(2*3840) x (2*2160)`, the size of the frames, which are PNG files, can grow quite large (easily 12MB+ each). So for an animation with thousands of frames, be prepared to have plenty of storage space available for the frames. In the example above, running `./ant RLLR 600 100_000_000` wrote 3.8 GB to disk.
