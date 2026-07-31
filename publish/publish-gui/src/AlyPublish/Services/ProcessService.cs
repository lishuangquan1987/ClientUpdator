using System;
using System.Diagnostics;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Serilog;

namespace AlyPublish.Services;

public class ProcessResult
{
    public bool Success { get; set; }
    public string StandardOutput { get; set; } = string.Empty;
    public string StandardError { get; set; } = string.Empty;
    public int ExitCode { get; set; }
}

public class ProcessService
{
    public async Task<ProcessResult> RunAsync(
        string fileName, string arguments, string? workingDir = null, int timeoutMs = 30000)
        => await RunCoreAsync(fileName, arguments, null, workingDir, timeoutMs);

    /// <summary>
    /// 使用 ArgumentList 启动进程：参数数组由 .NET 按 Windows 规则自动转义，
    /// 杜绝手工拼接引号导致的参数注入。
    /// </summary>
    public async Task<ProcessResult> RunAsync(
        string fileName, IReadOnlyList<string> argumentList, string? workingDir = null, int timeoutMs = 30000)
        => await RunCoreAsync(fileName, null, argumentList, workingDir, timeoutMs);

    private async Task<ProcessResult> RunCoreAsync(
        string fileName, string? arguments, IReadOnlyList<string>? argumentList,
        string? workingDir, int timeoutMs)
    {
        var psi = new ProcessStartInfo
        {
            FileName = fileName,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8
        };
        if (argumentList is not null)
        {
            foreach (var arg in argumentList)
                psi.ArgumentList.Add(arg);
        }
        else
        {
            psi.Arguments = arguments ?? string.Empty;
        }
        if (!string.IsNullOrWhiteSpace(workingDir))
        {
            psi.WorkingDirectory = workingDir;
            Log.Debug("工作目录: {WorkDir}", workingDir);
        }

        Log.Debug("启动进程: {File} {Args} (超时={Timeout}ms)", fileName, arguments, timeoutMs);

        using var proc = new Process { StartInfo = psi };

        try
        {
            proc.Start();

            // 并发读取 stdout/stderr，防止管道缓冲区满导致子进程死锁
            var stdoutTask = proc.StandardOutput.ReadToEndAsync();
            var stderrTask = proc.StandardError.ReadToEndAsync();

            using var cts = new CancellationTokenSource(timeoutMs);
            try
            {
                await proc.WaitForExitAsync(cts.Token);
            }
            catch (OperationCanceledException)
            {
                // Kill(true)：同时结束 CLI 子进程树，避免孤儿进程占用文件/锁
                proc.Kill(true);
                try
                {
                    // 等待进程退出，加 5 秒超时防止无限挂起
                    using var killCts = new CancellationTokenSource(5000);
                    await proc.WaitForExitAsync(killCts.Token);
                }
                catch (OperationCanceledException)
                {
                    Log.Warning("进程 Kill 后未在 5s 内退出: {File} {Args}", fileName, arguments);
                }
                // 等待 stdout/stderr 读取任务完成，避免未观察异常和丢失错误信息
                try
                {
                    await Task.WhenAll(stdoutTask, stderrTask);
                }
                catch (Exception readEx)
                {
                    Log.Warning(readEx, "超时后读取 stdout/stderr 异常: {File} {Args}", fileName, arguments);
                }
                Log.Warning("进程超时: {File} {Args}", fileName, arguments);
                return new ProcessResult { Success = false, StandardError = "进程执行超时" };
            }

            var stdout = (await stdoutTask).Trim();
            var stderr = (await stderrTask).Trim();

            var result = new ProcessResult
            {
                Success = proc.ExitCode == 0,
                StandardOutput = stdout.Trim(),
                StandardError = stderr.Trim(),
                ExitCode = proc.ExitCode
            };

            Log.Debug("进程完成: ExitCode={Code}, StdOut={OutLen}, StdErr={ErrLen}",
                result.ExitCode, result.StandardOutput.Length, result.StandardError.Length);

            if (!result.Success)
            {
                Log.Warning("进程非零退出: ExitCode={Code}, StdErr={Err}",
                    result.ExitCode, result.StandardError);
            }

            return result;
        }
        catch (Exception ex)
        {
            Log.Error(ex, "进程执行异常: {File} {Args}", fileName, arguments);
            return new ProcessResult { Success = false, StandardError = ex.Message };
        }
    }

    /// <summary>
    /// 运行进程并逐行回调 stdout 输出（用于实时进度显示）。
    /// 每收到一行 stdout 即调用 onLine，无需等待进程结束。
    /// </summary>
    public async Task<ProcessResult> RunWithProgressAsync(
        string fileName, string arguments, Action<string> onLine,
        string? workingDir = null, int timeoutMs = 30000)
        => await RunWithProgressCoreAsync(fileName, arguments, null, onLine, workingDir, timeoutMs);

    /// <summary>使用 ArgumentList 的进度版本（防参数注入）。</summary>
    public async Task<ProcessResult> RunWithProgressAsync(
        string fileName, IReadOnlyList<string> argumentList, Action<string> onLine,
        string? workingDir = null, int timeoutMs = 30000)
        => await RunWithProgressCoreAsync(fileName, null, argumentList, onLine, workingDir, timeoutMs);

    private async Task<ProcessResult> RunWithProgressCoreAsync(
        string fileName, string? arguments, IReadOnlyList<string>? argumentList,
        Action<string> onLine, string? workingDir, int timeoutMs)
    {
        var psi = new ProcessStartInfo
        {
            FileName = fileName,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8
        };
        if (argumentList is not null)
        {
            foreach (var arg in argumentList)
                psi.ArgumentList.Add(arg);
        }
        else
        {
            psi.Arguments = arguments ?? string.Empty;
        }
        if (!string.IsNullOrWhiteSpace(workingDir))
        {
            psi.WorkingDirectory = workingDir;
            Log.Debug("工作目录 (流式): {WorkDir}", workingDir);
        }

        Log.Debug("启动进程 (流式): {File} {Args} (超时={Timeout}ms)", fileName, arguments, timeoutMs);

        using var proc = new Process { StartInfo = psi };

        try
        {
            proc.Start();

            // 在后台线程逐行读取 stdout，每行调用 onLine 回调
            var stdoutAll = new StringBuilder();
            var stdoutTask = Task.Run(async () =>
            {
                while (true)
                {
                    var line = await proc.StandardOutput.ReadLineAsync();
                    if (line == null) break;
                    stdoutAll.AppendLine(line);
                    try
                    {
                        onLine(line);
                    }
                    catch (Exception ex)
                    {
                        Log.Warning(ex, "onLine 回调异常: {Line}", line);
                    }
                }
            });

            // stderr 仍然一次性读取
            var stderrTask = proc.StandardError.ReadToEndAsync();

            using var cts = new CancellationTokenSource(timeoutMs);
            try
            {
                await proc.WaitForExitAsync(cts.Token);
            }
            catch (OperationCanceledException)
            {
                proc.Kill(true);
                try
                {
                    using var killCts = new CancellationTokenSource(5000);
                    await proc.WaitForExitAsync(killCts.Token);
                }
                catch (OperationCanceledException)
                {
                    Log.Warning("进程 Kill 后未在 5s 内退出 (流式): {File} {Args}", fileName, arguments);
                }
                try
                {
                    await Task.WhenAll(stdoutTask, stderrTask);
                }
                catch (Exception readEx)
                {
                    Log.Warning(readEx, "超时后读取 stdout/stderr 异常 (流式): {File} {Args}", fileName, arguments);
                }
                Log.Warning("进程超时 (流式): {File} {Args}", fileName, arguments);
                return new ProcessResult { Success = false, StandardError = "进程执行超时" };
            }

            // 等待 stdout 读取完成
            await stdoutTask;
            var stderr = (await stderrTask).Trim();

            var result = new ProcessResult
            {
                Success = proc.ExitCode == 0,
                StandardOutput = stdoutAll.ToString().Trim(),
                StandardError = stderr,
                ExitCode = proc.ExitCode
            };

            Log.Debug("进程完成 (流式): ExitCode={Code}, StdOut={OutLen}, StdErr={ErrLen}",
                result.ExitCode, result.StandardOutput.Length, result.StandardError.Length);

            if (!result.Success)
            {
                Log.Warning("进程非零退出 (流式): ExitCode={Code}, StdErr={Err}",
                    result.ExitCode, result.StandardError);
            }

            return result;
        }
        catch (Exception ex)
        {
            Log.Error(ex, "进程执行异常 (流式): {File} {Args}", fileName, arguments);
            return new ProcessResult { Success = false, StandardError = ex.Message };
        }
    }
}
