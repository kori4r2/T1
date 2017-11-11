CFLAGS = -g -Wall -O3
LINKFLAGS = -fopenmp
PROJECT = GaussJordan
CC = mpicc
DEBUGDIR = tests
BINDIR = bin
SRCDIR = src
LIBDIR = lib
SERVERFILES := $(wildcard remoteFiles/*)
LIBS := $(wildcard $(LIBDIR)/*h)
SRCS := $(wildcard $(SRCDIR)/*c)
OBJS := $(patsubst $(SRCDIR)/%.c, $(BINDIR)/%.o, $(SRCS))

all : build

build : $(BINDIR) $(OBJS)
	$(CC) $(LINKFLAGS) $(OBJS) -o $(PROJECT)

$(DEBUGDIR) :
	mkdir -p $(DEBUGDIR)

$(BINDIR) :
	mkdir -p $(BINDIR)

$(BINDIR)/%.o : $(SRCDIR)/%.c $(LIBS)
	$(CC) -c $< -I $(LIBDIR) $(CFLAGS) -o $@

sendfiles : build
	scp -P 22200 $(PROJECT) $(SERVERFILES) gpra07@halley.lasdpc.icmc.usp.br:/home/gpra07/

clean :
	rm -rf $(BINDIR)
	rm -rf $(DEBUGDIR)
	rm -f $(PROJECT).zip
	rm -f $(PROJECT)
	rm -f debug*.txt
	clear

run :
	./$(PROJECT)

.zip : clean
	zip $(PROJECT).zip $(SRCS) $(LIBS) Makefile *.pdf

debug: $(DEBUGDIR) all
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(PROJECT) > $(DEBUGDIR)/output.txt 2> $(DEBUGDIR)/error.txt
	diff resultadoCorreto.txt $(DEBUGDIR)/output.txt > $(DEBUGDIR)/diff.txt
