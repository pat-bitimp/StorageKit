@all:
	objfw-compile --arc --lib 0.0 -o storagekit src/*.m src/drivers/*/*m -lobjpgsql -lpq