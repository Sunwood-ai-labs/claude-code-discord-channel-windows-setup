import { defineConfig } from "vitepress";

const repo = "https://github.com/Sunwood-ai-labs/claude-code-discord-channel-windows-setup";

export default defineConfig({
  title: "Claude Code Discord Channel Windows Setup",
  description: "Windows-first setup guide for the official Claude Code Discord channel plugin.",
  base: "/claude-code-discord-channel-windows-setup/",
  cleanUrls: true,
  lastUpdated: true,
  head: [["link", { rel: "icon", href: "/claude-code-discord-channel-windows-setup/icon.svg" }]],
  themeConfig: {
    logo: "/icon.svg",
    socialLinks: [{ icon: "github", link: repo }],
    search: {
      provider: "local"
    }
  },
  locales: {
    root: {
      label: "English",
      lang: "en",
      themeConfig: {
        nav: [
          { text: "Guide", link: "/guide/windows-setup" },
          { text: "Scripts", link: "/guide/scripts" },
          { text: "Troubleshooting", link: "/guide/troubleshooting" },
          { text: "Setup Report", link: `${repo}/blob/main/SETUP_REPORT.md` }
        ],
        sidebar: [
          {
            text: "Guide",
            items: [
              { text: "Windows Setup", link: "/guide/windows-setup" },
              { text: "Scripts", link: "/guide/scripts" },
              { text: "Troubleshooting", link: "/guide/troubleshooting" }
            ]
          }
        ]
      }
    },
    ja: {
      label: "日本語",
      lang: "ja",
      link: "/ja/",
      themeConfig: {
        nav: [
          { text: "ガイド", link: "/ja/guide/windows-setup" },
          { text: "スクリプト", link: "/ja/guide/scripts" },
          { text: "トラブルシュート", link: "/ja/guide/troubleshooting" },
          { text: "作業レポート", link: `${repo}/blob/main/SETUP_REPORT.md` }
        ],
        sidebar: [
          {
            text: "ガイド",
            items: [
              { text: "Windows セットアップ", link: "/ja/guide/windows-setup" },
              { text: "スクリプト一覧", link: "/ja/guide/scripts" },
              { text: "トラブルシュート", link: "/ja/guide/troubleshooting" }
            ]
          }
        ]
      }
    }
  }
});
