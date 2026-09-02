// +build windows

package util

import (
	"fmt"
	"syscall"
	"unsafe"
)

// Restart Manager API 用于探测并定位占用指定文件/文件夹的进程。
// 参考: https://learn.microsoft.com/en-us/windows/win32/api/restartmanager/
// rstrtmgr.dll 在 Windows XP 及以上系统提供（XP 上若 API 缺失则返回错误，由调用方降级处理）。

const (
	errorMoreData     = 234 // ERROR_MORE_DATA
	errorSuccess      = 0   // ERROR_SUCCESS
	rmSessionKeyLen   = 33  // CCH_RM_SESSION_KEY (32) + 1
	rmMaxAppName      = 255
	rmMaxSvcName      = 63
)

var (
	restartMgrDLL        = syscall.NewLazyDLL("rstrtmgr.dll")
	procRmStartSession   = restartMgrDLL.NewProc("RmStartSession")
	procRmRegisterRes    = restartMgrDLL.NewProc("RmRegisterResources")
	procRmGetList        = restartMgrDLL.NewProc("RmGetList")
	procRmEndSession     = restartMgrDLL.NewProc("RmEndSession")
)

type rmUniqueProcess struct {
	ProcessID        uint32
	ProcessStartTime syscall.Filetime
}

type rmProcessInfo struct {
	Process             rmUniqueProcess
	StrAppName          [rmMaxAppName + 1]uint16
	StrServiceShortName [rmMaxSvcName + 1]uint16
	ApplicationType     uint32
	AppStatus           uint32
	TSSessionID         uint32
	BRestartable        int32
}

// FindProcessesHoldingPath 使用 Restart Manager API 找出占用指定文件/文件夹的进程 PID。
// 返回 nil 且无错误表示该 API 不可用或当前没有占用者，不视为失败。
func FindProcessesHoldingPath(path string) ([]uint32, error) {
	// XP 等不支持 Restart Manager 的环境，函数地址为 0
	if procRmStartSession.Addr() == 0 {
		return nil, nil
	}

	var sessionHandle uint32
	var sessionKey [rmSessionKeyLen]uint16
	ret, _, _ := procRmStartSession.Call(
		uintptr(unsafe.Pointer(&sessionHandle)),
		0, // dwSessionFlags: 0
		uintptr(unsafe.Pointer(&sessionKey[0])),
	)
	if ret != errorSuccess {
		return nil, fmt.Errorf("RmStartSession failed: 0x%x", ret)
	}
	defer procRmEndSession.Call(uintptr(sessionHandle))

	pathPtr, err := syscall.UTF16PtrFromString(path)
	if err != nil {
		return nil, err
	}
	filenameArgs := []uintptr{uintptr(unsafe.Pointer(pathPtr))}
	ret, _, _ = procRmRegisterRes.Call(
		uintptr(sessionHandle),
		1, // nFiles
		uintptr(unsafe.Pointer(&filenameArgs[0])),
		0, // nApplications
		0,
		0, // nServices
		0,
	)
	if ret != errorSuccess {
		return nil, fmt.Errorf("RmRegisterResources failed: 0x%x", ret)
	}

	var procInfoNeeded uint32
	var procInfo uint32
	var rebootReasons uint32
	ret, _, _ = procRmGetList.Call(
		uintptr(sessionHandle),
		uintptr(unsafe.Pointer(&procInfoNeeded)),
		uintptr(unsafe.Pointer(&procInfo)),
		0,
		uintptr(unsafe.Pointer(&rebootReasons)),
	)
	if procInfoNeeded == 0 {
		return nil, nil // 无占用者
	}

	sizeOfInfo := unsafe.Sizeof(rmProcessInfo{})
	buf := make([]byte, int(procInfoNeeded)*int(sizeOfInfo))
	// pnProcInfo 是 in/out 参数：输入时必须为缓冲区能容纳的条目数
	procInfo = procInfoNeeded
	ret, _, _ = procRmGetList.Call(
		uintptr(sessionHandle),
		uintptr(unsafe.Pointer(&procInfoNeeded)),
		uintptr(unsafe.Pointer(&procInfo)),
		uintptr(unsafe.Pointer(&buf[0])),
		uintptr(unsafe.Pointer(&rebootReasons)),
	)
	if ret != errorSuccess {
		return nil, fmt.Errorf("RmGetList failed: 0x%x", ret)
	}

	var pids []uint32
	base := uintptr(unsafe.Pointer(&buf[0]))
	for i := uint32(0); i < procInfo; i++ {
		info := (*rmProcessInfo)(unsafe.Pointer(base + uintptr(i)*sizeOfInfo))
		pids = append(pids, info.Process.ProcessID)
	}
	return pids, nil
}
