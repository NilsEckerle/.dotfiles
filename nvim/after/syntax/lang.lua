-- Load C syntax first
vim.cmd("runtime! syntax/c.vim")

-- Add your custom syntax rules
vim.cmd([[
  " Keywords
  syntax keyword langKeyword struct enum union typedef
  syntax keyword langKeyword static
  syntax keyword langKeyword break continue return if else switch case default
  syntax keyword langKeyword for while do
  
  " Types
  syntax keyword langType void bool char short int long float double signed unsigned dyn let mut
  
  " Constants
  syntax keyword langBoolean true false
  syntax keyword langConstant null
  
  " Link to highlight groups
  highlight link langKeyword Keyword
  highlight link langType Type
  highlight link langBoolean Boolean
  highlight link langConstant Constant
]])
