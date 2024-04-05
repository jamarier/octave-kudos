#Projecto kudos de octave
# (C) 2013 Javier M. Mora-Merchan et al.
# Bajo licencia BSD 3-Clause License

INPUTDIR = experimentos
SRCDIR = src
BINDIR = bin
DOCDIR = doc
OUTPUTDIR= build
OUTPUTDIREXP = $(OUTPUTDIR)/experimentos


ORIGINALES= $(shell find $(INPUTDIR) -iname "exp_*.expm")
PROCESADO= $(ORIGINALES:.expm=.m)

GENERADOS+= listaexperimentos.m
GENERADOS+= indice.m
GENERADOS+= pista.m
GENERADOS+= glosario.m

GRAFO+= casos.dot
GRAFO_GENERADO = $(GRAFO:.dot=.dot.pdf)

BLOQUES+= $(INPUTDIR)/.
#BLOQUES+= $(INPUTDIR)/debug
BLOQUES+= $(INPUTDIR)/octave
BLOQUES+= $(INPUTDIR)/programacion

BORRABLE+= octave-core
BORRABLE+= *~
BORRABLE+= $(GENERADOS)
BORRABLE+= $(GRAFO)
BORRABLE+= $(GRAFO_GENERADO)

DATE = $(shell date +%Y%m%d)
ZIPDIR = octavekudos-$(DATE)
COMPRIMIDO = $(ZIPDIR).zip

ZIPSRCDIR = octavekudossrc-$(DATE)
SRCCOMPRIMIDO = $(ZIPSRCDIR).zip

.PHONY: all
all: build $(GRAFO_GENERADO) 

.PHONY: build
build: $(PROCESADO) $(GENERADOS)
	mkdir -p $(OUTPUTDIR) $(OUTPUTDIREXP)
	cp -r $(SRCDIR)/* $(OUTPUTDIR)
	mv $(addsuffix /*.m, $(BLOQUES)) $(OUTPUTDIREXP)
	mv $(GENERADOS) $(OUTPUTDIREXP)

%.dot.pdf: %.dot
	dot -O -Tpdf $<

exp_%.m: exp_%.expm $(BINDIR)/creaexperimentos.pl
	perl $(BINDIR)/creaexperimentos.pl $<

$(GENERADOS) $(GRAFO): $(PROCESADO) $(BINDIR)/ordenaexperimentos.pl
	perl $(BINDIR)/ordenaexperimentos.pl $(BLOQUES)

$(COMPRIMIDO): build
	rm -f $(ZIPDIR) $@
	ln -s $(OUTPUTDIR) $(ZIPDIR)
	cp $(SRCDIR)/octavekudos-LEEME.txt .
	zip $@ $(ZIPDIR)/* octavekudos-LEEME.txt
	rm -f $(ZIPDIR)
	rm -f octavekudos-LEEME.txt

$(SRCCOMPRIMIDO): 
	rm -rf $(ZIPSRCDIR) $@
	mkdir $(ZIPSRCDIR)
	cp -r $(BINDIR) $(ZIPSRCDIR)
	cp -r $(SRCDIR) $(ZIPSRCDIR)
	cp -r $(INPUTDIR) $(ZIPSRCDIR)
	cp -r $(DOCDIR) $(ZIPSRCDIR)
	cp Makefile $(ZIPSRCDIR)

	zip -mrT $@ $(ZIPSRCDIR)
	rm -rf $(ZIPSRCDIR)

.PHONY: zip 
zip: $(COMPRIMIDO)

.PHONY: zipsrc
zipsrc: $(SRCCOMPRIMIDO)

.PHONY: clean
clean:
	rm -rf $(PROCESADO) 
	rm -rf $(BORRABLE)

.PHONY: veryclean
veryclean: clean
	rm -rf $(OUTPUTDIR)



