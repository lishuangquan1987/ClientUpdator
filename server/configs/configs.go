package configs

import (
	"github.com/fsnotify/fsnotify"
	"github.com/utils-go/ngo/io/file"
	"gopkg.in/yaml.v3"
	"io/ioutil"
	"log"
	"os"
)

var Config ConfigStruct
var configFile string = "config.yml"

func init() {
	loadConfig()
	//检测文件变化
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatalf("create file watcher error")
	}
	go func() {
		for {
			select {
			case <-watcher.Events:
				loadConfig()
				log.Printf("检测到server.yml变化。重新加载配置文件：%v", Config)
			}
		}
	}()
	err = watcher.Add(configFile)
	if err != nil {
		log.Fatalf("watch %s error:%v", configFile, err)
	}
}
func loadConfig() {
	f, err := os.Open(configFile)
	if err != nil {
		log.Fatalf("open file fail:%v", err)
	}
	content, err := ioutil.ReadAll(f)
	if err != nil {
		log.Fatalf("read file fail:%v", err)
	}

	err = yaml.Unmarshal(content, &Config)
	if err != nil {
		log.Fatalf("error:%v", err)
	}
}

type ConfigStruct struct {
	Version      string          `yaml:"Version"`
	ForceUpdate  bool            `yaml:"ForceUpdate"`
	ChangeLogs   []ChangeLogInfo `yaml:"ChangeLogs"`
	WatchFolder  string          `yaml:"WatchFolder"`
	IgnoreFolder []string        `yaml:"IgnoreFolder"`
	IgnoreFile   []string        `yaml:"IgnoreFile"`
}
type ChangeLogInfo struct {
	Version string   `yaml:"Version"`
	Logs    []string `yaml:"Logs"`
	Time    string   `yaml:"Time"`
}

func SaveConfig(cfg ConfigStruct) error {
	data, err := yaml.Marshal(cfg)
	if err != nil {
		return err
	}
	return file.WriteAllText(configFile, string(data))
}
