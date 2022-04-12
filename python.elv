use str
use path

var curr-venv

# Assert elvish version
if (not-eq [(str:split . $version)][..2] [0 18]) {
    fail 'Incompatible elvish version'
}

fn venv-activate {|path|
  # Activate/deactivate venv under given path
  # examples:
  # venv-activate /path/to/my/.venv # activate
  # venv-activate -                 # deactivate

  if (eq $path -) {
    if (is $curr-venv $nil) {
      return
    } else {
      echo (styled "== Deactivating venv: "$curr-venv green)
      var new-paths = []
      var curr-venv-bin = $curr-venv/bin
      for p $paths {
        if (not-eq $p $curr-venv-bin) {
          set new-paths = [$@new-paths $p]
        }
      }
      set paths = $new-paths
      set curr-venv = $nil
      set edit:rprompt = { put "" }
    }
  } else {
    venv-activate -
    if (not (path:is-dir $path)) {
      echo (styled "== Creating venv: "$path green)
      python3 -m virtualenv $path
    }
    set curr-venv = (path:abs $path)
    echo (styled "== Activating venv: "$curr-venv green)
    var curr-venv-bin = $curr-venv/bin
    set paths = [$curr-venv-bin $@paths]
    set edit:rprompt = { styled (path:base $path) inverse }
  }
  var text = (echo "Active python3:" (which python3))
  echo (styled $text blue)
}

fn init-auto-venv-activation {|venv-name|
  # Activate venv if $venv-name dir exists.
  # Otherwise deactivate last venv.
  # Can be called multiple times.
  # example:
  # init-auto-venv-activation .venv

  fn watch-venv {
    if (path:is-dir $venv-name) {
      venv-activate $venv-name > nop
    } else {
      venv-activate - > nop
    }
  }

  # activate/deactivate after `cd` or interactive dir change
  set after-chdir = [$@after-chdir {|path| watch-venv }]

  # activate right away
  watch-venv
}

fn wrap-py-code {|code| put "
import json as _json
locals().update(_json.loads(input()))
"$code"
print(_json.dumps({k: v for k, v in locals().items() if not k.startswith('_')}))
"}

fn pyeval {|vars code|
  # evaluate code in python3
  # examples:
  #
  # var res: = (ns (pyeval [&x=(num 123) &y=(num 2)] 'z = x / y'))
  # echo $res:z  # 61.5
  #
  # fn dv {|x y| { put (pyeval [&x=(num $x) &y=(num $y)] 'z = x / y')[z] } }
  # dv 123 2  # ▶ (num 61.5)
  # dv 123 0  # exception

  put $vars | to-json | python3 -c (wrap-py-code $code) | from-json
}

