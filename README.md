

download file https://drive.google.com/drive/folders/1ZOGt2t6zG8STnWR5WLxdMabHEtsDEMJa?usp=share_link
Copy thư mục gama ra Project chính


docker-compose build

docker-compose up -d

docker exec -it gama_php bash 

composer install

php artisan migrate

php artisan db:seed

php artisan key:generate



open mysql workbench with similar below config 

![img.png](img.png)

username and password: gama_user

import db from file GamaBE.sql -->
