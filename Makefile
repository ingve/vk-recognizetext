CC=clang
SDKROOT=$(shell xcrun --show-sdk-path)
OBJCOPTS=-Wall -Wextra -Wfatal-errors -fobjc-arc -isysroot $(SDKROOT)
FRAMEWORKS=-framework AppKit -framework CoreImage -framework Vision

all:
	$(CC) $(OBJCOPTS) $(FRAMEWORKS) -o vk-recognizetext vk-recognizetext.m
	
clean:
	$(RM) vk-recognizetext
