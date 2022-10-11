SUBDIRS := Julius OpenHSP OpenJTalk
OBJS := julius.deb openhsp.deb openjtalk.deb

.PHONY: all
all: $(OBJS)

$(OBJS): $(SUBDIRS)
	./contrib/compose_deb.sh

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	make -C $@ $(MAKEFLAGS) $(MAKECMDGOALS)

