return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>Ha", function()
      harpoon:list():add()
    end, { desc = "Harpoon add file" })
    vim.keymap.set("n", "<leader>Hm", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon menu" })

    for i = 1, 4 do
      vim.keymap.set("n", "<leader>H" .. i, function()
        harpoon:list():select(i)
      end, { desc = "Harpoon file " .. i })
    end

    vim.keymap.set("n", "<leader>Hp", function()
      harpoon:list():prev()
    end, { desc = "Harpoon previous file" })
    vim.keymap.set("n", "<leader>Hn", function()
      harpoon:list():next()
    end, { desc = "Harpoon next file" })
  end,
}
