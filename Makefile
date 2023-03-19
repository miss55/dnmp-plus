
help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
load_nginx: ## load nginx image
	cd services/nginx && tar -zxf jenson_nginx_1_21_5.tar.jenson.tar.gz && mv jenson_nginx_1_21_5.tar.jenson jenson_nginx_1_21_5.tar && docker load -i jenson_nginx_1_21_5.tar && rm jenson_nginx_1_21_5.tar && docker images | grep nginx
test: ## test nginx config
	docker-compose exec nginx nginx -t
reload: ## reload nginx 
	docker-compose exec nginx nginx -s reload
