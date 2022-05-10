# vk-recognizetext

> Recognize text from images.

Wafer-thin wrapper for performaing OCR on image files using Vision.Framework `VNRecognizeTextRequest` API requests. Detected text is written to `stdout` so you can `grep` your JPEGs.

## Build

```
$ git clone [...]
$ cd vk-recognizetext
$ make
```

## Usage

```
$ ./vk-recognizetext [--json] <file1> <file2> <file...>
$ ./vk-recognizetext test.png
$ ./vk-recognizetext --json ~/Downloads/*.pdf
$ ./wget -q https://upload.wikimedia.org/wikipedia/commons/6/6f/Keep-calm-and-carry-on-scan.jpg && ./vk-recognizetext Keep-calm-and-carry-on-scan.jpg
KEEP
CALM
AND
CARRY
ON
```

## License

MIT © 2022 [Ingve Vormestrand](https://github.com/ingve)
