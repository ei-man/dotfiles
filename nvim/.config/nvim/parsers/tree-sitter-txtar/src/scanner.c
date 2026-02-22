#include <stdbool.h>
#include <stdint.h>
#include <tree_sitter/parser.h>

enum TokenType {
  ARCHIVE_BODY_LINE,
};

static bool is_space(int32_t c) {
  return c == ' ' || c == '\t';
}

static bool is_line_end(int32_t c) {
  return c == '\n' || c == '\r' || c == 0;
}

// Header form: -- <filename> --
static bool scan_archive_header(TSLexer *lexer) {
  if (lexer->lookahead != '-') {
    return false;
  }
  lexer->advance(lexer, false);
  if (lexer->lookahead != '-') {
    return false;
  }
  lexer->advance(lexer, false);

  if (!is_space(lexer->lookahead)) {
    return false;
  }
  while (is_space(lexer->lookahead)) {
    lexer->advance(lexer, false);
  }

  if (is_line_end(lexer->lookahead)) {
    return false;
  }
  while (!is_space(lexer->lookahead) && !is_line_end(lexer->lookahead)) {
    lexer->advance(lexer, false);
  }

  if (!is_space(lexer->lookahead)) {
    return false;
  }
  while (is_space(lexer->lookahead)) {
    lexer->advance(lexer, false);
  }

  if (lexer->lookahead != '-') {
    return false;
  }
  lexer->advance(lexer, false);
  if (lexer->lookahead != '-') {
    return false;
  }
  lexer->advance(lexer, false);

  if (lexer->lookahead == '\r') {
    lexer->advance(lexer, false);
    if (lexer->lookahead == '\n') {
      lexer->advance(lexer, false);
    }
    return true;
  }

  return lexer->lookahead == '\n' || lexer->lookahead == 0;
}

void *tree_sitter_txtar_external_scanner_create(void) {
  return NULL;
}

void tree_sitter_txtar_external_scanner_destroy(void *payload) {
  (void)payload;
}

unsigned tree_sitter_txtar_external_scanner_serialize(void *payload, char *buffer) {
  (void)payload;
  (void)buffer;
  return 0;
}

void tree_sitter_txtar_external_scanner_deserialize(void *payload, const char *buffer, unsigned length) {
  (void)payload;
  (void)buffer;
  (void)length;
}

bool tree_sitter_txtar_external_scanner_scan(void *payload, TSLexer *lexer, const bool *valid_symbols) {
  (void)payload;

  if (!valid_symbols[ARCHIVE_BODY_LINE] || lexer->lookahead == 0) {
    return false;
  }

  if (scan_archive_header(lexer)) {
    return false;
  }

  while (lexer->lookahead != 0 && lexer->lookahead != '\n' && lexer->lookahead != '\r') {
    lexer->advance(lexer, false);
  }

  if (lexer->lookahead == '\r') {
    lexer->advance(lexer, false);
    if (lexer->lookahead == '\n') {
      lexer->advance(lexer, false);
    }
  } else if (lexer->lookahead == '\n') {
    lexer->advance(lexer, false);
  }

  lexer->mark_end(lexer);
  lexer->result_symbol = ARCHIVE_BODY_LINE;
  return true;
}
