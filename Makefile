ARM_CC ?= arm-linux-gnueabihf-gcc
ARM_CFLAGS = -c -g -Wall -Wextra -O0 -mfpu=neon
ARM_LDFLAGS = -Wall -g -Wextra -O0

EXEC = main_arm main_arm_pre
GIT_HOOKS := .git/hooks/applied
.PHONY: all
all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

main_arm: $(GIT_HOOKS) main.c
	$(ARM_CC) $(ARM_CFLAGS) -DARM -o main_arm.o main.c
	$(ARM_CC) $(ARM_LDFLAGS) -o main_arm main_arm.o

main_arm_pre: $(GIT_HOOKS) main.c
	$(ARM_CC) $(ARM_CFLAGS) -DARM_PRE -o main_arm.o main.c
	$(ARM_CC) $(ARM_LDFLAGS) -o main_arm_pre main_arm.o

cache-test: $(EXEC)
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./main_arm
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./main_arm_pre


.PHONY: clean
clean:
	$(RM) main_arm main_arm_pre
