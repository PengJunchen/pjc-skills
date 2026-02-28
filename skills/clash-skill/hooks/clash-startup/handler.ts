import { exec } from "node:child_process";
import { promisify } from "node:util";
import fs from "node:fs/promises";
import path from "node:path";

const execAsync = promisify(exec);

const logFile = "/tmp/clash-startup.log";

async function log(message: string) {
  const timestamp = new Date().toISOString();
  const logLine = `[${timestamp}] ${message}\n`;
  try {
    await fs.appendFile(logFile, logLine);
  } catch (err) {
    console.error("[clash-startup] Failed to write log:", err);
  }
}

async function isClashRunning(): Promise<boolean> {
  try {
    const { stdout } = await execAsync("pgrep -f clash");
    return stdout.trim().length > 0;
  } catch {
    return false;
  }
}

async function startClash(): Promise<{ success: boolean; error?: string }> {
  const workspace = process.env.HOME
    ? path.join(process.env.HOME, ".openclaw", "workspace")
    : "/home/node/.openclaw/workspace";

  const clashScript = path.join(workspace, "pjc-skills", "skills", "clash-skill", "scripts", "clash.sh");

  // 检查冲突脚本是否存在
  try {
    await fs.access(clashScript);
  } catch {
    return {
      success: false,
      error: `Clash script not found at ${clashScript}`,
    };
  }

  try {
    await log(`Starting Clash with script: ${clashScript}`);
    const { stdout, stderr } = await execAsync(`bash "${clashScript}" start`);

    if (stderr && stderr.trim().length > 0) {
      await log(`Clash start stderr: ${stderr}`);
    }

    await log(`Clash start stdout: ${stdout}`);
    return { success: true };
  } catch (err) {
    const error = err instanceof Error ? err.message : String(err);
    await log(`Failed to start Clash: ${error}`);
    return { success: false, error };
  }
}

const clashStartup: import("../../hooks").HookHandler = async (event) => {
  // 只处理 gateway:startup 事件
  if (event.type !== "gateway" || event.action !== "startup") {
    return;
  }

  await log("Clash startup hook triggered");

  // 检查是否已经在运行
  const running = await isClashRunning();
  if (running) {
    await log("Clash is already running, skipping...");
    return;
  }

  await log("Clash is not running, starting...");

  // 启动 Clash
  const result = await startClash();

  if (result.success) {
    await log("Clash started successfully");
  } else {
    await log(`Failed to start Clash: ${result.error}`);
  }
};

export default clashStartup;
