
help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
load_nginx: ## load nginx image
	cd services/nginx && unzip jenson_nginx_1_21_5_2.zip && docker load -i jenson_nginx_1_21_5_2.tar && rm jenson_nginx_1_21_5_2.tar
test: ## test nginx config
	docker-compose exec nginx nginx -t
reload: ## reload nginx 
	docker-compose exec nginx nginx -s reload
