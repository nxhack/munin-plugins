#!/bin/bash
# Logstash Munin plugin
# Copyright (C) 2013 - Remy van Elst

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# I need a logstash /elasticsearch server

TIMEFRAME=60
MUNIN_PERIOD=5 #minutes

case $1 in
   config)
        cat <<'EOM'
graph_title Logstash Events Per Hour
graph_vlabel Events / Hour
events.label events
graph_scale no
graph_category logstash
graph_info The number of events the logstash server handles per hour
events.info Number of log events per 5 minutes.
EOM
        exit 0;;
esac

TOTAL_EVENTS=$(curl -s -k -XGET http://127.0.0.1:9200/logstash-`/bin/date -u --date "1 day ago" +%Y.%m.%d`,logstash-`/bin/date -u +%Y.%m.%d`/_search -d '{ "size": 0, "query": { "bool": { "must": { "match_all": { } }, "filter": { "range": { "@timestamp": { "from": "'`/bin/date -u --date "1 hours ago" +%Y-%m-%dT%H:00:00.000Z`'", "to": "'`/bin/date -u +%Y-%m-%dT%H:00:00.000Z`'" } } } } }, "from": 0, "sort": { "@timestamp": { "order": "desc" } }}' | /bin/grep --only \"hits\"\:\{\"total\"\:[0-9]*,\" | /bin/grep -o [0-9]*)

# Basic check to see if we get any logging...
if [[ $TOTAL_EVENTS -lt 1 ]]; then
    echo -n events.value U
    exit
fi

echo -n events.value $TOTAL_EVENTS
