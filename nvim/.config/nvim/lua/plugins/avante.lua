return {
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false,
    build = 'make',
    opts = {
      provider = 'gemini',
      providers = {
        gemini = {
          endpoint = 'https://api.generativelanguage.googleapis.com/v1beta/openai/',
          model = 'gemini-3-pro',
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 8192,
          },
        },
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'MeanderingProgrammer/render-markdown.nvim',
    },
  },
}
