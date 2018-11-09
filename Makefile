# MAKEFILE FILE CHUNKS
######################

# VARIABLE DEFINITIONS
######################
LODESTONE := .lodestone

SHELL := /opt/local/bin/bash

FILE  := Golang
ROOT  := $(PWD)
FILES := workspace

# DEFAULT Target
################
.PHONY : TWJR JRTANGLE TANGLE JRWEAVE WEAVE TEXI INFO PDF HTML
.PHONY : default twjr twjrkeep jrtangle tangle
.PHONY : jrweave weave texi info pdf html newmakefile

default : TWJR

# TWJR TARGETS
##############

# Process everything; don't remove any build or log files;
twjrkeep : jrtangle jrweave info pdf html

# Process everything; remove build files and logs.
TWJR : twjr
twjr : twjrkeep dirclean

# JRTANGLE depends upon the LODESTONE and the ROOT FILES directory;
# if either is missing or out of date, then JRTANGLE will be run to
# extract its files.
JRTANGLE : TANGLE
TANGLE   : jrtangle
jrtangle : tangle
tangle   : $(LODESTONE) $(ROOT)/$(FILES)
$(LODESTONE) : $(FILE).twjr
	@printf "${YELLOW}Tangling $(FILE)...${CLEAR}\n"
	@jrtangle $(FILE).twjr
	@touch $(LODESTONE)
	@printf "${GREEN}done tangling.${CLEAR}\n"

# Extracts the source files using jrtangle
$(ROOT)/$(FILES) :
	@jrtangle $(FILE).twjr
	@touch $(LODESTONE)

# Extracts the Makefile if necessary by tangling; everything else
# is thereafter deleted
newmakefile : $(LODESTONE)
	make allclean

# Extracts the TEXI, and updates the nodes and sections with a batch call to
# Emacs; it depends upon TWJR
JRWEAVE : WEAVE
WEAVE   : jrweave
jrweave : weave
weave : TEXI
TEXI  : texi
texi  : $(FILE).texi
$(FILE).texi : $(FILE).twjr
	@printf "${YELLOW}Weaving $(FILE)...${CLEAR}\n"
	@jrweave $(FILE).twjr > $(FILE).texi
	@printf "${GREEN}done weaving.${CLEAR}\n";
	@printf "${YELLOW}updating $(FILE)'s menus and nodes...${CLEAR}\n"
	@emacs --batch --eval '(progn (find-file "./$(FILE).texi" nil) \
	  (texinfo-master-menu 1) (save-buffer 0))' 2> batch.log
	@printf "${GREEN}done updating.${CLEAR}\n"

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

.PHONY : clean dirclean distclean worldclean allclean

# remove backup files
clean :
	@printf "${WHITEBOLD}Cleaning...${CYAN}\n"
	@rm -f *~ .*~ #*#
	@printf "${GREEN}done cleaning.${CLEAR}\n"

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

# after dirclean: remove INFO, HTML, and PDF, and FILES
distclean : dirclean
	@printf "${WHITEBOLD}Dist-cleaning...${CYAN}\n"
	@rm -vfr $(FILE) $(FILE).info $(FILE).pdf $(ROOT)/$(FILES)
	@printf "${GREEN}done dist-cleaning.${CLEAR}\n"

# allclean: remove TEXI, leaving only TWJR and Makefile
allclean : distclean
	@printf "${WHITEBOLD}Cleaning all...${CYAN}\n"
	@rm -vfr $(FILE).texi
	@printf "${GREEN}done cleaning all.${CLEAR}\n"

# Go Hello World
################
.PHONY   : hello.go buildhello insttallhello runhello hello-world

# installs the source
hello.go : $(ROOT)/$(FILES)/src/hello/hello.go
$(ROOT)/$(FILES)/src/hello/hello.go :
	make JRTANGLE

# builds an executable from the source
buildhello : $(ROOT)/$(FILES)/src/hello/hello
$(ROOT)/$(FILES)/src/hello/hello : $(ROOT)/$(FILES)/src/hello/hello.go
	@printf "${YELLOW}Building 'hello' from 'hello.go'..."
	@cd $(ROOT)/$(FILES)/src/hello && go build && printf "${GREEN}done.\n"

# installs the executable into the 'bin' directory
installhello : $(ROOT)/$(FILES)/bin/hello
$(ROOT)/$(FILES)/bin/hello :
	@if ! [ -e $(ROOT)/$(FILES)/bin/hello ]; then make buildhello; fi
	@printf "${YELLOW}Installing 'hello' executable in 'bin/'..."
	@cd $(ROOT)/$(FILES)/src/hello && go install && printf "${GREEN}done.\n"

# run the executable 'hello'
hello-world : installhello
	@printf "${YELLOW}Executing 'hello'...${CLEAR}\n"
	@{ cd $(ROOT)/$(FILES)/bin; \
	  ./hello; \
	  printf "${GREEN}done.${CLEAR}"; \
	}



