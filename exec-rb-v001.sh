#!/bin/bash

# docker-compose.yml で定義したサービス名
SVC=rb
 
# オプション解析
ARGENV=()
while getopts :e:p:c:f:t:vV OPT; do
  case $OPT in
    e) ARGENV=(${ARGENV[@]} "-e $OPTARG") ;; # 環境変数を「-e」で繋げていく
    p) ARGPRJ=$OPTARG ;;       #! Dockerコンテナ内でのプロジェクトのディレクトリ名 (例: ./$SVC/src/main )
    c) CLIMODE="cli"
       break ;;      
    f) ARGDCY=$OPTARG ;;       #! docker-compose.yml が別名の場合
    v) ARGDBGL="1"    ;;       #! 弱デバッグモード
    V) ARGDBGL="1"
       ARGDBGH="1"    ;;       #! 強デバッグモード
    t) ARGMODE="$OPTARG" ;;    #! init, run, build,...etc
    :) echo "Mission arg: -$OPTARG" >&2; exit 1 ;;    # オプション引数がない (OPT = :)
    *) echo "Unknown option: -$OPTARG" >&2; exit 1 ;; # 不正なオプション (OPT = ?)
  esac
done

test "$CLIMODE" = "cli" && {
  shift $((OPTIND - 2)) 
} || {
  shift $((OPTIND - 1)) 
}

# -f は, docker-compose.yml という名称以外の場合に使用する.
test -z "$ARGDCY" && ARGDCY="docker-compose.yml"

test ! -z "$ARGDBGH" && {
  echo "[-e] ARGENV  => ${ARGENV[@]}"
  echo "[-p] ARGPRJ  => $ARGPRJ"
  echo "[-f] ARGDCY  => $ARGDCY"
  echo "[-t] ARGMODE => $ARGMODE"
  echo "[-c] ARGMODE => $@"
}

# -p で指定できるディレクトリは「./$SVC/src/main」か「$SVC/src/main」のみとする.
# 「././$SVC/src/main」や絶対パス指定はエラーとする.
case $ARGPRJ in
  /*) echo "Error: absolute path not allowed: ARGPRJ => <$ARGPRJ>"
      exit 2 ;;
  ..) echo "Error: could not specify a different layer: ARGPRJ => <$ARGPRJ>"
      exit 2 ;;
  ././*) echo "Error: enter the dot duplicate not allowed: ARGPRJ => <$ARGPRJ>"
      exit 2 ;;
  ./*) DKRPRJ=`echo $ARGPRJ | sed 's%^./%/%g'` ;;
  *) DKRPRJ="/$ARGPRJ" ;;
esac

test ! -f $ARGDCY && {
  echo 'ERROR: could not found ./docker-compose.yml'
  exit 3
}
 
# ここでの ARGCLI に指定したコマンドが、コンテナ内部で実行される.
case "$ARGMODE" in
  *) # -c オプションで指定されたコマンド
    test ! -z "$DKRPRJ" && {
      ARGCLI="test -d $DKRPRJ && cd $DKRPRJ && $@"
    } || {
      ARGCLI="$@"
    }
    ;;
esac

# docker-compose exec <環境変数> <SVC> <コマンド> を実行する
docker-compose exec ${ARGENV[@]} $SVC bash -c "
  test ! -z \"$ARGDBGL\" && set -x
  eval $ARGCLI || {
      # eval $ARGCLI に失敗した場合
      echo \"[$ARGMODE]:ERROR: eval $ARGCLI\"
      test ! -z \"$ARGDBGL\" && set +x
      test ! -z \"$ARGDBGH\" && {
        echo \"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\"
        echo \"Debug Information \"
        echo \"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\"
        echo \"----------------------------------------------------------------\"
        echo \"# pwd\"
        echo \"----------------------------------------------------------------\"
        pwd
        echo \"----------------------------------------------------------------\"
        echo \"# env\"
        echo \"----------------------------------------------------------------\"
        env
      }
      exit 9
  }
  test ! -z \"$ARGDBGL\" && set +x
  test ! -z \"$ARGDBGH\" && {
    echo \"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\"
    echo \"Debug Information \"
    echo \"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\"
    echo \"----------------------------------------------------------------\"
    echo \"# pwd\"
    echo \"----------------------------------------------------------------\"
    pwd
    echo \"----------------------------------------------------------------\"
    echo \"# env\"
    echo \"----------------------------------------------------------------\"
    env
  }
"
test $? -ne 0 && {
    test ! -z "$ARGDBGH" && {
      echo "----------------------------------------------------------------"
      echo "\$ tree ./PV/$SVC --charset=C -a"
      tree ./PV/$SVC --charset=C -a
    }
    exit 44
}

test ! -z "$ARGDBGH" && {
  echo "----------------------------------------------------------------"
  echo "\$ tree ./PV/$SVC --charset=C -a"
  tree ./PV/$SVC --charset=C -a
}

