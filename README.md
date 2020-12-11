## DNMP (Docker、Nginx、MySQL Cluster、PHP) 範例 (Swarm 版)




### 調整 Project 設定 (project name, uid, gid)
### System user 或 group，uid & gid 範圍請參考 SYS_UID_MIN & SYS_GID_MIN (/etc/login.defs)
### 注意: PROJECT_GROUP 是獨立的，PROJECT_GID 不要和 PROJECT_UID 相同，名稱也一樣
.env


### Project user 預設是 root，若需要新增 project user 可執行下面指令 (請先調整 .env)
[root]# ./usr/local/create_system_project_user.sh


### Nginx 設定
將 etc/nginx119/conf.d/samples/994-demo.conf 複製到 etc/nginx119/conf.d/vhosts 底下
並修改 server_name 為 127.0.0.1 或你自己的 domain (localhost 是 nginx 的預設值，請不要使用，或自行調整預設值 etc/nginx119/conf.d/default.conf)

若不想使用 root 執行，請修改 ./etc/nginx119/nginx.conf 裡的 user 設定


### MySQL 設定 (phpMyAdmin)
先到 https://www.phpmyadmin.net/ 下載最新版本 phpMyAdmin
解壓縮到 volumes/htdocs 底下
將資料夾名稱改為 phpMyAdmin，複製 config.sample.inc.php 存成 config.inc.php，並將 $cfg['Servers'][$i]['host'] 設定改為 mysql80 (docker-compose.yml 裡 services 定義的名稱)
複製 nginx 裡 995-phpMyAdmin.conf 設定 (請參考 Nginx 設定)
預設的登入帳密是 root / root (可以到 ./env/mysql80 更改預設密碼)


### PHP 設定
若不想使用預設的身份 (www-data) 執行，請修改 ./etc/php73-fpm.d/www.conf 裡的 user 設定


### 部署
請將該資料夾放到每一台要部署的 server 上 (路徑要一致)
選定一台 server 當 manager node (docker swarm init)
其它 server 加入 swarm (docker swarm join)
若該 node 要負責執行 php & nginx 請增加 ap label (docker node update --label-add="type=ap" {node})
若該 node 要負責執行 mysql 請增加 db label (docker node update --label-add="type=db" {node})
DB 預設有 4 個 role 請增加對應的 label (docker node update --label-add="db_role=(mgm_1 | ndb_1 | ndb_2 | api_1)" {node})


### 啟動
在 manager node 上，此資料夾下，執行
$ docker stack deploy -c docker-compose.yml {stack_name}


### 畫面檢視
http://{your-domain}:9080	// Web
https://{your-domain}:9443	// phpMyAdmin


### 關閉
在 manager node 上，此資料夾下，執行
$ docker stack rm {stack_name}




#### 注意事項 (目前 Mysql Cluster 在 swarm 模式有問題，待研究解決)
1. 使用 Swarm 模式，無法使用 build，請將會使用到的 image 都先 push 到 docker hub 或 local registry 上，並調整 docker-compose 裡的 image 來源
2. PHP 預設沒有安裝 mysqli extension (phpMyAdmin 需要)，請自行 build services/php73，並 push 到 registry 上
3. 避免使用 aliases，因為 swarm 無法使用 depends_on，在該 service 啟動前，使用 aliases 會導致找不到該 service，而發生錯誤
4. Nginx 與 PHP 最好是在同一台 host，否則請確保兩邊的 htdocs 一致
