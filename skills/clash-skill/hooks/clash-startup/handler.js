import { exec } from "node:child_process";
import { promisify } from "node:util";
import fs from "node:fs/promises";
import path from "node:path";

const execAsync = promisify(exec);

const logFile = "/tmp/clash-startup.log";
const extraLogFile = "/tmp/clash-startup-debug.log";

async function log(message) {
  const timestamp = new Date().toISOString();
  const logLine = `[${timestamp}] ${message}\n`;

  // 写入主日志
  try {
    await fs.appendFile(logFile, logLine);
  } catch (err) {
    console.error("[clash-startup] Failed to write log:", err);
  }

  // 写入额外的调试日志（记录所有事件）
  try {
    await fs.appendFile(extraLogFile, logLine);
  } catch (err) {
    console.error("[clash-startup] Failed to write debug log:", err);
  }
}

async function logDetails(event) {
  const timestamp = new Date().toISOString();
  const logLine = `
[${timestamp}] ===== EVENT DETAILS =====
  type: ${event.type}
  action: ${event.action}
  sessionKey: ${event.sessionKey}
  timestamp: ${event.timestamp?.toISOString?.() || event.timestamp}
  context: ${JSON.stringify(event.context, null, 2)}
  messages count: ${event.messages?.length || 0}
===========================\n`;

  try {
    await fs.appendFile(extraLogFile, logLine);
  } catch (err) {
    console.error("[clash-startup] Failed to write event details:", err);
  }
}

/**
 * 检查 Clash 是否在运行
 * 使用多种方法验证，避免误报
 */
async function isClashRunning() {
  try {
    await log("Checking if Clash is running...");

    // 方法1: 检查 PID 文件并验证进程
    const clashPidFile = "/home/node/.config/clash/clash.pid";
    if (await fileExists(clashPidFile)) {
      const pidContent = await fs.readFile(clashPidFile, "utf8");
      const pid = parseInt(pidContent.trim(), 10);

      if (!isNaN(pid) && pid > 0) {
        await log(`Found PID file: ${pid}, verifying process...`);

        // 验证进程是否存在
        const { stdout } = await execAsync(`ps -p ${pid} -o comm=`, { stdio: "pipe" });
        const comm = stdout.trim();

        await log(`Process command: "${comm}"`);

        // 检查进程是否确实是 clash 或 mihomo
        if (comm === "clash" || comm === "mihomo") {
          await log("✓ Clash is running (verified via PID file)");
          return true;
        } else {
          await log(`✗ PID file exists but process is "${comm}", not clash/mihomo`);
        }
      }
    } else {
      await log("PID file does not exist");
    }

    // 方法2: 使用 pgrep 精确匹配进程名
    const { stdout } = await execAsync("pgrep -x clash", { stdio: "pipe" });
    if (stdout.trim().length > 0) {
      await log(`✓ Clash is running (found via pgrep -x clash: ${stdout.trim()})`);
      return true;
    }

    // 方法3: 某些版本可能使用 mihomo 进程名
    const { stdout: mihomoStdout } = await execAsync("pgrep -x mihomo", { stdio: "pipe" });
    if (mihomoStdout.trim().length > 0) {
      await log(`✓ Clash is running (found via pgrep -x mihomo: ${mihomoStdout.trim()})`);
      return true;
    }

    await log("✗ Clash is not running");
    return false;
  } catch (err) {
    const error = err instanceof Error ? err.message : String(err);
    await log(`Error checking Clash status: ${error}`);
    // 任何错误都认为 Clash 未运行
    return false;
  }
}

/**
 * 检查文件是否存在
 */
async function fileExists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

/**
 * 启动 Clash
 */
async function startClash() {
  const workspace = process.env.HOME
    ? path.join(process.env.HOME, ".openclaw", "workspace")
    : "/home/node/.openclaw/workspace";

  const clashScript = path.join(workspace, "pjc-skills", "skills", "clash-skill", "scripts", "clash.sh");

  // 检查冲突脚本是否存在
  try {
    await fs.access(clashScript);
    await log(`✓ Clash script exists: ${clashScript}`);
  } catch {
    await log(`✗ Clash script not found at ${clashScript}`);
    return {
      success: false,
      error: `Clash script not found at ${clashScript}`,
    };
  }

  try {
    await log(`Starting Clash with script: ${clashScript}`);
    const { stdout, stderr } = await execAsync(`bash "${clashScript}" start`, { stdio: "pipe" });

    if (stderr && stderr.trim().length > 0) {
      await log(`Clash start stderr: ${stderr}`);
    }

    if (stdout) {
      await log(`Clash start stdout: ${stdout}`);
    }
    
    return { success: true };
  } catch (err) {
    const error = err instanceof Error ? err.message : String(err);
    await log(`✗ Failed to start Clash: ${error}`);
    return { success: false, error };
  }
}

/**
 * 等待 Clash 启动完成
 */
async function waitForClashToStart(maxAttempts = 10, interval = 1000) {
  for (let i = 0; i < maxAttempts; i++) {
    try {
      const running = await isClashRunning();
      if (running) {
        await log(`✓ Clash started successfully after ${i + 1} check(s)`);
        return true;
      }
    } catch (err) {
      await log(`Error checking Clash status: ${err}`);
    }

    await new Promise(resolve => setTimeout(resolve, interval));
  }

  await log(`✗ Clash did not start after ${maxAttempts} attempts`);
  return false;
}

/**
 * Hook 处理器
 */
const clashStartup = async (event) => {
  await log("=== Clash startup hook triggered ===");
  await logDetails(event);

  // 检查事件类型
  await log(`Event type: ${event.type}, action: ${event.action}`);

  // 只处理 gateway:startup 事件
  if (event.type !== "gateway" || event.action !== "startup") {
    await log(`✗ Event type mismatch, skipping (expected type=gateway, action=startup)`);
    return;
  }

  await log("✓ Event type matches gateway:startup");

  // 检查是否已经在运行
  const running = await isClashRunning();
  if (running) {
    await log("Clash is already running, skipping...");
    return;
  }

  await log("Clash is not running, starting...");

  // 启动 Clash
  const startResult = await startClash();

  if (startResult.success) {
    await log("Clash start command executed successfully");

    // 等待验证 Clash 真的启动了
    const started = await waitForClashToStart(10, 1000);

    if (started) {
      await log("✓✓✓ Clash successfully started and verified ✓✓✓");
    } else {
      await log("✗ Clash start command executed but process not found");
    }
  } else {
    await log(`✗ Failed to start Clash: ${startResult.error}`);
  }

  await log("=== Clash startup hook completed ===");
};

export default clashStartup;
