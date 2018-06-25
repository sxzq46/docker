#!/bin/bash
set -e
##
[ $# -gt 0 ] && JarName="$@"
if [ "x$JarName" == "x" ]; then
  JarName=$(find ${APP_HOME} -maxdepth 1 -name '*.[jw]ar' -print0)
fi

set -- java ${JAVA_OPTS} -jar ${JarName}

for appCfg in `echo ${appCfgs} | sed 's/,/ /g'`
do
  echo "etcdGet.py ${etcdClusterIp} /quarkfinance.com/instances/${instanceId}/${appCfg} ..."
  mkdir -p `dirname "${APP_HOME}/${appCfg}"`
  etcdGet.py "${etcdClusterIp}" "/quarkfinance.com/instances/${instanceId}/${appCfg}" "${APP_HOME}/${appCfg}"
  [ $? -ne 0 ] && echo "etcdGet.py ${etcdClusterIp} /quarkfinance.com/instances/${instanceId}/${appCfg} failure!" 1>&2 exit 1
  echo "etcdGet.py ${etcdClusterIp} /quarkfinance.com/instances/${instanceId}/${appCfg} success!"
done

# If GOSU_CHOWN environment variable set, recursively chown all specified directories
# to match the user:group set in GOSU_USER environment variable.
if [ -n "$GOSU_CHOWN" ]; then
    for DIR in $GOSU_CHOWN
    do
        chown -R $GOSU_USER $DIR
    done
fi

# If GOSU_USER environment variable set to something other than 0:0 (root:root),
# become user:group set within and exec command passed in args
if [ "$GOSU_USER" != "0:0" ]; then
    exec gosu $GOSU_USER "$@" 2>&1 | tee ${AppLogs}/appConsole.log
else
    # If GOSU_USER was 0:0 exec command passed in args without gosu (assume already root)
    exec "$@"
fi
