deploy:
	zola build && cd public && rsync . root@v:/var/www/mymaterials.ru -a

