const copy = {
  "zh-CN": {
    brand: "Windows 系统维护",
    github: "GitHub",
    switchLabel: "Switch to English",
    eyebrow: "CODEX SKILL · WINDOWS 运维",
    heroTitle: "先检查，再决定。|<span>一次确认后执行。</span>",
    heroLead: "面向 Windows 磁盘清理、启动项分析和软件卸载的审计优先工作流。先把事实和风险讲清楚，再由用户做唯一一次执行决定。",
    viewRepo: "查看 GitHub 仓库",
    readSkill: "阅读 Skill 说明",
    quickStartBtn: "一键发送指令",
    launchStripTitle: "一键发送给 Agent",
    launchStripText: "复制现成指令，发给 Codex、DeepSeekHarness 或其他工具。",
    launchCodex: "复制 Codex 指令",
    launchDeepseek: "复制 DeepSeekHarness 指令",
    launchShell: "复制 PowerShell",
    installEyebrow: "一键安装与调用",
    installTitle: "复制指令，直接发送给你的 Agent",
    installLead: "任选一个工具。指令会要求它安装这份 Skill，先执行只读检查，生成编号清单，并在你回复一次“确认”后再执行。",
    codexTitle: "Codex 安装并调用",
    deepseekTitle: "DeepSeekHarness / 通用 Agent",
    shellTitle: "直接克隆并运行审计",
    copyButton: "复制指令",
    copyCommand: "复制命令",
    copied: "已复制",
    installNote: "DeepSeekHarness 等工具没有统一的 Skill 安装协议，因此使用自然语言指令最稳妥：让 Agent 读取仓库中的中文规则，再按同一审阅流程执行。",
    codexPrompt: `请从 https://github.com/vyvyc/windows-system-maintenance 安装 Codex Skill 到 $CODEX_HOME/skills/windows-system-maintenance。

安装后，请使用 $windows-system-maintenance：
1. 先只读检查本机磁盘和开机启动项。
2. 执行安全检查，生成带编号的审阅清单。
3. 说明每项动作、路径、大小、风险和预计影响。
4. 停止并等待我回复一次“确认”或指定编号，再一次性执行。`,
    deepseekPrompt: `请把 https://github.com/vyvyc/windows-system-maintenance 作为当前任务可用的 Windows 系统维护 Skill。优先读取 SKILL.zh-CN.md、references/review-gate.zh-CN.md 和对应中文策略文件。

先只读检查本机磁盘与开机启动项，生成带编号的安全清单；说明路径、大小、风险与保留项。然后停止，等待我回复一次“确认”或指定编号后再批量执行，不要逐项重复询问。`,
    shellCommands: `$dest = "$HOME\\.codex\\skills\\windows-system-maintenance"
if (Test-Path "$dest\\.git") {
  git -C $dest pull --ff-only
} else {
  git clone https://github.com/vyvyc/windows-system-maintenance $dest
}
pwsh -NoProfile -File "$dest\\scripts\\audit-windows.ps1"`,
    badgeReadOnly: "只读审计",
    badgeConfirm: "一次确认",
    badgeBilingual: "中英双语",
    metricAuditTitle: "全面审计",
    metricAuditText: "磁盘、缓存、大文件、启动项、任务和自动服务。",
    metricSafetyTitle: "安全分类",
    metricSafetyText: "区分可重建缓存、用户数据、安装介质和受保护系统项。",
    metricGateTitle: "审批闸门",
    metricGateText: "生成带编号清单，只等待一次明确执行命令。",
    metricVerifyTitle: "结果验证",
    metricVerifyText: "执行后复核空间、路径、服务状态和残留项。",
    workflowEyebrow: "工作流程",
    workflowTitle: "系统改动只有一次最终授权",
    workflowLead: "审计结果先变成可审阅的计划，避免在没有完整上下文时直接删除或停用。",
    step1Title: "只读检索",
    step1Text: "收集容量、路径、进程、服务、计划和注册表状态，不修改系统。",
    step2Title: "安全检查",
    step2Text: "识别锁定目标、用户数据、系统保护项和真实可释放空间。",
    step3Title: "编号审阅",
    step3Text: "列出 C01、C02、S01 等候选编号，说明动作、风险与保留项。",
    step4Title: "一次性确认",
    step4Text: "用户回复“确认”或指定编号后批量执行，不再逐项重复追问。",
    toolsEyebrow: "内置工具",
    toolsTitle: "三个确定性 PowerShell 脚本",
    toolDiskText: "扫描固定卷、顶层目录、已知缓存、受保护路径和大文件，输出 JSON 审阅报告。",
    toolStartupText: "汇总 Run、StartupApproved、计划任务、第三方自动服务和失效路径。",
    toolServiceText: "在 Automatic、Manual、Disabled 间安全调整服务，并保留软件配置。",
    safetyEyebrow: "安全边界",
    safetyTitle: "保护系统，也保护你的数据",
    safetyText: "不属于受保护项的候选也不会被自动删除。用户数据、虚拟机、录像和安装介质必须先经过明确审阅；WinSxS、Windows Installer 等系统修复数据禁止手动清除。",
    footer: "MIT License · 为 Codex 构建",
    pageTitle: "Windows 系统维护 | Codex Skill",
    languageButton: "EN",
    skillHref: "https://github.com/vyvyc/windows-system-maintenance/blob/main/SKILL.zh-CN.md"
  },
  en: {
    brand: "Windows System Maintenance",
    github: "GitHub",
    switchLabel: "切换到中文",
    eyebrow: "CODEX SKILL · WINDOWS OPERATIONS",
    heroTitle: "Audit first. Decide once.|<span>One confirmation.</span>",
    heroLead: "An audit-first workflow for Windows disk cleanup, startup analysis, and software removal. Establish the facts and risks first, then let the user make one final execution decision.",
    viewRepo: "View on GitHub",
    readSkill: "Read the skill",
    quickStartBtn: "Send a one-click prompt",
    launchStripTitle: "Send to your agent",
    launchStripText: "Copy a ready-made prompt for Codex, DeepSeekHarness, or another tool.",
    launchCodex: "Copy Codex prompt",
    launchDeepseek: "Copy DeepSeekHarness prompt",
    launchShell: "Copy PowerShell",
    installEyebrow: "ONE-CLICK START",
    installTitle: "Copy a command and send it to your agent",
    installLead: "Choose your tool. The instruction installs this skill, runs a read-only audit, produces a numbered review, and waits for one confirmation before execution.",
    codexTitle: "Install and invoke in Codex",
    deepseekTitle: "DeepSeekHarness / generic agent",
    shellTitle: "Clone and run the audit directly",
    copyButton: "Copy prompt",
    copyCommand: "Copy command",
    copied: "Copied",
    installNote: "DeepSeekHarness and similar tools do not share one skill-install protocol. A natural-language instruction is therefore the most portable approach: have the agent read the repository rules and follow the same review workflow.",
    codexPrompt: `Install the Codex skill from https://github.com/vyvyc/windows-system-maintenance into $CODEX_HOME/skills/windows-system-maintenance.

Then use $windows-system-maintenance:
1. Perform a read-only audit of disks and startup items.
2. Run the safety checks and produce a numbered review list.
3. Explain each action, path, size, risk, and expected impact.
4. Stop and wait for one "confirm" reply or explicit IDs, then execute the approved batch.`,
    deepseekPrompt: `Use https://github.com/vyvyc/windows-system-maintenance as the Windows system maintenance skill for this task. Read SKILL.zh-CN.md, references/review-gate.zh-CN.md, and the corresponding Chinese policy files.

Run a read-only audit of disks and startup items, then produce a numbered safety review with paths, sizes, risks, and preserved items. Stop and wait for one confirmation or explicit IDs before executing the approved batch. Do not ask again for every item.`,
    shellCommands: `$dest = "$HOME\\.codex\\skills\\windows-system-maintenance"
if (Test-Path "$dest\\.git") {
  git -C $dest pull --ff-only
} else {
  git clone https://github.com/vyvyc/windows-system-maintenance $dest
}
pwsh -NoProfile -File "$dest\\scripts\\audit-windows.ps1"`,
    badgeReadOnly: "Read-only audit",
    badgeConfirm: "One confirmation",
    badgeBilingual: "Bilingual",
    metricAuditTitle: "Deep audit",
    metricAuditText: "Disks, caches, large files, startup entries, tasks, and automatic services.",
    metricSafetyTitle: "Risk classes",
    metricSafetyText: "Separate rebuildable caches, user data, installers, and protected system stores.",
    metricGateTitle: "Review gate",
    metricGateText: "Create a numbered plan and wait for one clear execution command.",
    metricVerifyTitle: "Verify results",
    metricVerifyText: "Recheck space, paths, service state, and residual items after execution.",
    workflowEyebrow: "WORKFLOW",
    workflowTitle: "One final authorization for system changes",
    workflowLead: "Turn audit findings into a reviewable plan instead of deleting or disabling without full context.",
    step1Title: "Read-only scan",
    step1Text: "Collect capacity, paths, processes, services, tasks, and registry state without changing the system.",
    step2Title: "Safety check",
    step2Text: "Identify locked targets, user data, protected system items, and realistic reclaimable space.",
    step3Title: "Numbered review",
    step3Text: "List C01, C02, S01 and similar IDs with the action, risk, and items being preserved.",
    step4Title: "One-time confirmation",
    step4Text: "After the user confirms or selects IDs, run the batch without asking again item by item.",
    toolsEyebrow: "TOOLKIT",
    toolsTitle: "Three deterministic PowerShell scripts",
    toolDiskText: "Scan fixed volumes, top-level folders, known caches, protected paths, and large files into a JSON review report.",
    toolStartupText: "Collect Run entries, StartupApproved state, scheduled tasks, automatic third-party services, and broken paths.",
    toolServiceText: "Safely switch services between Automatic, Manual, and Disabled while preserving application configuration.",
    safetyEyebrow: "SAFETY BOUNDARY",
    safetyTitle: "Protect the system and your data",
    safetyText: "Candidates outside protected stores are never deleted automatically either. User data, virtual machines, recordings, and installation media require explicit review; system repair stores such as WinSxS and Windows Installer must not be removed manually.",
    footer: "MIT License · Built for Codex",
    pageTitle: "Windows System Maintenance | Codex Skill",
    languageButton: "中文",
    skillHref: "https://github.com/vyvyc/windows-system-maintenance/blob/main/SKILL.md"
  }
};

const storageKey = "windows-system-maintenance-language";
const queryLanguage = new URLSearchParams(window.location.search).get("lang");
const savedLanguage = window.localStorage.getItem(storageKey);
let language = queryLanguage === "en" || queryLanguage === "zh-CN"
  ? queryLanguage
  : (savedLanguage === "en" ? "en" : "zh-CN");

function applyLanguage(nextLanguage, persist = true) {
  language = nextLanguage === "en" ? "en" : "zh-CN";
  const strings = copy[language];

  document.documentElement.lang = language;
  document.title = strings.pageTitle;

  document.querySelectorAll("[data-i18n]").forEach((element) => {
    const value = strings[element.dataset.i18n];
    if (typeof value !== "string") return;
    if (element.dataset.i18n === "heroTitle") {
      element.innerHTML = value.split("|").join("<br>");
    } else {
      element.textContent = value;
    }
  });

  document.querySelectorAll("[data-i18n-code]").forEach((element) => {
    const value = strings[element.dataset.i18nCode];
    if (typeof value === "string") element.textContent = value;
  });

  document.querySelectorAll("[data-i18n-href]").forEach((element) => {
    const key = element.dataset.i18nHref;
    if (strings[key]) element.setAttribute("href", strings[key]);
  });

  const toggle = document.getElementById("languageToggle");
  toggle.textContent = strings.languageButton;
  toggle.setAttribute("aria-label", strings.switchLabel);

  if (persist) {
    window.localStorage.setItem(storageKey, language);
  }

  const url = new URL(window.location.href);
  url.searchParams.set("lang", language);
  window.history.replaceState({}, "", url);
}

document.getElementById("languageToggle").addEventListener("click", () => {
  applyLanguage(language === "zh-CN" ? "en" : "zh-CN");
});

async function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(text);
    return;
  }

  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.style.position = "fixed";
  textarea.style.opacity = "0";
  document.body.appendChild(textarea);
  textarea.select();
  document.execCommand("copy");
  textarea.remove();
}

document.querySelectorAll("[data-copy-target]").forEach((button) => {
  button.addEventListener("click", async () => {
    const target = document.getElementById(button.dataset.copyTarget);
    if (!target) return;
    try {
      await copyText(target.textContent);
      button.textContent = copy[language].copied;
      window.setTimeout(() => {
        button.textContent = copy[language][button.dataset.i18n];
      }, 1500);
    } catch {
      button.textContent = copy[language].copied;
    }
  });
});

applyLanguage(language, false);
