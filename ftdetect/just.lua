-- Neovim filetype plugin
-- Language:	Justfile
-- Maintainer:	Noah Bogart <noah.bogart@hey.com>
-- URL:		https://github.com/NoahTheDuke/vim-just.git
-- Last Change:	2024 May 30

if vim.fn.has("nvim-0.8") then
  vim.filetype.add({
    extension = {
      -- Disable extension-based detection of *.just justfiles.
      -- The extensions table is also matched against the program in shebang lines,
      -- which in case of just scripts is too broad.
      just = function()
        return nil
      end,
    },

    -- Neovim adds start/end anchors to the patterns
    pattern = {
      ['[Jj][Uu][Ss][Tt][Ff][Ii][Ll][Ee]'] = 'just',
      ['.*%.[Jj][Uu][Ss][Tt][Ff][Ii][Ll][Ee]'] = 'just',
      ['.*%.[Jj][Uu][Ss][Tt]'] = 'just',
    },
  })
end
