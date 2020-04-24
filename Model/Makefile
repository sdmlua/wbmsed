.PHONY: all

all: _CMlib _MFlib _WBMplus

_CMlib:
        $(MAKE) -C CMlib all

_MFlib:
        $(MAKE) -C MFlib all

_WBMplus:
        $(MAKE) -C WBMplus all

LIBS = CMlib MFlib WBMplus
.PHONY: clean $(LIBS)
$(LIBS):
        $(MAKE) -C $@ clean

clean: $(LIBS)

