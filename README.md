# lunulata.io

Hugo project for [kressi.github.io](https://github.com/kressi/kressi.github.io).

## Dependencies

- Target `tidy` depends on https://www.html-tidy.org/
- Target `check` depends on `npm` package `htmlproofer` https://github.com/gjtorikian/html-proofer

## Build and deploy

Site is deployed to submodule `kressi.github.io` in `public` folder.

```bash
$ make deploy
```
