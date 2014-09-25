#!/bin/bash

export DOCKER_ZF2_ENV=${DOCKER_ZF2_ENV:-"DEV"}

INIT_CHECK_FILE="/etc/DOCKER-INITIALIZED"
ASSET_DIR_DEFAULT_ETC="/assets/_default/etc/."

PHP_MODS_DISABLE=(${PHP_MODS_DISABLE:-""})
PHP_MODS_ENABLE=(${PHP_MODS_ENABLE:-""})

function say() {
    echo "[DOCKER-ZF2] $1"
}


if [ ! -e "$INIT_CHECK_FILE" ]; then

    say "this container seems to be uninitialized"

    case "$DOCKER_ZF2_ENV" in
        "PROD")
            ASSET_DIR_ETC="/assets/prod/etc/."
            PHP_MODS_DEFAULT_DISABLE=( xdebug )
            PHP_MODS_DEFAULT_ENABLE=(  )
        ;;
        *)
            ASSET_DIR_ETC="/assets/dev/etc/."
            PHP_MODS_DEFAULT_DISABLE=(  )
            PHP_MODS_DEFAULT_ENABLE=(  )
        ;;
    esac

    say "copying default assets from $ASSET_DIR_DEFAULT_ETC"
    cp -rf $ASSET_DIR_DEFAULT_ETC /etc/

    say "copying assets from $ASSET_DIR_ETC"
    cp -rf $ASSET_DIR_ETC /etc/

    for MOD in $PHP_MODS_DEFAULT_DISABLE
    do
        say "(default) disable php5 module $MOD"
        php5dismod $MOD
    done

    for MOD in $PHP_MODS_DEFAULT_ENABLE
    do
        say "(default) enable php5 module $MOD"
        php5enmod $MOD
    done

    for MOD in $PHP_MODS_DISABLE
    do
        say "disable php5 module $MOD"
        php5dismod $MOD
    done

    for MOD in $PHP_MODS_ENABLE
    do
        say "enable php5 module $MOD"
        php5enmod $MOD
    done

    # apache configuration
    a2enmod rewrite
    a2dissite 000-default
    a2ensite zf2-app

    say "touching initialization file at $INIT_CHECK_FILE"
    touch $INIT_CHECK_FILE
    say "initialization finished"
fi

say "starting apache now"
# run apache
/usr/sbin/apache2 -D FOREGROUND
