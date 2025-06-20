local cmp_ai = require('cmp_ai.config')
-- cmp_ai:setup({
--     max_lines = 100,
--     provider = "Ollama",
--     provider_options = {
--       model = "qwen2.5-coder:1.5b",
--     },
--     notify = true,
--     notify_callback = function(msg)
--       vim.notify(msg)
--     end,
--     run_on_every_keystroke = true,
--     ignored_file_types = {
--       -- default is not to ignore
--       -- uncomment to ignore in lua:
--       -- lua = true
--     },
-- })
cmp_ai:setup({
	max_lines = 100,
	provider = 'Ollama',
	provider_options = {
		model = 'qwen2.5-coder:1.5b-base-q6_K',
		prompt = function(lines_before, lines_after)
			return "<|fim_prefix|>" .. lines_before .. "<|fim_suffix|>" .. lines_after .. "<|fim_middle|>"
		end,
	},
	notify = true,
	notify_callback = function(msg)
		vim.notify(msg)
	end,
	run_on_every_keystroke = false,
})



-- cmp_ai:setup({
--   max_lines = 100,
--   provider = 'Ollama',
--   provider_options = {
--     model = 'codellama:7b-code',
--     auto_unload = false, -- Set to true to automatically unload the model when
--                         -- exiting nvim.
--   },
--   notify = true,
--   notify_callback = function(msg)
--     vim.notify(msg)
--   end,
--   run_on_every_keystroke = true,
--   ignored_file_types = {
--     -- default is not to ignore
--     -- uncomment to ignore in lua:
--     -- lua = true
--   },
-- })

-- cmp_ai:setup {
--     max_lines = 30,
--     provider = "Ollama", -- my local LlamaCpp forvading server (will auto start different models)
--     provider_options = {
--       -- prompt="<｜fim▁begin｜>"..lines_before.."<｜fim▁hole｜>"..lines_after.."<｜fim▁end｜>"
--       options = {
-- 	-- TEMP COMMENT
-- 	-- temperature = 0.1,
-- 	-- n_predict = 1,  -- number of generated predictions
-- 	-- ['min-p'] = 0.1, -- default 0.05,  Cut off predictions with probability below  Max_prob * min_p
-- 	-- TEMP COMMENT -- END
-- 	-- repeat_last_n = 64, -- default 64
-- 	-- repeat_penalty = 1.100, -- default 1.1
--
--
-- 	-- new args for my forwarding my python server  branch.. ---------------
-- 	-- model = "CodeQwen1.5-7B-Q4_K_S.gguf", -- still best?
-- 	-- model = "Qwen2.5-Coder-7B-Instruct-Q5_K_S", -- last's best with FIM and instruct at same time
-- 	-- cache_prompt= true, -- is necessary for llama.cpp to use the draft model -not..
-- 	-- md = "Qwen2.5.1-Coder-1.5B-Instruct-Q6_K.gguf", -- draft model: at 1.5 size and bigger - questionabel speedup
-- 	-- md = "Qwen2.5-Coder-0.5B-Instruct-Q6_K.gguf", -- draft model: at 0.5 size and bigger - nicer speedup
-- 	-- ngl = 50,
-- 	-- draft_min_p = 0.1,
--       },
--       model = "dagbs/qwen2.5-coder-1.5b-instruct-abliterated", -- is at as good as 2.5?
--       prompt = function(lines_before, lines_after)
-- 	return '<|fim_prefix|>' .. lines_before .. '<|fim_suffix|>' .. lines_after .. '<|fim_middle|>' -- CodeQwen1
--
-- 	-- codegeex4-all-9b-Q4_K_M - not so good
-- 	-- local upper_first_ft = vim.bo.filetype:gsub('^%l', string.upper)
-- 	-- local file_name = vim.fn.expand "%:t"
-- 	-- return '<|user|>\n###PATH:'..file_name..'\n###LANGUAGE:'.. upper_first_ft ..'\n###MODE:LINE\n<|code_suffix|>' .. lines_after .. '<|code_prefix|>' .. lines_before .. '<|code_middle|><|assistant|>\n' -- codegeex4-all-9b-Q4_K_M
--
-- 	-- return "<s><｜fim▁begin｜>" .. lines_before .. "<｜fim▁hole｜>" .. lines_after .. "<｜fim▁end｜>" -- for deepseek coder
-- 	-- return "<fim_prefix>" .. lines_before .. "<fim_suffix>" .. lines_after .. "<fim_middle>" -- for Refact 1.5 coder -- stopped workign after llama update..
--       end,
--     },
--     debounce_delay = 600, -- ms
--     notify = true,
--     notify_callback = function(msg)
--       print(msg)
--       -- vim.notify(msg)
--     end,
--     run_on_every_keystroke = false,
--     ignored_file_types = {
--       -- default is not to ignore
--       -- uncomment to ignore in lua:
--       -- lua = true
--       -- markdown = true,
--     },
-- }
