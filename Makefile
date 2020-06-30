#
# FrankenJiffy Makefile
# Distributed under the GNU software license  
# (C) 2020 - Mark Seelye - mseelye@yahoo.com - 2020-06-20
#

# Release Version
VERSION = v0.1

# Determine what OS this is running on and adjust
OSUNAME := $(shell uname)
ifeq "$(OSUNAME)" "Darwin"
	ECHO := echo
	CC65_HOME := /usr/local
else ifeq "$(OSUNAME)" "Linux"
	ECHO := echo -e
	CC65_HOME := /usr
else # Windows
	ECHO := echo -e
	CC65_HOME := /usr/local/cc65
endif

# Target System
SYS ?= c64

# Required Executables
AS = $(CC65_HOME)/bin/ca65
CC = $(CC65_HOME)/bin/cc65
LD = $(CC65_HOME)/bin/ld65
MKDIR_P = mkdir -p

# Optional Executables
# c1541 - used to create d64 and d81 disk images
C1541_EXE := c1541
C1541 := "$(shell command -v $(C1541_EXE) 2> /dev/null)"
C1541_CONSIDER = "please consider installing vice/$(C1541_EXE) from https://vice-emu.sourceforge.io/"

# exomizer - used to crunch the program file
CRUNCHER_EXE = exomizerX
CRUNCHER = "$(shell command -v $(CRUNCHER_EXE) 2> /dev/null)"
CRUNCHER_CONSIDER = " please consider installing $(CRUNCHER_EXE) from https://bitbucket.org/magli143/exomizer/wiki/Home"
ifeq ("",$(CRUNCHER))
	CRUNCHER_EXT := 
else
	CRUNCHER_EXT := .sfx
endif

# Compiler flags
CRUNCHERFLAGS =  sfx sys -m 16384 -q -n
CFLAGS = --static-locals -Ors --codesize 500 -T -g -t $(SYS)

# Check for required executables
REQ_EXECUTABLES = $(AS) $(CC) $(LD)
K := $(foreach exec,$(REQ_EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "Required tool $(exec) not found in PATH")))

# Directories
OBJDIR = out
SRCDIR = src
BINDIR = bin
DISTDIR = dist

# Main target
TARGET = frankenjiffy
DIST = $(DISTDIR)/$(TARGET)

# Note: 16 character limit on filenames in a d64/d81 disk image
SOURCES  := $(wildcard $(SRCDIR)/*.c)
INCLUDES := $(wildcard $(SRCDIR)/*.h)
OBJECTS  := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
ASMS  := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

all: directories $(BINDIR)/$(TARGET) disk

%: %.c
%: %.s

# Link main target
$(BINDIR)/$(TARGET): $(OBJECTS)
	@$(ECHO) "*** Linking $<"
	$(LD) $(LDFLAGS) -o $@ -t $(SYS) -m $@.map $(OBJECTS) $(SYS).lib
ifeq ("",$(CRUNCHER))
	@$(ECHO) "*** Note: $(CRUNCHER_EXE) is not in PATH, cannot crunch $@, $(CRUNCHER_CONSIDER)"
else
	$(CRUNCHER) $(CRUNCHERFLAGS) -o $@$(CRUNCHER_EXT) $@
endif
	@$(ECHO) "*** Linking complete\n"

# Compile main target
$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.c $(INCLUDES)
	@$(ECHO) "*** Compiling $<"
	@cat $< | sed -e "$(DIST_SED)" > $<.tmp
	$(CC) $(CFLAGS) $<.tmp
	$(AS) $<.s -o $@
#	$(AS) $(<:.c =.s) -o $@
	@$(ECHO) "*** Compilation complete\n"
	@rm $<.tmp $<.s

# Create d64 disk
.PHONY: disk
disk:  $(DIST).d64
$(DIST).d64: $(BINDIR)/$(TARGET)
ifeq ("",$(C1541))
	@$(ECHO) "\n*** Note: c1541 is not in PATH, cannot build disk. $(C1541_CONSIDER)"
else
	@$(ECHO) "\n*** Building d64 disk...$@"
	@$(C1541) -format frankenjiffy,bh d64 $@
	@$(C1541) -attach $@ -write $(BINDIR)/$(TARGET)$(CRUNCHER_EXT) $(TARGET)
	@$(C1541) -attach $@ -write $(SRCDIR)/testfile1 testfile1
	@$(ECHO) "\n*** Disk Contents:"
	@$(C1541) -attach $@ -dir
	@$(ECHO) "\n*** Building d64 disk complete\n"
endif

# Cleans
.PHONY: clean
clean:
	-rm -rf $(OBJDIR)
	-rm -rf $(BINDIR)
	-rm -f $(SRCDIR)/$(TARGET).s

# Build out directories
.PHONY: directories
directories: $(OBJDIR) $(BINDIR) $(DISTDIR)
$(OBJDIR):
	@$(MKDIR_P) $(OBJDIR)
$(BINDIR):
	@$(MKDIR_P) $(BINDIR)
$(DISTDIR):
	@$(MKDIR_P) $(DISTDIR)
