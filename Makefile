NAME    = loader
SRC_ASM = $(wildcard src/*.s)
SRC_C   = $(wildcard src/*.c)
OBJ     = $(addprefix build/, $(SRC_C:.c=.o) $(SRC_ASM:.s=.o))

all: $(NAME)

$(NAME): $(OBJ)
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -e _start $(OBJ) -o $(NAME)

build/%.o: %.s
	mkdir -p $(shell dirname $@)
	nasm -f elf64 $< -o $@

#build/%.o: %.c
#	mkdir -p $(shell dirname $@)
#	gcc -c $< -o $@

clean:
	rm -rf build/*

fclean: clean
	rm -rf $(NAME)

re: fclean all
