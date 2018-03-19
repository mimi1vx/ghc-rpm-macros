#!/bin/sh
# find rpm provides and requires for Haskell GHC libraries

[ $# -ne 2 ] && echo "Usage: `basename $0` [--provides|--requires] %{buildroot}%{ghclibdir}" && exit 1

set +x

mode=$1
pkgbasedir=$2
pkgconfdir=$pkgbasedir/package.conf.d

ghc_pkg="/usr/lib/rpm/ghc-pkg-wrapper $pkgbasedir"

case $mode in
    --provides) field=id ;;
    --requires) field=depends ;;
    *) echo "`basename $0`: Need --provides or --requires" ; exit 1
esac

ghc_ver=$(basename $pkgbasedir | sed -e s/ghc-//)

files=$(cat)

#cabal_ver=$(ghc-pkg --global --simple-output list Cabal | sed -e "s/Cabal-//")

for i in $files; do
    case $i in
        # exclude builtin_rts.conf
	$pkgconfdir/*-*.conf)
            case $ghc_ver in
                8.*) id=$(grep "id: " $i | sed -e "s/id: //") ;;
                *) id=$(echo $i | sed -e "s%$pkgconfdir/%%" -e "s%.conf%%") ;;
            esac
	    ids=$($ghc_pkg field $id $field | sed -e "s/rts//" -e "s/bin-package-db-[^ ]\+//")

	    for d in $ids; do
		case $d in
		    *-*) echo "ghc-devel($d)" ;;
		    *) ;;
		esac
	    done
	    ;;
        *)
            ;;
    esac
done
