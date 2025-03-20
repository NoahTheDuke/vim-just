-- Neovim filetype plugin
-- Language:	Justfile
-- Maintainer:	Noah Bogart <noah.bogart@hey.com>
-- URL:		https://github.com/NoahTheDuke/vim-just.git
-- Last Change:	2025 Feb 05

if vim.fn.has("nvim-0.8") then
  vim.filetype.add({
    -- Neovim adds start/end anchors to the patterns
    pattern = {
      ['[Jj][Uu][Ss][Tt][Ff][Ii][Ll][Ee]'] = 'just',
      ['.*%.[Jj][Uu][Ss][Tt][Ff][Ii][Ll][Ee]'] = 'just',
      ['.*%.[Jj][Uu][Ss][Tt]'] = 'just',
    },
  })
end
