THIS_SCRIPT_DIR="$(cd "$( dirname "$0" )" && pwd)"

echo "**This script is switching you to ocaml 4.02.3 for the subsequent bspacking. Please switch back to your own version afterward. Thanks!**\n"
# switch to 4.02.3. Bspacking means we're sending the final bundle to BuckleScript, which is still on 4.02
opam switch 4.06.1

# =============
# first step, build ocaml-migrate-parsetree
# =============
eval $(opam config env)

OMP_ARTIFACTS_DIR="$THIS_SCRIPT_DIR/ocaml-migrate-parsetree"

rm -rf $OMP_ARTIFACTS_DIR
mkdir $OMP_ARTIFACTS_DIR

# ocaml-migrate-parsetree uses jbuilder to build, and having jBuilder inside the
# reason repo clashes with reason's own jbuilder build
TEMP_DIR_FOR_OMP=`mktemp -d`
echo "cloning ocaml-migrate-parsetree into $TEMP_DIR_FOR_OMP"
git clone https://github.com/ocaml-ppx/ocaml-migrate-parsetree.git $TEMP_DIR_FOR_OMP

pushd $TEMP_DIR_FOR_OMP

# pin it at a certain commit
git checkout 458a7d48cc5d88863a4092e984a8146118796e63
# if there's any error, check if you have everything installed. You should
# already from opam pin-ing the reason repo (which depends on ocaml-migrate-parsetree)
make

pushd ./_build/default/src

rm -rf ./*.cm*
rm -rf ./*.o
rm -rf ./*.a

# # bspack needs the fully processed files with ppx already applied to them, and
# # jBuilder keeps them around in files like `x.pp.ml`, so rename them to `x.ml`
for i in ./*.pp.{ml,mli}; do mv $i ${i/.pp/}; done

popd
popd

mv $TEMP_DIR_FOR_OMP/* $OMP_ARTIFACTS_DIR

# =============
# second step, download google closure compiler
# =============
# CLOSURE_COMPILER_DIR="$THIS_SCRIPT_DIR/closure-compiler"

# mkdir -p $CLOSURE_COMPILER_DIR
# pushd $CLOSURE_COMPILER_DIR
# curl -O http://dl.google.com/closure-compiler/compiler-20170910.tar.gz
# tar -xzf compiler-20170910.tar.gz

# popd
