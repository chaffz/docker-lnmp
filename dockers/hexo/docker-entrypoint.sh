#!/bin/sh

if [[ -z "$HEXO_GIT_USER" ]]; then
    echo "ERROR: missing mandatory config: HEXO_GIT_USER"
    exit 1
fi

if [[ -z "$HEXO_GIT_EMAIL" ]]; then
    echo "ERROR: missing mandatory config: HEXO_GIT_EMAIL"
    exit 1
fi

git config --global user.name $HEXO_GIT_USER
git config --global user.email $HEXO_GIT_EMAIL

if [[ "$HEXO_TYPE" = "s" ]]; then
    set -- /usr/bin/hexo s -p 80
fi

if [[ "$HEXO_TYPE" = "d" ]]; then
    set -- /usr/bin/hexo cl && /usr/bin/hexo d -g
fi

exec "$@"
