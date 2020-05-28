export COB_LDFLAGS='-Wl,--no-as-needed'
cc -c cobsqlitedriver.c -g -lsqlite3
cobc -c   -x cobteste.cob  -g -std=mf
cobc -x -o cob1 cobsqlitedriver.o cobteste.o -lncurses -lsqlite3 -g -std=mf
