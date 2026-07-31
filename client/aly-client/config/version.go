package config

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

const (
	VersionStatusDownloaded = "downloaded"
	VersionStatusApplying   = "applying"
	VersionStatusApplied    = "applied"
)

// VersionInfo represents the version.json structure.
type VersionInfo struct {
	VersionPrevious        string `json:"version_previous"`
	Version                string `json:"version"`
	VersionStatus          string `json:"version_status"`
	AfterApplyUpdateScript string `json:"after_apply_update_script,omitempty"`
}

func versionPath() (string, error) {
	dir, err := ExeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "version.json"), nil
}

// ReadVersion reads version.json; returns an empty struct if the file does not exist (first deploy).
func ReadVersion() (*VersionInfo, error) {
	path, err := versionPath()
	if err != nil {
		return nil, err
	}

	data, err := ioutilReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return &VersionInfo{}, nil
		}
		return nil, fmt.Errorf("读取 version.json 失败: %v", err)
	}

	var info VersionInfo
	if err := json.Unmarshal(data, &info); err != nil {
		return nil, fmt.Errorf("解析 version.json 失败: %v", err)
	}

	return &info, nil
}

// WriteVersion writes version.json.
func WriteVersion(info *VersionInfo) error {
	path, err := versionPath()
	if err != nil {
		return err
	}

	data, err := json.MarshalIndent(info, "", "  ")
	if err != nil {
		return fmt.Errorf("序列化 version.json 失败: %v", err)
	}

	// 原子写：先写临时文件再 rename，崩溃/断电不会留下半截损坏的 version.json
	// （旧实现直接截断式写入，中途崩溃会丢失全部版本状态，check/apply/rollback 全失效）。
	tmpPath := path + ".tmp"
	if err := ioutil.WriteFile(tmpPath, data, 0644); err != nil {
		return fmt.Errorf("写入 version.json 失败: %v", err)
	}
	if err := os.Rename(tmpPath, path); err != nil {
		os.Remove(tmpPath)
		return fmt.Errorf("原子替换 version.json 失败: %v", err)
	}

	return nil
}
