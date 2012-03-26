.PHONY: open clean

docs = report.pdf

TEX = xelatex
TEXFLAGS =

open: $(docs)
	xdg-open $^

%.pdf: %.tex
	$(TEX) $(TEXFLAGS) $<

clean:
	$(RM) $(foreach ext,.log .aux .pdf,$(addsuffix $(ext),$(basename $(docs))))

