# tex-to-gif
Convert a TeX document :page_with_curl: into an animation GIF :tv:

![example](https://raw.githubusercontent.com/ymyzk/tex-to-gif-example/master/animation.gif)

## How to use?
```
$ ./tex-to-gif.sh --help
usage: tex-to-gif.sh [options]

Options:
  -h, --help    show help
  -y, --yes     say 'yes' to all prompts

TeX Options:
  --tex-build <command>     how to build a document
  --tex-commits <command>   how to make a list of commits
  --tex-pdf <path>          path of PDF file

Montage Options:
  --image-geometry <geometry>   preferred tile and border sizes
  --image-tile <geometry>       number of tiles per row and column

Animation Options:
  --animation-delay <value>     display the next image after pausing
  --animation-file <path>       path of animation GIF file
```

## Example
See [ymyzk/tex-to-gif-example](https://github.com/ymyzk/tex-to-gif-example)
