# elvish-libs

## Requirements

- Supported platforms: Linux
- Python3, modules: virtualenv

## Installation

Execute once:
```
use epm
epm:install github.com/gergelyk/elvish-libs
```

Put this in your `~/.elvish/rc.elv`:
```
use github.com/gergelyk/elvish-libs/python
python:init-auto-venv-activation .venv
var venv~ = $python:venv-activate~
var pyeval~ = $python:pyeval~
```

## Usage

### Virtualenv Activation

Virtualenv will be activated whenever you cd into directory with .venv and deactivated whenever you leave it.

You can also activate/deactivate it manually:
```
venv /path/to/your/venv  # activate
venv -                   # deactivate
```

### Code Evaluation

```
pyeval [&] z=10+20 # ▶ [&z=(num 30.0)]
```
```
var res: = (ns (pyeval [&x=(num 123) &y=(num 2)] 'z = x / y'))
echo $res:z  # 61.5
```
```
fn dv {|x y| { put (pyeval [&x=(num $x) &y=(num $y)] 'z = x / y')[z] } }
dv 123 2  # ▶ (num 61.5)
dv 123 0  # exception
```
