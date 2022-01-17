## setup prowlarr

login to the webui

#### Indexers

Head over to Indexers -> Add

- add indexers to your liking

#### Download Clients
Settings -> Download Clients

###### rtorrent-flood
- select option flood
- Host: rtorrent-flood
- UrlBase: /
- Username/Password ( as you set in ../rtorrent-flood/README.md )

###### nzbget 
- select option nzbget
- Host: nzbget
- Category: emtpy

#### Apps
Settings -> Apps

###### Radarr
- prowlar host: http://prowlarr:9696
- radar host:   http://radarr:7878
- api key - copy from radarr Settings -> General

###### Sonarr
- prowlar host: http://prowlarr:9696
- radar host:   http://sonarr:8989
- api key - copy from sonarr Settings -> General