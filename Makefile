CMPS_PATH	= -f ./docker-compose.yml

all : media build run

media :
	mkdir media

build :
	docker compose $(CMPS_PATH) build

run : 
	docker compose $(CMPS_PATH) up -d

stop :
	docker compose $(CMPS_PATH) stop

fclean :
	docker compose $(CMPS_PATH) down -v

re: fclean build run

.PHONY : all build run stop fclean re