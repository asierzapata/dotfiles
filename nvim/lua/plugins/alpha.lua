return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    enabled = true,
    init = false,
    opts = function()
      local dashboard = require("alpha.themes.dashboard")

    vim.api.nvim_set_hl(0, "NeovimDashboardLogo1", { fg = "#DA4939" })
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo2", { fg = "#FF875F" })
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo3", { fg = "#FFC66D" })
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo4", { fg = "#00FF03" })
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo5", { fg = "#00AFFF" })
    vim.api.nvim_set_hl(0, "NeovimDashboardLogo6", { fg = "#8800FF" })

    dashboard.section.header.type = "group"
    dashboard.section.header.val = {
        { type = "text", val = "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ", opts = { hl = "NeovimDashboardLogo1", shrink_margin = false, position = "center" } },
        { type = "text", val = "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ", opts = { hl = "NeovimDashboardLogo2", shrink_margin = false, position = "center" } },
        { type = "text", val = "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ", opts = { hl = "NeovimDashboardLogo3", shrink_margin = false, position = "center" } },
        { type = "text", val = "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ", opts = { hl = "NeovimDashboardLogo4", shrink_margin = false, position = "center" } },
        { type = "text", val = "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ", opts = { hl = "NeovimDashboardLogo5", shrink_margin = false, position = "center" } },
        { type = "text", val = "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ", opts = { hl = "NeovimDashboardLogo6", shrink_margin = false, position = "center" } },
    }

      dashboard.section.buttons.val = {
        dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
        dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
        dashboard.button("SPC ff", "󰱼 > Find File", "<cmd>Telescope find_files<CR>"),
        dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
        dashboard.button("q", " > Quit NVIM", "<cmd>qa<CR>"),
      }

      dashboard.section.header.opts.hl = ""
      dashboard.section.footer.opts.hl = "Keyword"
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,

    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          once = true,
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "LazyVimStarted",
        callback = function()
          -- Get the current date and time

          -- Get the current hour
          local current_hour = tonumber(os.date("%H"))

          -- Define the greeting variable
          local greeting

          if current_hour < 5 then
            greeting = "    Good night!"
          elseif current_hour < 12 then
            greeting = "  󰼰 Good morning!"
          elseif current_hour < 17 then
            greeting = "    Good afternoon!"
          elseif current_hour < 20 then
            greeting = "  󰖝  Good evening!"
          else
            greeting = "  󰖔  Good night!"
          end

          dashboard.section.footer.val = greeting

          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
