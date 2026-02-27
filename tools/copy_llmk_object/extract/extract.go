package extract

import (
	"github.com/BurntSushi/toml"
	"os"
	"path"
	"log"
)

type config struct {
	Source []string `toml:"source"`
}

func ExtractSourcesInLLMKToml(cwd string) ([]string, error) {
	llmk_toml_path := path.Join(cwd, "llmk.toml")
	tomlData, err := os.ReadFile(llmk_toml_path)
	if err != nil {
		return nil, err
	}
	var conf config
	_, err = toml.Decode(string(tomlData), &conf)
	if err != nil {
		return nil, err
	}
	log.Printf("source files found: %v.\n", conf.Source)
	return conf.Source, nil
}
