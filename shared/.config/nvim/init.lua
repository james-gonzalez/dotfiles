-- Options first: sets mapleader before lazy loads plugins
require 'config.options'
require 'lazy-init'

require('lazy').setup({ import = 'plugins' }, {
  change_detection = { notify = false },
})

require 'config.keymaps'
require 'config.autocmd'
require 'config.macros'
require 'config.diagnostics_virtual_line'
