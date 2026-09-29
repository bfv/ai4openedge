
.PHONY: build ci compile

ANTEXE=$(DLC)/ant/bin/ant -lib $(DLC)/pct/PCT.jar \
	-logger org.apache.tools.ant.listener.AnsiColorLogger \
	-Dant.logger.defaults=off \
	-DAnsiColorLogger.WARNING_COLOR=34

build:
	$(ANTEXE) -buildfile build.xml

ci:
	$(ANTEXE) ci

compile:
	$(ANTEXE) -Dsources=$(sources) compileSources
	$(ANTEXE) -Dsources=$(sources) unittestSources

