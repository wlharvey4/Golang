# MAKEFILE FILE CHUNKS
######################

# VARIABLE DEFINITIONS
######################
LODESTONE := .lodestone

SHELL := /usr/local/bin/bash

FILE  := Golang
ROOT  := $(PWD)
FILES := workspace

# DEFAULT Target
################
.PHONY : TWJR JRTANGLE TANGLE JRWEAVE WEAVE TEXI INFO PDF HTML
.PHONY : default twjr twjrkeep jrtangle tangle
.PHONY : jrweave weave texi info pdf html newmakefile
.PHONY : files

default : TWJR

# TWJR TARGETS
##############

# <------------------------------------->
#               twjrkeep

# Process everything; don't remove any build or log files;
twjrkeep : jrtangle jrweave info pdf html


# <------------------------------------->
#                 TWJR
#                DEFAULT

# Process everything; remove build files and logs.

TWJR : twjr
twjr : twjrkeep dirclean


# <------------------------------------->
#               JRTANGLE

# JRTANGLE depends upon the LODESTONE and the ROOT FILES directory;
# if either is missing or out of date, then JRTANGLE will be run to
# extract its files.

JRTANGLE : TANGLE
TANGLE   : jrtangle
jrtangle : tangle
tangle   : $(LODESTONE) files


# <------------------------------------->
#               LODESTONE

# Checks the relative time to determine if JRTANGLE should be rerun

$(LODESTONE) : $(FILE).twjr
	@printf "${YELLOW}Tangling $(FILE)...${CLEAR}\n"
	@jrtangle $(FILE).twjr
	@touch $(LODESTONE)
	@printf "${GREEN}done tangling.${CLEAR}\n"


# <------------------------------------->
#                files

# Checks for  the existence  of the ROOT/FILES  directory; extracts  files into
# them if they don't  exist or are out of date; they must  be retouched if they
# exist but  are out of date  because they will  not be remade or  updated when
# files are extracted into them

files : $(ROOT)/$(FILES)
$(ROOT)/$(FILES) :  $(FILE).twjr
	@printf "${YELLOW}Creating files...${CLEAR}\n"
	@touch $(FILE).twjr
	@make $(LODESTONE)
	@touch $(ROOT)/$(FILES)
	@printf "${GREEN}done creating files.${CLEAR}\n"


# <------------------------------------->
#              newmakefile

# Extracts the Makefile if necessary by tangling; everything else
# is thereafter deleted

newmakefile : $(LODESTONE) allclean


# <------------------------------------->
#              JRWEAVE

# Extracts the TEXI, and updates the nodes and sections with a batch call to
# Emacs; it depends upon TWJR

JRWEAVE : WEAVE
WEAVE   : TEXI
TEXI    : jrweave
jrweave : weave
weave   : texi
texi    : $(FILE).texi
$(FILE).texi : $(FILE).twjr
	@printf "${YELLOW}Weaving $(FILE)...${CLEAR}\n"
	@jrweave $(FILE).twjr > $(FILE).texi
	@printf "${GREEN}done weaving.${CLEAR}\n";
	@printf "${YELLOW}updating $(FILE)'s menus and nodes...${CLEAR}\n"
	@emacs --batch --eval '(progn (find-file "./$(FILE).texi" nil) \
	  (texinfo-master-menu 1) (save-buffer 0))' 2> batch.log
	@printf "${GREEN}done updating.${CLEAR}\n"


# <------------------------------------->
#                 INFO
#               OPENINFO

# Runs makeinfo on the TEXI file;
# Opens the INFO file in Emacs

INFO : info
info : $(FILE).info
$(FILE).info : $(FILE).texi
	@printf "${YELLOW}Creating an INFO file...${CLEAR}\n"
	@makeinfo $(FILE).texi
	@printf "${GREEN}done${CLEAR}\n"
openinfo : INFO
	@printf "${YELLOW}Opening INFO in Emacs...${CLEAR}\n"
	@emacsclient -s server --eval '(info "($(ROOT)/$(FILE).info)top")'
	@printf "${GREEN}done${CLEAR}\n"


# <------------------------------------->
#                  PDF
#                OPENPDF

# Runs pdftexi2dvi on the TEXI file;
# Opens the PDF file

PDF : pdf
pdf : $(FILE).pdf
$(FILE).pdf : $(FILE).texi
	@printf "${YELLOW}Creating a PDF file...${CLEAR}\n"
	@pdftexi2dvi --build=tidy --build-dir=build --quiet $(FILE).texi
	@printf "${GREEN}done${CLEAR}\n"
openpdf : PDF
	@printf "${YELLOW}Opening PDF...${CLEAR}\n"
	@open $(FILE).pdf
	@printf "${GREEN}done${CLEAR}\n"


# <------------------------------------->
#                 HTML
#               OPENHTML

# Runs makeinfo --html on the TEXI file;
# Opens index.html in a browser

HTML : html
html : $(FILE)/index.html
$(FILE)/index.html : $(FILE).texi
	@printf "${YELLOW}Creating an HTML directory...${CLEAR}\n"
	@makeinfo --html $(FILE).texi
	@printf "${GREEN}done${CLEAR}\n"
openhtml : HTML
	@printf "${YELLOW}Opening INDEX.HTML in the browser...${CLEAR}\n"
	@open $(FILE)/index.html
	@printf "${GREEN}done${CLEAR}\n"

# CLEAN TARGETS
################
.PHONY : clean dirclean distclean worldclean allclean

# <------------------------------------->
#                clean

# remove backup files

clean :
	@printf "${WHITEBOLD}Cleaning...${CYAN}\n"
	@rm -f *~ .*~ #*#
	@printf "${GREEN}done cleaning.${CLEAR}\n"


# <------------------------------------->
#               dirclean

# after clean: remove all build and miscellaneous files, leaving only
# TWJR, TEXI, INFO, HTML, PDF, Makefile & the source documents.

dirclean : clean
	@printf "${WHITEBOLD}Dir-cleaning...${CYAN}\n"
	@for file in *; do         \
	  case $$file in           \
	    $(FILE)* | Makefile) ;;\
	    $(FILES)*)	 	 ;;\
	    $(LODESTONE))        ;;\
	    *) rm -vfr $$file	 ;;\
	  esac                     \
	done
	@printf "${GREEN}done dir-cleaning.${CLEAR}\n"


# <------------------------------------->
#                distclean

# after dirclean: remove INFO, HTML, and PDF, and FILES

distclean : dirclean
	@printf "${WHITEBOLD}Dist-cleaning...${CYAN}\n"
	@rm -vfr $(FILE) $(FILE).info $(FILE).pdf $(ROOT)/$(FILES)
	@printf "${GREEN}done dist-cleaning.${CLEAR}\n"


# <------------------------------------->
#                allclean

# allclean: remove TEXI, leaving only TWJR and Makefile

allclean : distclean
	@printf "${WHITEBOLD}Cleaning all...${CYAN}\n"
	@rm -vfr $(FILE).texi
	@printf "${GREEN}done cleaning all.${CLEAR}\n"

# APPLICATION TARGETS
######################

# APPLICATION: HELLO, WORLD!
############################
.PHONY   : hello.go buildhello insttallhello runhello hello-world

# <------------------------------------->
#              hello.go

# installs the source

hello.go : $(ROOT)/$(FILES)/src/hello/hello.go
$(ROOT)/$(FILES)/src/hello/hello.go : $(FILE).twjr
	@touch $(FILE).twjr
	@make $(LODESTONE)


# <------------------------------------->
#               buildhello

# builds an executable from the source

buildhello : $(ROOT)/$(FILES)/src/hello/hello
$(ROOT)/$(FILES)/src/hello/hello : $(ROOT)/$(FILES)/src/hello/hello.go $(FILE).twjr
	@printf "${YELLOW}Building 'hello' from 'hello.go'..."
	@cd $(ROOT)/$(FILES)/src/hello && go build hello && printf "${GREEN}done.${CLEAR}\n" || printf "${RED}failed.${CLEAR}\n"


# <------------------------------------->
#              installhello

# installs the executable into the 'bin' directory;
# because the 'install' command can move the executable from one directory into
# another, the rule below is convulated as it tries to avoid recompiling unless
# necessary, by checking for an executable in, first the 'src/hello' directory,
# and then the 'bin' directory.

installhello : $(ROOT)/$(FILES)/bin/hello
$(ROOT)/$(FILES)/bin/hello : $(FILE).twjr hello.go
	@printf "${YELLOW}Installing \'hello\' executable in \'bin/\'...${CLEAR}\n"
	@[ -e ${ROOT}/${FILES}/src/hello/hello ] && \
	{\
	    printf "${BLUE}\'hello\' executable exists in \'src/hello\'; moving it into \'bin\'...${CLEAR}"; \
	    cd ${ROOT}/${FILES}/src/hello && \
	    {\
		printf "${GREEN}successfully cd\'ed into \'...src/hello\'; now moving it...${CLEAR}"; \
		go install && \
		    printf "${GREEN}done moving.${CLEAR}\n" || \
		    printf "${RED}failed to move.${CLEAR}\n"; \
	    } || printf "${RED}unable to cd to into .src/hello${CLEAR}\n"; \
	} || {\
	    printf "${PURPLE}\'hello\' executable does not exist in \'...src/hello/\' so checking \'...bin/\'...${CLEAR}"; \
	    [ -e ${ROOT}/${FILES}/bin/hello ] && \
	    {\
	        printf "${BLUE}\'hello\' executable exists in \'bin/\'${CLEAR}\n"; \
	    } || {\
		printf "${PURPLE}\'hello\' executable does not exist in \'...bin/\'...${CLEAR}\n"; \
		printf "${BLUE}compiling and installing...${CLEAR}"; \
		go install hello && printf "${GREEN}successfully compiled and installed \'hello\' executable in \'...bin/\'.${CLEAR}\n"; \
	    };\
	}
	@printf "${GREEN}done installing.${CLEAR}\n"


# <------------------------------------->
#               hello-world

# run the executable 'hello'

hello-world : installhello
	@printf "${YELLOW}Executing \'hello\' with manual compilation...${CLEAR}\n"
	@{ cd $(ROOT)/$(FILES)/bin; \
	  ./hello && \
	    printf "${GREEN}done.${CLEAR}\n" || \
	    printf "${RED}failed.${CLEAR}\n"; \
	}

run-hello-world : hello.go
	@printf "${YELLOW}Executing \'go run hello\' with automatic compilation...${CLEAR}\n"
	@go run hello && \
	    printf "${GREEN}done.${CLEAR}\n" || \
	    printf "${RED}failed.${CLEAR}\n"



