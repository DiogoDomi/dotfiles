-- ===================================================================
-- ARQUIVO DE CONFIGURAÇÃO PARA NEOVIM (init.lua)
-- ===================================================================

-- -------------------------------------------------------------------
-- Opções Globais do Neovim
-- -------------------------------------------------------------------
vim.opt.nu = true              -- Habilita o número das linhas
vim.opt.tabstop = 4            -- Tamanho da tabulação em espaços
vim.opt.shiftwidth = 4         -- Largura da indentação
vim.opt.expandtab = true       -- Usa espaços em vez de tabs
vim.opt.smartindent = true     -- Habilita indentação inteligente
vim.opt.wrap = true           -- Desabilita a quebra de linha automática
vim.opt.swapfile = false       -- Desabilita o arquivo de swap
vim.opt.clipboard = "unnamedplus" -- Integra a área de transferência do sistema
vim.opt.termguicolors = true   -- Habilita cores de 24-bit no terminal
vim.opt.textwidth = 80
vim.opt.formatoptions:append 't'

-- Define a tecla <Leader> como a barra de espaço (mais ergonômico)
vim.g.mapleader = ' '

-- -------------------------------------------------------------------
-- Gerenciador de Plugins: Packer
-- -------------------------------------------------------------------
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
    -- Packer, para gerenciar a si mesmo
    use 'wbthomason/packer.nvim'

    -- LSP (Language Server Protocol) e Autocomplete
    use 'neovim/nvim-lspconfig'            -- Configuração base para LSPs
    use 'williamboman/mason.nvim'          -- Gerenciador de LSPs, linters e formatters
    use 'williamboman/mason-lspconfig.nvim'-- Integra o Mason com o lspconfig
    use 'hrsh7th/nvim-cmp'                 -- Motor de autocompletar
    use 'hrsh7th/cmp-nvim-lsp'             -- Fonte de autocomplete para o LSP
    use 'hrsh7th/cmp-buffer'               -- Fonte de autocomplete para palavras no buffer atual
    use 'L3MON4D3/LuaSnip'                 -- Motor de snippets
    use 'saadparwaiz1/cmp_luasnip'         -- Integra o LuaSnip com o nvim-cmp

    -- UI (Interface do Usuário)
    use 'nvim-tree/nvim-tree.lua'          -- Explorador de arquivos
    use {'nvim-lua/plenary.nvim'}          -- Dependência para Telescope
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {
        'nvim-lualine/lualine.nvim',       -- Barra de status
        requires = { 'nvim-tree/nvim-web-devicons' }
    }
    use {
        'akinsho/bufferline.nvim',         -- Barra de "abas" (buffers)
        tag = "*",
        requires = 'nvim-tree/nvim-web-devicons'
    }
    use {
        'Mofiqul/vscode.nvim',             -- Tema de cores
        branch = 'main'
    }

    -- Syntax Highlighting
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

end)

-- -------------------------------------------------------------------
-- Configuração do LSP e Mason
-- -------------------------------------------------------------------
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local on_attach = function(client, bufnr)
end

require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = { "clangd", "jdtls", "lua_ls" },
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({
                on_attach = on_attach,
                capabilities = capabilities,
            })
        end,
        ["lua_ls"] = function()
            require('lspconfig').lua_ls.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        diagnostics = { globals = { 'vim' } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                    },
                },
            })
        end,
    }
})

-- -------------------------------------------------------------------
-- Configuração do AutoComplete (nvim-cmp)
-- -------------------------------------------------------------------
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
    }),
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    }),
})

-- -------------------------------------------------------------------
-- Configuração do TreeSitter (Syntax Highlighting)
-- -------------------------------------------------------------------
require('nvim-treesitter.configs').setup {
    ensure_installed = { "c", "cpp", "java", "lua", "python", "vim" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
}

-- -------------------------------------------------------------------
-- Configuração dos Plugins de UI (Interface)
-- -------------------------------------------------------------------
-- Tema de Cores (deve vir antes dos outros plugins de UI)
vim.cmd("colorscheme vscode")

-- Nvim-Tree
require('nvim-tree').setup({
    sort_by = "case_sensitive",
    view = { width = 30 },
    renderer = { group_empty = true },
    filters = { dotfiles = true },
})

-- Bufferline
require("bufferline").setup({
    options = {
        buffer_close_icon = "",
        close_command = "bdelete %d",
        close_icon = "",
        indicator = {
          style = "icon",
          icon = " ",
        },
        left_trunc_marker = "",
        modified_icon = "●",
        offsets = { { filetype = "NvimTree", text = "EXPLORER", text_align = "center" } },
        right_mouse_command = "bdelete! %d",
        right_trunc_marker = "",
        show_close_icon = false,
        show_tab_indicators = true,
    },
    highlights = {
        fill = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "StatusLineNC" },
        },
        background = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "StatusLine" },
        },
        buffer_visible = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
        },
        buffer_selected = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
        },
        separator = {
            fg = { attribute = "bg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "StatusLine" },
        },
        separator_selected = {
            fg = { attribute = "fg", highlight = "Special" },
            bg = { attribute = "bg", highlight = "Normal" },
        },
        separator_visible = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "StatusLineNC" },
        },
        close_button = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "StatusLine" },
        },
        close_button_selected = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
        },
        close_button_visible = {
            fg = { attribute = "fg", highlight = "Normal" },
            bg = { attribute = "bg", highlight = "Normal" },
        },
    },
})

-- Lualine
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
    },
}

-- -------------------------------------------------------------------
-- Atalhos de Teclado (Keymaps)
-- -------------------------------------------------------------------
-- Nvim-Tree: Abre/fecha o explorador de arquivos com <Espaço>e
vim.keymap.set('n', '<leader>b', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = "Toggle file explorer" })

-- Telescope:
vim.keymap.set('n', '<leader>ff', function()
    require('telescope.builtin').find_files()
end, { desc = "Find files" })

vim.keymap.set('n', '<leader>fg', function()
    require('telescope.builtin').live_grep()
end, { desc = "Find text in project (Grep)" })

-- Bufferline: Navega e fecha buffers
vim.keymap.set('n', '<leader>]', ':bnext<CR>', { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set('n', '<leader>[', ':bprevious<CR>', { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set('n', '<leader>-', ':bdelete!<CR>', { noremap = true, silent = true, desc = "Close buffer" })

-- Buffer: Alternar entre janelas (splis)
vim.keymap.set('n', '<leader>e', function()
    local status_ok, api = pcall(require, "nvim-tree.api")
    if not status_ok then
        return
    end

    if vim.bo.filetype == "NvimTree" then
        vim.cmd.wincmd("p")
    else
        api.tree.focus()
    end
end, { desc = "Alternar foco entre arquivoe Nvim-tree" } )

vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Mover para a janela da esquerda' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Mover para a janela de baixo' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Mover para a janela de cima' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Mover para a janela da direita' })
