package generated_files

import (
	"fmt"
	"path"
	"strings"
)

func ListGeneratedFiles(sources []string) []string {
	generatedFiles := make([]string, 0)
	for _, src := range sources {
		stem := strings.TrimSuffix(src, path.Ext(src))
		generatedFiles = append(generatedFiles,
			// TODO: use const and share with main.usage()
			fmt.Sprintf("%s.pdf", stem),
			fmt.Sprintf("%s.aux", stem),
			fmt.Sprintf("%s.bbl", stem),
			fmt.Sprintf("%s.bcf", stem),
			fmt.Sprintf("%s-blx.bib", stem),
			fmt.Sprintf("%s.blg", stem),
			fmt.Sprintf("%s.fls", stem),
			fmt.Sprintf("%s.idx", stem),
			fmt.Sprintf("%s.ilg", stem),
			fmt.Sprintf("%s.ind", stem),
			fmt.Sprintf("%s.lof", stem),
			fmt.Sprintf("%s.log", stem),
			fmt.Sprintf("%s.lot", stem),
			fmt.Sprintf("%s.nav", stem),
			fmt.Sprintf("%s.out", stem),
			fmt.Sprintf("%s.run.xml", stem),
			fmt.Sprintf("%s.snm", stem),
			fmt.Sprintf("%s.toc", stem),
			fmt.Sprintf("%s.vrb", stem),
		)
	}
	return generatedFiles
}
