// +build !windows

package util

// FindProcessesHoldingPath 查找占用指定文件/文件夹的进程（Unix 兼容实现）。
// Restart Manager 为 Windows 特有 API，Unix 上不做探测，返回空。
func FindProcessesHoldingPath(path string) ([]uint32, error) {
	return nil, nil
}
